package com.peiwan.platform.persistence.mapper;
import org.apache.ibatis.annotations.Select;import java.util.*;
public interface SystemAccessMapper{
 @Select("select r.code from sys_role r join sys_user_role ur on ur.role_id=r.id where ur.user_id=#{userId} and r.enabled=true") List<String> roleCodes(long userId);
 @Select("select role_id from sys_user_role where user_id=#{userId} order by role_id") List<Long> roleIds(long userId);
 @Select("select distinct m.auth_mark from sys_menu m join sys_role_menu rm on rm.menu_id=m.id join sys_role r on r.id=rm.role_id join sys_user_role ur on ur.role_id=r.id where ur.user_id=#{userId} and r.enabled=true and m.type='BUTTON' and m.enabled=true and m.auth_mark is not null") List<String> buttonCodes(long userId);
 @Select("select distinct m.* from sys_menu m join sys_role_menu rm on rm.menu_id=m.id join sys_role r on r.id=rm.role_id join sys_user_role ur on ur.role_id=r.id where ur.user_id=#{userId} and r.enabled=true and m.enabled=true order by m.sort_no,m.id") List<Map<String,Object>> userMenus(long userId);
 @Select("select count(distinct u.id) from sys_user u join sys_user_role ur on ur.user_id=u.id join sys_role r on r.id=ur.role_id where u.enabled=true and r.enabled=true and r.code='admin'") long enabledAdminCount();
}
