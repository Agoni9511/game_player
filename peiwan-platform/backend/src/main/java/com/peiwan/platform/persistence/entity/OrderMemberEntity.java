package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.time.LocalDateTime;

@TableName("pw_order_member")
public class OrderMemberEntity {
 @TableId(type=IdType.AUTO) public Long id;
 public Long orderId;
 public Long playerId;
 public String memberStatus;
 public String joinSource;
 public Long dispatchTaskId;
 public LocalDateTime joinedAt;
 public LocalDateTime serviceStartedAt;
 public LocalDateTime completedAt;
 public LocalDateTime cancelledAt;
 public LocalDateTime createdAt;
 public LocalDateTime updatedAt;
}
