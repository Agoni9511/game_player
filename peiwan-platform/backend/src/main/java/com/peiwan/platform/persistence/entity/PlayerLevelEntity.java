package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_player_level") public class PlayerLevelEntity{@TableId(type=IdType.AUTO)public Long id;public Long gameId;public String levelCode;public String levelName;public String description;public Integer sortNo;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
