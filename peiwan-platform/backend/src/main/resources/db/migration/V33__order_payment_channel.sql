alter table pw_order_payment add column payment_channel varchar(24) not null default 'BALANCE';
update pw_order_payment set payment_channel='BALANCE' where payment_channel is null;
