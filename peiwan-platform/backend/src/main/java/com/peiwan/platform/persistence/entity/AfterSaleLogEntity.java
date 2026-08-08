package com.peiwan.platform.persistence.entity;import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_after_sale_log") public class AfterSaleLogEntity{@TableId(type=IdType.AUTO)public Long id;public Long afterSaleId;public String action;public String fromStatus;public String toStatus;public String remark;public Long operatorId;public LocalDateTime createdAt;}
