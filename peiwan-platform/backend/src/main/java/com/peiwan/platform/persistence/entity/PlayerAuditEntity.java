package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_player_audit") public class PlayerAuditEntity{@TableId(type=IdType.AUTO)public Long id;public Long playerId;public String auditType;public String beforeStatus;public String afterStatus;public String result;public String reason;public String snapshotData;public Long auditorId;public LocalDateTime auditedAt;public LocalDateTime createdAt;}
