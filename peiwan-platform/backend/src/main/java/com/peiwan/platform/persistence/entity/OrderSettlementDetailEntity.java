package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("pw_order_settlement_detail")
public class OrderSettlementDetailEntity {
 @TableId(type=IdType.AUTO) public Long id;
 public Long settlementId;
 public Long orderId;
 public Long orderMemberId;
 public Long playerId;
 public String detailType;
 public BigDecimal amount;
 public BigDecimal calculationBase;
 public BigDecimal rate;
 public String remark;
 public LocalDateTime createdAt;
}
