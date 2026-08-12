package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_game_rank_system") public class GameRankSystemEntity{@TableId(type=IdType.AUTO)public Long id;public Long gameId;public String systemCode;public String systemName;public String description;public Integer sortNo;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
