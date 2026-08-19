package com.peiwan.platform.persistence.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.peiwan.platform.persistence.entity.OrderRequestedPlayerEntity;
import org.apache.ibatis.annotations.*;
import java.util.*;

public interface OrderRequestedPlayerMapper extends BaseMapper<OrderRequestedPlayerEntity> {
 @Select("select player_id from pw_order_requested_player where order_id=#{orderId} order by sort_no,id")
 List<Long> playerIds(long orderId);

 @Select("select r.player_id,p.player_no,p.nickname,p.work_status,pg.price_level_id,l.level_name,r.sort_no from pw_order_requested_player r join pw_player p on p.id=r.player_id left join pw_order_game_profile og on og.order_id=r.order_id left join pw_player_game pg on pg.player_id=p.id and pg.game_id=og.game_id left join pw_player_level l on l.id=pg.price_level_id where r.order_id=#{orderId} order by r.sort_no,r.id")
 List<Map<String,Object>> players(long orderId);
}
