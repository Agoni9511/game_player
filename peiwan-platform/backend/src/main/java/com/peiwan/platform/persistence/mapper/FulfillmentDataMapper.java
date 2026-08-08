package com.peiwan.platform.persistence.mapper;import com.baomidou.mybatisplus.core.metadata.IPage;import com.baomidou.mybatisplus.extension.plugins.pagination.Page;import org.apache.ibatis.annotations.*;import java.util.*;
public interface FulfillmentDataMapper{
 @Select("<script>select f.*,o.order_no,o.order_status,p.nickname player_name,p.player_no,i.product_name from pw_fulfillment f join pw_order o on o.id=f.order_id join pw_player p on p.id=f.player_id left join pw_order_item i on i.id=(select min(x.id) from pw_order_item x where x.order_id=o.id) where 1=1 <if test='status != null and status != &quot;&quot;'>and f.fulfillment_status=#{status}</if> order by f.id desc</script>") IPage<Map<String,Object>> fulfillments(Page<Map<String,Object>> page,@Param("status")String status);
 @Select("select f.*,o.order_no,o.order_status,p.nickname player_name,p.player_no from pw_fulfillment f join pw_order o on o.id=f.order_id join pw_player p on p.id=f.player_id where f.id=#{id}") Map<String,Object> detail(long id);
 @Select("select customer_confirm_hours from pw_order_rule order by id limit 1") Integer confirmHours();
 @Select("select proof_url from pw_fulfillment_proof where fulfillment_id=#{id} order by sort_no") List<String> proofUrls(long id);
 @Select("select * from pw_fulfillment_audit where fulfillment_id=#{id} order by id") List<Map<String,Object>> audits(long id);
}
