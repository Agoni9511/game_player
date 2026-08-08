insert into sys_role(name,code,description,enabled,built_in)
select '超级管理员','admin','系统内置超级管理员',true,true
where not exists(select 1 from sys_role where code='admin');

insert into sys_role(name,code,description,enabled,built_in)
select '陪玩师','player','陪玩师工作台内置角色',true,true
where not exists(select 1 from sys_role where code='player');

insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select null,'DIRECTORY','PlayerPortal','/player','/index/index','陪玩师中心','ri:customer-service-2-line',30
where not exists(select 1 from sys_menu where name='PlayerPortal');
insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','PlayerWorkbench','workbench','/player/workbench','接单工作台','ri:dashboard-3-line',1
from sys_menu where name='PlayerPortal' and not exists(select 1 from sys_menu where name='PlayerWorkbench');

insert into sys_menu(parent_id,type,name,title,auth_mark,sort_no)
select p.id,'BUTTON',concat('PlayerWorkbench',a.suffix),a.title,a.mark,a.sort_no from sys_menu p join (
 select 'View' suffix,'查看工作台' title,'player:workbench:view' mark,1 sort_no union all
 select 'Status','切换接单状态','player:work-status:update',2 union all
 select 'DispatchList','查看待响应派单','player:dispatch:list',3 union all
 select 'DispatchAccept','接受派单','player:dispatch:accept',4 union all
 select 'DispatchReject','拒绝派单','player:dispatch:reject',5 union all
 select 'OrderList','查看本人订单','player:order:list',6 union all
 select 'OrderDetail','查看本人订单详情','player:order:detail',7
) a on 1=1 where p.name='PlayerWorkbench' and not exists(select 1 from sys_menu m where m.auth_mark=a.mark);

insert into sys_role_menu(role_id,menu_id)
select r.id,m.id from sys_role r cross join sys_menu m
where r.code='admin' and m.name in('PlayerPortal','PlayerWorkbench')
and not exists(select 1 from sys_role_menu x where x.role_id=r.id and x.menu_id=m.id);
insert into sys_role_menu(role_id,menu_id)
select r.id,m.id from sys_role r cross join sys_menu m
where r.code='admin' and m.auth_mark like 'player:%'
and not exists(select 1 from sys_role_menu x where x.role_id=r.id and x.menu_id=m.id);
insert into sys_role_menu(role_id,menu_id)
select r.id,m.id from sys_role r cross join sys_menu m
where r.code='player' and (m.name in('PlayerPortal','PlayerWorkbench') or m.auth_mark like 'player:%')
and not exists(select 1 from sys_role_menu x where x.role_id=r.id and x.menu_id=m.id);
