package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_game_rank") public class GameRankEntity{@TableId(type=IdType.AUTO)public Long id;public Long rankSystemId;public String rankCode;public String rankName;public Integer tierNo;public Integer sortNo;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
