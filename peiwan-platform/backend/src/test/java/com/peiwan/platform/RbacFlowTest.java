package com.peiwan.platform;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(properties={"spring.datasource.url=jdbc:h2:mem:rbac;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1","ADMIN_INITIAL_PASSWORD=Test-Only-Password-9x!"})
@AutoConfigureMockMvc
class RbacFlowTest {
  @Autowired MockMvc mvc; @Autowired ObjectMapper json; @Autowired JdbcTemplate db;

  @Test void completeRbacIsolationAndAuditFlow() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long adminId=db.queryForObject("select id from sys_user where username='admin'",Long.class);

    mvc.perform(get("/api/role/options").header("Authorization",admin))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.data[0].roleId").isNumber())
      .andExpect(jsonPath("$.data[0].roleName").value("超级管理员"))
      .andExpect(jsonPath("$.data[0].roleCode").value("admin"));

    long systemId=db.queryForObject("select id from sys_menu where name='System'",Long.class);
    long userMenuId=db.queryForObject("select id from sys_menu where name='User'",Long.class);
    long roleMenuId=db.queryForObject("select id from sys_menu where name='Role'",Long.class);
    mvc.perform(put("/api/menu/{id}",userMenuId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"parentId\":"+systemId+",\"type\":\"MENU\",\"name\":\"User\",\"path\":\"user\",\"component\":\"/system/user\",\"title\":\"用户管理\",\"icon\":\"ri:user-line\",\"authMark\":\"\",\"sortNo\":1,\"hidden\":false,\"enabled\":true,\"keepAlive\":false}"))
      .andExpect(status().isOk());
    mvc.perform(put("/api/menu/{id}",roleMenuId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"parentId\":"+systemId+",\"type\":\"MENU\",\"name\":\"Role\",\"path\":\"role\",\"component\":\"/system/role\",\"title\":\"角色管理\",\"icon\":\"ri:shield-user-line\",\"authMark\":\"\",\"sortNo\":2,\"hidden\":false,\"enabled\":true,\"keepAlive\":false}"))
      .andExpect(status().isOk());
    assertThat(db.queryForObject("select count(*) from sys_menu where auth_mark=''",Long.class)).isZero();

    mvc.perform(post("/api/role").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"roleName\":\"只读用户管理员\",\"roleCode\":\"user_reader\",\"description\":\"仅查询用户\",\"enabled\":true}"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.code").value(200));
    long roleId=db.queryForObject("select id from sys_role where code='user_reader'",Long.class);
    long listPermissionId=db.queryForObject("select id from sys_menu where auth_mark='system:user:list'",Long.class);

    mvc.perform(put("/api/role/{id}/menus",roleId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"ids\":["+listPermissionId+"]}"))
      .andExpect(status().isOk());

    mvc.perform(post("/api/user").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"userName\":\"reader\",\"password\":\"Reader-Pass-123!\",\"nickName\":\"只读账号\",\"userPhone\":\"\",\"userEmail\":\"reader@example.com\",\"userGender\":\"未知\",\"enabled\":true,\"roleIds\":["+roleId+"]}"))
      .andExpect(status().isOk());

