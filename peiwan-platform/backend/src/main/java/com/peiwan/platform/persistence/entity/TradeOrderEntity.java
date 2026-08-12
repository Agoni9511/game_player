package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("pw_trade_order")
public class TradeOrderEntity {
 @TableId(type=IdType.AUTO) public Long id;
 public String orderNo;
 public Long customerId;
 public String businessType;
 public String tradeStatus;
 public String title;
 public BigDecimal totalAmount;
 public BigDecimal discountAmount;
 public BigDecimal payableAmount;
 public BigDecimal paidAmount;
 public BigDecimal refundedAmount;
 public String paymentStatus;
 public String refundStatus;
 public String customerRemark;
 public String cancelReason;
 public LocalDateTime paidAt;
 public LocalDateTime completedAt;
 public LocalDateTime cancelledAt;
 public Long createdBy;
 public LocalDateTime createdAt;
 public LocalDateTime updatedAt;
}
