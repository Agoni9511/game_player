package com.peiwan.platform.order;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.peiwan.platform.persistence.entity.OrderRuleEntity;
import com.peiwan.platform.persistence.mapper.OrderRuleMapper;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderRuleService {
  private final OrderRuleMapper rules;

  public OrderRuleService(OrderRuleMapper rules) {
    this.rules = rules;
  }

  public Map<String, Object> adminRule() {
    return view(requiredRule());
  }

  @Transactional
  public void updateRule(RuleCommand command) {
    if (command == null) throw new IllegalArgumentException("订单确认规则不能为空");
    if (command.customerConfirmHours() < 1 || command.customerConfirmHours() > 720) {
      throw new IllegalArgumentException("用户确认时限必须在1到720小时之间");
    }
    var rule = requiredRule();
    rule.customerConfirmHours = command.customerConfirmHours();
    rule.autoCompleteEnabled = command.autoCompleteEnabled();
    rule.updatedAt = LocalDateTime.now();
    rules.updateById(rule);
  }

  private OrderRuleEntity requiredRule() {
    var rule = rules.selectOne(new QueryWrapper<OrderRuleEntity>().orderByAsc("id").last("limit 1"));
    if (rule == null) throw new IllegalArgumentException("未配置订单确认规则，请先执行订单规则初始化脚本");
    return rule;
  }

  private Map<String, Object> view(OrderRuleEntity rule) {
    var result = new LinkedHashMap<String, Object>();
    result.put("customerConfirmHours", rule.customerConfirmHours);
    result.put("autoCompleteEnabled", rule.autoCompleteEnabled);
    result.put("updatedAt", rule.updatedAt);
    return result;
  }

  public record RuleCommand(int customerConfirmHours, boolean autoCompleteEnabled) {}
}
