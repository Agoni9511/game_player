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
 @Select("select e.*,o.order_no,p.player_no,p.nickname from pw_player_earning e join pw_order o on o.id=e.order_id join pw_player p on p.id=e.player_id order by e.id desc") List<Map<String,Object>> earningReport();
 @Select("select w.*,p.player_no,p.nickname,u.username reviewer_name from pw_withdrawal_request w join pw_player p on p.id=w.player_id left join sys_user u on u.id=w.reviewed_by order by w.id desc") List<Map<String,Object>> withdrawalReport();
 @Select("<script>select w.*,p.player_no,p.nickname from pw_withdrawal_request w join pw_player p on p.id=w.player_id where 1=1<if test='status != null and status != &quot;&quot;'> and w.withdrawal_status=#{status}</if> order by w.id desc</script>") IPage<Map<String,Object>> withdrawals(Page<Map<String,Object>> page,@Param("status")String status);
}
