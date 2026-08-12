-- Regular service products use game-scoped player-level pricing. SKU price is the PRO fallback.

insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,pricing_mode,status,sort_no)
select g.id,c.id,'delta-beacon-escort','烽火地带撤离护航','按局下单，物资规划与安全撤离','适合烽火地带搜打撤场景，陪玩师提供路线规划、交战判断、物资分配与撤离护航。','/uploads/demo/products/delta-escort-experience-cover.png','SERVICE','PLAYER_LEVEL','ON_SALE',21
from pw_game g join pw_product_category c on c.game_id=g.id and c.category_code='delta-single'
where g.game_code='delta-force' and not exists(select 1 from pw_product where product_code='delta-beacon-escort');

insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'GAME',1 from pw_product p join pw_service_item s on s.service_code='delta-escort'
where p.product_code='delta-beacon-escort' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);

insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-beacon-escort-1g','撤离护航 1 局',89,109,'GAME',1,1,5,'UNLIMITED',60,true,1 from pw_product where product_code='delta-beacon-escort' and not exists(select 1 from pw_product_sku where sku_code='delta-beacon-escort-1g');
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-beacon-escort-3g','连续护航 3 局',249,309,'GAME',3,1,2,'UNLIMITED',180,true,2 from pw_product where product_code='delta-beacon-escort' and not exists(select 1 from pw_product_sku where sku_code='delta-beacon-escort-3g');
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-beacon-escort-5g','深度护航 5 局',399,499,'GAME',5,1,1,'UNLIMITED',300,true,3 from pw_product where product_code='delta-beacon-escort' and not exists(select 1 from pw_product_sku where sku_code='delta-beacon-escort-5g');

insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,pricing_mode,status,sort_no)
select g.id,c.id,'delta-map-clear-order','三角洲清图专项','指定地图按局服务，路线更熟练','针对指定地图提供资源点讲解、任务路线规划和清图协作，适合补任务与熟悉地图。','/uploads/demo/products/delta-regular-package-cover.png','SERVICE','PLAYER_LEVEL','ON_SALE',22
from pw_game g join pw_product_category c on c.game_id=g.id and c.category_code='delta-special'
where g.game_code='delta-force' and not exists(select 1 from pw_product where product_code='delta-map-clear-order');

insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'GAME',1 from pw_product p join pw_service_item s on s.service_code='delta-map-clear'
where p.product_code='delta-map-clear-order' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);

insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-map-clear-1g','专项清图 1 局',79,99,'GAME',1,1,4,'UNLIMITED',60,true,1 from pw_product where product_code='delta-map-clear-order' and not exists(select 1 from pw_product_sku where sku_code='delta-map-clear-1g');
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'delta-map-clear-3g','专项清图 3 局',219,279,'GAME',3,1,2,'UNLIMITED',180,true,2 from pw_product where product_code='delta-map-clear-order' and not exists(select 1 from pw_product_sku where sku_code='delta-map-clear-3g');

insert into pw_product(game_id,category_id,product_code,product_name,subtitle,description,cover_url,product_type,pricing_mode,status,sort_no)
select g.id,c.id,'valorant-ranked-companion','无畏契约竞技陪玩','按时长组队，稳定沟通配合','适合竞技模式双排或组队，陪玩师根据等级提供报点、道具配合和阵容建议。','/uploads/demo/products/valorant-ranked-hour-cover.png','SERVICE','PLAYER_LEVEL','ON_SALE',23
from pw_game g join pw_product_category c on c.game_id=g.id and c.category_code='valorant-ranked'
where g.game_code='valorant' and not exists(select 1 from pw_product where product_code='valorant-ranked-companion');

insert into pw_product_service(product_id,service_id,service_quantity,unit_type,sort_no)
select p.id,s.id,1,'HOUR',1 from pw_product p join pw_service_item s on s.service_code='valorant-ranked'
where p.product_code='valorant-ranked-companion' and not exists(select 1 from pw_product_service x where x.product_id=p.id and x.service_id=s.id);

insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'valorant-ranked-companion-1h','竞技陪玩 1 小时',58,72,'HOUR',1,1,6,'UNLIMITED',60,true,1 from pw_product where product_code='valorant-ranked-companion' and not exists(select 1 from pw_product_sku where sku_code='valorant-ranked-companion-1h');
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'valorant-ranked-companion-2h','竞技陪玩 2 小时',109,144,'HOUR',2,1,3,'UNLIMITED',120,true,2 from pw_product where product_code='valorant-ranked-companion' and not exists(select 1 from pw_product_sku where sku_code='valorant-ranked-companion-2h');
insert into pw_product_sku(product_id,sku_code,sku_name,price,market_price,unit_type,unit_count,min_quantity,max_quantity,stock_mode,service_minutes,enabled,sort_no)
select id,'valorant-ranked-companion-3h','竞技陪玩 3 小时',159,216,'HOUR',3,1,2,'UNLIMITED',180,true,3 from pw_product where product_code='valorant-ranked-companion' and not exists(select 1 from pw_product_sku where sku_code='valorant-ranked-companion-3h');

insert into pw_sku_level_price(sku_id,player_level_id,price,market_price,enabled)
select k.id,l.id,
  case k.sku_code
    when 'delta-beacon-escort-1g' then case l.level_code when 'STARTER' then 69 when 'MASTER' then 129 else 89 end
    when 'delta-beacon-escort-3g' then case l.level_code when 'STARTER' then 189 when 'MASTER' then 369 else 249 end
    when 'delta-beacon-escort-5g' then case l.level_code when 'STARTER' then 299 when 'MASTER' then 599 else 399 end
    when 'delta-map-clear-1g' then case l.level_code when 'STARTER' then 59 when 'MASTER' then 119 else 79 end
    when 'delta-map-clear-3g' then case l.level_code when 'STARTER' then 159 when 'MASTER' then 329 else 219 end
    when 'valorant-ranked-companion-1h' then case l.level_code when 'STARTER' then 42 when 'MASTER' then 88 else 58 end
    when 'valorant-ranked-companion-2h' then case l.level_code when 'STARTER' then 79 when 'MASTER' then 168 else 109 end
    when 'valorant-ranked-companion-3h' then case l.level_code when 'STARTER' then 115 when 'MASTER' then 248 else 159 end
  end,
  k.market_price,true
from pw_product_sku k
join pw_product p on p.id=k.product_id
join pw_player_level l on l.game_id=p.game_id and l.level_code in('STARTER','PRO','MASTER') and l.enabled=true
where k.sku_code in('delta-beacon-escort-1g','delta-beacon-escort-3g','delta-beacon-escort-5g','delta-map-clear-1g','delta-map-clear-3g','valorant-ranked-companion-1h','valorant-ranked-companion-2h','valorant-ranked-companion-3h')
  and not exists(select 1 from pw_sku_level_price x where x.sku_id=k.id and x.player_level_id=l.id);
