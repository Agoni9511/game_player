update pw_player_game
set audit_status='APPROVED', updated_at=current_timestamp
where audit_status<>'APPROVED'
  and player_id in (select id from pw_player where audit_status='APPROVED' and enabled=true);
