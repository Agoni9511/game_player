-- Rich, persistent workflow data for the player/123456 mini-program demo account.

update pw_player set max_active_orders=10 where user_id=(select id from sys_user where username='player');
update pw_dispatch_rule set max_active_orders=10,allow_busy=true,grab_minutes=30 where enabled=true;

-- Trade headers covering every player-side order state.
insert into pw_trade_order(order_no,customer_id,business_type,trade_status,title,total_amount,payable_amount,paid_amount,payment_status,paid_at,created_by,created_at,updated_at)
select v.order_no,u.id,'PLAYER_SERVICE',case when v.service_status='COMPLETED' then 'COMPLETED' else 'PROCESSING' end,v.title,v.amount,v.amount,v.amount,'PAID',dateadd('HOUR',-v.age_hours,current_timestamp),u.id,dateadd('HOUR',-v.age_hours,current_timestamp),current_timestamp
from sys_user u cross join (
  select 'DEMO-P-DISPATCH-01' order_no,'烽火地带撤离护航' title,89.00 amount,'WAIT_ASSIGN' service_status,2 age_hours union all
  select 'DEMO-P-DISPATCH-02','三角洲清图专项',79.00,'WAIT_ASSIGN',3 union all
  select 'DEMO-P-ASSIGNED-01','撤离护航 1 局',89.00,'ASSIGNED',5 union all
  select 'DEMO-P-ASSIGNED-02','竞技陪玩 2 小时',109.00,'ASSIGNED',8 union all
  select 'DEMO-P-SERVICE-01','竞技陪玩 3 小时',159.00,'IN_SERVICE',12 union all
  select 'DEMO-P-SERVICE-02','专项清图 3 局',219.00,'IN_SERVICE',18 union all
  select 'DEMO-P-REVIEW-01','烽火地带撤离护航',99.00,'PENDING_CONFIRM',28 union all
  select 'DEMO-P-CONFIRM-01','竞技陪玩 1 小时',58.00,'WAIT_CUSTOMER_CONFIRM',36 union all
  select 'DEMO-P-COMPLETED-01','新人撤离体验',89.00,'COMPLETED',72 union all
  select 'DEMO-P-COMPLETED-02','双排竞技陪玩',109.00,'COMPLETED',120 union all
  select 'DEMO-P-COMPLETED-03','深度上分陪练',159.00,'COMPLETED',168 union all
  select 'DEMO-P-TRANSFER-01','多人烽火护航',198.00,'IN_SERVICE',10
) v
where u.username='customer' and not exists(select 1 from pw_trade_order x where x.order_no=v.order_no);

insert into pw_service_order(order_id,required_player_count,pricing_mode,price_type,base_unit_price,contact_name,contact_phone,service_status,assigned_at,service_started_at,completion_submitted_at,customer_confirm_deadline,created_at,updated_at)
select t.id,case when t.order_no='DEMO-P-TRANSFER-01' then 2 else 1 end,'FIXED_SKU','PER_PLAYER',t.payable_amount,u.nickname,u.phone,
  case
    when t.order_no like 'DEMO-P-DISPATCH-%' then 'WAIT_ASSIGN'
    when t.order_no like 'DEMO-P-ASSIGNED-%' then 'ASSIGNED'
    when t.order_no like 'DEMO-P-SERVICE-%' or t.order_no='DEMO-P-TRANSFER-01' then 'IN_SERVICE'
    when t.order_no='DEMO-P-REVIEW-01' then 'PENDING_CONFIRM'
    when t.order_no='DEMO-P-CONFIRM-01' then 'WAIT_CUSTOMER_CONFIRM'
    else 'COMPLETED' end,
  case when t.order_no like 'DEMO-P-DISPATCH-%' then null else dateadd('HOUR',1,t.created_at) end,
  case when t.order_no like 'DEMO-P-SERVICE-%' or t.order_no like 'DEMO-P-REVIEW-%' or t.order_no like 'DEMO-P-CONFIRM-%' or t.order_no like 'DEMO-P-COMPLETED-%' or t.order_no='DEMO-P-TRANSFER-01' then dateadd('HOUR',2,t.created_at) end,
  case when t.order_no like 'DEMO-P-REVIEW-%' or t.order_no like 'DEMO-P-CONFIRM-%' then dateadd('HOUR',3,t.created_at) end,
  case when t.order_no like 'DEMO-P-CONFIRM-%' then dateadd('DAY',1,current_timestamp) end,
  t.created_at,current_timestamp
