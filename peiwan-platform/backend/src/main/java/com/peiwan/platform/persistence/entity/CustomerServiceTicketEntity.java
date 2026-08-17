package com.peiwan.platform.persistence.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import java.time.LocalDateTime;

@TableName("pw_customer_service_ticket")
public class CustomerServiceTicketEntity {
  @TableId(type = IdType.AUTO) public Long id;
  public String ticketNo;
  public Long userId;
  public Long orderId;
  public String category;
  public String subject;
  public String ticketStatus;
  public String priority;
  public Long assignedAdminId;
  public Integer adminUnreadCount;
  public Integer customerUnreadCount;
  public LocalDateTime lastMessageAt;
  public LocalDateTime resolvedAt;
  public LocalDateTime closedAt;
  public LocalDateTime createdAt;
  public LocalDateTime updatedAt;
}
