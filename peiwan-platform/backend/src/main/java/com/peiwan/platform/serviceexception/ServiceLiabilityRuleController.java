package com.peiwan.platform.serviceexception;

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
public class ServiceLiabilityRuleController {
  private final ServiceLiabilityRuleService service;
  private final AuditService audit;

  public ServiceLiabilityRuleController(ServiceLiabilityRuleService service, AuditService audit) {
    this.service = service;
    this.audit = audit;
  }

  @PreAuthorize("hasAuthority('business:service-liability-rule:view') or hasRole('admin')")
  @GetMapping("/api/business/service-liability-rule")
  public ApiResponse<?> rule() {
    return ApiResponse.ok(service.adminRule());
  }

  @PreAuthorize("hasAuthority('business:service-liability-rule:update') or hasRole('admin')")
  @PutMapping("/api/business/service-liability-rule")
  public ApiResponse<?> update(
      Authentication auth, @RequestBody ServiceLiabilityRuleService.RuleCommand command, HttpServletRequest request) {
    service.updateRule(command);
    audit.operation(auth, "business:service-liability-rule:update", "SERVICE_LIABILITY_RULE", null, "修改服务责任规则", request);
    return ApiResponse.ok();
  }
}
