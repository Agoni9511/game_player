package com.peiwan.platform.persistence.mapper;
import com.baomidou.mybatisplus.core.metadata.IPage;import com.baomidou.mybatisplus.extension.plugins.pagination.Page;import org.apache.ibatis.annotations.*;import java.math.BigDecimal;import java.util.*;
public interface SettlementDataMapper{
 @Select("select * from pw_player_account where player_id=#{id} for update") Map<String,Object> lockAccount(long id);
 @Update("update pw_player_account set available_balance=available_balance+#{amount},total_income=total_income+#{amount},version=version+1,updated_at=current_timestamp where id=#{id}") int creditIncome(long id,BigDecimal amount);
 @Update("update pw_player_account set available_balance=available_balance-#{amount},frozen_balance=frozen_balance+#{amount},version=version+1,updated_at=current_timestamp where id=#{id} and available_balance>=#{amount}") int freeze(long id,BigDecimal amount);
 @Update("update pw_player_account set available_balance=available_balance+#{amount},frozen_balance=frozen_balance-#{amount},version=version+1,updated_at=current_timestamp where id=#{id} and frozen_balance>=#{amount}") int reject(long id,BigDecimal amount);
 @Update("update pw_player_account set frozen_balance=frozen_balance-#{amount},total_withdrawn=total_withdrawn+#{amount},version=version+1,updated_at=current_timestamp where id=#{id} and frozen_balance>=#{amount}") int approve(long id,BigDecimal amount);
 @Select("select p.id from pw_player p where p.user_id=#{uid} and p.enabled=true and p.audit_status='APPROVED'") Long playerId(long uid);
 @Select("select r.* from pw_commission_rule r where r.enabled=true order by r.id limit 1") Map<String,Object> rule();
 @Select("select id,player_id from pw_order_member where order_id=#{orderId} and member_status='COMPLETED' order by id") List<Map<String,Object>> completedMembers(long orderId);
 @Select("select e.*,t.order_no,t.title,s.service_status order_status,s.required_player_count,"+
  "i.product_name,i.sku_name,i.quantity,i.unit_price,g.game_name,g.server_name,g.rank_name,"+
  "os.platform_amount,os.distributable_amount,d.calculation_base,d.rate distribution_rate,d.remark settlement_remark,"+
  "(select count(*) from pw_order_member m where m.order_id=e.order_id and m.member_status='COMPLETED') completed_member_count "+
  "from pw_player_earning e join pw_trade_order t on t.id=e.order_id "+
  "left join pw_service_order s on s.order_id=t.id "+
  "left join pw_order_item i on i.id=(select min(x.id) from pw_order_item x where x.order_id=t.id) "+
  "left join pw_order_game_profile g on g.order_id=t.id "+
  "left join pw_order_settlement os on os.order_id=t.id "+
  "left join pw_order_settlement_detail d on d.id=e.settlement_detail_id "+
  "where e.player_id=#{playerId} order by e.id desc")
 IPage<Map<String,Object>> playerEarnings(Page<Map<String,Object>> page,@Param("playerId")long playerId);
 @Select("select e.*,o.order_no,p.player_no,p.nickname from pw_player_earning e join pw_trade_order o on o.id=e.order_id join pw_player p on p.id=e.player_id order by e.id desc") List<Map<String,Object>> earningReport();
 @Select("select w.*,p.player_no,p.nickname,u.username reviewer_name from pw_withdrawal_request w join pw_player p on p.id=w.player_id left join sys_user u on u.id=w.reviewed_by order by w.id desc") List<Map<String,Object>> withdrawalReport();
 @Select("<script>select w.*,p.player_no,p.nickname from pw_withdrawal_request w join pw_player p on p.id=w.player_id where 1=1<if test='status != null and status != &quot;&quot;'> and w.withdrawal_status=#{status}</if> order by w.id desc</script>") IPage<Map<String,Object>> withdrawals(Page<Map<String,Object>> page,@Param("status")String status);
}
