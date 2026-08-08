package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_player_status_log") public class PlayerStatusLogEntity{@TableId(type=IdType.AUTO)public Long id;public Long playerId;public String statusType;public String beforeValue;public String afterValue;public String reason;public String operatorType;public Long operatorId;public LocalDateTime createdAt;}
