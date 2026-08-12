-- Keep service exception review with the other player-operation workflows.
update sys_menu
set parent_id=(select id from sys_menu where name='PlayerOps'),
    sort_no=4,
    hidden=false,
    enabled=true,
    updated_at=current_timestamp
where name='ServiceExceptionManage'
  and exists(select 1 from sys_menu where name='PlayerOps');

insert into sys_role_menu(role_id,menu_id)
select r.id,m.id from sys_role r cross join sys_menu m
where r.code='admin'
  and m.name='ServiceExceptionManage'
  and not exists(select 1 from sys_role_menu x where x.role_id=r.id and x.menu_id=m.id);
