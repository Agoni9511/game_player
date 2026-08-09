update pw_player
set nickname='北极星',
    introduction='三角洲行动全面战场指挥，熟悉地图轮转与载具配合。',
    updated_at=current_timestamp
where player_no='DEMO-PW-001';

update pw_player
set nickname='小熊突击手',
    introduction='烽火地带跑图与物资规划，节奏稳定，支持新手教学。',
    updated_at=current_timestamp
where player_no='DEMO-PW-002';

update pw_player
set nickname='夜航',
    introduction='无畏契约主玩控场与先锋，擅长报点、道具教学。',
    updated_at=current_timestamp
where player_no='DEMO-PW-003';

update pw_player
set nickname='糖果枪手',
    introduction='无畏契约娱乐陪玩，主玩决斗，氛围轻松。',
    updated_at=current_timestamp
where player_no='DEMO-PW-004';
