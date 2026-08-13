-- Administrative finance center. Existing immutable ledgers remain the source of truth.

insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no,hidden,enabled,keep_alive)
select null,'DIRECTORY','FinanceCenter','/finance-center','/index/index','财务中心','ri:funds-box-line',24,false,true,true
where not exists(select 1 from sys_menu where name='FinanceCenter');

insert into sys_menu(parent_id,type,name,path,component,title,icon,sort_no,hidden,enabled,keep_alive)
select (select id from sys_menu where name='FinanceCenter'),'MENU','FinanceLedger','finance-ledger','/business/finance-ledger','财务流水','ri:exchange-funds-line',1,false,true,true
where not exists(select 1 from sys_menu where name='FinanceLedger');

insert into sys_menu(parent_id,type,name,title,auth_mark,sort_no,hidden,enabled,keep_alive)
select (select id from sys_menu where name='FinanceLedger'),'BUTTON','FinanceLedgerList','查询财务流水','business:finance:list',1,false,true,true
where not exists(select 1 from sys_menu where auth_mark='business:finance:list');

update sys_menu set parent_id=(select id from sys_menu where name='FinanceCenter'),sort_no=2,updated_at=current_timestamp where name='SettlementManage';

insert into sys_role_menu(role_id,menu_id)
select r.id,m.id from sys_role r cross join sys_menu m
where r.code='admin' and (m.name in('FinanceCenter','FinanceLedger','SettlementManage') or m.auth_mark='business:finance:list')
and not exists(select 1 from sys_role_menu x where x.role_id=r.id and x.menu_id=m.id);
