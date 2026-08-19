package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("pw_service_liability_rule")
public class ServiceLiabilityRuleEntity {
  @TableId(type = IdType.AUTO) public Long id;
  public String ruleCode;
  public String ruleName;
  public BigDecimal transferRate;
  public BigDecimal abortRate;
  public Boolean enabled;
  public LocalDateTime updatedAt;
}
