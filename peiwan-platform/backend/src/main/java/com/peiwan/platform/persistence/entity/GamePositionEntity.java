package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_game_position") public class GamePositionEntity{@TableId(type=IdType.AUTO)public Long id;public Long gameId;public String positionCode;public String positionName;public String iconUrl;public Integer sortNo;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;public Object get(String field){return "game_id".equals(field)?gameId:null;}}
