-- Early versions relied on application bootstrap code for these base menus.
-- Keep schema/data initialization reproducible after moving bootstrap to MyBatis-Plus.
insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select null,'DIRECTORY','System','/system','/index/index','系统管理','ri:settings-3-line',10
where not exists(select 1 from sys_menu where name='System');

insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','User','user','/system/user','用户管理','ri:user-line',1 from sys_menu
where name='System' and not exists(select 1 from sys_menu where name='User');
insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','Role','role','/system/role','角色管理','ri:shield-user-line',2 from sys_menu
where name='System' and not exists(select 1 from sys_menu where name='Role');
insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','Menu','menu','/system/menu','菜单管理','ri:menu-line',3 from sys_menu
where name='System' and not exists(select 1 from sys_menu where name='Menu');
insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','LoginLog','login-log','/system/login-log','登录日志','ri:login-box-line',4 from sys_menu
where name='System' and not exists(select 1 from sys_menu where name='LoginLog');
insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','OperationLog','operation-log','/system/operation-log','操作日志','ri:file-list-3-line',5 from sys_menu
where name='System' and not exists(select 1 from sys_menu where name='OperationLog');

insert into sys_menu(parent_id,type,name,title,auth_mark,sort_no)
select p.id,'BUTTON',concat(p.name,a.suffix),a.title,a.mark,a.sort_no from sys_menu p join (
 select 'User' parent_name,'List' suffix,'查询用户' title,'system:user:list' mark,1 sort_no union all
 select 'User','Add','新增用户','system:user:create',2 union all select 'User','Edit','编辑用户','system:user:update',3 union all
 select 'User','Delete','删除用户','system:user:delete',4 union all select 'User','Status','启用/禁用用户','system:user:status',5 union all
 select 'User','ResetPassword','重置密码','system:user:reset-password',6 union all select 'User','AssignRole','分配角色','system:user:assign-role',7 union all
 select 'Role','List','查询角色','system:role:list',1 union all select 'Role','Add','新增角色','system:role:create',2 union all
 select 'Role','Edit','编辑角色','system:role:update',3 union all select 'Role','Delete','删除角色','system:role:delete',4 union all
 select 'Role','Status','启用/禁用角色','system:role:status',5 union all select 'Role','Assign','分配权限','system:role:assign',6 union all
 select 'Menu','List','查询菜单','system:menu:list',1 union all select 'Menu','Add','新增菜单','system:menu:create',2 union all
 select 'Menu','Edit','编辑菜单','system:menu:update',3 union all select 'Menu','Delete','删除菜单','system:menu:delete',4 union all
 select 'LoginLog','List','查询登录日志','system:login-log:list',1 union all
 select 'OperationLog','List','查询操作日志','system:operation-log:list',1
) a on a.parent_name=p.name
where not exists(select 1 from sys_menu m where m.auth_mark=a.mark);

insert into sys_role_menu(role_id,menu_id)
select r.id,m.id from sys_role r cross join sys_menu m
where r.code='admin' and not exists(select 1 from sys_role_menu x where x.role_id=r.id and x.menu_id=m.id);
