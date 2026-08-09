-- 早期演示库曾导入固定主键，先把 H2 自增序列移到安全区间。
alter table pw_product alter column id restart with 1000;
alter table pw_product_sku alter column id restart with 1000;

-- 三角洲行动：按小时服务
insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,status,sort_no)
select g.id,c.id,'delta-warfare-hour','全面战场默契陪玩','按小时组队，沟通指挥更轻松','适合日常组队与连续作战，陪玩师提供报点、路线建议和团队配合。','/uploads/demo/products/delta-escort-experience-cover.png','SERVICE','ON_SALE',3
from pw_game g join pw_product_category c on c.category_code='delta-special'
where g.game_code='delta-force' and not exists(select 1 from pw_product where product_code='delta-warfare-hour');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='delta-warfare'
where p.product_code='delta-warfare-hour' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-warfare-1h','默契陪玩 1 小时',38,45,'HOUR',1,1,6,'UNLIMITED',60,true,1 from pw_product where product_code='delta-warfare-hour' and not exists(select 1 from pw_product_sku where sku_code='delta-warfare-1h');
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-warfare-3h','畅玩陪伴 3 小时',99,135,'HOUR',3,1,2,'UNLIMITED',180,true,2 from pw_product where product_code='delta-warfare-hour' and not exists(select 1 from pw_product_sku where sku_code='delta-warfare-3h');

insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,status,sort_no)
select g.id,c.id,'delta-map-training-hour','三角洲战术跑图教学','地图资源点、撤离路线专项讲解','陪玩师带练常用地图，讲解资源规划、交战判断与安全撤离路线。','/uploads/demo/products/delta-regular-package-cover.png','SERVICE','ON_SALE',4
from pw_game g join pw_product_category c on c.category_code='delta-special'
where g.game_code='delta-force' and not exists(select 1 from pw_product where product_code='delta-map-training-hour');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='delta-map-clear'
where p.product_code='delta-map-training-hour' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-map-training-1h','专项教学 1 小时',68,88,'HOUR',1,1,4,'UNLIMITED',60,true,1 from pw_product where product_code='delta-map-training-hour' and not exists(select 1 from pw_product_sku where sku_code='delta-map-training-1h');
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-map-training-2h','深度教学 2 小时',118,176,'HOUR',2,1,2,'UNLIMITED',120,true,2 from pw_product where product_code='delta-map-training-hour' and not exists(select 1 from pw_product_sku where sku_code='delta-map-training-2h');

-- 三角洲行动：组合套餐
insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,status,sort_no,validity_days,purchase_limit)
select g.id,c.id,'delta-newcomer-package','三角洲新人开荒包','教学陪玩 + 单局护航，一次熟悉流程','从基础操作、地图路线到完成一局撤离，适合首次体验陪玩服务。','/uploads/demo/products/delta-escort-experience-cover.png','PACKAGE','ON_SALE',12,15,2
from pw_game g join pw_product_category c on c.category_code='delta-regular'
where g.game_code='delta-force' and not exists(select 1 from pw_product where product_code='delta-newcomer-package');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='delta-warfare' where p.product_code='delta-newcomer-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'GAME',2 from pw_product p join pw_service_item s on s.service_code='delta-escort' where p.product_code='delta-newcomer-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-newcomer-package-standard','新人开荒套餐',88,128,'ORDER',1,1,2,'UNLIMITED',120,true,1 from pw_product where product_code='delta-newcomer-package' and not exists(select 1 from pw_product_sku where sku_code='delta-newcomer-package-standard');

insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,status,sort_no,validity_days,purchase_limit)
select g.id,c.id,'delta-weekend-package','周末战术畅玩套餐','2 小时战场陪玩 + 2 局撤离护航','适合周末连续开黑，兼顾全面战场团队配合与烽火地带撤离体验。','/uploads/demo/products/delta-regular-package-cover.png','PACKAGE','ON_SALE',13,30,3
from pw_game g join pw_product_category c on c.category_code='delta-regular'
where g.game_code='delta-force' and not exists(select 1 from pw_product where product_code='delta-weekend-package');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,2,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='delta-warfare' where p.product_code='delta-weekend-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,2,'GAME',2 from pw_product p join pw_service_item s on s.service_code='delta-escort' where p.product_code='delta-weekend-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-weekend-package-standard','周末畅玩套餐',159,226,'ORDER',1,1,3,'UNLIMITED',240,true,1 from pw_product where product_code='delta-weekend-package' and not exists(select 1 from pw_product_sku where sku_code='delta-weekend-package-standard');

