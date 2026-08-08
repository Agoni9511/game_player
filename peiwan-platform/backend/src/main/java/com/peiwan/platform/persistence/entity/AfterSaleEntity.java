package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_after_sale") public class AfterSaleEntity{@TableId(type=IdType.AUTO)public Long id;public String afterSaleNo;public Long orderId;public Long customerId;public String reasonType;public String description;public String afterSaleStatus;public String resultType;public String resultRemark;public Long handledBy;public LocalDateTime handledAt;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
