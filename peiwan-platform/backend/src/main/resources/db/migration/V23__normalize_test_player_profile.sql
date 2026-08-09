update sys_user
set nickname='陪玩师测试账号', updated_at=current_timestamp
where username='player';

update pw_player
set nickname='陪玩师测试账号', updated_at=current_timestamp
where user_id=(select id from sys_user where username='player');
