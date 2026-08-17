package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import java.time.LocalDateTime;

@TableName("pw_customer_service_message")
public class CustomerServiceMessageEntity {
  @TableId(type = IdType.AUTO) public Long id;
  public Long ticketId;
  public Long senderId;
  public String senderRole;
  public String content;
  public LocalDateTime createdAt;
}
