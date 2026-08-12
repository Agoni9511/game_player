package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("pw_platform_ledger")
public class PlatformLedgerEntity {
 @TableId(type=IdType.AUTO) public Long id;
 public String ledgerNo;
 public Long orderId;
 public Long settlementDetailId;
 public String businessType;
 public String direction;
 public BigDecimal amount;
 public String remark;
 public LocalDateTime createdAt;
}
