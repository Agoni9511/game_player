package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_service_member_transfer") public class ServiceMemberTransferEntity{@TableId(type=IdType.AUTO)public Long id;public Long orderId;public Long exceptionRequestId;public Long fromOrderMemberId;public Long toOrderMemberId;public LocalDateTime transferredAt;public LocalDateTime createdAt;}
