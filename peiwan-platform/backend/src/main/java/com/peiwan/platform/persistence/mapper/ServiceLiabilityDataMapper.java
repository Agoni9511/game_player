package com.peiwan.platform.persistence.mapper;
import org.apache.ibatis.annotations.*;import java.math.BigDecimal;import java.util.*;
public interface ServiceLiabilityDataMapper{
 @Select("select base_unit_price from pw_service_order where order_id=#{orderId}")BigDecimal baseUnitPrice(long orderId);
 @Select("select x.id,x.exception_request_id,x.from_order_member_id,x.to_order_member_id,f.player_id from_player_id,t.player_id to_player_id from pw_service_member_transfer x join pw_order_member f on f.id=x.from_order_member_id join pw_order_member t on t.id=x.to_order_member_id where x.order_id=#{orderId} order by x.id")List<Map<String,Object>> transferLinks(long orderId);
 @Select("select id,player_id from pw_order_member where order_id=#{orderId} and member_status in('ACCEPTED','IN_SERVICE') order by id")List<Map<String,Object>> activeMembers(long orderId);
 @Select("select count(*) from pw_service_liability where order_id=#{orderId} and liability_type=#{type}")int liabilityCount(long orderId,String type);
 @Select("select * from pw_player_account where player_id=#{playerId} for update")Map<String,Object> lockAccount(long playerId);
 @Update("update pw_player_account set available_balance=available_balance-#{amount},version=version+1,updated_at=current_timestamp where id=#{accountId}")int debit(long accountId,BigDecimal amount);
 @Update("update pw_player_account set available_balance=available_balance+#{amount},total_income=total_income+#{amount},version=version+1,updated_at=current_timestamp where id=#{accountId}")int credit(long accountId,BigDecimal amount);
}
