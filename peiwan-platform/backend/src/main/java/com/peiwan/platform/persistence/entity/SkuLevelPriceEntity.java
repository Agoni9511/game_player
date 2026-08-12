package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.math.BigDecimal;import java.time.LocalDateTime;
@TableName("pw_sku_level_price") public class SkuLevelPriceEntity{@TableId(type=IdType.AUTO)public Long id;public Long skuId;public Long playerLevelId;public BigDecimal price;public BigDecimal marketPrice;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
