package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import java.time.LocalDateTime;

@TableName("pw_order_rule")
public class OrderRuleEntity {
  @TableId(type = IdType.AUTO) public Long id;
  public Integer customerConfirmHours;
  public Boolean autoCompleteEnabled;
  public LocalDateTime updatedAt;
}
