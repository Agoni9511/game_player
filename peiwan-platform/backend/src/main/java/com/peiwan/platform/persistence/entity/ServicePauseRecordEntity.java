package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_service_pause_record") public class ServicePauseRecordEntity{
 @TableId(type=IdType.AUTO)public Long id;public Long orderId;public Long pauseRequestId;public Long resumeRequestId;public String pauseReason;public String resumeReason;public LocalDateTime pausedAt;public LocalDateTime resumedAt;public Long pausedBy;public Long resumedBy;public LocalDateTime createdAt;public LocalDateTime updatedAt;
}
