package com.peiwan.platform.player;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.peiwan.platform.persistence.entity.PlayerApplicationEntity;
import com.peiwan.platform.persistence.mapper.PlayerApplicationMapper;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PlayerApplicationService {
  private static final Set<String> ACTIVE_STATUSES = Set.of("PENDING", "PROCESSING");
  private final PlayerApplicationMapper applications;

  public PlayerApplicationService(PlayerApplicationMapper applications) {
    this.applications = applications;
  }

  public Map<String, Object> ownLatest(long userId) {
    var row = applications.selectOne(new QueryWrapper<PlayerApplicationEntity>()
      .eq("user_id", userId).orderByDesc("id").last("limit 1"));
    return row == null ? Map.of() : view(row);
  }

  @Transactional
  public long create(long userId, Command command) {
    validate(command);
    long active = applications.selectCount(new QueryWrapper<PlayerApplicationEntity>()
      .eq("user_id", userId).in("application_status", ACTIVE_STATUSES));
    if (active > 0) throw new IllegalArgumentException("已有待处理的入驻申请，请勿重复提交");
    var row = new PlayerApplicationEntity();
    row.userId = userId;
    row.realName = command.realName().trim();
    row.phone = command.phone().trim();
    row.address = command.address().trim();
    row.applicationStatus = "PENDING";
    applications.insert(row);
    return row.id;
  }

  public Map<String, Object> list(int current, int size, String keyword, String status) {
    var query = new QueryWrapper<PlayerApplicationEntity>();
    if (keyword != null && !keyword.isBlank()) query.and(x -> x.like("real_name", keyword.trim()).or().like("phone", keyword.trim()).or().like("address", keyword.trim()));
    if (status != null && !status.isBlank()) query.eq("application_status", status);
    query.orderByAsc("case when application_status='PENDING' then 0 when application_status='PROCESSING' then 1 else 2 end").orderByDesc("id");
    var page = applications.selectPage(new Page<>(Math.max(1, current), Math.min(100, Math.max(1, size))), query);
    return Map.of("records", page.getRecords().stream().map(this::view).toList(), "current", current, "size", size, "total", page.getTotal());
  }

  @Transactional
  public void handle(long id, HandleCommand command, long operator) {
    if (command == null || !Set.of("PROCESSING", "CLOSED").contains(command.status())) throw new IllegalArgumentException("处理状态无效");
    var row = applications.selectById(id);
    if (row == null) throw new IllegalArgumentException("入驻申请不存在");
    if ("CLOSED".equals(row.applicationStatus)) throw new IllegalArgumentException("入驻申请已经关闭");
    row.applicationStatus = command.status();
    row.followUpRemark = command.remark() == null ? null : command.remark().trim();
    row.handledBy = operator;
    row.handledAt = LocalDateTime.now();
    row.updatedAt = LocalDateTime.now();
    applications.updateById(row);
  }

  private void validate(Command command) {
    if (command == null || command.realName() == null || command.realName().isBlank()) throw new IllegalArgumentException("请填写姓名");
    if (command.realName().trim().length() > 64) throw new IllegalArgumentException("姓名不能超过64个字");
    if (command.phone() == null || !command.phone().trim().matches("^1\\d{10}$")) throw new IllegalArgumentException("请填写正确的11位手机号");
    if (command.address() == null || command.address().isBlank()) throw new IllegalArgumentException("请填写所在地址");
    if (command.address().trim().length() > 500) throw new IllegalArgumentException("地址不能超过500个字");
  }

  private Map<String, Object> view(PlayerApplicationEntity row) {
    var result = new LinkedHashMap<String, Object>();
    result.put("id", row.id);
    result.put("userId", row.userId);
    result.put("realName", row.realName);
    result.put("phone", row.phone);
    result.put("address", row.address);
    result.put("status", row.applicationStatus);
    result.put("followUpRemark", row.followUpRemark);
    result.put("handledBy", row.handledBy);
    result.put("handledAt", row.handledAt);
    result.put("createdAt", row.createdAt);
    result.put("updatedAt", row.updatedAt);
    return result;
  }

  public record Command(String realName, String phone, String address) {}
  public record HandleCommand(String status, String remark) {}
}

