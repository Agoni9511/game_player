package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("pw_service_order")
public class ServiceOrderEntity {
 @TableId(type=IdType.INPUT) public Long orderId;
 public Long requestedPlayerId;
 public Long requestedPlayerLevelId;
 public String playerLevelCode;
 public String playerLevelName;
 public Integer requiredPlayerCount;
 public String pricingMode;
 public String priceType;
 public BigDecimal baseUnitPrice;
 public String contactName;
 public String contactPhone;
 public String serviceStatus;
 public LocalDateTime assignedAt;
 public LocalDateTime serviceStartedAt;
 public LocalDateTime completionSubmittedAt;
 public LocalDateTime customerConfirmDeadline;
 public LocalDateTime customerConfirmedAt;
 public LocalDateTime createdAt;
 public LocalDateTime updatedAt;
}
