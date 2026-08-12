insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no)
select id,'MENU','MemberLevelManage','member-level','/business/member-level','会员等级','ri:vip-diamond-line',6
from sys_menu
where name='BasicConfig'
  and not exists(select 1 from sys_menu where name='MemberLevelManage');

insert into sys_menu(parent_id,type,name,title,auth_mark,sort_no)
select p.id,'BUTTON',concat('MemberLevel',a.suffix),a.title,a.mark,a.sort_no
from sys_menu p
join (
  select 'List' suffix,'查询会员等级' title,'business:member-level:list' mark,1 sort_no union all
  select 'Create','新增会员等级','business:member-level:create',2 union all
  select 'Update','编辑会员等级','business:member-level:update',3 union all
  select 'Status','启停会员等级','business:member-level:status',4 union all
  select 'Delete','删除会员等级','business:member-level:delete',5
) a on 1=1
where p.name='MemberLevelManage'
  and not exists(select 1 from sys_menu m where m.auth_mark=a.mark);

insert into sys_role_menu(role_id,menu_id)
select r.id,m.id
from sys_role r
cross join sys_menu m
where r.code='admin'
  and (
    m.name='MemberLevelManage'
    or m.auth_mark like 'business:member-level:%'
  )
  and not exists(select 1 from sys_role_menu x where x.role_id=r.id and x.menu_id=m.id);
