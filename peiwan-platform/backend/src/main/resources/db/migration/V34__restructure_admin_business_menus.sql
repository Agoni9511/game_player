-- Restructure admin-side business menus by operational domain instead of technical modules.
-- Keep existing route paths, component paths, and auth_mark values unchanged.

insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no,hidden,enabled,keep_alive)
select null,'DIRECTORY','BasicConfig','/basic-config','/index/index','基础配置','ri:settings-3-line',20,false,true,true
where not exists(select 1 from sys_menu where name='BasicConfig');

insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no,hidden,enabled,keep_alive)
select null,'DIRECTORY','ProductCenter','/product-center','/index/index','商品中心','ri:shopping-bag-3-line',21,false,true,true
where not exists(select 1 from sys_menu where name='ProductCenter');

insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no,hidden,enabled,keep_alive)
select null,'DIRECTORY','OrderCenter','/order-center','/index/index','订单中心','ri:file-list-3-line',22,false,true,true
where not exists(select 1 from sys_menu where name='OrderCenter');

insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no,hidden,enabled,keep_alive)
select null,'DIRECTORY','PlayerOps','/player-ops','/index/index','陪玩运营','ri:user-star-line',23,false,true,true
where not exists(select 1 from sys_menu where name='PlayerOps');

update sys_menu
set title='基础配置',
    path='/basic-config',
    icon='ri:settings-3-line',
    sort_no=20,
    hidden=false,
    enabled=true,
    keep_alive=true,
    updated_at=current_timestamp
where name='BasicConfig';

update sys_menu
set title='商品中心',
    path='/product-center',
    icon='ri:shopping-bag-3-line',
    sort_no=21,
    hidden=false,
    enabled=true,
    keep_alive=true,
    updated_at=current_timestamp
where name='ProductCenter';

update sys_menu
set title='订单中心',
    path='/order-center',
    icon='ri:file-list-3-line',
    sort_no=22,
    hidden=false,
    enabled=true,
    keep_alive=true,
    updated_at=current_timestamp
where name='OrderCenter';

update sys_menu
set title='陪玩运营',
    path='/player-ops',
    icon='ri:user-star-line',
    sort_no=23,
    hidden=false,
    enabled=true,
    keep_alive=true,
    updated_at=current_timestamp
where name='PlayerOps';

update sys_menu
set hidden=true,
    sort_no=24,
    updated_at=current_timestamp
where name='Business';

update sys_menu
set parent_id=(select id from sys_menu where name='BasicConfig'),
    sort_no=1,
    updated_at=current_timestamp
where name='Game';

update sys_menu
set parent_id=(select id from sys_menu where name='BasicConfig'),
    sort_no=2,
    updated_at=current_timestamp
where name='PlayerTag';

update sys_menu
set parent_id=(select id from sys_menu where name='BasicConfig'),
    sort_no=3,
    updated_at=current_timestamp
where name='ProductCategory';

update sys_menu
set parent_id=(select id from sys_menu where name='BasicConfig'),
    sort_no=4,
    updated_at=current_timestamp
where name='ServiceItem';

update sys_menu
set parent_id=(select id from sys_menu where name='BasicConfig'),
    sort_no=5,
    updated_at=current_timestamp
where name='PlayerLevel';

update sys_menu
set parent_id=(select id from sys_menu where name='ProductCenter'),
    sort_no=1,
    updated_at=current_timestamp
where name='ProductManage';

update sys_menu
set parent_id=(select id from sys_menu where name='ProductCenter'),
    sort_no=2,
    updated_at=current_timestamp
where name='RechargePlanManage';

update sys_menu
set parent_id=(select id from sys_menu where name='OrderCenter'),
    sort_no=1,
    updated_at=current_timestamp
where name='OrderManage';

update sys_menu
set parent_id=(select id from sys_menu where name='OrderCenter'),
    sort_no=2,
    updated_at=current_timestamp
where name='DispatchManage';

update sys_menu
set parent_id=(select id from sys_menu where name='OrderCenter'),
    sort_no=3,
    updated_at=current_timestamp
where name='AfterSaleManage';

update sys_menu
set parent_id=(select id from sys_menu where name='PlayerOps'),
    sort_no=1,
    updated_at=current_timestamp
where name='Player';

update sys_menu
set parent_id=(select id from sys_menu where name='PlayerOps'),
    sort_no=2,
    updated_at=current_timestamp
where name='FulfillmentReview';

update sys_menu
set parent_id=(select id from sys_menu where name='PlayerOps'),
    sort_no=3,
    updated_at=current_timestamp
where name='SettlementManage';

insert into sys_role_menu(role_id,menu_id)
select r.id,m.id from sys_role r cross join sys_menu m
where r.code='admin'
  and m.name in('BasicConfig','ProductCenter','OrderCenter','PlayerOps')
  and not exists(select 1 from sys_role_menu x where x.role_id=r.id and x.menu_id=m.id);