from pw_trade_order t join sys_user u on u.id=t.customer_id
where t.order_no like 'DEMO-P-%' and not exists(select 1 from pw_service_order s where s.order_id=t.id);

-- Every order has product and game detail, so card taps open a complete detail page.
insert into pw_order_item(order_id,product_id,sku_id,product_code,product_name,sku_code,sku_name,product_type,unit_price,quantity,subtotal_amount,service_snapshot)
select t.id,p.id,k.id,p.product_code,t.title,k.sku_code,k.sku_name,'SERVICE',t.payable_amount,1,t.payable_amount,'[{"service_name":"演示陪玩服务","quantity":1,"unit_type":"ORDER"}]'
from pw_trade_order t join pw_product p on p.product_code='delta-beacon-escort' join pw_product_sku k on k.product_id=p.id and k.sku_code='delta-beacon-escort-1g'
where t.order_no like 'DEMO-P-%' and not exists(select 1 from pw_order_item i where i.order_id=t.id);

insert into pw_order_game_profile(order_id,game_id,game_name,game_account,game_nickname,server_name,rank_name,extra_requirement)
select t.id,g.id,g.game_name,concat('demo-',t.id),concat('演示顾客',t.id),'国服',case when mod(t.id,2)=0 then '钻石' else '白金' end,
  case when t.order_no like 'DEMO-P-DISPATCH-%' then '积极沟通，熟悉撤离路线' when t.order_no='DEMO-P-TRANSFER-01' then '多人协作，语音报点' else '按预约时间上线，服务过程留证' end
from pw_trade_order t join pw_game g on g.game_code='delta-force'
where t.order_no like 'DEMO-P-%' and not exists(select 1 from pw_order_game_profile x where x.order_id=t.id);

-- Current player owns all non-dispatch demo orders except the transfer source order.
insert into pw_order_member(order_id,player_id,member_status,join_source,joined_at,service_started_at,completed_at,created_at,updated_at)
select t.id,p.id,
  case when t.order_no like 'DEMO-P-ASSIGNED-%' then 'ACCEPTED' when t.order_no like 'DEMO-P-COMPLETED-%' then 'COMPLETED' else 'IN_SERVICE' end,
  'DEMO',dateadd('HOUR',1,t.created_at),
  case when t.order_no not like 'DEMO-P-ASSIGNED-%' then dateadd('HOUR',2,t.created_at) end,
  case when t.order_no like 'DEMO-P-COMPLETED-%' then dateadd('HOUR',4,t.created_at) end,t.created_at,current_timestamp
from pw_trade_order t join sys_user u on u.username='player' join pw_player p on p.user_id=u.id
where t.order_no like 'DEMO-P-%' and t.order_no not like 'DEMO-P-DISPATCH-%' and t.order_no<>'DEMO-P-TRANSFER-01'
  and not exists(select 1 from pw_order_member m where m.order_id=t.id and m.player_id=p.id);

insert into pw_fulfillment(order_id,order_member_id,player_id,fulfillment_status,completion_note,actual_quantity,submitted_at,reviewed_at,review_remark,created_at,updated_at)
select m.order_id,m.id,m.player_id,
  case when t.order_no like 'DEMO-P-SERVICE-%' then 'IN_SERVICE' when t.order_no='DEMO-P-REVIEW-01' then 'PENDING_REVIEW' when t.order_no='DEMO-P-CONFIRM-01' or t.order_no like 'DEMO-P-COMPLETED-%' then 'APPROVED' else 'IN_SERVICE' end,
  case when t.order_no like 'DEMO-P-REVIEW-%' or t.order_no like 'DEMO-P-CONFIRM-%' or t.order_no like 'DEMO-P-COMPLETED-%' then '演示完成凭证：服务时长和局数均已完成，沟通顺畅。' end,
  1,
  case when t.order_no like 'DEMO-P-REVIEW-%' or t.order_no like 'DEMO-P-CONFIRM-%' or t.order_no like 'DEMO-P-COMPLETED-%' then dateadd('HOUR',3,t.created_at) end,
  case when t.order_no like 'DEMO-P-CONFIRM-%' or t.order_no like 'DEMO-P-COMPLETED-%' then dateadd('HOUR',4,t.created_at) end,
  case when t.order_no like 'DEMO-P-CONFIRM-%' or t.order_no like 'DEMO-P-COMPLETED-%' then '平台审核通过' end,
  t.created_at,current_timestamp
