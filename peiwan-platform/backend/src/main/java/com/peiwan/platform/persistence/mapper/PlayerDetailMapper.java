package com.peiwan.platform.persistence.mapper;
import com.baomidou.mybatisplus.core.metadata.IPage;import com.baomidou.mybatisplus.extension.plugins.pagination.Page;import org.apache.ibatis.annotations.*;import java.util.*;
public interface PlayerDetailMapper{
 @Select("select u.id,u.username,u.nickname,u.phone from sys_user u left join pw_player p on p.user_id=u.id where u.enabled=true and (p.id is null or p.id=#{playerId}) order by u.id") List<Map<String,Object>> userOptions(long playerId);
 @Select("<script>select p.*,g.game_name primary_game from pw_player p left join pw_player_game pg on pg.player_id=p.id and pg.is_primary=true left join pw_game g on g.id=pg.game_id where (p.player_no like concat('%',#{keyword},'%') or p.nickname like concat('%',#{keyword},'%') or coalesce(p.phone,'') like concat('%',#{keyword},'%')) <if test='auditStatus != null and auditStatus != &quot;&quot;'>and p.audit_status=#{auditStatus}</if> <if test='workStatus != null and workStatus != &quot;&quot;'>and p.work_status=#{workStatus}</if> <if test='enabled != null'>and p.enabled=#{enabled}</if> order by p.sort_no,p.id desc</script>") IPage<Map<String,Object>> players(Page<Map<String,Object>> page,@Param("keyword")String keyword,@Param("auditStatus")String auditStatus,@Param("workStatus")String workStatus,@Param("enabled")Boolean enabled);
 @Select("select p.*,g.game_name primary_game from pw_player p left join pw_player_game pg on pg.player_id=p.id and pg.is_primary=true left join pw_game g on g.id=pg.game_id where p.id=#{id}") Map<String,Object> playerDetail(long id);
 @Select("select tag_id from pw_player_tag_rel where player_id=#{id} order by tag_id") List<Long> tagIds(long id);
 @Select("select pg.*,g.game_name from pw_player_game pg join pw_game g on g.id=pg.game_id where pg.player_id=#{id} order by pg.is_primary desc,pg.id") List<Map<String,Object>> playerGames(long id);
 @Select("select * from pw_player_media where player_id=#{id} order by sort_no,id") List<Map<String,Object>> media(long id);
 @Select("select a.*,u.username auditor_name from pw_player_audit a left join sys_user u on u.id=a.auditor_id where a.player_id=#{id} order by a.id desc") List<Map<String,Object>> audits(long id);
 @Select("select position_id from pw_player_game_position where player_game_id=#{id} order by position_id") List<Long> positionIds(long id);
 @Select("select position_id from pw_player_game_position where player_game_id=#{id} and is_primary=true limit 1") Long primaryPositionId(long id);
}
