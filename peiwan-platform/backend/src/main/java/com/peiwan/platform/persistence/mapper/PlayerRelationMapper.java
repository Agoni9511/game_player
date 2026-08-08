package com.peiwan.platform.persistence.mapper;import org.apache.ibatis.annotations.*;
public interface PlayerRelationMapper{
 @Select("select count(*) from pw_product where game_id=#{id} and status='ON_SALE'") long onSaleProductCount(long id);
 @Select("select count(*) from pw_product where game_id=#{id}") long productCount(long id);
 @Select("select count(*) from pw_player_game where game_id=#{id}") long playerGameCount(long id);
 @Delete("delete from pw_game_position where game_id=#{id}") int deleteGamePositions(long id);
 @Select("select count(*) from pw_player_game_position where position_id=#{id}") long positionUseCount(long id);
 @Delete("delete from pw_player_tag_rel where tag_id=#{id}") int deleteTagRelations(long id);
 @Select("select count(*) from pw_order where assigned_player_id=#{id} and order_status in('ASSIGNED','IN_SERVICE','PENDING_CONFIRM')") long activeOrderCount(long id);
 @Delete("delete from pw_player_tag_rel where player_id=#{id}") int deletePlayerTags(long id);
 @Insert("insert into pw_player_tag_rel(player_id,tag_id) values(#{pid},#{tid})") int addPlayerTag(long pid,long tid);
 @Delete("delete from pw_player_game_position where player_game_id in(select id from pw_player_game where player_id=#{id})") int deletePlayerGamePositions(long id);
 @Delete("delete from pw_player_game where player_id=#{id}") int deletePlayerGames(long id);
 @Insert("insert into pw_player_game_position(player_game_id,position_id,is_primary) values(#{pgid},#{positionId},#{primary})") int addGamePosition(long pgid,long positionId,boolean primary);
 @Delete("delete from pw_player_media where player_id=#{id}") int deletePlayerMedia(long id);
}
