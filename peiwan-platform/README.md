# 陪玩平台

> 当前实现进度、启动方式、业务规则、已知限制和后续开发计划，请先阅读 [项目交接文档](docs/PROJECT_HANDOFF.md)。

陪玩平台采用前后端分离架构：

- `admin-web/`：运营管理后台，基于 Art Design Pro。
- `miniapp/`：微信小程序，基于 Uni-app。
- `backend/`：Java 后端，计划采用 Spring Boot、MyBatis-Plus 和 RBAC 权限模型。
- `database/`：MySQL 数据库设计及迁移脚本。
- `docs/`：需求、架构、接口和部署文档。
- `deploy/`：本地及服务器部署配置。

## 技术栈

| 模块 | 技术方案 |
| --- | --- |
| 管理后台 | Art Design Pro / Vue / TypeScript |
| 微信小程序 | Uni-app / Vue / TypeScript |
| 服务端 | Java / Spring Boot |
| 持久层 | MyBatis-Plus |
| 数据库 | MySQL |
| 权限模型 | RBAC |

## 后端业务模块规划

- 用户与微信登录
- RBAC 用户、角色、权限和菜单
- 游戏、区服、商品和规格
- 陪玩入驻、审核、资料和价格
- 订单、抢单、派单和服务履约
- 支付、退款、收益、佣金和提现
- 消息、客服、评价和投诉
- 系统配置、操作日志和数据看板
