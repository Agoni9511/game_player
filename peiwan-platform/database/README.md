# MySQL 数据库

后端默认连接数据库 `peiwan_platform`，数据库配置见
`backend/src/main/resources/application-mysql.yml`。

## 现有服务器数据库更新

服务器上的 MySQL 数据库已经存在并具备 V51 表结构，因此不再执行全量建库脚本，
依次执行业务数据和客服工单两个增量：

```bash
mysql --default-character-set=utf8mb4 -u root -p peiwan_platform < database/03_incremental_business_data.sql
mysql --default-character-set=utf8mb4 -u root -p peiwan_platform < database/04_customer_service_ticket.sql
```

该增量包含：

- 10 个测试用户，其中 5 个绑定陪玩师；
- 45 个陪玩师标签；
- 无畏契约、三角洲行动及 COS 图片、区服、位置和段位体系；
- 4 个充值套餐。
- 客服工单、会话消息表，以及管理端菜单权限。

脚本按业务编码幂等写入，可以重复执行；测试账号密码统一为 `123456`。

## 后端连接配置

后端默认启用 MySQL Profile。部署时通过环境变量提供服务器数据库连接和生产密码：

```powershell
$env:DB_URL = "jdbc:mysql://数据库地址:3306/peiwan_platform?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai"
$env:DB_USERNAME = "peiwan_app"
$env:DB_PASSWORD = "你的强密码"
$env:ADMIN_INITIAL_PASSWORD = "管理员强密码"
java -jar backend/target/platform-backend-0.1.0.jar
```

后端不再集成 Flyway，启动时不会自动重建或修改服务器表结构。后续结构变化应提供独立、
可审查和可回滚的 MySQL 增量 SQL。

## 更新结果检查

```sql
USE `peiwan_platform`;

SELECT COUNT(*) AS test_user_count
FROM `sys_user`
WHERE `username` REGEXP '^user(0[1-9]|10)$';

SELECT `game_code`, `game_name`
FROM `pw_game`
WHERE `game_code` IN ('delta-force', 'valorant');

SELECT `plan_code`, `plan_name`
FROM `pw_recharge_plan`
WHERE `plan_code` LIKE 'RECHARGE_%';
```
