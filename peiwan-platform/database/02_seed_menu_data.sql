-- 陪玩平台系统菜单、按钮权限及角色授权（MySQL 8.0+）
-- 执行顺序：00_create_database.sql -> 01_full_schema.sql -> 02_seed_menu_data.sql

USE `peiwan_platform`;
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO `sys_menu` (`id`,`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`) VALUES
  (1,NULL,'DIRECTORY','Business','/business','/index/index','业务管理','ri:briefcase-4-line',NULL,24,1,1,0,'2026-08-09 16:53:52.712745','2026-08-11 01:40:22.11102'),
  (2,164,'MENU','Player','player','/business/player','陪玩师管理','ri:user-star-line',NULL,1,0,1,0,'2026-08-09 16:53:52.713745','2026-08-11 01:40:22.12602'),
  (3,161,'MENU','Game','game','/business/game','游戏管理','ri:gamepad-line',NULL,1,0,1,0,'2026-08-09 16:53:52.713745','2026-08-11 01:40:22.11202'),
  (4,161,'MENU','PlayerTag','player-tag','/business/player-tag','陪玩师标签','ri:price-tag-3-line',NULL,2,0,1,0,'2026-08-09 16:53:52.713745','2026-08-11 01:40:22.11202'),
  (5,2,'BUTTON','PlayerList',NULL,NULL,'查询陪玩师',NULL,'business:player:list',1,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (6,2,'BUTTON','PlayerCreate',NULL,NULL,'新增陪玩师',NULL,'business:player:create',2,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (7,2,'BUTTON','PlayerUpdate',NULL,NULL,'编辑陪玩师',NULL,'business:player:update',3,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (8,2,'BUTTON','PlayerStatus',NULL,NULL,'修改陪玩师状态',NULL,'business:player:status',4,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (9,2,'BUTTON','PlayerAudit',NULL,NULL,'审核陪玩师',NULL,'business:player:audit',5,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (10,2,'BUTTON','PlayerDetail',NULL,NULL,'管理陪玩师资料',NULL,'business:player:detail',6,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (11,3,'BUTTON','GameList',NULL,NULL,'查询游戏',NULL,'business:game:list',1,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (12,3,'BUTTON','GameCreate',NULL,NULL,'新增游戏',NULL,'business:game:create',2,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (13,3,'BUTTON','GameUpdate',NULL,NULL,'编辑游戏',NULL,'business:game:update',3,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (14,3,'BUTTON','GameStatus',NULL,NULL,'修改游戏状态',NULL,'business:game:status',4,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (15,3,'BUTTON','GameDelete',NULL,NULL,'删除游戏',NULL,'business:game:delete',5,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (16,4,'BUTTON','PlayerTagList',NULL,NULL,'查询标签',NULL,'business:player-tag:list',1,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (17,4,'BUTTON','PlayerTagCreate',NULL,NULL,'新增标签',NULL,'business:player-tag:create',2,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (18,4,'BUTTON','PlayerTagUpdate',NULL,NULL,'编辑标签',NULL,'business:player-tag:update',3,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (19,4,'BUTTON','PlayerTagDelete',NULL,NULL,'删除标签',NULL,'business:player-tag:delete',4,0,1,0,'2026-08-09 16:53:52.722377','2026-08-09 16:53:52.722377'),
  (20,3,'BUTTON','GamePositionList',NULL,NULL,'查询游戏位置',NULL,'business:game-position:list',6,0,1,0,'2026-08-09 16:53:52.724337','2026-08-09 16:53:52.724337'),
  (21,3,'BUTTON','GamePositionCreate',NULL,NULL,'新增游戏位置',NULL,'business:game-position:create',7,0,1,0,'2026-08-09 16:53:52.724337','2026-08-09 16:53:52.724337'),
  (22,3,'BUTTON','GamePositionUpdate',NULL,NULL,'编辑游戏位置',NULL,'business:game-position:update',8,0,1,0,'2026-08-09 16:53:52.724337','2026-08-09 16:53:52.724337'),
  (23,3,'BUTTON','GamePositionDelete',NULL,NULL,'删除游戏位置',NULL,'business:game-position:delete',9,0,1,0,'2026-08-09 16:53:52.724337','2026-08-09 16:53:52.724337'),
  (24,161,'MENU','ProductCategory','product-category','/business/product-category','商品分类','ri:folder-chart-line',NULL,3,0,1,0,'2026-08-09 16:53:52.77067','2026-08-11 01:40:22.11302'),
  (25,161,'MENU','ServiceItem','service-item','/business/service-item','基础服务','ri:service-line',NULL,4,0,1,0,'2026-08-09 16:53:52.77067','2026-08-11 01:40:22.11402'),
  (26,24,'BUTTON','ProductCategoryList',NULL,NULL,'查询商品分类',NULL,'business:product-category:list',1,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (27,24,'BUTTON','ProductCategoryCreate',NULL,NULL,'新增商品分类',NULL,'business:product-category:create',2,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (28,24,'BUTTON','ProductCategoryUpdate',NULL,NULL,'编辑商品分类',NULL,'business:product-category:update',3,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (29,24,'BUTTON','ProductCategoryStatus',NULL,NULL,'修改分类状态',NULL,'business:product-category:status',4,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (30,24,'BUTTON','ProductCategoryDelete',NULL,NULL,'删除商品分类',NULL,'business:product-category:delete',5,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (31,25,'BUTTON','ServiceItemList',NULL,NULL,'查询基础服务',NULL,'business:service:list',1,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (32,25,'BUTTON','ServiceItemCreate',NULL,NULL,'新增基础服务',NULL,'business:service:create',2,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (33,25,'BUTTON','ServiceItemUpdate',NULL,NULL,'编辑基础服务',NULL,'business:service:update',3,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (34,25,'BUTTON','ServiceItemStatus',NULL,NULL,'修改服务状态',NULL,'business:service:status',4,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (35,25,'BUTTON','ServiceItemDelete',NULL,NULL,'删除基础服务',NULL,'business:service:delete',5,0,1,0,'2026-08-09 16:53:52.77067','2026-08-09 16:53:52.77067'),
  (36,162,'MENU','ProductManage','product-manage','/business/product-manage','商品管理','ri:shopping-bag-3-line',NULL,1,0,1,0,'2026-08-09 16:53:52.786294','2026-08-11 01:40:22.11602'),
  (37,36,'BUTTON','ProductManageList',NULL,NULL,'查询商品',NULL,'business:product:list',1,0,1,0,'2026-08-09 16:53:52.786294','2026-08-09 16:53:52.786294'),
  (38,36,'BUTTON','ProductManageCreate',NULL,NULL,'新增商品',NULL,'business:product:create',2,0,1,0,'2026-08-09 16:53:52.786294','2026-08-09 16:53:52.786294'),
  (39,36,'BUTTON','ProductManageUpdate',NULL,NULL,'编辑商品',NULL,'business:product:update',3,0,1,0,'2026-08-09 16:53:52.786294','2026-08-09 16:53:52.786294'),
  (40,36,'BUTTON','ProductManageStatus',NULL,NULL,'商品上下架',NULL,'business:product:status',4,0,1,0,'2026-08-09 16:53:52.786294','2026-08-09 16:53:52.786294'),
  (41,36,'BUTTON','ProductManageDelete',NULL,NULL,'删除商品',NULL,'business:product:delete',5,0,1,0,'2026-08-09 16:53:52.786294','2026-08-09 16:53:52.786294'),
  (42,163,'MENU','OrderManage','order-manage','/business/order-manage','订单管理','ri:file-list-3-line',NULL,1,0,1,0,'2026-08-09 16:53:52.833163','2026-08-11 01:40:22.121022'),
  (43,42,'BUTTON','OrderManageList',NULL,NULL,'查询订单',NULL,'business:order:list',1,0,1,0,'2026-08-09 16:53:52.833163','2026-08-09 16:53:52.833163'),
  (44,42,'BUTTON','OrderManageCreate',NULL,NULL,'创建订单',NULL,'business:order:create',2,0,1,0,'2026-08-09 16:53:52.833163','2026-08-09 16:53:52.833163'),
  (45,42,'BUTTON','OrderManageStatus',NULL,NULL,'订单状态流转',NULL,'business:order:status',3,0,1,0,'2026-08-09 16:53:52.833163','2026-08-09 16:53:52.833163'),
  (46,42,'BUTTON','OrderManageAssign',NULL,NULL,'订单派单',NULL,'business:order:assign',4,0,1,0,'2026-08-09 16:53:52.833163','2026-08-09 16:53:52.833163'),
  (47,163,'MENU','DispatchManage','dispatch-manage','/business/dispatch-manage','派单任务','ri:route-line',NULL,2,0,1,0,'2026-08-09 16:53:52.848788','2026-08-11 01:40:22.124023'),
  (48,47,'BUTTON','DispatchManageList',NULL,NULL,'查询派单任务',NULL,'business:dispatch:list',1,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (49,47,'BUTTON','DispatchManageCreate',NULL,NULL,'发起或重新派单',NULL,'business:dispatch:create',2,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (50,47,'BUTTON','DispatchManageRespond',NULL,NULL,'模拟接受或拒绝',NULL,'business:dispatch:respond',3,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (51,47,'BUTTON','DispatchManageCancel',NULL,NULL,'取消派单任务',NULL,'business:dispatch:cancel',4,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (52,NULL,'DIRECTORY','PlayerPortal','/player','/index/index','陪玩师中心','ri:customer-service-2-line',NULL,30,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (53,52,'MENU','PlayerWorkbench','workbench','/player/workbench','接单工作台','ri:dashboard-3-line',NULL,1,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (54,53,'BUTTON','PlayerWorkbenchView',NULL,NULL,'查看工作台',NULL,'player:workbench:view',1,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (55,53,'BUTTON','PlayerWorkbenchStatus',NULL,NULL,'切换接单状态',NULL,'player:work-status:update',2,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (56,53,'BUTTON','PlayerWorkbenchDispatchList',NULL,NULL,'查看待响应派单',NULL,'player:dispatch:list',3,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (57,53,'BUTTON','PlayerWorkbenchDispatchAccept',NULL,NULL,'接受派单',NULL,'player:dispatch:accept',4,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (58,53,'BUTTON','PlayerWorkbenchDispatchReject',NULL,NULL,'拒绝派单',NULL,'player:dispatch:reject',5,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (59,53,'BUTTON','PlayerWorkbenchOrderList',NULL,NULL,'查看本人订单',NULL,'player:order:list',6,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (60,53,'BUTTON','PlayerWorkbenchOrderDetail',NULL,NULL,'查看本人订单详情',NULL,'player:order:detail',7,0,1,0,'2026-08-09 16:53:52.848788','2026-08-09 16:53:52.848788'),
  (61,164,'MENU','FulfillmentReview','fulfillment-review','/business/fulfillment-review','履约审核','ri:shield-check-line',NULL,2,0,1,0,'2026-08-09 16:53:52.880034','2026-08-11 01:40:22.12602'),
  (62,61,'BUTTON','FulfillmentReviewList',NULL,NULL,'查询履约记录',NULL,'business:fulfillment:list',1,0,1,0,'2026-08-09 16:53:52.880034','2026-08-09 16:53:52.880034'),
  (63,61,'BUTTON','FulfillmentReviewDetail',NULL,NULL,'查看履约详情',NULL,'business:fulfillment:detail',2,0,1,0,'2026-08-09 16:53:52.880034','2026-08-09 16:53:52.880034'),
  (64,61,'BUTTON','FulfillmentReviewReview',NULL,NULL,'审核完成凭证',NULL,'business:fulfillment:review',3,0,1,0,'2026-08-09 16:53:52.880034','2026-08-09 16:53:52.880034'),
  (65,53,'BUTTON','PlayerWorkbenchOrderStart',NULL,NULL,'开始服务',NULL,'player:order:start',8,0,1,0,'2026-08-09 16:53:52.880034','2026-08-09 16:53:52.880034'),
  (66,53,'BUTTON','PlayerWorkbenchOrderSubmit',NULL,NULL,'提交完成凭证',NULL,'player:order:submit',9,0,1,0,'2026-08-09 16:53:52.880034','2026-08-09 16:53:52.880034'),
  (67,NULL,'DIRECTORY','CustomerPortal','/customer','/index/index','我的服务','ri:user-heart-line',NULL,40,0,1,0,'2026-08-09 16:53:52.911299','2026-08-09 16:53:52.911299'),
  (68,67,'MENU','CustomerOrders','orders','/customer/orders','我的订单','ri:file-list-2-line',NULL,1,0,1,0,'2026-08-09 16:53:52.911299','2026-08-09 16:53:52.911299'),
  (69,68,'BUTTON','CustomerOrdersList',NULL,NULL,'查看本人订单',NULL,'customer:order:list',1,0,1,0,'2026-08-09 16:53:52.911299','2026-08-09 16:53:52.911299'),
  (70,68,'BUTTON','CustomerOrdersDetail',NULL,NULL,'查看本人订单详情',NULL,'customer:order:detail',2,0,1,0,'2026-08-09 16:53:52.911299','2026-08-09 16:53:52.911299'),
  (71,68,'BUTTON','CustomerOrdersConfirm',NULL,NULL,'确认服务完成',NULL,'customer:order:confirm',3,0,1,0,'2026-08-09 16:53:52.911299','2026-08-09 16:53:52.911299'),
  (72,68,'BUTTON','CustomerOrdersAfterSale',NULL,NULL,'提交售后申请',NULL,'customer:after-sale:create',4,0,1,0,'2026-08-09 16:53:52.911299','2026-08-09 16:53:52.911299'),
  (73,163,'MENU','AfterSaleManage','after-sale-manage','/business/after-sale-manage','售后管理','ri:customer-service-line',NULL,3,0,1,0,'2026-08-09 16:53:52.911299','2026-08-11 01:40:22.12502'),
  (74,73,'BUTTON','AfterSaleManageList',NULL,NULL,'查询售后',NULL,'business:after-sale:list',1,0,1,0,'2026-08-09 16:53:52.911299','2026-08-09 16:53:52.911299'),
  (75,73,'BUTTON','AfterSaleManageDetail',NULL,NULL,'查看售后详情',NULL,'business:after-sale:detail',2,0,1,0,'2026-08-09 16:53:52.911299','2026-08-09 16:53:52.911299'),
  (76,73,'BUTTON','AfterSaleManageHandle',NULL,NULL,'处理售后',NULL,'business:after-sale:handle',3,0,1,0,'2026-08-09 16:53:52.911299','2026-08-09 16:53:52.911299'),
  (77,NULL,'DIRECTORY','System','/system','/index/index','系统管理','ri:settings-3-line',NULL,10,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (78,77,'MENU','User','user','/system/user','用户管理','ri:user-line',NULL,1,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (79,77,'MENU','Role','role','/system/role','角色管理','ri:shield-user-line',NULL,2,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (80,77,'MENU','Menu','menu','/system/menu','菜单管理','ri:menu-line',NULL,3,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (81,77,'MENU','LoginLog','login-log','/system/login-log','登录日志','ri:login-box-line',NULL,4,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (82,77,'MENU','OperationLog','operation-log','/system/operation-log','操作日志','ri:file-list-3-line',NULL,5,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (83,78,'BUTTON','UserList',NULL,NULL,'查询用户',NULL,'system:user:list',1,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (84,78,'BUTTON','UserAdd',NULL,NULL,'新增用户',NULL,'system:user:create',2,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (85,78,'BUTTON','UserEdit',NULL,NULL,'编辑用户',NULL,'system:user:update',3,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (86,78,'BUTTON','UserDelete',NULL,NULL,'删除用户',NULL,'system:user:delete',4,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (87,78,'BUTTON','UserStatus',NULL,NULL,'启用/禁用用户',NULL,'system:user:status',5,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (88,78,'BUTTON','UserResetPassword',NULL,NULL,'重置密码',NULL,'system:user:reset-password',6,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (89,78,'BUTTON','UserAssignRole',NULL,NULL,'分配角色',NULL,'system:user:assign-role',7,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (90,79,'BUTTON','RoleList',NULL,NULL,'查询角色',NULL,'system:role:list',1,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (91,79,'BUTTON','RoleAdd',NULL,NULL,'新增角色',NULL,'system:role:create',2,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (92,79,'BUTTON','RoleEdit',NULL,NULL,'编辑角色',NULL,'system:role:update',3,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (93,79,'BUTTON','RoleDelete',NULL,NULL,'删除角色',NULL,'system:role:delete',4,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (94,79,'BUTTON','RoleStatus',NULL,NULL,'启用/禁用角色',NULL,'system:role:status',5,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (95,79,'BUTTON','RoleAssign',NULL,NULL,'分配权限',NULL,'system:role:assign',6,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (96,80,'BUTTON','MenuList',NULL,NULL,'查询菜单',NULL,'system:menu:list',1,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (97,80,'BUTTON','MenuAdd',NULL,NULL,'新增菜单',NULL,'system:menu:create',2,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (98,80,'BUTTON','MenuEdit',NULL,NULL,'编辑菜单',NULL,'system:menu:update',3,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (99,80,'BUTTON','MenuDelete',NULL,NULL,'删除菜单',NULL,'system:menu:delete',4,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (100,81,'BUTTON','LoginLogList',NULL,NULL,'查询登录日志',NULL,'system:login-log:list',1,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (101,82,'BUTTON','OperationLogList',NULL,NULL,'查询操作日志',NULL,'system:operation-log:list',1,0,1,0,'2026-08-09 16:53:52.926929','2026-08-09 16:53:52.926929'),
  (102,67,'MENU','CustomerWallet','wallet','/customer/wallet','我的钱包','ri:wallet-3-line',NULL,2,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (103,102,'BUTTON','CustomerWalletView',NULL,NULL,'查看钱包',NULL,'customer:wallet:view',1,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (104,102,'BUTTON','CustomerWalletRecharge',NULL,NULL,'模拟充值',NULL,'customer:wallet:recharge',2,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (105,102,'BUTTON','CustomerWalletTransaction',NULL,NULL,'查看资金流水',NULL,'customer:wallet:transaction:list',3,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (106,162,'MENU','RechargePlanManage','recharge-plan','/business/recharge-plan','充值套餐','ri:coupon-3-line',NULL,2,0,1,0,'2026-08-09 16:53:52.942552','2026-08-11 01:40:22.118024'),
  (107,106,'BUTTON','RechargePlanList',NULL,NULL,'查询充值套餐',NULL,'business:recharge-plan:list',1,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (108,106,'BUTTON','RechargePlanCreate',NULL,NULL,'新增充值套餐',NULL,'business:recharge-plan:create',2,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (109,106,'BUTTON','RechargePlanUpdate',NULL,NULL,'编辑充值套餐',NULL,'business:recharge-plan:update',3,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (110,106,'BUTTON','RechargePlanStatus',NULL,NULL,'启停充值套餐',NULL,'business:recharge-plan:status',4,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (111,68,'BUTTON','CustomerOrdersPay',NULL,NULL,'余额支付',NULL,'customer:order:pay',5,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (112,68,'BUTTON','CustomerOrdersCancel',NULL,NULL,'取消订单',NULL,'customer:order:cancel',6,0,1,0,'2026-08-09 16:53:52.942552','2026-08-09 16:53:52.942552'),
  (113,52,'MENU','PlayerSettlement','settlement','/player/settlement','我的收益','ri:money-cny-circle-line',NULL,2,0,1,0,'2026-08-09 16:53:52.958178','2026-08-09 16:53:52.958178'),
  (114,113,'BUTTON','PlayerSettlementView',NULL,NULL,'查看收益',NULL,'player:settlement:view',1,0,1,0,'2026-08-09 16:53:52.958178','2026-08-09 16:53:52.958178'),
  (115,113,'BUTTON','PlayerSettlementWithdraw',NULL,NULL,'申请提现',NULL,'player:withdraw:create',2,0,1,0,'2026-08-09 16:53:52.958178','2026-08-09 16:53:52.958178'),
  (116,257,'MENU','SettlementManage','settlement-manage','/business/settlement-manage','结算管理','ri:secure-payment-line',NULL,2,0,1,0,'2026-08-09 16:53:52.958178','2026-08-15 03:19:24.496734'),
  (117,116,'BUTTON','SettlementManageList',NULL,NULL,'查询提现',NULL,'business:settlement:list',1,0,1,0,'2026-08-09 16:53:52.958178','2026-08-09 16:53:52.958178'),
  (118,116,'BUTTON','SettlementManageAudit',NULL,NULL,'审核提现',NULL,'business:settlement:audit',2,0,1,0,'2026-08-09 16:53:52.958178','2026-08-09 16:53:52.958178'),
  (119,116,'BUTTON','SettlementManageExport',NULL,NULL,'导出结算报表',NULL,'business:settlement:export',3,0,1,0,'2026-08-09 16:53:52.958178','2026-08-09 16:53:52.958178'),
  (120,116,'BUTTON','SettlementManageRule',NULL,NULL,'维护抽佣规则',NULL,'business:settlement:rule',4,0,1,0,'2026-08-09 16:53:52.958178','2026-08-09 16:53:52.958178'),
  (129,161,'MENU','PlayerLevel','player-level','/business/player-level','陪玩等级','ri:vip-crown-2-line',NULL,5,0,1,0,'2026-08-10 18:37:50.662537','2026-08-11 01:40:22.11502'),
  (130,129,'BUTTON','PlayerLevelList',NULL,NULL,'查询陪玩等级',NULL,'business:player-level:list',1,0,1,0,'2026-08-10 18:37:50.671507','2026-08-10 18:37:50.671507'),
  (131,129,'BUTTON','PlayerLevelCreate',NULL,NULL,'新增陪玩等级',NULL,'business:player-level:create',2,0,1,0,'2026-08-10 18:37:50.671507','2026-08-10 18:37:50.671507'),
  (132,129,'BUTTON','PlayerLevelUpdate',NULL,NULL,'编辑陪玩等级',NULL,'business:player-level:update',3,0,1,0,'2026-08-10 18:37:50.671507','2026-08-10 18:37:50.671507'),
  (133,129,'BUTTON','PlayerLevelStatus',NULL,NULL,'启停陪玩等级',NULL,'business:player-level:status',4,0,1,0,'2026-08-10 18:37:50.671507','2026-08-10 18:37:50.671507'),
  (134,129,'BUTTON','PlayerLevelDelete',NULL,NULL,'删除陪玩等级',NULL,'business:player-level:delete',5,0,1,0,'2026-08-10 18:37:50.671507','2026-08-10 18:37:50.671507'),
  (161,NULL,'DIRECTORY','BasicConfig','/basic-config','/index/index','基础配置','ri:settings-3-line',NULL,20,0,1,1,'2026-08-11 01:40:22.09002','2026-08-11 01:40:22.108021'),
  (162,NULL,'DIRECTORY','ProductCenter','/product-center','/index/index','商品中心','ri:shopping-bag-3-line',NULL,21,0,1,1,'2026-08-11 01:40:22.103021','2026-08-11 01:40:22.109019'),
  (163,NULL,'DIRECTORY','OrderCenter','/order-center','/index/index','订单中心','ri:file-list-3-line',NULL,22,0,1,1,'2026-08-11 01:40:22.10502','2026-08-11 01:40:22.11002'),
  (164,NULL,'DIRECTORY','PlayerOps','/player-ops','/index/index','陪玩运营','ri:user-star-line',NULL,23,0,1,1,'2026-08-11 01:40:22.10502','2026-08-11 01:40:22.11002'),
  (193,161,'MENU','MemberLevelManage','member-level','/business/member-level','会员等级','ri:vip-diamond-line',NULL,6,0,1,0,'2026-08-11 02:11:47.139734','2026-08-11 02:11:47.139734'),
  (194,193,'BUTTON','MemberLevelList',NULL,NULL,'查询会员等级',NULL,'business:member-level:list',1,0,1,0,'2026-08-11 02:11:47.161734','2026-08-11 02:11:47.161734'),
  (195,193,'BUTTON','MemberLevelCreate',NULL,NULL,'新增会员等级',NULL,'business:member-level:create',2,0,1,0,'2026-08-11 02:11:47.161734','2026-08-11 02:11:47.161734'),
  (196,193,'BUTTON','MemberLevelUpdate',NULL,NULL,'编辑会员等级',NULL,'business:member-level:update',3,0,1,0,'2026-08-11 02:11:47.161734','2026-08-11 02:11:47.161734'),
  (197,193,'BUTTON','MemberLevelStatus',NULL,NULL,'启停会员等级',NULL,'business:member-level:status',4,0,1,0,'2026-08-11 02:11:47.161734','2026-08-11 02:11:47.161734'),
  (198,193,'BUTTON','MemberLevelDelete',NULL,NULL,'删除会员等级',NULL,'business:member-level:delete',5,0,1,0,'2026-08-11 02:11:47.161734','2026-08-11 02:11:47.161734'),
  (225,164,'MENU','ServiceExceptionManage','service-exception-manage','/business/service-exception-manage','服务变更审核','ri:swap-box-line',NULL,4,0,1,0,'2026-08-13 00:14:33.397679','2026-08-13 01:40:08.332598'),
  (226,225,'BUTTON','ServiceExceptionList',NULL,NULL,'查询异常申请',NULL,'business:service-exception:list',1,0,1,0,'2026-08-13 00:14:33.407238','2026-08-13 00:14:33.407238'),
  (227,225,'BUTTON','ServiceExceptionReview',NULL,NULL,'审核异常申请',NULL,'business:service-exception:review',2,0,1,0,'2026-08-13 00:14:33.407238','2026-08-13 00:14:33.407238'),
  (257,NULL,'DIRECTORY','FinanceCenter','/finance-center','/index/index','财务中心','ri:funds-box-line',NULL,24,0,1,1,'2026-08-15 03:19:24.485132','2026-08-15 03:19:24.485132'),
  (258,257,'MENU','FinanceLedger','finance-ledger','/business/finance-ledger','财务流水','ri:exchange-funds-line',NULL,1,0,1,1,'2026-08-15 03:19:24.495404','2026-08-15 03:19:24.495404'),
  (259,258,'BUTTON','FinanceLedgerList',NULL,NULL,'查询财务流水',NULL,'business:finance:list',1,0,1,1,'2026-08-15 03:19:24.496499','2026-08-15 03:19:24.496499'),
  (300,163,'MENU','CustomerServiceTicket','customer-service-ticket','/business/customer-service-ticket','客服工单','ri:customer-service-2-line',NULL,5,0,1,1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
  (301,300,'BUTTON','CustomerServiceTicketList',NULL,NULL,'查询客服工单',NULL,'business:customer-service:list',1,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
  (302,300,'BUTTON','CustomerServiceTicketReply',NULL,NULL,'回复客服工单',NULL,'business:customer-service:reply',2,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
  (303,300,'BUTTON','CustomerServiceTicketStatus',NULL,NULL,'更新工单状态',NULL,'business:customer-service:status',3,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE `parent_id`=VALUES(`parent_id`),`type`=VALUES(`type`),`path`=VALUES(`path`),`component`=VALUES(`component`),`title`=VALUES(`title`),`icon`=VALUES(`icon`),`auth_mark`=VALUES(`auth_mark`),`sort_no`=VALUES(`sort_no`),`hidden`=VALUES(`hidden`),`enabled`=VALUES(`enabled`),`keep_alive`=VALUES(`keep_alive`),`updated_at`=VALUES(`updated_at`);

INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='Business' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='Player' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='Game' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerTag' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerAudit' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerDetail' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='GameList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='GameCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='GameUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='GameStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='GameDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerTagList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerTagCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerTagUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerTagDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='GamePositionList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='GamePositionCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='GamePositionUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='GamePositionDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductCategory' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ServiceItem' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductCategoryList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductCategoryCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductCategoryUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductCategoryStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductCategoryDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ServiceItemList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ServiceItemCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ServiceItemUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ServiceItemStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ServiceItemDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductManage' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductManageList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductManageCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductManageUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductManageStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductManageDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='OrderManage' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='OrderManageList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='OrderManageCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='OrderManageStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='OrderManageAssign' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='DispatchManage' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='DispatchManageList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='DispatchManageCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='DispatchManageRespond' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='DispatchManageCancel' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerPortal' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbench' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchView' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchDispatchList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchDispatchAccept' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchDispatchReject' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchOrderList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchOrderDetail' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='FulfillmentReview' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='FulfillmentReviewList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='FulfillmentReviewDetail' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='FulfillmentReviewReview' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchOrderStart' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchOrderSubmit' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerPortal' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrders' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersDetail' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersConfirm' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersAfterSale' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='AfterSaleManage' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='AfterSaleManageList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='AfterSaleManageDetail' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='AfterSaleManageHandle' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='System' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='User' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='Role' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='Menu' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='LoginLog' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='OperationLog' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='UserList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='UserAdd' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='UserEdit' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='UserDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='UserStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='UserResetPassword' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='UserAssignRole' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RoleList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RoleAdd' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RoleEdit' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RoleDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RoleStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RoleAssign' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MenuList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MenuAdd' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MenuEdit' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MenuDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='LoginLogList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='OperationLogList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerWallet' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerWalletView' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerWalletRecharge' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerWalletTransaction' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RechargePlanManage' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RechargePlanList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RechargePlanCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RechargePlanUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='RechargePlanStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersPay' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersCancel' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerSettlement' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerSettlementView' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerSettlementWithdraw' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='SettlementManage' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='SettlementManageList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='SettlementManageAudit' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='SettlementManageExport' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='SettlementManageRule' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerLevel' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerLevelList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerLevelCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerLevelUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerLevelStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerLevelDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='BasicConfig' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ProductCenter' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='OrderCenter' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerOps' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MemberLevelManage' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MemberLevelList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MemberLevelCreate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MemberLevelUpdate' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MemberLevelStatus' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='MemberLevelDelete' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ServiceExceptionManage' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ServiceExceptionList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='ServiceExceptionReview' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='FinanceCenter' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='FinanceLedger' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='FinanceLedgerList' WHERE r.`code`='admin';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerPortal' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrders' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersList' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersDetail' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersConfirm' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersAfterSale' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerWallet' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerWalletView' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerWalletRecharge' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerWalletTransaction' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersPay' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='CustomerOrdersCancel' WHERE r.`code`='customer';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerPortal' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbench' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchView' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchStatus' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchDispatchList' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchDispatchAccept' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchDispatchReject' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchOrderList' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchOrderDetail' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchOrderStart' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerWorkbenchOrderSubmit' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerSettlement' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerSettlementView' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name`='PlayerSettlementWithdraw' WHERE r.`code`='player';
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`id` IN (300,301,302,303) WHERE r.`code`='admin';

COMMIT;

