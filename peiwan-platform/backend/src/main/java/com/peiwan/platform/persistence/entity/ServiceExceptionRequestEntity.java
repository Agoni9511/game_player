package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_service_exception_request") public class ServiceExceptionRequestEntity{
 @TableId(type=IdType.AUTO)public Long id;public String requestNo;public Long orderId;public String requestType;public Long sourceOrderMemberId;public Long targetPlayerId;public String applicantType;public Long applicantUserId;public String reason;public String proofUrls;public String requestStatus;public String reviewRemark;public Long reviewedBy;public LocalDateTime reviewedAt;public Long replacementOrderMemberId;public LocalDateTime resolvedAt;public LocalDateTime createdAt;public LocalDateTime updatedAt;
}
