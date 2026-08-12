package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("pw_order_settlement")
public class OrderSettlementEntity {
 @TableId(type=IdType.AUTO) public Long id;
 public String settlementNo;
 public Long orderId;
 public BigDecimal orderAmount;
 public BigDecimal platformAmount;
 public BigDecimal distributableAmount;
 public String settlementStatus;
 public LocalDateTime settledAt;
 public LocalDateTime createdAt;
 public LocalDateTime updatedAt;
}
