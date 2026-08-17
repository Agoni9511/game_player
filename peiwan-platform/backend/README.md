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

## 文件存储

默认使用本地目录 `./data/uploads`。后端会依次加载资源目录中的
`src/main/resources/application-private.yml` 和部署目录下的
`config/application-private.yml`，两处文件均已被 Git 忽略，外部配置优先级更高。
资源目录模板集中保存 MySQL、管理员、JWT 和 COS 配置；填写后重新打包，原有
`POST /api/file/upload` 接口会切换到腾讯云 COS。

部署环境也可以使用以下环境变量覆盖配置：

```powershell
$env:STORAGE_TYPE = 'cos'
$env:COS_SECRET_ID = 'CAM 子账号 SecretId'
$env:COS_SECRET_KEY = 'CAM 子账号 SecretKey'
$env:COS_BUCKET = 'bucket-name-APPID'
$env:COS_REGION = 'ap-guangzhou'
$env:COS_PUBLIC_BASE_URL = 'https://bucket-name-APPID.cos.ap-guangzhou.myqcloud.com'
$env:COS_PREFIX = 'peiwan'
```

`COS_PUBLIC_BASE_URL` 可省略，系统会根据 Bucket 和 Region 生成默认 HTTPS 域名。
密钥只能通过环境变量或部署平台的密钥管理注入，不得写入配置文件或提交到 Git。
