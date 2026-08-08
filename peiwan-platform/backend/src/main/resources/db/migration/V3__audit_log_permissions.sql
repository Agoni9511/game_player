insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','LoginLog','login-log','/system/login-log','登录日志','ri:login-box-line',4
from sys_menu where name='System' and not exists(select 1 from sys_menu where name='LoginLog');

insert into sys_menu(parent_id,type,name,title,auth_mark,sort_no)
select id,'BUTTON','LoginLogList','查询登录日志','system:login-log:list',1
from sys_menu where name='LoginLog' and not exists(select 1 from sys_menu where auth_mark='system:login-log:list');

insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','OperationLog','operation-log','/system/operation-log','操作日志','ri:file-list-3-line',5
from sys_menu where name='System' and not exists(select 1 from sys_menu where name='OperationLog');

insert into sys_menu(parent_id,type,name,title,auth_mark,sort_no)
select id,'BUTTON','OperationLogList','查询操作日志','system:operation-log:list',1
from sys_menu where name='OperationLog' and not exists(select 1 from sys_menu where auth_mark='system:operation-log:list');

insert into sys_role_menu(role_id,menu_id)
select r.id,m.id from sys_role r cross join sys_menu m
where r.code='admin' and not exists(select 1 from sys_role_menu rm where rm.role_id=r.id and rm.menu_id=m.id);
