package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import java.time.LocalDateTime;

@TableName("pw_player_application")
public class PlayerApplicationEntity {
  @TableId(type = IdType.AUTO) public Long id;
  public Long userId;
  public String realName;
  public String phone;
  public String address;
  public String applicationStatus;
  public String followUpRemark;
  public Long handledBy;
  public LocalDateTime handledAt;
  public LocalDateTime createdAt;
  public LocalDateTime updatedAt;
}

