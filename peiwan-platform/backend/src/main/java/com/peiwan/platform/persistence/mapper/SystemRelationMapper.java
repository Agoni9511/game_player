package com.peiwan.platform.persistence.mapper;import org.apache.ibatis.annotations.*;
public interface SystemRelationMapper{
 @Select("select count(*) from sys_user_role where user_id=#{uid} and role_id=#{rid}") int hasUserRole(long uid,long rid);
 @Insert("insert into sys_user_role(user_id,role_id) values(#{uid},#{rid})") int addUserRole(long uid,long rid);
 @Insert("insert into sys_role_menu(role_id,menu_id) select #{rid},m.id from sys_menu m where not exists(select 1 from sys_role_menu x where x.role_id=#{rid} and x.menu_id=m.id)") int grantAllMenus(long rid);
 @Delete("delete from sys_user_role where user_id=#{uid}") int deleteUserRoles(long uid);
 @Delete("delete from sys_user_role where role_id=#{rid}") int deleteUsersByRole(long rid);
 @Delete("delete from sys_role_menu where role_id=#{rid}") int deleteRoleMenus(long rid);
 @Delete("delete from sys_role_menu where menu_id=#{mid}") int deleteRolesByMenu(long mid);
 @Insert("insert into sys_role_menu(role_id,menu_id) values(#{rid},#{mid})") int addRoleMenu(long rid,long mid);
 @Select("select menu_id from sys_role_menu where role_id=#{rid} order by menu_id") java.util.List<Long> roleMenuIds(long rid);
}
