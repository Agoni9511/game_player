package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_player_media") public class PlayerMediaEntity{@TableId(type=IdType.AUTO)public Long id;public Long playerId;public String mediaType;public String mediaUrl;public String thumbnailUrl;public String title;public Integer sortNo;public String auditStatus;public String auditRemark;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
