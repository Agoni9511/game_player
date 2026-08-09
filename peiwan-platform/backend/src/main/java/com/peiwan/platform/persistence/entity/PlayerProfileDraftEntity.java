package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import java.time.LocalDateTime;

@TableName("pw_player_profile_draft")
public class PlayerProfileDraftEntity {
  @TableId(type = IdType.AUTO)
  public Long id;
  public Long playerId;
  public String profileData;
  public String draftStatus;
  public String reviewRemark;
  public LocalDateTime submittedAt;
  public Long reviewedBy;
  public LocalDateTime reviewedAt;
  public LocalDateTime createdAt;
  public LocalDateTime updatedAt;
}
