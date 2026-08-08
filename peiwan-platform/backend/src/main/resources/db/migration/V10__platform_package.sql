alter table pw_product add column validity_days integer;
alter table pw_product add column purchase_limit integer;
alter table pw_product_service add column service_quantity decimal(10,2) not null default 1;
alter table pw_product_service add column unit_type varchar(32) not null default 'ORDER';
alter table pw_product_service add column sort_no integer not null default 0;
alter table pw_product_sku add column market_price decimal(12,2);

insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,product_type,status,sort_no,validity_days,purchase_limit)
select g.id,c.id,'delta-regular-package','三角洲常规护航套餐','陪玩指挥 + 撤离护航组合服务','适合需要连续体验全面战场与烽火地带的用户','PACKAGE','ON_SALE',10,30,3 from pw_game g join pw_product_category c on c.category_code='delta-regular' where g.game_code='delta-force' and not exists(select 1 from pw_product where product_code='delta-regular-package');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no) select p.id,s.id,2,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='delta-warfare' where p.product_code='delta-regular-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no) select p.id,s.id,2,'GAME',2 from pw_product p join pw_service_item s on s.service_code='delta-escort' where p.product_code='delta-regular-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no) select id,'delta-regular-package-standard','常规套餐',198,256,'ORDER',1,1,3,'UNLIMITED',240,true,1 from pw_product where product_code='delta-regular-package' and not exists(select 1 from pw_product_sku where sku_code='delta-regular-package-standard');

insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,product_type,status,sort_no,validity_days,purchase_limit)
select g.id,c.id,'valorant-growth-package','无畏契约进阶套餐','排位实战 + 针对性教学','包含排位陪玩、枪法和道具复盘教学','PACKAGE','ON_SALE',11,15,2 from pw_game g join pw_product_category c on c.category_code='valorant-training' where g.game_code='valorant' and not exists(select 1 from pw_product where product_code='valorant-growth-package');
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no) select p.id,s.id,2,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='valorant-ranked' where p.product_code='valorant-growth-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no) select p.id,s.id,1,'HOUR',2 from pw_product p join pw_service_item s on s.service_code='valorant-teaching' where p.product_code='valorant-growth-package' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no) select id,'valorant-growth-package-standard','进阶套餐',168,210,'ORDER',1,1,2,'UNLIMITED',180,true,1 from pw_product where product_code='valorant-growth-package' and not exists(select 1 from pw_product_sku where sku_code='valorant-growth-package-standard');
