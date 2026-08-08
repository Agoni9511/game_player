package com.peiwan.platform.persistence.entity;import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_fulfillment_proof") public class FulfillmentProofEntity{@TableId(type=IdType.AUTO)public Long id;public Long fulfillmentId;public String proofType;public String proofUrl;public Integer sortNo;public LocalDateTime createdAt;}
