package com.peiwan.platform.persistence.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.Map;

public interface FinanceDataMapper {
 @Select("<script>select " +
  "(select coalesce(sum(cash_amount+bonus_amount),0) from pw_trade_payment where payment_status in('PAID','REFUNDED')<if test='startAt != null'> and paid_at&gt;=#{startAt}</if><if test='endAt != null'> and paid_at&lt;#{endAt}</if>) gross_paid_amount," +
  "(select coalesce(sum(refunded_cash_amount+refunded_bonus_amount),0) from pw_trade_payment where refunded_at is not null<if test='startAt != null'> and refunded_at&gt;=#{startAt}</if><if test='endAt != null'> and refunded_at&lt;#{endAt}</if>) refund_amount," +
  "(select coalesce(sum(amount),0) from pw_order_settlement_detail where detail_type='PLAYER_INCOME'<if test='startAt != null'> and created_at&gt;=#{startAt}</if><if test='endAt != null'> and created_at&lt;#{endAt}</if>) player_income_amount," +
  "(select coalesce(sum(amount),0) from pw_platform_ledger where direction='IN'<if test='startAt != null'> and created_at&gt;=#{startAt}</if><if test='endAt != null'> and created_at&lt;#{endAt}</if>) platform_income_amount," +
  "(select coalesce(sum(amount),0) from pw_withdrawal_request where withdrawal_status='PAID'<if test='startAt != null'> and reviewed_at&gt;=#{startAt}</if><if test='endAt != null'> and reviewed_at&lt;#{endAt}</if>) withdrawn_amount," +
  "(select count(*) from pw_trade_payment where payment_status in('PAID','REFUNDED')<if test='startAt != null'> and paid_at&gt;=#{startAt}</if><if test='endAt != null'> and paid_at&lt;#{endAt}</if>) payment_count," +
  "(select count(*) from pw_order_settlement where settlement_status='SETTLED'<if test='startAt != null'> and settled_at&gt;=#{startAt}</if><if test='endAt != null'> and settled_at&lt;#{endAt}</if>) settlement_count" +
  "</script>")
 Map<String,Object> summary(@Param("startAt") LocalDateTime startAt,@Param("endAt") LocalDateTime endAt);

 @Select("<script>select p.*,t.order_no,t.business_type,u.username,u.nickname from pw_trade_payment p join pw_trade_order t on t.id=p.order_id join sys_user u on u.id=p.user_id where 1=1" +
  "<if test='keyword != null and keyword != &quot;&quot;'> and (p.payment_no like concat('%',#{keyword},'%') or p.request_no like concat('%',#{keyword},'%') or t.order_no like concat('%',#{keyword},'%') or u.username like concat('%',#{keyword},'%') or u.nickname like concat('%',#{keyword},'%'))</if>" +
  "<if test='businessType != null and businessType != &quot;&quot;'> and t.business_type=#{businessType}</if>" +
  "<if test='status != null and status != &quot;&quot;'> and p.payment_status=#{status}</if>" +
  "<if test='channel != null and channel != &quot;&quot;'> and p.payment_channel=#{channel}</if>" +
  "<if test='startAt != null'> and coalesce(p.paid_at,p.created_at)&gt;=#{startAt}</if><if test='endAt != null'> and coalesce(p.paid_at,p.created_at)&lt;#{endAt}</if> order by p.id desc</script>")
 IPage<Map<String,Object>> payments(Page<Map<String,Object>> page,@Param("keyword")String keyword,@Param("businessType")String businessType,@Param("status")String status,@Param("channel")String channel,@Param("startAt")LocalDateTime startAt,@Param("endAt")LocalDateTime endAt);

 @Select("<script>select l.*,t.order_no,t.business_type from pw_platform_ledger l left join pw_trade_order t on t.id=l.order_id where 1=1" +
  "<if test='keyword != null and keyword != &quot;&quot;'> and (l.ledger_no like concat('%',#{keyword},'%') or t.order_no like concat('%',#{keyword},'%') or coalesce(l.remark,'') like concat('%',#{keyword},'%'))</if>" +
  "<if test='businessType != null and businessType != &quot;&quot;'> and l.business_type=#{businessType}</if><if test='direction != null and direction != &quot;&quot;'> and l.direction=#{direction}</if>" +
  "<if test='startAt != null'> and l.created_at&gt;=#{startAt}</if><if test='endAt != null'> and l.created_at&lt;#{endAt}</if> order by l.id desc</script>")
 IPage<Map<String,Object>> platformLedger(Page<Map<String,Object>> page,@Param("keyword")String keyword,@Param("businessType")String businessType,@Param("direction")String direction,@Param("startAt")LocalDateTime startAt,@Param("endAt")LocalDateTime endAt);

