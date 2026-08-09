update pw_game
set icon_url='/uploads/demo/games/delta-force-icon.png',
    cover_url='/uploads/demo/games/delta-force-cover.png',
    updated_at=current_timestamp
where game_code='delta-force';

update pw_game
set icon_url='/uploads/demo/games/valorant-icon.png',
    cover_url='/uploads/demo/games/valorant-cover.png',
    updated_at=current_timestamp
where game_code='valorant';

update pw_product_category
set icon_url='/uploads/demo/categories/delta-category-icon.png',
    updated_at=current_timestamp
where category_code='delta-category';

update pw_product_category
set icon_url='/uploads/demo/categories/delta-regular-icon.png',
    updated_at=current_timestamp
where category_code='delta-regular';

update pw_product_category
set icon_url='/uploads/demo/categories/delta-single-icon.png',
    updated_at=current_timestamp
where category_code='delta-single';

update pw_product_category
set icon_url='/uploads/demo/categories/delta-special-icon.png',
    updated_at=current_timestamp
where category_code='delta-special';

update pw_product_category
set icon_url='/uploads/demo/categories/valorant-category-icon.png',
    updated_at=current_timestamp
where category_code='valorant-category';

update pw_product_category
set icon_url='/uploads/demo/categories/valorant-ranked-icon.png',
    updated_at=current_timestamp
where category_code='valorant-ranked';

update pw_product_category
set icon_url='/uploads/demo/categories/valorant-training-icon.png',
    updated_at=current_timestamp
where category_code='valorant-training';

update pw_product
set cover_url='/uploads/demo/products/delta-escort-experience-cover.png',
    updated_at=current_timestamp
where product_code='delta-escort-experience';

update pw_product
set cover_url='/uploads/demo/products/delta-regular-package-cover.png',
    updated_at=current_timestamp
where product_code='delta-regular-package';

update pw_product
set cover_url='/uploads/demo/products/valorant-ranked-hour-cover.png',
    updated_at=current_timestamp
where product_code='valorant-ranked-hour';

update pw_product
set cover_url='/uploads/demo/products/valorant-growth-package-cover.png',
    updated_at=current_timestamp
where product_code='valorant-growth-package';

update pw_player
set avatar_url='/uploads/demo/players/DEMO-PW-001-avatar.png',
    updated_at=current_timestamp
where player_no='DEMO-PW-001';

update pw_player
set avatar_url='/uploads/demo/players/DEMO-PW-002-avatar.png',
    updated_at=current_timestamp
where player_no='DEMO-PW-002';

update pw_player
set avatar_url='/uploads/demo/players/DEMO-PW-003-avatar.png',
    updated_at=current_timestamp
where player_no='DEMO-PW-003';

update pw_player
set avatar_url='/uploads/demo/players/DEMO-PW-004-avatar.png',
    updated_at=current_timestamp
where player_no='DEMO-PW-004';

update pw_player
set avatar_url='/uploads/demo/players/DEMO-PW-005-avatar.png',
    updated_at=current_timestamp
where player_no='DEMO-PW-005';

update pw_player
set avatar_url='/uploads/demo/players/DEMO-ADMIN-PLAYER-avatar.png',
    cover_url='/uploads/demo/players/DEMO-ADMIN-PLAYER-cover.png',
    updated_at=current_timestamp
where player_no='DEMO-ADMIN-PLAYER';

update sys_user
set avatar='/uploads/demo/players/DEMO-ADMIN-PLAYER-avatar.png',
    updated_at=current_timestamp
where username='admin';
