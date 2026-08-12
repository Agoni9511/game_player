package com.peiwan.platform.persistence.mapper;

import org.apache.ibatis.annotations.*;
import java.util.*;

public interface OrderMemberDataMapper {
 @Select("select order_id id,service_status order_status,required_player_count from pw_service_order where order_id=#{orderId} for update") Map<String,Object> lockOrder(long orderId);
 @Select("select count(*) from pw_order_member where order_id=#{orderId} and member_status in('ACCEPTED','IN_SERVICE','COMPLETED')") int joinedCount(long orderId);
 @Select("select count(*) from pw_order_member where order_id=#{orderId} and player_id=#{playerId}") int memberExists(long orderId,long playerId);
 @Select("select count(*) from pw_order_member where order_id=#{orderId} and player_id=#{playerId} and member_status in('ACCEPTED','IN_SERVICE','COMPLETED')") int activeMemberExists(long orderId,long playerId);
 @Update("update pw_service_order set service_status='ASSIGNED',assigned_at=current_timestamp,updated_at=current_timestamp where order_id=#{orderId} and service_status='WAIT_ASSIGN'") int fillOrder(long orderId);
 @Select("select m.id,m.order_id,m.player_id,m.member_status,m.join_source,m.dispatch_task_id,m.joined_at,m.service_started_at,m.completed_at,m.cancelled_at,p.player_no,p.nickname player_name,p.avatar_url from pw_order_member m join pw_player p on p.id=m.player_id where m.order_id=#{orderId} order by case when m.member_status in('ACCEPTED','IN_SERVICE','COMPLETED') then 0 else 1 end,m.id") List<Map<String,Object>> members(long orderId);
 @Select("select player_id from pw_order_member where order_id=#{orderId} and member_status in('ACCEPTED','IN_SERVICE','COMPLETED') order by id") List<Long> activePlayerIds(long orderId);
 @Update("update pw_order_member set member_status=#{status},service_started_at=case when #{status}='IN_SERVICE' then coalesce(service_started_at,current_timestamp) else service_started_at end,completed_at=case when #{status}='COMPLETED' then coalesce(completed_at,current_timestamp) else completed_at end,cancelled_at=case when #{status}='CANCELLED' then coalesce(cancelled_at,current_timestamp) else cancelled_at end,updated_at=current_timestamp where order_id=#{orderId} and member_status in('ACCEPTED','IN_SERVICE')") int updateStatuses(long orderId,String status);
 @Select("select count(*) from pw_order_member m join pw_service_order s on s.order_id=m.order_id where m.player_id=#{playerId} and m.member_status in('ACCEPTED','IN_SERVICE') and s.service_status in('WAIT_ASSIGN','ASSIGNED','IN_SERVICE','PENDING_CONFIRM','WAIT_CUSTOMER_CONFIRM','AFTER_SALE')") long activeOrderCount(long playerId);
}