from pw_order_member m join pw_trade_order t on t.id=m.order_id
where t.order_no like 'DEMO-P-%' and t.order_no not like 'DEMO-P-ASSIGNED-%'
  and not exists(select 1 from pw_fulfillment f where f.order_member_id=m.id);

-- Two fresh grab cards for the player-side hall.
insert into pw_dispatch_task(task_no,order_id,dispatch_mode,task_status,target_player_id,attempt_no,candidate_count,deadline_at,created_by,created_at,updated_at)
select concat('DSP-',t.order_no),t.id,'GRAB','DISPATCHING',null,1,1,dateadd('DAY',30,current_timestamp),u.id,current_timestamp,current_timestamp
from pw_trade_order t join sys_user u on u.username='admin'
where t.order_no like 'DEMO-P-DISPATCH-%' and not exists(select 1 from pw_dispatch_task d where d.task_no=concat('DSP-',t.order_no));

insert into pw_dispatch_candidate(task_id,player_id,match_score,active_order_count,candidate_status,notified,created_at)
select d.id,p.id,98.00,0,'PENDING',true,current_timestamp
from pw_dispatch_task d join pw_trade_order t on t.id=d.order_id join sys_user u on u.username='player' join pw_player p on p.user_id=u.id
where t.order_no like 'DEMO-P-DISPATCH-%' and not exists(select 1 from pw_dispatch_candidate c where c.task_id=d.id and c.player_id=p.id);

-- An audited transfer invitation targeting the current demo player.
insert into pw_order_member(order_id,player_id,member_status,join_source,joined_at,service_started_at,created_at,updated_at)
select t.id,p.id,'IN_SERVICE','DEMO',dateadd('HOUR',1,t.created_at),dateadd('HOUR',2,t.created_at),t.created_at,current_timestamp
from pw_trade_order t join pw_player p on p.id=(select min(x.id) from pw_player x join pw_player_game pg on pg.player_id=x.id join pw_game g on g.id=pg.game_id where g.game_code='delta-force' and x.user_id<>(select id from sys_user where username='player'))
where t.order_no='DEMO-P-TRANSFER-01' and not exists(select 1 from pw_order_member m where m.order_id=t.id);

insert into pw_fulfillment(order_id,order_member_id,player_id,fulfillment_status,created_at,updated_at)
select m.order_id,m.id,m.player_id,'IN_SERVICE',m.created_at,current_timestamp from pw_order_member m join pw_trade_order t on t.id=m.order_id
where t.order_no='DEMO-P-TRANSFER-01' and not exists(select 1 from pw_fulfillment f where f.order_member_id=m.id);

insert into pw_service_exception_request(request_no,order_id,request_type,source_order_member_id,target_player_id,applicant_type,applicant_user_id,reason,proof_urls,request_status,review_remark,reviewed_by,reviewed_at,created_at,updated_at)
select 'EXC-DEMO-TRANSFER-01',t.id,'TRANSFER',m.id,target.id,'PLAYER',source.user_id,'临时网络故障，申请由队友接替剩余服务','[]','WAIT_TARGET','情况属实，平台审核通过',admin.id,current_timestamp,current_timestamp,current_timestamp
from pw_trade_order t join pw_order_member m on m.order_id=t.id join pw_player source on source.id=m.player_id join sys_user admin on admin.username='admin' join sys_user pu on pu.username='player' join pw_player target on target.user_id=pu.id
where t.order_no='DEMO-P-TRANSFER-01' and not exists(select 1 from pw_service_exception_request r where r.request_no='EXC-DEMO-TRANSFER-01');

