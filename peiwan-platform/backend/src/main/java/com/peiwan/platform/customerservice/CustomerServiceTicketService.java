package com.peiwan.platform.customerservice;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.peiwan.platform.persistence.entity.CustomerServiceMessageEntity;
import com.peiwan.platform.persistence.entity.CustomerServiceTicketEntity;
import com.peiwan.platform.persistence.mapper.CustomerServiceDataMapper;
import com.peiwan.platform.persistence.mapper.CustomerServiceMessageMapper;
import com.peiwan.platform.persistence.mapper.CustomerServiceTicketMapper;
import com.peiwan.platform.persistence.mapper.SystemUserMapper;
import com.peiwan.platform.persistence.mapper.TradeOrderMapper;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CustomerServiceTicketService {
  private static final Set<String> CATEGORIES = Set.of("ORDER", "PAYMENT", "SERVICE", "AFTER_SALE", "ACCOUNT", "OTHER");
  private static final Set<String> STATUSES = Set.of("PENDING", "PROCESSING", "WAIT_CUSTOMER", "RESOLVED", "CLOSED");
  private final CustomerServiceTicketMapper tickets;
  private final CustomerServiceMessageMapper messages;
  private final CustomerServiceDataMapper data;
  private final SystemUserMapper users;
  private final TradeOrderMapper orders;

  public CustomerServiceTicketService(CustomerServiceTicketMapper tickets, CustomerServiceMessageMapper messages,
      CustomerServiceDataMapper data, SystemUserMapper users, TradeOrderMapper orders) {
    this.tickets = tickets;
    this.messages = messages;
    this.data = data;
    this.users = users;
    this.orders = orders;
  }

  @Transactional
  public long create(long userId, CreateCommand command) {
    if (command == null || !CATEGORIES.contains(command.category())) throw new IllegalArgumentException("请选择正确的问题类型");
    required(command.subject(), "请填写问题标题", 120);
    required(command.content(), "请填写问题描述", 4000);
    if (command.orderId() != null && data.canAccessOrder(userId, command.orderId()) == 0) throw new IllegalArgumentException("关联订单不存在或无权访问");
    var now = LocalDateTime.now();
    var ticket = new CustomerServiceTicketEntity();
    ticket.ticketNo = "CS" + now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) + UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
    ticket.userId = userId;
    ticket.orderId = command.orderId();
    ticket.category = command.category();
    ticket.subject = command.subject().trim();
    ticket.ticketStatus = "PENDING";
    ticket.priority = "NORMAL";
    ticket.adminUnreadCount = 1;
    ticket.customerUnreadCount = 0;
    ticket.lastMessageAt = now;
    tickets.insert(ticket);
    insertMessage(ticket.id, userId, "CUSTOMER", command.content());
    return ticket.id;
  }

  public Map<String, Object> ownList(long userId, int current, int size) {
    var page = tickets.selectPage(new Page<>(positive(current), pageSize(size)), new QueryWrapper<CustomerServiceTicketEntity>()
      .eq("user_id", userId).orderByDesc("last_message_at", "id"));
    return page(page.getRecords().stream().map(this::view).toList(), current, size, page.getTotal());
  }

  @Transactional
  public Map<String, Object> ownDetail(long userId, long id) {
    var ticket = own(userId, id);
    if (ticket.customerUnreadCount != null && ticket.customerUnreadCount > 0) {
      ticket.customerUnreadCount = 0;
      ticket.updatedAt = LocalDateTime.now();
      tickets.updateById(ticket);
    }
    return detail(ticket);
  }

  @Transactional
  public void customerReply(long userId, long id, String content) {
    required(content, "请输入回复内容", 4000);
    var ticket = own(userId, id);
    if ("CLOSED".equals(ticket.ticketStatus)) throw new IllegalArgumentException("工单已经关闭，无法继续回复");
    insertMessage(id, userId, "CUSTOMER", content);
    ticket.ticketStatus = "PENDING";
    ticket.adminUnreadCount = value(ticket.adminUnreadCount) + 1;
    ticket.lastMessageAt = LocalDateTime.now();
    ticket.resolvedAt = null;
    ticket.updatedAt = LocalDateTime.now();
    tickets.updateById(ticket);
  }

  public Map<String, Object> adminList(int current, int size, String keyword, String status, String category) {
    var query = new QueryWrapper<CustomerServiceTicketEntity>();
    if (keyword != null && !keyword.isBlank()) query.and(x -> x.like("ticket_no", keyword.trim()).or().like("subject", keyword.trim()));
    if (status != null && !status.isBlank()) query.eq("ticket_status", status);
    if (category != null && !category.isBlank()) query.eq("category", category);
    query.orderByAsc("case when ticket_status='PENDING' then 0 when ticket_status='PROCESSING' then 1 when ticket_status='WAIT_CUSTOMER' then 2 else 3 end")
      .orderByDesc("last_message_at", "id");
    var page = tickets.selectPage(new Page<>(positive(current), pageSize(size)), query);
    return page(page.getRecords().stream().map(this::view).toList(), current, size, page.getTotal());
  }

  @Transactional
  public Map<String, Object> adminDetail(long id) {
    var ticket = require(id);
    if (ticket.adminUnreadCount != null && ticket.adminUnreadCount > 0) {
      ticket.adminUnreadCount = 0;
      ticket.updatedAt = LocalDateTime.now();
      tickets.updateById(ticket);
    }
    return detail(ticket);
  }

  @Transactional
  public void adminReply(long id, long adminId, String content) {
    required(content, "请输入回复内容", 4000);
    var ticket = require(id);
    if ("CLOSED".equals(ticket.ticketStatus)) throw new IllegalArgumentException("工单已经关闭，无法继续回复");
    insertMessage(id, adminId, "ADMIN", content);
    ticket.assignedAdminId = adminId;
    ticket.ticketStatus = "WAIT_CUSTOMER";
    ticket.customerUnreadCount = value(ticket.customerUnreadCount) + 1;
    ticket.lastMessageAt = LocalDateTime.now();
    ticket.updatedAt = LocalDateTime.now();
    tickets.updateById(ticket);
  }

  @Transactional
  public void changeStatus(long id, long adminId, String status) {
    if (!STATUSES.contains(status)) throw new IllegalArgumentException("工单状态无效");
    var ticket = require(id);
    ticket.ticketStatus = status;
    ticket.assignedAdminId = adminId;
    ticket.updatedAt = LocalDateTime.now();
    if ("RESOLVED".equals(status)) ticket.resolvedAt = LocalDateTime.now();
    if ("CLOSED".equals(status)) ticket.closedAt = LocalDateTime.now();
    tickets.updateById(ticket);
  }

  private CustomerServiceTicketEntity own(long userId, long id) {
    var ticket = require(id);
    if (!ticket.userId.equals(userId)) throw new IllegalArgumentException("客服工单不存在");
    return ticket;
  }

  private CustomerServiceTicketEntity require(long id) {
    var ticket = tickets.selectById(id);
    if (ticket == null) throw new IllegalArgumentException("客服工单不存在");
    return ticket;
  }

  private void insertMessage(long ticketId, long senderId, String role, String content) {
    var message = new CustomerServiceMessageEntity();
    message.ticketId = ticketId;
    message.senderId = senderId;
    message.senderRole = role;
    message.content = content.trim();
    messages.insert(message);
  }

  private Map<String, Object> detail(CustomerServiceTicketEntity ticket) {
    var result = new LinkedHashMap<>(view(ticket));
    result.put("messages", messages.selectList(new QueryWrapper<CustomerServiceMessageEntity>()
      .eq("ticket_id", ticket.id).orderByAsc("id")).stream().map(this::messageView).toList());
    return result;
  }

  private Map<String, Object> view(CustomerServiceTicketEntity ticket) {
    var result = new LinkedHashMap<String, Object>();
    var user = users.selectById(ticket.userId);
    var admin = ticket.assignedAdminId == null ? null : users.selectById(ticket.assignedAdminId);
    var order = ticket.orderId == null ? null : orders.selectById(ticket.orderId);
    result.put("id", ticket.id);
    result.put("ticketNo", ticket.ticketNo);
    result.put("userId", ticket.userId);
    result.put("userName", user == null ? "未知用户" : user.nickname);
    result.put("orderId", ticket.orderId);
    result.put("orderNo", order == null ? null : order.orderNo);
    result.put("category", ticket.category);
    result.put("subject", ticket.subject);
    result.put("status", ticket.ticketStatus);
    result.put("priority", ticket.priority);
    result.put("assignedAdminId", ticket.assignedAdminId);
    result.put("assignedAdminName", admin == null ? null : admin.nickname);
    result.put("adminUnreadCount", value(ticket.adminUnreadCount));
    result.put("customerUnreadCount", value(ticket.customerUnreadCount));
    result.put("lastMessageAt", ticket.lastMessageAt);
    result.put("createdAt", ticket.createdAt);
    result.put("updatedAt", ticket.updatedAt);
    return result;
  }

  private Map<String, Object> messageView(CustomerServiceMessageEntity message) {
    var result = new LinkedHashMap<String, Object>();
    var sender = users.selectById(message.senderId);
    result.put("id", message.id);
    result.put("senderId", message.senderId);
    result.put("senderRole", message.senderRole);
    result.put("senderName", sender == null ? ("ADMIN".equals(message.senderRole) ? "平台客服" : "用户") : sender.nickname);
    result.put("content", message.content);
    result.put("createdAt", message.createdAt);
    return result;
  }

  private Map<String, Object> page(List<Map<String, Object>> records, int current, int size, long total) {
    return Map.of("records", records, "current", positive(current), "size", pageSize(size), "total", total);
  }

  private int positive(int value) { return Math.max(1, value); }
  private int pageSize(int value) { return Math.min(100, Math.max(1, value)); }
  private int value(Integer value) { return value == null ? 0 : value; }
  private void required(String value, String message, int max) {
    if (value == null || value.isBlank()) throw new IllegalArgumentException(message);
    if (value.trim().length() > max) throw new IllegalArgumentException(message + "，最多" + max + "个字");
  }

  public record CreateCommand(Long orderId, String category, String subject, String content) {}
  public record ReplyCommand(String content) {}
  public record StatusCommand(String status) {}
}
