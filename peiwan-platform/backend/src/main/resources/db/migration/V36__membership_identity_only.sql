update pw_member_level set discount_rate=1;
update pw_member_level set benefit_description='累计充值达到门槛后展示基础会员身份' where level_code='NORMAL';
update pw_member_level set benefit_description='累计充值达到门槛后展示白银会员身份' where level_code='SILVER';
update pw_member_level set benefit_description='累计充值达到门槛后展示黄金会员身份' where level_code='GOLD';
