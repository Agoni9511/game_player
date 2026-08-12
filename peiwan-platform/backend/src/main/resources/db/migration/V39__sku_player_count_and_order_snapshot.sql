alter table pw_product_sku add column player_count integer not null default 1;
alter table pw_product_sku add column price_type varchar(20) not null default 'PER_PLAYER';

alter table pw_order add column required_player_count integer not null default 1;
alter table pw_order add column sku_price_type varchar(20) not null default 'PER_PLAYER';
alter table pw_order add column base_unit_price decimal(14,2);

update pw_product_sku set price_type='FIXED_TOTAL'
where product_id in(select id from pw_product where product_type='PACKAGE');

update pw_order set base_unit_price=(select min(i.unit_price) from pw_order_item i where i.order_id=pw_order.id)
where base_unit_price is null;
