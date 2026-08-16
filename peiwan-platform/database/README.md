# MySQL 数据库

推荐数据库名：`peiwan_platform`，与后端的 `application-mysql.yml` 默认配置一致。

## 服务器初始化

先在 MySQL 8.0+ 服务器上执行：

```bash
mysql -u root -p < database/00_create_database.sql
mysql -u root -p < database/01_full_schema.sql
mysql -u root -p < database/02_seed_menu_data.sql
```

生产环境建议取消 `00_create_database.sql` 中应用账号相关语句的注释，替换强密码，
并把账号允许登录的主机从 `%` 收紧为后端服务器固定 IP。

`01_full_schema.sql` 是可以直接执行的 MySQL 8 全量表结构，共 71 张业务表，覆盖系统用户、
RBAC、游戏配置、陪玩师、商品、交易订单、支付、派单、履约、售后、会员、钱包、充值、
结算、提现和财务流水。脚本不包含演示业务数据，也不会写入默认明文密码。

`02_seed_menu_data.sql` 初始化当前后台的全部菜单、按钮权限和角色授权：142 条菜单/权限，
其中 `admin` 授权 142 条、`customer` 授权 12 条、`player` 授权 14 条。该脚本可以重复执行。

## 完整业务表与后续升级

业务表的唯一结构来源是后端 Flyway 迁移目录：

`backend/src/main/resources/db/migration/`

现有 Flyway 文件同时承担开发环境 H2 建库和演示数据初始化。完整上线前应继续制作并验证
MySQL 专用的增量迁移，不能把现有文件直接、乱序粘贴到生产库。`01_full_schema.sql` 与 Flyway
初始化属于两种建库方式，不应在同一个空库中混用。

后端连接 MySQL 的环境变量如下：

```powershell
$env:SPRING_PROFILES_ACTIVE = "mysql"
$env:DB_URL = "jdbc:mysql://数据库地址:3306/peiwan_platform?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai"
$env:DB_USERNAME = "peiwan_app"
$env:DB_PASSWORD = "你的强密码"
$env:ADMIN_INITIAL_PASSWORD = "管理员初始强密码"
$env:SPRING_FLYWAY_ENABLED = "false" # 使用全量建表脚本初始化时关闭
java -jar backend/target/platform-backend-0.1.0.jar
```

如果使用全量建表脚本，应设置 `$env:SPRING_FLYWAY_ENABLED = "false"`；待 MySQL 专用增量
迁移准备好后再恢复 Flyway。可用以下 SQL 检查建库结果：

```sql
USE `peiwan_platform`;
SHOW TABLES;
SELECT COUNT(*) AS menu_count FROM `sys_menu`;
SELECT r.`code`, COUNT(*) AS permission_count
FROM `sys_role_menu` rm
JOIN `sys_role` r ON r.`id` = rm.`role_id`
GROUP BY r.`code`;
SHOW CREATE TABLE `sys_user`;
SHOW CREATE TABLE `pw_trade_order`;
```

预期 `SHOW TABLES` 返回 71 张业务表，`menu_count` 返回 142。
