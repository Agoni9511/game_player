-- Replace the generic ranks created in V29 with game-specific rank ladders.
update pw_game_rank_system
set system_name='烽火地带段位', description='三角洲行动烽火地带排位段位'
where game_id=(select id from pw_game where game_code='delta-force')
  and system_code='DEFAULT';

update pw_game_rank
set rank_code='BLACK_HAWK', rank_name='黑鹰', tier_no=6, sort_no=6
where rank_system_id=(
  select s.id from pw_game_rank_system s
  join pw_game g on g.id=s.game_id
  where g.game_code='delta-force' and s.system_code='DEFAULT'
) and rank_code='MASTER';

update pw_game_rank
set rank_code='DELTA_PEAK', rank_name='三角洲巅峰', tier_no=7, sort_no=7
where rank_system_id=(
  select s.id from pw_game_rank_system s
  join pw_game g on g.id=s.game_id
  where g.game_code='delta-force' and s.system_code='DEFAULT'
) and rank_code='TOP';

update pw_game_rank_system
set system_name='竞技模式段位', description='无畏契约竞技模式排位段位'
where game_id=(select id from pw_game where game_code='valorant')
  and system_code='DEFAULT';

update pw_game_rank
set rank_code='IMMORTAL', rank_name='神话', tier_no=8, sort_no=8
where rank_system_id=(
  select s.id from pw_game_rank_system s
  join pw_game g on g.id=s.game_id
  where g.game_code='valorant' and s.system_code='DEFAULT'
) and rank_code='MASTER';

update pw_game_rank
set rank_code='RADIANT', rank_name='赋能战魂', tier_no=9, sort_no=9
where rank_system_id=(
  select s.id from pw_game_rank_system s
  join pw_game g on g.id=s.game_id
  where g.game_code='valorant' and s.system_code='DEFAULT'
) and rank_code='TOP';

insert into pw_game_rank(rank_system_id,rank_code,rank_name,tier_no,sort_no,enabled)
select s.id,'IRON','黑铁',1,1,true
from pw_game_rank_system s
join pw_game g on g.id=s.game_id
where g.game_code='valorant' and s.system_code='DEFAULT'
  and not exists (
    select 1 from pw_game_rank r
    where r.rank_system_id=s.id and r.rank_code='IRON'
  );

insert into pw_game_rank(rank_system_id,rank_code,rank_name,tier_no,sort_no,enabled)
select s.id,'ASCENDANT','超凡',7,7,true
from pw_game_rank_system s
join pw_game g on g.id=s.game_id
where g.game_code='valorant' and s.system_code='DEFAULT'
  and not exists (
    select 1 from pw_game_rank r
    where r.rank_system_id=s.id and r.rank_code='ASCENDANT'
  );

update pw_game_rank
set tier_no=case rank_code
    when 'IRON' then 1 when 'BRONZE' then 2 when 'SILVER' then 3
    when 'GOLD' then 4 when 'PLATINUM' then 5 when 'DIAMOND' then 6
    when 'ASCENDANT' then 7 when 'IMMORTAL' then 8 when 'RADIANT' then 9
  end,
  sort_no=case rank_code
    when 'IRON' then 1 when 'BRONZE' then 2 when 'SILVER' then 3
    when 'GOLD' then 4 when 'PLATINUM' then 5 when 'DIAMOND' then 6
    when 'ASCENDANT' then 7 when 'IMMORTAL' then 8 when 'RADIANT' then 9
  end
where rank_system_id=(
  select s.id from pw_game_rank_system s
  join pw_game g on g.id=s.game_id
  where g.game_code='valorant' and s.system_code='DEFAULT'
)
and rank_code in ('IRON','BRONZE','SILVER','GOLD','PLATINUM','DIAMOND','ASCENDANT','IMMORTAL','RADIANT');
