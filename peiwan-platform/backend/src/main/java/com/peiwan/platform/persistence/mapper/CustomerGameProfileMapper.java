package com.peiwan.platform.persistence.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.peiwan.platform.persistence.entity.CustomerGameProfileEntity;
import org.apache.ibatis.annotations.Select;

import java.util.Map;

public interface CustomerGameProfileMapper extends BaseMapper<CustomerGameProfileEntity>{
 @Select("select gp.*,o.contact_name,o.contact_phone from pw_order_game_profile gp join pw_order o on o.id=gp.order_id where o.customer_id=#{uid} and gp.game_id=#{gameId} and coalesce(gp.game_account,'') != '' and coalesce(gp.game_nickname,'') != '' order by o.id desc limit 1")
 Map<String,Object> latestOrderProfile(long uid,long gameId);
}
