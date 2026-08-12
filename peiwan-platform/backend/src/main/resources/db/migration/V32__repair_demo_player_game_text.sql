-- Repair demo player-game text that was persisted as UTF-8 bytes interpreted as Latin-1.
update pw_player_game pg
set server_name='国服',
    server_id=(select s.id from pw_game_server s where s.game_id=pg.game_id and s.server_code='CN')
where pg.player_id in (
  select p.id from pw_player p
  where p.player_no in ('DEMO-PW-001','DEMO-PW-002','DEMO-PW-003','DEMO-PW-004','DEMO-ADMIN-PLAYER')
);

update pw_player_game set rank_name='全面战场王牌', introduction='主打大战场指挥与团队协作'
where player_id=(select id from pw_player where player_no='DEMO-PW-001');

update pw_player_game set rank_name='烽火地带钻石', introduction='熟悉物资点与撤离路线'
where player_id=(select id from pw_player where player_no='DEMO-PW-002');

update pw_player_game set rank_name='神话', introduction='道具配合与排位上分',
  rank_id=(select r.id from pw_game_rank r join pw_game_rank_system s on s.id=r.rank_system_id where s.game_id=pw_player_game.game_id and r.rank_code='IMMORTAL')
where player_id=(select id from pw_player where player_no='DEMO-PW-003');

update pw_player_game set rank_name='超凡', introduction='娱乐匹配与决斗位',
  rank_id=(select r.id from pw_game_rank r join pw_game_rank_system s on s.id=r.rank_system_id where s.game_id=pw_player_game.game_id and r.rank_code='ASCENDANT')
where player_id=(select id from pw_player where player_no='DEMO-PW-004');

update pw_player_game set rank_name='烽火地带黑鹰', introduction='熟悉烽火护航、撤离路线和全面战场指挥'
where player_id=(select id from pw_player where player_no='DEMO-ADMIN-PLAYER')
  and game_id=(select id from pw_game where game_code='delta-force');

update pw_player_game set rank_name='神话', introduction='主玩控场和先锋，支持排位与道具教学',
  rank_id=(select r.id from pw_game_rank r join pw_game_rank_system s on s.id=r.rank_system_id where s.game_id=pw_player_game.game_id and r.rank_code='IMMORTAL')
where player_id=(select id from pw_player where player_no='DEMO-ADMIN-PLAYER')
  and game_id=(select id from pw_game where game_code='valorant');
