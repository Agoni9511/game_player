package com.peiwan.platform.persistence.mapper;

import org.apache.ibatis.annotations.Select;

public interface CustomerServiceDataMapper {
  @Select("select count(*) from pw_trade_order t where t.id=#{orderId} and (t.customer_id=#{userId} or exists(select 1 from pw_order_member m join pw_player p on p.id=m.player_id where m.order_id=t.id and p.user_id=#{userId}))")
  int canAccessOrder(long userId, long orderId);
}