-- 无畏契约：按小时服务
insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,status,sort_no)
select g.id,c.id,'valorant-casual-hour','无畏契约轻松开黑','娱乐匹配按小时，轻松聊天不压力','适合休闲匹配、练英雄和轻松组队，陪玩师全程沟通配合。','/uploads/demo/products/valorant-ranked-hour-cover.png','SERVICE','ON_SALE',5
from pw_game g join pw_product_category c on c.category_code='valorant-ranked'
where g.game_code='valorant' and not exists(select 1 from pw_product where product_code='valorant-casual-hour');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='valorant-casual' where p.product_code='valorant-casual-hour' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'valorant-casual-1h','轻松开黑 1 小时',39,49,'HOUR',1,1,6,'UNLIMITED',60,true,1 from pw_product where product_code='valorant-casual-hour' and not exists(select 1 from pw_product_sku where sku_code='valorant-casual-1h');
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'valorant-casual-3h','欢乐畅玩 3 小时',99,147,'HOUR',3,1,2,'UNLIMITED',180,true,2 from pw_product where product_code='valorant-casual-hour' and not exists(select 1 from pw_product_sku where sku_code='valorant-casual-3h');

insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,status,sort_no)
select g.id,c.id,'valorant-coaching-hour','无畏契约一对一复盘','枪法、道具与站位按小时指导','根据近期对局进行针对性复盘，讲解英雄理解、道具思路和实战决策。','/uploads/demo/products/valorant-growth-package-cover.png','SERVICE','ON_SALE',6
from pw_game g join pw_product_category c on c.category_code='valorant-training'
where g.game_code='valorant' and not exists(select 1 from pw_product where product_code='valorant-coaching-hour');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='valorant-teaching' where p.product_code='valorant-coaching-hour' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'valorant-coaching-1h','一对一复盘 1 小时',88,108,'HOUR',1,1,4,'UNLIMITED',60,true,1 from pw_product where product_code='valorant-coaching-hour' and not exists(select 1 from pw_product_sku where sku_code='valorant-coaching-1h');
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'valorant-coaching-2h','进阶指导 2 小时',158,216,'HOUR',2,1,2,'UNLIMITED',120,true,2 from pw_product where product_code='valorant-coaching-hour' and not exists(select 1 from pw_product_sku where sku_code='valorant-coaching-2h');

-- 无畏契约：组合套餐
insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,status,sort_no,validity_days,purchase_limit)
select g.id,c.id,'valorant-rank-sprint-package','排位冲刺组合包','2 小时排位陪玩 + 1 小时专项教学','先实战配合，再针对问题进行复盘教学，适合希望稳定提升的玩家。','/uploads/demo/products/valorant-growth-package-cover.png','PACKAGE','ON_SALE',14,15,2
from pw_game g join pw_product_category c on c.category_code='valorant-training'
where g.game_code='valorant' and not exists(select 1 from pw_product where product_code='valorant-rank-sprint-package');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,2,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='valorant-ranked' where p.product_code='valorant-rank-sprint-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'HOUR',2 from pw_product p join pw_service_item s on s.service_code='valorant-teaching' where p.product_code='valorant-rank-sprint-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'valorant-rank-sprint-standard','排位冲刺套餐',148,224,'ORDER',1,1,2,'UNLIMITED',180,true,1 from pw_product where product_code='valorant-rank-sprint-package' and not exists(select 1 from pw_product_sku where sku_code='valorant-rank-sprint-standard');

insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,status,sort_no,validity_days,purchase_limit)
select g.id,c.id,'valorant-friends-night-package','好友夜排欢乐包','3 小时娱乐开黑 + 1 小时排位陪玩','兼顾娱乐氛围与认真排位，适合晚间连续组队。','/uploads/demo/products/valorant-ranked-hour-cover.png','PACKAGE','ON_SALE',15,30,3
from pw_game g join pw_product_category c on c.category_code='valorant-ranked'
where g.game_code='valorant' and not exists(select 1 from pw_product where product_code='valorant-friends-night-package');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,3,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='valorant-casual' where p.product_code='valorant-friends-night-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'HOUR',2 from pw_product p join pw_service_item s on s.service_code='valorant-ranked' where p.product_code='valorant-friends-night-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'valorant-friends-night-standard','好友夜排套餐',129,205,'ORDER',1,1,3,'UNLIMITED',240,true,1 from pw_product where product_code='valorant-friends-night-package' and not exists(select 1 from pw_product_sku where sku_code='valorant-friends-night-standard');
