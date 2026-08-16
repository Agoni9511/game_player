package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.math.BigDecimal;import java.time.LocalDateTime;
@TableName("pw_order_commitment") public class OrderCommitmentEntity{@TableId(type=IdType.AUTO)public Long id;public Long orderId;public Long orderItemId;public Long sourceCommitmentId;public String ruleType;public String title;public BigDecimal targetValue;public String targetUnit;public String description;public String failureAction;public Integer sortNo;public LocalDateTime createdAt;}
