package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_game_server") public class GameServerEntity{@TableId(type=IdType.AUTO)public Long id;public Long gameId;public String serverCode;public String serverName;public Integer sortNo;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
