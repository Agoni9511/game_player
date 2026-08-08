package com.peiwan.platform.persistence.mapper;import com.baomidou.mybatisplus.core.metadata.IPage;import com.baomidou.mybatisplus.extension.plugins.pagination.Page;import org.apache.ibatis.annotations.*;import java.util.*;
public interface CatalogQueryMapper{
 @Select("select c.*,g.game_name from pw_product_category c left join pw_game g on g.id=c.game_id order by c.sort_no,c.id") List<Map<String,Object>> categoryRows();
 @Select("<script>select s.*,g.game_name from pw_service_item s join pw_game g on g.id=s.game_id where s.service_name like concat('%',#{name},'%') <if test='gameId != null'>and s.game_id=#{gameId}</if><if test='type != null and type != &quot;&quot;'>and s.service_type=#{type}</if><if test='enabled != null'>and s.enabled=#{enabled}</if> order by s.sort_no,s.id desc</script>") IPage<Map<String,Object>> services(Page<Map<String,Object>> page,@Param("name")String name,@Param("gameId")Long gameId,@Param("type")String type,@Param("enabled")Boolean enabled);
 @Select("select count(*) from pw_product where category_id=#{id} and status='ON_SALE'") long onSaleCategoryProducts(long id);
 @Select("select count(*) from pw_product where category_id=#{id}") long categoryProducts(long id);
 @Select("select count(*) from pw_product_service ps join pw_product p on p.id=ps.product_id where ps.service_id=#{id} and p.status='ON_SALE'") long onSaleServiceProducts(long id);
 @Select("select count(*) from pw_product_service where service_id=#{id}") long serviceProducts(long id);
}
