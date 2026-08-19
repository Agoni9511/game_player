package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.time.LocalDateTime;

@TableName("pw_order_requested_player")
public class OrderRequestedPlayerEntity {
 @TableId(type=IdType.AUTO) public Long id;
 public Long orderId;
 public Long playerId;
 public Integer sortNo;
 public LocalDateTime createdAt;
}
