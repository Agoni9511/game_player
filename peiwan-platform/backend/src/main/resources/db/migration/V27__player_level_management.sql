insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','PlayerLevel','player-level','/business/player-level','陪玩等级','ri:vip-crown-2-line',5
from sys_menu where name='Business' and not exists(select 1 from sys_menu where name='PlayerLevel');

insert into sys_menu(parent_id,type,name,title,auth_mark,sort_no)
select p.id,'BUTTON',concat(p.name,a.suffix),a.title,a.mark,a.sort_no from sys_menu p join (
 select 'List' suffix,'查询陪玩等级' title,'business:player-level:list' mark,1 sort_no union all
 select 'Create','新增陪玩等级','business:player-level:create',2 union all
 select 'Update','编辑陪玩等级','business:player-level:update',3 union all
 select 'Status','启停陪玩等级','business:player-level:status',4 union all
 select 'Delete','删除陪玩等级','business:player-level:delete',5
) a on 1=1 where p.name='PlayerLevel' and not exists(select 1 from sys_menu m where m.auth_mark=a.mark);

insert into sys_role_menu(role_id,menu_id)
select r.id,m.id from sys_role r cross join sys_menu m
where r.code='admin' and not exists(select 1 from sys_role_menu x where x.role_id=r.id and x.menu_id=m.id);