 @Select("<script>select x.*,u.username,u.nickname from pw_wallet_transaction x left join sys_user u on x.owner_type='USER' and u.id=x.owner_id where 1=1" +
  "<if test='keyword != null and keyword != &quot;&quot;'> and (x.transaction_no like concat('%',#{keyword},'%') or x.business_no like concat('%',#{keyword},'%') or coalesce(u.username,'') like concat('%',#{keyword},'%') or coalesce(u.nickname,'') like concat('%',#{keyword},'%'))</if>" +
  "<if test='businessType != null and businessType != &quot;&quot;'> and x.business_type=#{businessType}</if><if test='direction != null and direction != &quot;&quot;'> and x.direction=#{direction}</if><if test='balanceType != null and balanceType != &quot;&quot;'> and x.balance_type=#{balanceType}</if>" +
  "<if test='startAt != null'> and x.created_at&gt;=#{startAt}</if><if test='endAt != null'> and x.created_at&lt;#{endAt}</if> order by x.id desc</script>")
 IPage<Map<String,Object>> walletTransactions(Page<Map<String,Object>> page,@Param("keyword")String keyword,@Param("businessType")String businessType,@Param("direction")String direction,@Param("balanceType")String balanceType,@Param("startAt")LocalDateTime startAt,@Param("endAt")LocalDateTime endAt);

 @Select("<script>select x.*,p.player_no,p.nickname from pw_player_account_transaction x join pw_player p on p.id=x.player_id where 1=1" +
  "<if test='keyword != null and keyword != &quot;&quot;'> and (x.transaction_no like concat('%',#{keyword},'%') or x.business_no like concat('%',#{keyword},'%') or p.player_no like concat('%',#{keyword},'%') or p.nickname like concat('%',#{keyword},'%'))</if>" +
  "<if test='businessType != null and businessType != &quot;&quot;'> and x.business_type=#{businessType}</if><if test='direction != null and direction != &quot;&quot;'> and x.direction=#{direction}</if><if test='balanceType != null and balanceType != &quot;&quot;'> and x.balance_type=#{balanceType}</if>" +
  "<if test='startAt != null'> and x.created_at&gt;=#{startAt}</if><if test='endAt != null'> and x.created_at&lt;#{endAt}</if> order by x.id desc</script>")
 IPage<Map<String,Object>> playerTransactions(Page<Map<String,Object>> page,@Param("keyword")String keyword,@Param("businessType")String businessType,@Param("direction")String direction,@Param("balanceType")String balanceType,@Param("startAt")LocalDateTime startAt,@Param("endAt")LocalDateTime endAt);

 @Select("<script>select s.*,t.order_no,t.business_type,u.username,u.nickname,(select count(*) from pw_order_settlement_detail d where d.settlement_id=s.id and d.detail_type='PLAYER_INCOME') player_count from pw_order_settlement s join pw_trade_order t on t.id=s.order_id join sys_user u on u.id=t.customer_id where 1=1" +
  "<if test='keyword != null and keyword != &quot;&quot;'> and (s.settlement_no like concat('%',#{keyword},'%') or t.order_no like concat('%',#{keyword},'%') or u.username like concat('%',#{keyword},'%') or u.nickname like concat('%',#{keyword},'%'))</if>" +
  "<if test='status != null and status != &quot;&quot;'> and s.settlement_status=#{status}</if><if test='startAt != null'> and coalesce(s.settled_at,s.created_at)&gt;=#{startAt}</if><if test='endAt != null'> and coalesce(s.settled_at,s.created_at)&lt;#{endAt}</if> order by s.id desc</script>")
 IPage<Map<String,Object>> settlements(Page<Map<String,Object>> page,@Param("keyword")String keyword,@Param("status")String status,@Param("startAt")LocalDateTime startAt,@Param("endAt")LocalDateTime endAt);
}
