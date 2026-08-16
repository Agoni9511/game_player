/**
 * API 接口类型定义模块
 *
 * 提供所有后端接口的类型定义
 *
 * ## 主要功能
 *
 * - 通用类型（分页参数、响应结构等）
 * - 认证类型（登录、用户信息等）
 * - 系统管理类型（用户、角色等）
 * - 全局命名空间声明
 *
 * ## 使用场景
 *
 * - API 请求参数类型约束
 * - API 响应数据类型定义
 * - 接口文档类型同步
 *
 * ## 注意事项
 *
 * - 在 .vue 文件使用需要在 eslint.config.mjs 中配置 globals: { Api: 'readonly' }
 * - 使用全局命名空间，无需导入即可使用
 *
 * ## 使用方式
 *
 * ```typescript
 * const params: Api.Auth.LoginParams = { userName: 'admin', password: '123456' }
 * const response: Api.Auth.UserInfo = await fetchUserInfo()
 * ```
 *
 * @module types/api/api
 * @author Art Design Pro Team
 */

declare namespace Api {
  /** 通用类型 */
  namespace Common {
    /** 分页参数 */
    interface PaginationParams {
      /** 当前页码 */
      current: number
      /** 每页条数 */
      size: number
      /** 总条数 */
      total: number
    }

    /** 通用搜索参数 */
    type CommonSearchParams = Pick<PaginationParams, 'current' | 'size'>

    /** 分页响应基础结构 */
    interface PaginatedResponse<T = any> {
      records: T[]
      current: number
      size: number
      total: number
    }

    /** 启用状态 */
    type EnableStatus = '1' | '2'
  }

  /** 认证类型 */
  namespace Auth {
    /** 登录参数 */
    interface LoginParams {
      userName: string
      password: string
    }

    /** 登录响应 */
    interface LoginResponse {
      token: string
      refreshToken: string
    }

    /** 用户信息 */
    interface UserInfo {
      buttons: string[]
      roles: string[]
      userId: number
      userName: string
      email: string
      avatar?: string
    }
  }

  /** 系统管理类型 */
  namespace SystemManage {
    /** 用户列表 */
    type UserList = Api.Common.PaginatedResponse<UserListItem>

    /** 用户列表项 */
    interface UserListItem {
      id: number
      avatar: string
      status: string
      userName: string
      userGender: string
      nickName: string
      userPhone: string
      userEmail: string
      userRoles: string[]
      roleIds: number[]
      enabled: boolean
      createBy: string
      createTime: string
      updateBy: string
      updateTime: string
    }

    /** 用户搜索参数 */
    type UserSearchParams = Partial<
      Pick<UserListItem, 'id' | 'userName' | 'userGender' | 'userPhone' | 'userEmail' | 'status'> &
        Api.Common.CommonSearchParams
    >

    /** 角色列表 */
    type RoleList = Api.Common.PaginatedResponse<RoleListItem>

    /** 角色列表项 */
    interface RoleListItem {
      roleId: number
      roleName: string
      roleCode: string
      description: string
      enabled: boolean
      builtIn?: boolean
      createTime: string
    }

    interface RoleOption {
      roleId: number
      roleName: string
      roleCode: string
      enabled: boolean
    }

    interface LoginLogItem { id:number; username:string; success:boolean; ipAddress:string; userAgent:string; message:string; createTime:string }
    interface OperationLogItem { id:number; operatorId?:number; operatorName:string; operation:string; targetType:string; targetId?:string; detail:string; ipAddress:string; createTime:string }
    type LoginLogList = Api.Common.PaginatedResponse<LoginLogItem>
    type OperationLogList = Api.Common.PaginatedResponse<OperationLogItem>

    interface UserSaveParams {
      userName: string
      password?: string
      nickName: string
      userPhone: string
      userEmail: string
      userGender: string
      avatar?: string
      enabled: boolean
      roleIds: number[]
    }

    interface MenuSaveParams {
      parentId?: number | null
      type: 'DIRECTORY' | 'MENU' | 'BUTTON'
      name: string
      path?: string
      component?: string
      title: string
      icon?: string
      authMark?: string
      sortNo: number
      hidden: boolean
      enabled: boolean
      keepAlive: boolean
    }

    /** 角色搜索参数 */
    type RoleSearchParams = Partial<
      Pick<RoleListItem, 'roleId' | 'roleName' | 'roleCode' | 'description' | 'enabled'> &
        Api.Common.CommonSearchParams & {
          startTime: string | null
          endTime: string | null
        }
    >
  }

