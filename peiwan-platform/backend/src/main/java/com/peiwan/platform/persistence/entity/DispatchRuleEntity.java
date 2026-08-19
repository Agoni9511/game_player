package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.time.LocalDateTime;

@TableName("pw_dispatch_rule")
public class DispatchRuleEntity {
 @TableId(type=IdType.AUTO) public Long id;
 public String ruleName;
 public Integer grabMinutes;
 public Integer maxCandidates;
 public Boolean allowBusy;
 public Integer maxActiveOrders;
 public Boolean allowReofferAfterReject;
 public Boolean enabled;
 public LocalDateTime updatedAt;
}
