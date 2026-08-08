package com.peiwan.platform.persistence.entity;import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_after_sale_proof") public class AfterSaleProofEntity{@TableId(type=IdType.AUTO)public Long id;public Long afterSaleId;public String proofUrl;public Integer sortNo;public LocalDateTime createdAt;}
