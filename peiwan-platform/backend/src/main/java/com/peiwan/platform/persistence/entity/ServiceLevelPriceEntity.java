package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("pw_service_level_price")
public class ServiceLevelPriceEntity {
 @TableId(type=IdType.AUTO) public Long id;
 public Long serviceId;
 public Long playerLevelId;
 public String unitType;
 public BigDecimal price;
 public BigDecimal marketPrice;
 public Boolean enabled;
 public LocalDateTime createdAt;
 public LocalDateTime updatedAt;
}
