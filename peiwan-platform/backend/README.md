# Java 后端

本目录用于 Java 服务端。

建议技术栈：

- Java 21
- Spring Boot 3.x
- Spring Security
- MyBatis-Plus
- MySQL 8.x
- Redis（订单锁、验证码、登录态及热点缓存）
- Sa-Token 或 Spring Security JWT（二选一）
- Knife4j / OpenAPI

## 推荐模块

- `platform-common`：公共组件、异常、返回对象和工具类。
- `platform-auth`：微信登录、后台登录、Token 和 RBAC 鉴权。
- `platform-system`：用户、角色、权限、菜单、字典和日志。
- `platform-catalog`：游戏、区服、商品、规格和价格。
- `platform-player`：陪玩入驻、审核、资料、排班和服务报价。
- `platform-order`：下单、抢单、派单、履约、取消和售后。
- `platform-payment`：微信支付、退款、佣金、收益和提现。
- `platform-message`：订单消息、客服、评价和投诉。

权限模型统一使用 RBAC：用户关联角色，角色关联权限和菜单。