    String reader=login("reader","Reader-Pass-123!");
    mvc.perform(get("/api/user/info").header("Authorization",reader))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.roles[0]").value("user_reader"))
      .andExpect(jsonPath("$.data.buttons[0]").value("system:user:list"));
    mvc.perform(get("/api/v3/system/menus").header("Authorization",reader))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data[0].name").value("System"))
      .andExpect(jsonPath("$.data[0].children[0].name").value("User"))
      .andExpect(jsonPath("$.data[0].children[0].meta.authList[0].authMark").value("system:user:list"));
    mvc.perform(get("/api/user/list").header("Authorization",reader)).andExpect(status().isOk());
    mvc.perform(post("/api/user").header("Authorization",reader).contentType(MediaType.APPLICATION_JSON)
      .content("{\"userName\":\"blocked\",\"password\":\"Blocked-123!\",\"nickName\":\"越权\",\"enabled\":true,\"roleIds\":[]}"))
      .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value(403));
    mvc.perform(get("/api/role/list").header("Authorization",reader)).andExpect(status().isForbidden());
    mvc.perform(get("/api/login-log/list").header("Authorization",reader)).andExpect(status().isForbidden());
    mvc.perform(get("/api/operation-log/list").header("Authorization",reader)).andExpect(status().isForbidden());

    mvc.perform(get("/api/login-log/list").header("Authorization",admin).param("username","reader"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.records[0].username").value("reader"));
    mvc.perform(get("/api/operation-log/list").header("Authorization",admin).param("operation","system:role:create"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.records[0].operation").value("system:role:create"));

    mvc.perform(put("/api/user/{id}/status",adminId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"enabled\":false}"))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("不能禁用最后一个超级管理员"));
    mvc.perform(put("/api/user/{id}/roles",adminId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"ids\":[]}"))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("不能移除最后一个超级管理员的管理员角色"));

    assertThat(db.queryForObject("select count(*) from sys_login_log where success=true",Long.class)).isGreaterThanOrEqualTo(2);
    assertThat(db.queryForObject("select count(*) from sys_operation_log",Long.class)).isGreaterThanOrEqualTo(3);
  }

  @Test void anonymousAndBadLoginAreRejectedAndLogged() throws Exception {
    mvc.perform(get("/api/user/info")).andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code").value(401));
    mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON).content("{\"userName\":\"admin\",\"password\":\"wrong-password\"}"))
      .andExpect(status().isUnauthorized()).andExpect(jsonPath("$.msg").value("账号或密码错误"));
    assertThat(db.queryForObject("select count(*) from sys_login_log where success=false",Long.class)).isGreaterThanOrEqualTo(1);
  }

  @Test void playerDomainRulesAndPermissionIsolation() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    mvc.perform(post("/api/business/game").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"gameCode\":\"wzry\",\"gameName\":\"王者荣耀\",\"platformType\":\"MOBILE\",\"description\":\"手游\",\"sortNo\":1,\"enabled\":true}"))
      .andExpect(status().isOk());
    long gameId=db.queryForObject("select id from pw_game where game_code='wzry'",Long.class);
    mvc.perform(post("/api/business/game/{id}/position",gameId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"positionCode\":\"jungle\",\"positionName\":\"打野\",\"sortNo\":1,\"enabled\":true}"))
      .andExpect(status().isOk());
    mvc.perform(post("/api/business/game/{id}/position",gameId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"positionCode\":\"mid\",\"positionName\":\"中路\",\"sortNo\":2,\"enabled\":true}"))
      .andExpect(status().isOk());
    long jungleId=db.queryForObject("select id from pw_game_position where game_id=? and position_code='jungle'",Long.class,gameId);
    long midId=db.queryForObject("select id from pw_game_position where game_id=? and position_code='mid'",Long.class,gameId);
    mvc.perform(post("/api/business/player-tag").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"tagCode\":\"test-patient\",\"tagName\":\"测试耐心教学\",\"tagColor\":\"#409EFF\",\"tagGroup\":\"STYLE\",\"sortNo\":99,\"enabled\":true}"))
      .andExpect(status().isOk());
    long tagId=db.queryForObject("select id from pw_player_tag where tag_code='test-patient'",Long.class);
    mvc.perform(post("/api/business/player").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"nickname\":\"小陪\",\"gender\":\"FEMALE\",\"phone\":\"13800000000\",\"enabled\":true,\"sortNo\":1,\"tagIds\":["+tagId+"],\"games\":[{\"gameId\":"+gameId+",\"gameNickname\":\"小陪游戏号\",\"rankName\":\"王者\",\"primary\":true,\"enabled\":true,\"positionIds\":["+jungleId+","+midId+"],\"primaryPositionId\":"+jungleId+"}],\"media\":[]}"))
      .andExpect(status().isOk());
    long playerId=db.queryForObject("select id from pw_player where nickname='小陪'",Long.class);
    mvc.perform(put("/api/business/player/{id}/status",playerId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"workStatus\":\"AVAILABLE\"}"))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("只有审核通过且已启用的陪玩师可以接单"));
    mvc.perform(put("/api/business/player/{id}/audit",playerId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"result\":\"APPROVED\",\"reason\":\"资料完整\"}"))
      .andExpect(status().isOk());
    mvc.perform(put("/api/business/player/{id}/status",playerId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"workStatus\":\"AVAILABLE\",\"reason\":\"开始接单\"}"))
      .andExpect(status().isOk());
    mvc.perform(get("/api/business/player/{id}",playerId).header("Authorization",admin)).andExpect(status().isOk()).andExpect(jsonPath("$.data.primaryGame").value("王者荣耀")).andExpect(jsonPath("$.data.tagIds[0]").value(tagId)).andExpect(jsonPath("$.data.games[0].positionIds.length()").value(2)).andExpect(jsonPath("$.data.games[0].primaryPositionId").value(jungleId));
    mvc.perform(delete("/api/business/game/position/{id}",jungleId).header("Authorization",admin)).andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("该位置已被陪玩师使用，不能删除"));
    mvc.perform(delete("/api/business/game/{id}",gameId).header("Authorization",admin)).andExpect(status().isBadRequest());
    mvc.perform(get("/api/business/player/list")).andExpect(status().isUnauthorized());
    assertThat(db.queryForObject("select count(*) from pw_player_status_log where player_id=?",Long.class,playerId)).isGreaterThanOrEqualTo(2);
  }

  @Test void productCategoryAndServiceRules() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    mvc.perform(get("/api/business/product-category/tree").header("Authorization",admin))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data[0].children").isArray());
    long rootId=db.queryForObject("select id from pw_product_category where category_code='delta-category'",Long.class);
    mvc.perform(delete("/api/business/product-category/{id}",rootId).header("Authorization",admin))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("请先删除子分类"));
    mvc.perform(get("/api/business/service/list").header("Authorization",admin).param("gameId",db.queryForObject("select id from pw_game where game_code='valorant'",Long.class).toString()))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.total").value(3));
    mvc.perform(post("/api/business/service").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"gameId\":1,\"serviceCode\":\"bad-type-test\",\"serviceName\":\"错误类型\",\"serviceType\":\"INVALID\",\"sortNo\":0,\"enabled\":true}"))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("服务类型无效"));
    mvc.perform(get("/api/business/service/list")).andExpect(status().isUnauthorized());
  }

  @Test void productSpuSkuAndSaleRules() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    mvc.perform(get("/api/business/product/list").header("Authorization",admin).param("productType","SERVICE"))
        .andExpect(status().isOk()).andExpect(jsonPath("$.data.total").value(9))
      .andExpect(jsonPath("$.data.records[0].skuCount").isNumber());
    long seeded=db.queryForObject("select id from pw_product where product_code='delta-escort-experience'",Long.class);
    mvc.perform(delete("/api/business/product/{id}",seeded).header("Authorization",admin))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("上架商品不能删除，请先下架"));

    long gameId=db.queryForObject("select id from pw_game where game_code='delta-force'",Long.class);
    long categoryId=db.queryForObject("select id from pw_product_category where category_code='delta-special'",Long.class);
    long serviceId=db.queryForObject("select id from pw_service_item where service_code='delta-map-clear'",Long.class);
    String body="{\"gameId\":"+gameId+",\"categoryId\":"+categoryId+",\"productCode\":\"disabled-sku-product\",\"productName\":\"待上架商品\",\"sortNo\":9,\"serviceIds\":["+serviceId+"],\"skus\":[{\"skuCode\":\"disabled-sku\",\"skuName\":\"停用规格\",\"price\":88,\"unitType\":\"ORDER\",\"unitCount\":1,\"minQuantity\":1,\"stockMode\":\"UNLIMITED\",\"enabled\":false,\"sortNo\":1}]}";
    mvc.perform(post("/api/business/product").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content(body))
      .andExpect(status().isOk());
    long productId=db.queryForObject("select id from pw_product where product_code='disabled-sku-product'",Long.class);
    mvc.perform(put("/api/business/product/{id}/status",productId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"status\":\"ON_SALE\"}"))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("至少启用一个销售规格"));
    mvc.perform(get("/api/business/product/{id}",productId).header("Authorization",admin))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.skus[0].skuCode").value("disabled-sku"));
    mvc.perform(get("/api/business/product/list")).andExpect(status().isUnauthorized());
  }

  @Test void platformPackageCompositionRules() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    mvc.perform(get("/api/business/product/list").header("Authorization",admin).param("productType","PACKAGE"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.total").value(6));
    long packageId=db.queryForObject("select id from pw_product where product_code='delta-regular-package'",Long.class);
    mvc.perform(get("/api/business/product/{id}",packageId).header("Authorization",admin))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.productType").value("PACKAGE"))
      .andExpect(jsonPath("$.data.components.length()").value(2))
      .andExpect(jsonPath("$.data.skus[0].marketPrice").value(256));
    long gameId=db.queryForObject("select id from pw_game where game_code='valorant'",Long.class);
    long categoryId=db.queryForObject("select id from pw_product_category where category_code='valorant-training'",Long.class);
    long serviceId=db.queryForObject("select id from pw_service_item where service_code='valorant-teaching'",Long.class);
    String invalid="{\"gameId\":"+gameId+",\"categoryId\":"+categoryId+",\"productCode\":\"bad-package\",\"productName\":\"错误套餐\",\"productType\":\"PACKAGE\",\"components\":[{\"serviceId\":"+serviceId+",\"quantity\":1,\"unitType\":\"HOUR\"}],\"skus\":[{\"skuCode\":\"bad-package-sku\",\"skuName\":\"套餐规格\",\"price\":100,\"unitType\":\"ORDER\",\"unitCount\":1,\"minQuantity\":1,\"stockMode\":\"UNLIMITED\",\"enabled\":true,\"sortNo\":1}]}";
    mvc.perform(post("/api/business/product").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content(invalid))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("平台套餐至少包含两个基础服务"));
  }

  @Test void customerCatalogSupportsServiceLevelPriceAndSortFilters() throws Exception {
    String token=login("admin","Test-Only-Password-9x!");
    long gameId=db.queryForObject("select id from pw_game where game_code='valorant'",Long.class);
    long levelId=db.queryForObject("select id from pw_player_level where game_id=? and level_code='PRO'",Long.class,gameId);

    mvc.perform(get("/api/customer/catalog/player-levels").header("Authorization",token).param("gameId",String.valueOf(gameId)))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.length()").value(3));
    mvc.perform(get("/api/customer/catalog/products").header("Authorization",token).param("gameId",String.valueOf(gameId))
        .param("serviceType","TEACHING").param("playerLevelId",String.valueOf(levelId)))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.total").isNumber());

    var response=mvc.perform(get("/api/customer/catalog/products").header("Authorization",token).param("minPrice","50")
        .param("maxPrice","170").param("sort","PRICE_ASC").param("size","100"))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
    JsonNode records=json.readTree(response).at("/data/records");
    assertThat(records).isNotEmpty();
    double previous=0;
    for(JsonNode record:records){double price=record.path("minPrice").asDouble();assertThat(price).isBetween(50d,170d);assertThat(price).isGreaterThanOrEqualTo(previous);previous=price;}

    mvc.perform(get("/api/customer/catalog/products").header("Authorization",token).param("sort","POPULAR"))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("商品排序方式无效"));
  }

  @Test void orderSnapshotAndStatusMachine() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long customerId=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    long skuId=db.queryForObject("select id from pw_product_sku where sku_code='valorant-growth-package-standard'",Long.class);
    String body="{\"customerId\":"+customerId+",\"skuId\":"+skuId+",\"quantity\":1,\"contactName\":\"测试联系人\",\"contactPhone\":\"13800000000\",\"gameAccount\":\"test-account\",\"gameNickname\":\"测试昵称\",\"serverName\":\"国服\",\"rankName\":\"黄金\",\"extraRequirement\":\"教学后复盘\"}";
    var created=mvc.perform(post("/api/business/order").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content(body))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
    long orderId=json.readTree(created).at("/data/id").asLong();
    mvc.perform(get("/api/business/order/{id}",orderId).header("Authorization",admin))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.orderStatus").value("PENDING_PAYMENT"))
      .andExpect(jsonPath("$.data.items[0].productName").value("无畏契约进阶套餐"))
      .andExpect(jsonPath("$.data.items[0].unitPrice").value(168))
      .andExpect(jsonPath("$.data.gameProfile.gameAccount").value("test-account"));
    fundAndPay(admin,orderId,"snapshot-pay");
    long playerId=db.queryForObject("select id from pw_player where player_no='DEMO-PW-001'",Long.class);
    mvc.perform(put("/api/business/order/{id}/assign",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"playerId\":"+playerId+",\"reason\":\"自动派单\"}"))
      .andExpect(status().isOk());
    mvc.perform(put("/api/business/order/{id}/status",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"status\":\"IN_SERVICE\"}"))
      .andExpect(status().isOk());
    mvc.perform(put("/api/business/order/{id}/status",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"status\":\"CANCELLED\",\"reason\":\"非法取消\"}"))
      .andExpect(status().isBadRequest());
    mvc.perform(put("/api/business/order/{id}/status",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"status\":\"COMPLETED\"}"))
      .andExpect(status().isOk());
    assertThat(db.queryForObject("select count(*) from pw_order_status_log where order_id=?",Long.class,orderId)).isEqualTo(5);
    assertThat(db.queryForObject("select commission_rate from pw_player_earning where order_id=?",java.math.BigDecimal.class,orderId)).isEqualByComparingTo("0.2800");
    assertThat(db.queryForObject("select commission_amount from pw_player_earning where order_id=?",java.math.BigDecimal.class,orderId)).isEqualByComparingTo("47.04");
    assertThat(db.queryForObject("select player_amount from pw_player_earning where order_id=?",java.math.BigDecimal.class,orderId)).isEqualByComparingTo("120.96");
    mvc.perform(get("/api/business/order/list")).andExpect(status().isUnauthorized());
  }

  @Test void serviceOrderUsesPlayerLevelPriceAndSnapshotsLevel() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long customerId=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    long skuId=db.queryForObject("select id from pw_product_sku where sku_code='delta-escort-1game'",Long.class);
    long levelId=db.queryForObject("select l.id from pw_player_level l join pw_product p on p.game_id=l.game_id join pw_product_sku k on k.product_id=p.id where k.id=? and l.level_code='PRO'",Long.class,skuId);
    var expected=db.queryForObject("select sp.price*k.unit_count from pw_product_sku k join pw_product_service ps on ps.product_id=k.product_id join pw_service_level_price sp on sp.service_id=ps.service_id and sp.unit_type=k.unit_type where k.id=? and sp.player_level_id=?",java.math.BigDecimal.class,skuId,levelId);
    String body="{\"customerId\":"+customerId+",\"skuId\":"+skuId+",\"playerLevelId\":"+levelId+",\"quantity\":1,\"contactName\":\"等级价测试\",\"contactPhone\":\"13800000000\",\"gameAccount\":\"level-test\",\"gameNickname\":\"等级测试\"}";
    var created=mvc.perform(post("/api/business/order").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content(body))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
    long orderId=json.readTree(created).at("/data/id").asLong();
    assertThat(db.queryForObject("select unit_price from pw_order_item where order_id=?",java.math.BigDecimal.class,orderId)).isEqualByComparingTo(expected);
    assertThat(db.queryForObject("select player_level_code from pw_order where id=?",String.class,orderId)).isEqualTo("PRO");
    assertThat(db.queryForObject("select pricing_rule_id from pw_order_item where order_id=?",Long.class,orderId)).isNotNull();
    fundAndPay(admin,orderId,"level-auto-dispatch");
    assertThat(db.queryForObject("select dispatch_mode from pw_dispatch_task where order_id=?",String.class,orderId)).isEqualTo("GRAB");
  }

  @Test void dispatchCandidateAndSingleWinnerRules() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long customerId=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    long skuId=db.queryForObject("select id from pw_product_sku where sku_code='delta-escort-1game'",Long.class);
    var orderCreated=mvc.perform(post("/api/business/order").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"customerId\":"+customerId+",\"skuId\":"+skuId+",\"quantity\":1,\"gameAccount\":\"dispatch-test\"}"))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
    long orderId=json.readTree(orderCreated).at("/data/id").asLong();
    fundAndPay(admin,orderId,"dispatch-pay");
    mvc.perform(get("/api/business/dispatch/eligible/{orderId}",orderId).header("Authorization",admin))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data[0].playerId").isNumber());
    var created=mvc.perform(post("/api/business/dispatch").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"orderId\":"+orderId+",\"dispatchMode\":\"GRAB\"}"))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
    long taskId=json.readTree(created).at("/data/id").asLong();
    var candidates=db.queryForList("select player_id from pw_dispatch_candidate where task_id=? order by id",Long.class,taskId);
    assertThat(candidates).isNotEmpty();
    long winner=candidates.getFirst();
    mvc.perform(put("/api/business/dispatch/{id}/respond",taskId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"playerId\":"+winner+",\"action\":\"ACCEPT\",\"reason\":\"模拟抢单\"}"))
      .andExpect(status().isOk());
    mvc.perform(put("/api/business/dispatch/{id}/respond",taskId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"playerId\":"+winner+",\"action\":\"ACCEPT\"}"))
      .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("派单任务已结束"));
    assertThat(db.queryForObject("select accepted_player_id from pw_dispatch_task where id=?",Long.class,taskId)).isEqualTo(winner);
    assertThat(db.queryForObject("select order_status from pw_order where id=?",String.class,orderId)).isEqualTo("ASSIGNED");
    mvc.perform(put("/api/business/order/{id}/status",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"status\":\"IN_SERVICE\"}")) .andExpect(status().isOk());
    mvc.perform(put("/api/business/order/{id}/status",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"status\":\"COMPLETED\"}")) .andExpect(status().isOk());
    mvc.perform(get("/api/business/dispatch/list")).andExpect(status().isUnauthorized());
  }

  @Test void multiPlayerOrderFillsOnlyAfterAllMembersJoin() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long customerId=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    long skuId=db.queryForObject("select id from pw_product_sku where sku_code='delta-escort-1game'",Long.class);
    long orderId=json.readTree(mvc.perform(post("/api/business/order").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"customerId\":"+customerId+",\"skuId\":"+skuId+",\"quantity\":1,\"gameAccount\":\"multi-member-test\"}"))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString()).at("/data/id").asLong();
    fundAndPay(admin,orderId,"multi-member-pay");
    db.update("update pw_order set required_player_count=2 where id=?",orderId);
    long gameId=db.queryForObject("select game_id from pw_order_game_profile where order_id=?",Long.class,orderId);
    Long levelId=db.queryForObject("select requested_player_level_id from pw_order where id=?",Long.class,orderId);
    db.update("update pw_player set work_status='AVAILABLE',max_active_orders=5 where player_no in('DEMO-PW-001','DEMO-PW-002')");
    db.update("update pw_player_game set price_level_id=?,audit_status='APPROVED',enabled=true where game_id=? and player_id in(select id from pw_player where player_no in('DEMO-PW-001','DEMO-PW-002'))",levelId,gameId);
    long taskId=json.readTree(mvc.perform(post("/api/business/dispatch").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"orderId\":"+orderId+",\"dispatchMode\":\"GRAB\"}"))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString()).at("/data/id").asLong();
    var candidates=db.queryForList("select player_id from pw_dispatch_candidate where task_id=? order by id",Long.class,taskId);
    assertThat(candidates).hasSizeGreaterThanOrEqualTo(2);
    long first=candidates.get(0),second=candidates.get(1);

    mvc.perform(put("/api/business/dispatch/{id}/respond",taskId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"playerId\":"+first+",\"action\":\"ACCEPT\"}"))
      .andExpect(status().isOk());
    assertThat(db.queryForObject("select order_status from pw_order where id=?",String.class,orderId)).isEqualTo("WAIT_ASSIGN");
    assertThat(db.queryForObject("select count(*) from pw_order_member where order_id=?",Long.class,orderId)).isEqualTo(1);
    assertThat(db.queryForObject("select task_status from pw_dispatch_task where id=?",String.class,taskId)).isEqualTo("DISPATCHING");

    mvc.perform(put("/api/business/dispatch/{id}/respond",taskId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"playerId\":"+second+",\"action\":\"ACCEPT\"}"))
      .andExpect(status().isOk());
    assertThat(db.queryForObject("select order_status from pw_order where id=?",String.class,orderId)).isEqualTo("ASSIGNED");
    assertThat(db.queryForObject("select task_status from pw_dispatch_task where id=?",String.class,taskId)).isEqualTo("ACCEPTED");
    assertThat(db.queryForObject("select assigned_player_id from pw_order where id=?",Long.class,orderId)).isEqualTo(first);
    assertThat(db.queryForObject("select count(*) from pw_order_member where order_id=?",Long.class,orderId)).isEqualTo(2);
    mvc.perform(get("/api/business/order/{id}",orderId).header("Authorization",admin))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.requiredPlayerCount").value(2))
      .andExpect(jsonPath("$.data.memberCount").value(2)).andExpect(jsonPath("$.data.members.length()").value(2));
  }

  @Test void walletRechargeIsIdempotentAndProducesImmutableLedger() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long adminId=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    long planId=db.queryForObject("select id from pw_recharge_plan where plan_code='R500'",Long.class);
    String requestNo="wallet-test-500";

    java.math.BigDecimal cashBefore=db.queryForObject("select coalesce((select cash_balance from pw_wallet_account where owner_type='USER' and owner_id=?),0)",java.math.BigDecimal.class,adminId);
    java.math.BigDecimal bonusBefore=db.queryForObject("select coalesce((select bonus_balance from pw_wallet_account where owner_type='USER' and owner_id=?),0)",java.math.BigDecimal.class,adminId);
    java.math.BigDecimal rechargeBefore=db.queryForObject("select coalesce((select total_recharge_amount from pw_user_member where user_id=?),0)",java.math.BigDecimal.class,adminId);
    mvc.perform(post("/api/customer/wallet/recharge").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"planId\":"+planId+",\"requestNo\":\""+requestNo+"\"}"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.duplicated").value(false));
    mvc.perform(post("/api/customer/wallet/recharge").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"planId\":"+planId+",\"requestNo\":\""+requestNo+"\"}"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.duplicated").value(true));

    String rechargeNo=db.queryForObject("select recharge_no from pw_recharge_order where user_id=? and request_no=?",String.class,adminId,requestNo);
    assertThat(db.queryForObject("select count(*) from pw_recharge_order where user_id=? and request_no=?",Long.class,adminId,requestNo)).isEqualTo(1);
    assertThat(db.queryForObject("select count(*) from pw_wallet_transaction where business_type='RECHARGE' and business_no=?",Long.class,rechargeNo)).isEqualTo(2);
    assertThat(db.queryForObject("select cash_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,adminId)).isEqualByComparingTo(cashBefore.add(new java.math.BigDecimal("500.00")));
    assertThat(db.queryForObject("select bonus_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,adminId)).isEqualByComparingTo(bonusBefore.add(new java.math.BigDecimal("40.00")));
    assertThat(db.queryForObject("select count(*) from pw_user_member where user_id=?",Long.class,adminId)).isEqualTo(1);
    var rechargeAfter=rechargeBefore.add(new java.math.BigDecimal("500.00"));
    assertThat(db.queryForObject("select total_recharge_amount from pw_user_member where user_id=?",java.math.BigDecimal.class,adminId)).isEqualByComparingTo(rechargeAfter);
    assertThat(db.queryForObject("select l.id from pw_member_level l where l.enabled=true and l.min_recharge_amount<=? order by l.min_recharge_amount desc,l.level_no desc limit 1",Long.class,rechargeAfter))
      .isEqualTo(db.queryForObject("select level_id from pw_user_member where user_id=?",Long.class,adminId));
    assertThat(db.queryForObject("select count(*) from pw_member_level where discount_rate<>1",Long.class)).isZero();
  }

  @Test void orderWalletPaymentIsIdempotentAndCancellationRefundsOriginalBalances() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long uid=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    long skuId=db.queryForObject("select id from pw_product_sku where sku_code='delta-escort-1game'",Long.class);
    long orderId=json.readTree(mvc.perform(post("/api/business/order").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"customerId\":"+uid+",\"skuId\":"+skuId+",\"quantity\":1,\"gameAccount\":\"refund-test\"}"))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString()).at("/data/id").asLong();
    recharge(admin,"payment-refund-fund");
    java.math.BigDecimal cashBefore=db.queryForObject("select cash_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid);
    java.math.BigDecimal bonusBefore=db.queryForObject("select bonus_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid);
    java.math.BigDecimal payable=db.queryForObject("select payable_amount from pw_order where id=?",java.math.BigDecimal.class,orderId);
    String requestNo="pay-refund-"+orderId;
    mvc.perform(post("/api/customer/orders/{id}/pay",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"requestNo\":\""+requestNo+"\"}"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.duplicated").value(false))
      .andExpect(jsonPath("$.data.cashAmount").value(payable.doubleValue()))
      .andExpect(jsonPath("$.data.bonusAmount").value(0));
    mvc.perform(post("/api/customer/orders/{id}/pay",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"requestNo\":\""+requestNo+"\"}"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.duplicated").value(true));
    mvc.perform(put("/api/customer/orders/{id}/cancel",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"reason\":\"测试退款\"}"))
      .andExpect(status().isOk());
    assertThat(db.queryForObject("select payment_status from pw_order_payment where order_id=?",String.class,orderId)).isEqualTo("REFUNDED");
    assertThat(db.queryForObject("select cash_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid)).isEqualByComparingTo(cashBefore);
    assertThat(db.queryForObject("select bonus_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid)).isEqualByComparingTo(bonusBefore);
    String paymentNo=db.queryForObject("select payment_no from pw_order_payment where order_id=?",String.class,orderId);
    assertThat(db.queryForObject("select count(*) from pw_wallet_transaction where business_no=? and business_type in('ORDER_PAYMENT','ORDER_REFUND')",Long.class,paymentNo)).isGreaterThanOrEqualTo(2);
  }

  @Test void walletPaymentUsesCashBeforeBonusAndRefundsEachBalance() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long uid=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    long skuId=db.queryForObject("select id from pw_product_sku where sku_code='delta-escort-1game'",Long.class);
    long orderId=json.readTree(mvc.perform(post("/api/business/order").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"customerId\":"+uid+",\"skuId\":"+skuId+",\"quantity\":1,\"gameAccount\":\"mixed-balance-test\"}"))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString()).at("/data/id").asLong();
    recharge(admin,"mixed-balance-fund-"+orderId);
    java.math.BigDecimal originalCash=db.queryForObject("select cash_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid);
    java.math.BigDecimal originalBonus=db.queryForObject("select bonus_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid);
    java.math.BigDecimal payable=db.queryForObject("select payable_amount from pw_order where id=?",java.math.BigDecimal.class,orderId);
    java.math.BigDecimal cash=new java.math.BigDecimal("10.00"),bonus=payable;
    try {
      db.update("update pw_wallet_account set cash_balance=?,bonus_balance=? where owner_type='USER' and owner_id=?",cash,bonus,uid);
      String requestNo="mixed-balance-pay-"+orderId;
      mvc.perform(post("/api/customer/orders/{id}/pay",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"requestNo\":\""+requestNo+"\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.data.cashAmount").value(cash.doubleValue()))
        .andExpect(jsonPath("$.data.bonusAmount").value(payable.subtract(cash).doubleValue()));
      assertThat(db.queryForObject("select cash_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid)).isEqualByComparingTo("0");
      assertThat(db.queryForObject("select bonus_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid)).isEqualByComparingTo(cash);
      mvc.perform(put("/api/customer/orders/{id}/cancel",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"reason\":\"混合余额退款测试\"}"))
        .andExpect(status().isOk());
      assertThat(db.queryForObject("select cash_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid)).isEqualByComparingTo(cash);
      assertThat(db.queryForObject("select bonus_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid)).isEqualByComparingTo(bonus);
    } finally {
      db.update("update pw_wallet_account set cash_balance=?,bonus_balance=? where owner_type='USER' and owner_id=?",originalCash,originalBonus,uid);
    }
  }

  @Test void concurrentPaymentRequestsCreateOnlyOnePayment() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long uid=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    long skuId=db.queryForObject("select id from pw_product_sku where sku_code='delta-escort-1game'",Long.class);
    long orderId=json.readTree(mvc.perform(post("/api/business/order").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"customerId\":"+uid+",\"skuId\":"+skuId+",\"quantity\":1,\"gameAccount\":\"concurrent-payment-test\"}"))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString()).at("/data/id").asLong();
    recharge(admin,"concurrent-payment-fund-"+orderId);

    var ready=new java.util.concurrent.CountDownLatch(2);
    var start=new java.util.concurrent.CountDownLatch(1);
    var pool=java.util.concurrent.Executors.newFixedThreadPool(2);
    try {
      var first=pool.submit(()->{ready.countDown();start.await();return mvc.perform(post("/api/customer/orders/{id}/pay",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"requestNo\":\"concurrent-a-"+orderId+"\"}")).andReturn();});
      var second=pool.submit(()->{ready.countDown();start.await();return mvc.perform(post("/api/customer/orders/{id}/pay",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"requestNo\":\"concurrent-b-"+orderId+"\"}")).andReturn();});
      assertThat(ready.await(5,java.util.concurrent.TimeUnit.SECONDS)).isTrue();
      start.countDown();
      assertThat(first.get(15,java.util.concurrent.TimeUnit.SECONDS).getResponse().getStatus()).isEqualTo(200);
      assertThat(second.get(15,java.util.concurrent.TimeUnit.SECONDS).getResponse().getStatus()).isEqualTo(200);
    } finally {
      pool.shutdownNow();
    }
    assertThat(db.queryForObject("select count(*) from pw_order_payment where order_id=?",Long.class,orderId)).isEqualTo(1);
    assertThat(db.queryForObject("select order_status from pw_order where id=?",String.class,orderId)).isEqualTo("WAIT_ASSIGN");
    mvc.perform(put("/api/customer/orders/{id}/cancel",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"reason\":\"并发支付测试清理\"}"))
      .andExpect(status().isOk());
  }

  @Test void mockWechatPaymentDoesNotRequireOrDebitWallet() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long uid=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    long skuId=db.queryForObject("select id from pw_product_sku where sku_code='delta-escort-1game'",Long.class);
    long orderId=json.readTree(mvc.perform(post("/api/business/order").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
      .content("{\"customerId\":"+uid+",\"skuId\":"+skuId+",\"quantity\":1,\"gameAccount\":\"mock-wechat-test\"}"))
      .andExpect(status().isOk()).andReturn().getResponse().getContentAsString()).at("/data/id").asLong();
    java.math.BigDecimal cashBefore=db.queryForObject("select cash_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid);
    java.math.BigDecimal bonusBefore=db.queryForObject("select bonus_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid);
    String requestNo="mock-wechat-"+orderId;
    mvc.perform(post("/api/customer/orders/{id}/pay/mock-wechat",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"requestNo\":\""+requestNo+"\"}"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.duplicated").value(false)).andExpect(jsonPath("$.data.paymentChannel").value("MOCK_WECHAT"));
    mvc.perform(post("/api/customer/orders/{id}/pay/mock-wechat",orderId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"requestNo\":\""+requestNo+"\"}"))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data.duplicated").value(true));
    assertThat(db.queryForObject("select order_status from pw_order where id=?",String.class,orderId)).isEqualTo("WAIT_ASSIGN");
    assertThat(db.queryForObject("select payment_channel from pw_order_payment where order_id=?",String.class,orderId)).isEqualTo("MOCK_WECHAT");
    assertThat(db.queryForObject("select cash_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid)).isEqualByComparingTo(cashBefore);
    assertThat(db.queryForObject("select bonus_balance from pw_wallet_account where owner_type='USER' and owner_id=?",java.math.BigDecimal.class,uid)).isEqualByComparingTo(bonusBefore);
  }

  @Test void mondayWithdrawalRequiresMinimumAndAdminAuditCanExportReports() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    long adminId=db.queryForObject("select id from sys_user where username='admin'",Long.class);
    db.update("update pw_player set user_id=?,audit_status='APPROVED',enabled=true where player_no='DEMO-PW-001' and not exists(select 1 from pw_player where user_id=?)",adminId,adminId);
    long playerId=db.queryForObject("select id from pw_player where user_id=?",Long.class,adminId);
    db.update("insert into pw_player_account(player_id,available_balance,frozen_balance,total_income,total_withdrawn,version) select ?,400,0,400,0,0 where not exists(select 1 from pw_player_account where player_id=?)",playerId,playerId);
    db.update("update pw_player_account set available_balance=400,frozen_balance=0 where player_id=?",playerId);
    int today=java.time.LocalDate.now().getDayOfWeek().getValue();
    db.update("update pw_commission_rule set withdraw_weekday=? where rule_code='DEFAULT'",today);
    try {
      mvc.perform(post("/api/player/withdrawals").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
        .content("{\"amount\":299,\"payoutMethod\":\"BANK\",\"accountName\":\"测试陪玩师\",\"accountNo\":\"6222000000000000\"}"))
        .andExpect(status().isBadRequest()).andExpect(jsonPath("$.msg").value("单次提现金额不能低于300元"));
      var result=mvc.perform(post("/api/player/withdrawals").header("Authorization",admin).contentType(MediaType.APPLICATION_JSON)
        .content("{\"amount\":300,\"payoutMethod\":\"BANK\",\"accountName\":\"测试陪玩师\",\"accountNo\":\"6222000000000000\"}"))
        .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
      long withdrawalId=json.readTree(result).at("/data/id").asLong();
      assertThat(db.queryForObject("select available_balance from pw_player_account where player_id=?",java.math.BigDecimal.class,playerId)).isEqualByComparingTo("100");
      assertThat(db.queryForObject("select frozen_balance from pw_player_account where player_id=?",java.math.BigDecimal.class,playerId)).isEqualByComparingTo("300");
      mvc.perform(put("/api/business/settlement/withdrawals/{id}/audit",withdrawalId).header("Authorization",admin).contentType(MediaType.APPLICATION_JSON).content("{\"action\":\"APPROVE\",\"remark\":\"已打款\"}"))
        .andExpect(status().isOk());
      assertThat(db.queryForObject("select withdrawal_status from pw_withdrawal_request where id=?",String.class,withdrawalId)).isEqualTo("PAID");
      assertThat(db.queryForObject("select total_withdrawn from pw_player_account where player_id=?",java.math.BigDecimal.class,playerId)).isEqualByComparingTo("300");
      mvc.perform(get("/api/business/settlement/export").header("Authorization",admin).param("type","withdrawal"))
        .andExpect(status().isOk()).andExpect(header().string("Content-Type",org.hamcrest.Matchers.startsWith("text/csv")));
    } finally {db.update("update pw_commission_rule set withdraw_weekday=1 where rule_code='DEFAULT'");}
  }

  @Test void customerOrderSummaryAndGroupedListsAreAvailable() throws Exception {
    String admin=login("admin","Test-Only-Password-9x!");
    mvc.perform(get("/api/customer/orders/summary").header("Authorization",admin))
      .andExpect(status().isOk()).andExpect(jsonPath("$.data").isMap());
    for(String filter:new String[]{"PENDING_PAYMENT","WAIT_ASSIGN","ACTIVE_SERVICE","PENDING_CONFIRMATION","AFTER_SALE"}){
      var body=mvc.perform(get("/api/customer/orders").header("Authorization",admin).param("status",filter).param("size","100"))
        .andExpect(status().isOk()).andExpect(jsonPath("$.data.records").isArray()).andReturn().getResponse().getContentAsString();
      for(var order:json.readTree(body).at("/data/records")){
        String actual=order.path("orderStatus").asText();
        if("ACTIVE_SERVICE".equals(filter))assertThat(actual).isIn("ASSIGNED","IN_SERVICE");
        else if("PENDING_CONFIRMATION".equals(filter))assertThat(actual).isIn("PENDING_CONFIRM","WAIT_CUSTOMER_CONFIRM");
        else assertThat(actual).isEqualTo(filter);
      }
    }
  }

  @Test void regularServiceProductSeedsHaveGameScopedLevelPrices() {
    assertThat(db.queryForObject("select count(*) from pw_product where product_code in('delta-beacon-escort','delta-map-clear-order','valorant-ranked-companion') and product_type='SERVICE' and pricing_mode='PLAYER_LEVEL' and status='ON_SALE'",Long.class)).isEqualTo(3);
    assertThat(db.queryForObject("select count(*) from pw_product_sku where sku_code in('delta-beacon-escort-1g','delta-beacon-escort-3g','delta-beacon-escort-5g','delta-map-clear-1g','delta-map-clear-3g','valorant-ranked-companion-1h','valorant-ranked-companion-2h','valorant-ranked-companion-3h')",Long.class)).isEqualTo(8);
    assertThat(db.queryForObject("select count(*) from pw_sku_level_price x join pw_product_sku k on k.id=x.sku_id join pw_player_level l on l.id=x.player_level_id join pw_product p on p.id=k.product_id where k.sku_code in('delta-beacon-escort-1g','delta-beacon-escort-3g','delta-beacon-escort-5g','delta-map-clear-1g','delta-map-clear-3g','valorant-ranked-companion-1h','valorant-ranked-companion-2h','valorant-ranked-companion-3h') and l.game_id=p.game_id",Long.class)).isEqualTo(24);
  }

  private void fundAndPay(String token,long orderId,String prefix) throws Exception {recharge(token,prefix+"-fund-"+orderId);mvc.perform(post("/api/customer/orders/{id}/pay",orderId).header("Authorization",token).contentType(MediaType.APPLICATION_JSON).content("{\"requestNo\":\""+prefix+"-"+orderId+"\"}")) .andExpect(status().isOk());}
  private void recharge(String token,String requestNo) throws Exception {long planId=db.queryForObject("select id from pw_recharge_plan where plan_code='R1000'",Long.class);mvc.perform(post("/api/customer/wallet/recharge").header("Authorization",token).contentType(MediaType.APPLICATION_JSON).content("{\"planId\":"+planId+",\"requestNo\":\""+requestNo+"\"}")) .andExpect(status().isOk());}

  private String login(String username,String password) throws Exception {
    var response=mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
      .content(json.writeValueAsString(java.util.Map.of("userName",username,"password",password))))
      .andExpect(status().isOk()).andExpect(jsonPath("$.code").value(200)).andReturn().getResponse().getContentAsString();
    JsonNode node=json.readTree(response);String token=node.at("/data/token").asText();assertThat(token).isNotBlank();return token;
  }
}
