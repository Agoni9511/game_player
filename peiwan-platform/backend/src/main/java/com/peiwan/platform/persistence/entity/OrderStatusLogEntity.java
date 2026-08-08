package com.peiwan.platform.persistence.entity;import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_order_status_log") public class OrderStatusLogEntity{@TableId(type=IdType.AUTO)public Long id;public Long orderId;public String fromStatus;public String toStatus;public Long operatorId;public String reason;public LocalDateTime createdAt;}
