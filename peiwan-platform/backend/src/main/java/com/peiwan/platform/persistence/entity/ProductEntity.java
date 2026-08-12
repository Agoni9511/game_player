package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_product") public class ProductEntity{@TableId(type=IdType.AUTO)public Long id;public Long gameId;public Long categoryId;public String productCode;public String productName;public String subtitle;public String description;public String coverUrl;public String productType;public String pricingMode;public String status;public Integer sortNo;public Integer validityDays;public Integer purchaseLimit;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
