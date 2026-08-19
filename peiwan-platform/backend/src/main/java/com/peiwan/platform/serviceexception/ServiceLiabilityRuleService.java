package com.peiwan.platform.serviceexception;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.peiwan.platform.persistence.entity.ServiceLiabilityRuleEntity;
import com.peiwan.platform.persistence.mapper.ServiceLiabilityRuleMapper;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ServiceLiabilityRuleService {
  private final ServiceLiabilityRuleMapper rules;

  public ServiceLiabilityRuleService(ServiceLiabilityRuleMapper rules) {
    this.rules = rules;
  }

  public Map<String, Object> adminRule() {
    return view(requiredRule());
  }

  @Transactional
  public void updateRule(RuleCommand command) {
    if (command == null) throw new IllegalArgumentException("服务责任规则不能为空");
    validateRate(command.transferRate(), "转单责任比例");
    validateRate(command.abortRate(), "炸单责任比例");
    var rule = requiredRule();
    rule.transferRate = command.transferRate();
    rule.abortRate = command.abortRate();
    rule.updatedAt = LocalDateTime.now();
    rules.updateById(rule);
  }

  public ServiceLiabilityRuleEntity requiredRule() {
    var rule = rules.selectOne(new QueryWrapper<ServiceLiabilityRuleEntity>().eq("enabled", true).orderByAsc("id").last("limit 1"));
    if (rule == null) throw new IllegalArgumentException("未配置启用的服务责任规则");
    return rule;
  }

  private void validateRate(BigDecimal rate, String label) {
    if (rate == null || rate.signum() < 0 || rate.compareTo(BigDecimal.ONE) >= 0) {
      throw new IllegalArgumentException(label + "必须大于等于0且小于1");
    }
  }

  private Map<String, Object> view(ServiceLiabilityRuleEntity rule) {
    var result = new LinkedHashMap<String, Object>();
    result.put("ruleName", rule.ruleName);
    result.put("transferRate", rule.transferRate);
    result.put("abortRate", rule.abortRate);
    result.put("updatedAt", rule.updatedAt);
    return result;
  }

  public record RuleCommand(BigDecimal transferRate, BigDecimal abortRate) {}
}