-- Three completed settlements and visible earning entries.
insert into pw_order_settlement(settlement_no,order_id,order_amount,platform_amount,distributable_amount,settlement_status,settled_at,created_at,updated_at)
select concat('SET-',t.order_no),t.id,t.paid_amount,round(t.paid_amount*0.28,2),round(t.paid_amount*0.72,2),'SETTLED',dateadd('HOUR',5,t.created_at),t.created_at,current_timestamp
from pw_trade_order t where t.order_no like 'DEMO-P-COMPLETED-%' and not exists(select 1 from pw_order_settlement s where s.order_id=t.id);

insert into pw_order_settlement_detail(settlement_id,order_id,order_member_id,player_id,detail_type,amount,calculation_base,rate,remark,created_at)
select s.id,t.id,null,null,'PLATFORM_COMMISSION',s.platform_amount,t.paid_amount,0.28,'演示订单平台佣金',s.created_at
from pw_order_settlement s join pw_trade_order t on t.id=s.order_id where t.order_no like 'DEMO-P-COMPLETED-%' and not exists(select 1 from pw_order_settlement_detail d where d.settlement_id=s.id and d.detail_type='PLATFORM_COMMISSION');

insert into pw_order_settlement_detail(settlement_id,order_id,order_member_id,player_id,detail_type,amount,calculation_base,rate,remark,created_at)
select s.id,t.id,m.id,m.player_id,'PLAYER_INCOME',s.distributable_amount,t.paid_amount,0.72,'演示陪玩师订单收入',s.created_at
from pw_order_settlement s join pw_trade_order t on t.id=s.order_id join pw_order_member m on m.order_id=t.id and m.member_status='COMPLETED'
where t.order_no like 'DEMO-P-COMPLETED-%' and not exists(select 1 from pw_order_settlement_detail d where d.settlement_id=s.id and d.order_member_id=m.id and d.detail_type='PLAYER_INCOME');

insert into pw_player_earning(earning_no,order_id,order_member_id,settlement_detail_id,player_id,order_amount,commission_rate,commission_amount,player_amount,earning_status,settled_at,created_at,updated_at)
select concat('ERN-',t.order_no),t.id,m.id,d.id,m.player_id,t.paid_amount,0.28,s.platform_amount,s.distributable_amount,'AVAILABLE',s.settled_at,s.created_at,current_timestamp
from pw_trade_order t join pw_order_member m on m.order_id=t.id join pw_order_settlement s on s.order_id=t.id join pw_order_settlement_detail d on d.settlement_id=s.id and d.order_member_id=m.id and d.detail_type='PLAYER_INCOME'
where t.order_no like 'DEMO-P-COMPLETED-%' and not exists(select 1 from pw_player_earning e where e.order_member_id=m.id);

insert into pw_player_account(player_id,available_balance,frozen_balance,total_income,total_withdrawn,version)
select p.id,0,0,0,0,0 from sys_user u join pw_player p on p.user_id=u.id where u.username='player' and not exists(select 1 from pw_player_account a where a.player_id=p.id);

update pw_player_account a set available_balance=available_balance+(select coalesce(sum(e.player_amount),0) from pw_player_earning e where e.player_id=a.player_id and e.earning_no like 'ERN-DEMO-P-COMPLETED-%'),total_income=total_income+(select coalesce(sum(e.player_amount),0) from pw_player_earning e where e.player_id=a.player_id and e.earning_no like 'ERN-DEMO-P-COMPLETED-%'),updated_at=current_timestamp
where a.player_id=(select p.id from sys_user u join pw_player p on p.user_id=u.id where u.username='player');

update pw_trade_order set completed_at=dateadd('HOUR',4,created_at),updated_at=current_timestamp where order_no like 'DEMO-P-COMPLETED-%';
update pw_player set work_status='BUSY',updated_at=current_timestamp where user_id=(select id from sys_user where username='player');
