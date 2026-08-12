insert into pw_customer_game_profile(user_id,game_id,server_id,game_account,game_nickname,is_default,enabled)
select u.id,g.id,(select min(s.id) from pw_game_server s where s.game_id=g.id and s.enabled=true),
       'customer-delta','凌竞测试玩家',true,true
from sys_user u cross join pw_game g
where u.username='customer' and g.game_code='delta-force'
  and not exists(select 1 from pw_customer_game_profile p where p.user_id=u.id and p.game_id=g.id);

insert into pw_customer_game_profile(user_id,game_id,server_id,game_account,game_nickname,is_default,enabled)
select u.id,g.id,(select min(s.id) from pw_game_server s where s.game_id=g.id and s.enabled=true),
       'customer-valorant','凌竞测试玩家',true,true
from sys_user u cross join pw_game g
where u.username='customer' and g.game_code='valorant'
  and not exists(select 1 from pw_customer_game_profile p where p.user_id=u.id and p.game_id=g.id);

insert into pw_customer_game_rank(profile_id,rank_system_id,rank_id)
select p.id,rs.id,r.id
from pw_customer_game_profile p
join sys_user u on u.id=p.user_id and u.username='customer'
join pw_game_rank_system rs on rs.game_id=p.game_id and rs.system_code='DEFAULT'
join pw_game_rank r on r.rank_system_id=rs.id and r.rank_code='GOLD'
where not exists(select 1 from pw_customer_game_rank x where x.profile_id=p.id and x.rank_system_id=rs.id);

update sys_user set phone='13800000000'
where username='customer' and coalesce(phone,'')='';
