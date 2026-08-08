package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_game") public class GameEntity{@TableId(type=IdType.AUTO)public Long id;public String gameCode;public String gameName;public String iconUrl;public String coverUrl;public String platformType;public String description;public Integer sortNo;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
