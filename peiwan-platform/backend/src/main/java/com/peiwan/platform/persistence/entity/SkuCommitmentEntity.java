package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.math.BigDecimal;import java.time.LocalDateTime;
@TableName("pw_sku_commitment") public class SkuCommitmentEntity{@TableId(type=IdType.AUTO)public Long id;public Long skuId;public String ruleType;public String title;public BigDecimal targetValue;public String targetUnit;public String description;public String failureAction;public Boolean enabled;public Integer sortNo;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
