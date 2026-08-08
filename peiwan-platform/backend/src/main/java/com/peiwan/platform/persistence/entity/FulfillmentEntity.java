package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.math.BigDecimal;import java.time.LocalDateTime;
@TableName("pw_fulfillment") public class FulfillmentEntity{@TableId(type=IdType.AUTO)public Long id;public Long orderId;public Long playerId;public String fulfillmentStatus;public String completionNote;public BigDecimal actualQuantity;public LocalDateTime submittedAt;public Long reviewedBy;public LocalDateTime reviewedAt;public String reviewRemark;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
