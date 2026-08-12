package com.peiwan.platform.persistence.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.peiwan.platform.persistence.entity.CustomerGameProfileEntity;
import org.apache.ibatis.annotations.Select;

import java.util.Map;

public interface CustomerGameProfileMapper extends BaseMapper<CustomerGameProfileEntity>{
 @Select("select gp.*,s.contact_name,s.contact_phone from pw_order_game_profile gp join pw_trade_order t on t.id=gp.order_id join pw_service_order s on s.order_id=t.id where t.customer_id=#{uid} and gp.game_id=#{gameId} and coalesce(gp.game_account,'') != '' and coalesce(gp.game_nickname,'') != '' order by t.id desc limit 1")
 Map<String,Object> latestOrderProfile(long uid,long gameId);
}