  namespace Business {
    interface Game { id:number;gameCode:string;gameName:string;iconUrl?:string;coverUrl?:string;platformType:string;description?:string;sortNo:number;enabled:boolean;createTime?:string }
    interface GamePosition { id:number;gameId:number;positionCode:string;positionName:string;iconUrl?:string;sortNo:number;enabled:boolean }
    interface ProductCategory { id:number;gameId?:number;gameName?:string;parentId?:number;categoryCode:string;categoryName:string;iconUrl?:string;sortNo:number;enabled:boolean;children?:ProductCategory[] }
    interface ServiceItem { id:number;gameId:number;gameName:string;serviceCode:string;serviceName:string;serviceType:string;usageType:'STANDALONE'|'PACKAGE_ONLY';description?:string;sortNo:number;enabled:boolean;createTime?:string;levelPrices?:Array<{id?:number;playerLevelId:number;unitType:'HOUR'|'GAME'|'ORDER';price:number;marketPrice?:number;enabled:boolean}> }
    interface SkuCommitment { id?:number;ruleType:'GUARANTEE_VALUE'|'TARGET_COUNT'|'SUCCESS_CONDITION'|'KEEP_PLAYING'|'DESIGNATED_ITEM'|'DESIGNATED_MAP'|'COMPENSATION'|'OTHER';title:string;targetValue?:number;targetUnit?:string;description?:string;failureAction?:string;enabled:boolean;sortNo:number }
    interface ProductSku { id?:number;skuCode:string;skuName:string;price:number;marketPrice?:number;unitType:'HOUR'|'GAME'|'ORDER';unitCount:number;playerCount:number;priceType:'PER_PLAYER'|'FIXED_TOTAL';minQuantity:number;maxQuantity?:number;stockMode:'UNLIMITED'|'LIMITED';stockQuantity?:number;serviceMinutes?:number;enabled:boolean;sortNo:number;commitments?:SkuCommitment[] }
    interface ProductComponent { serviceId:number;serviceName?:string;serviceCode?:string;quantity:number;unitType:'HOUR'|'GAME'|'ORDER';sortNo:number }
    interface Product { id:number;gameId:number;gameName?:string;categoryId:number;categoryName?:string;productCode:string;productName:string;subtitle?:string;description?:string;coverUrl?:string;productType:'SERVICE'|'PACKAGE';status:'DRAFT'|'ON_SALE'|'OFF_SHELF';sortNo:number;validityDays?:number;purchaseLimit?:number;skuCount?:number;minPrice?:number;serviceIds?:number[];components?:ProductComponent[];skus?:ProductSku[];createTime?:string }
    interface OrderItem { id:number;productId:number;skuId:number;productCode:string;productName:string;skuCode:string;skuName:string;productType:string;unitPrice:number;quantity:number;subtotalAmount:number;serviceSnapshot:string }
    interface OrderGameProfile { gameId:number;gameName:string;gameAccount?:string;gameNickname?:string;serverName?:string;rankName?:string;extraRequirement?:string }
    interface OrderStatusLog { id:number;fromStatus?:string;toStatus:string;operatorName?:string;reason?:string;createTime:string }
    interface OrderMember { id:number;playerId:number;playerNo:string;playerName:string;avatarUrl?:string;memberStatus:string;joinSource:string;dispatchTaskId?:number;joinedAt:string;serviceStartedAt?:string;completedAt?:string;cancelledAt?:string }
    interface Order { id:number;orderNo:string;customerId:number;customerUsername:string;customerNickname?:string;businessType?:string;tradeStatus?:string;productName?:string;orderStatus:string;pricingMode?:string;playerLevelName?:string;requiredPlayerCount?:number;memberCount?:number;totalAmount:number;payableAmount:number;paidAmount:number;contactName?:string;contactPhone?:string;customerRemark?:string;cancelReason?:string;createTime:string;items?:OrderItem[];members?:OrderMember[];gameProfile?:OrderGameProfile;statusLogs?:OrderStatusLog[] }
    interface DispatchCandidate { id?:number;playerId:number;playerNo:string;playerName:string;workStatus:string;ratingScore:number;matchScore:number;activeOrderCount:number;primaryGame?:boolean;candidateStatus?:string;rejectReason?:string;respondedAt?:string }
    interface DispatchLog { id:number;playerName?:string;actionType:string;fromStatus?:string;toStatus:string;operatorName?:string;reason?:string;createTime:string }
    interface DispatchTask { id:number;taskNo:string;orderId:number;orderNo:string;orderStatus:string;dispatchMode:'DIRECT'|'GRAB';taskStatus:string;targetPlayerId?:number;acceptedPlayerId?:number;acceptedPlayerName?:string;attemptNo:number;candidateCount:number;deadlineAt:string;createTime:string;candidates?:DispatchCandidate[];logs?:DispatchLog[] }
    interface PlayerTag { id:number;tagCode:string;tagName:string;tagColor?:string;tagGroup:string;sortNo:number;enabled:boolean;createTime?:string }
    interface PlayerGame { id?:number;gameId:number;gameName?:string;priceLevelId?:number;priceLevelName?:string;serverId?:number;rankId?:number;gameNickname?:string;gameAccount?:string;serverName?:string;rankName?:string;rankLevel?:number;experienceYears?:number;introduction?:string;proofUrl?:string;primary:boolean;enabled:boolean;positionIds?:number[];primaryPositionId?:number }
    interface PlayerMedia { id?:number;mediaType:string;mediaUrl:string;thumbnailUrl?:string;title?:string;sortNo:number;enabled:boolean }
    interface Player { id:number;playerNo:string;userId?:number;maxActiveOrders?:number;nickname:string;realName?:string;gender:string;phone?:string;email?:string;avatarUrl?:string;coverUrl?:string;introduction?:string;voiceUrl?:string;auditStatus:string;workStatus:string;enabled:boolean;auditRemark?:string;orderCount:number;ratingScore:number;ratingCount:number;sortNo:number;remark?:string;primaryGame?:string;tagIds?:number[];games?:PlayerGame[];media?:PlayerMedia[];createTime?:string }
    interface PlayerSave { userId?:number;maxActiveOrders?:number;nickname:string;realName?:string;gender:string;phone?:string;email?:string;avatarUrl?:string;coverUrl?:string;introduction?:string;voiceUrl?:string;enabled:boolean;sortNo:number;remark?:string;tagIds:number[];games:PlayerGame[];media:PlayerMedia[] }
    type GameList=Api.Common.PaginatedResponse<Game>;type TagList=Api.Common.PaginatedResponse<PlayerTag>;type PlayerList=Api.Common.PaginatedResponse<Player>;type ServiceList=Api.Common.PaginatedResponse<ServiceItem>;type ProductList=Api.Common.PaginatedResponse<Product>;type OrderList=Api.Common.PaginatedResponse<Order>;type DispatchList=Api.Common.PaginatedResponse<DispatchTask>
  }
}
