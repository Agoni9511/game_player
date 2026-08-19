package com.peiwan.platform.order;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.common.AuditService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class OrderRuleController {
  private final OrderRuleService service;
  private final AuditService audit;

  public OrderRuleController(OrderRuleService service, AuditService audit) {
    this.service = service;
    this.audit = audit;
  }

  @PreAuthorize("hasAuthority('business:order-rule:view') or hasRole('admin')")
  @GetMapping("/api/business/order-rule")
  public ApiResponse<?> rule() {
    return ApiResponse.ok(service.adminRule());
  }

  @PreAuthorize("hasAuthority('business:order-rule:update') or hasRole('admin')")
  @PutMapping("/api/business/order-rule")
  public ApiResponse<?> update(
      Authentication auth, @RequestBody OrderRuleService.RuleCommand command, HttpServletRequest request) {
    service.updateRule(command);
    audit.operation(auth, "business:order-rule:update", "ORDER_RULE", null, "修改订单确认规则", request);
    return ApiResponse.ok();
  }
}
