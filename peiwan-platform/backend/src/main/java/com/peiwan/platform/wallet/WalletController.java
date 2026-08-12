package com.peiwan.platform.wallet;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.common.AuditService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class WalletController {
  private final WalletService service;
  private final AuditService audit;

  public WalletController(WalletService service, AuditService audit) {
    this.service = service;
    this.audit = audit;
  }

  @PreAuthorize("hasAuthority('customer:wallet:view')")
  @GetMapping("/api/customer/wallet")
  public ApiResponse<?> wallet(Authentication authentication) {
    return ApiResponse.ok(service.summary(uid(authentication)));
  }

  @PreAuthorize("hasAuthority('customer:wallet:view')")
  @GetMapping("/api/customer/recharge-plans")
  public ApiResponse<?> plans() {
    return ApiResponse.ok(service.enabledPlans());
  }

  @PreAuthorize("hasAuthority('customer:wallet:transaction:list')")
  @GetMapping("/api/customer/wallet/transactions")
  public ApiResponse<?> transactions(
    Authentication authentication,
    @RequestParam(defaultValue = "1") int current,
    @RequestParam(defaultValue = "20") int size,
    @RequestParam(required = false) String businessType
  ) {
    return ApiResponse.ok(service.transactionPage(uid(authentication), current, size, businessType));
  }

  @PreAuthorize("hasAuthority('customer:wallet:recharge')")
  @PostMapping("/api/customer/wallet/recharge")
  public ApiResponse<?> recharge(Authentication authentication, @RequestBody Recharge body, HttpServletRequest request) {
    var result = service.simulateRecharge(uid(authentication), body.planId(), body.requestNo());
    audit.operation(authentication, "customer:wallet:recharge", "WALLET", uid(authentication), "plan=" + body.planId() + ",requestNo=" + body.requestNo(), request);
    return ApiResponse.ok(result);
  }

  @PreAuthorize("hasAuthority('business:recharge-plan:list')")
  @GetMapping("/api/business/recharge-plan/list")
  public ApiResponse<?> adminPlans(
    @RequestParam(defaultValue = "1") int current,
    @RequestParam(defaultValue = "20") int size
  ) {
    return ApiResponse.ok(service.adminPlans(current, size));
  }

  @PreAuthorize("hasAuthority('business:recharge-plan:create')")
  @PostMapping("/api/business/recharge-plan")
  public ApiResponse<?> createPlan(Authentication authentication, @RequestBody WalletService.PlanCommand body, HttpServletRequest request) {
    long id = service.savePlan(null, body);
    audit.operation(authentication, "business:recharge-plan:create", "RECHARGE_PLAN", id, body.planCode(), request);
    return ApiResponse.ok(Map.of("id", id));
  }

  @PreAuthorize("hasAuthority('business:recharge-plan:update')")
  @PutMapping("/api/business/recharge-plan/{id}")
  public ApiResponse<?> updatePlan(
    Authentication authentication,
    @PathVariable long id,
    @RequestBody WalletService.PlanCommand body,
    HttpServletRequest request
  ) {
    service.savePlan(id, body);
    audit.operation(authentication, "business:recharge-plan:update", "RECHARGE_PLAN", id, body.planCode(), request);
    return ApiResponse.ok();
  }

  @PreAuthorize("hasAuthority('business:recharge-plan:status')")
  @PutMapping("/api/business/recharge-plan/{id}/status")
  public ApiResponse<?> planStatus(
    Authentication authentication,
    @PathVariable long id,
    @RequestBody Status body,
    HttpServletRequest request
  ) {
    service.status(id, body.enabled());
    audit.operation(authentication, "business:recharge-plan:status", "RECHARGE_PLAN", id, "enabled=" + body.enabled(), request);
    return ApiResponse.ok();
  }

  @PreAuthorize("hasAuthority('business:member-level:list') or hasRole('admin')")
  @GetMapping("/api/business/member-level/list")
  public ApiResponse<?> memberLevels(
    @RequestParam(defaultValue = "1") int current,
    @RequestParam(defaultValue = "20") int size,
    @RequestParam(required = false) String keyword,
    @RequestParam(required = false) Boolean enabled
  ) {
    return ApiResponse.ok(service.memberLevelPage(current, size, keyword, enabled));
  }

  @PreAuthorize("hasAuthority('business:member-level:create') or hasRole('admin')")
  @PostMapping("/api/business/member-level")
  public ApiResponse<?> createMemberLevel(
    Authentication authentication,
    @RequestBody WalletService.MemberLevelCommand body,
    HttpServletRequest request
  ) {
    long id = service.saveMemberLevel(null, body);
    audit.operation(authentication, "business:member-level:create", "MEMBER_LEVEL", id, body.levelName(), request);
    return ApiResponse.ok(Map.of("id", id));
  }

  @PreAuthorize("hasAuthority('business:member-level:update') or hasRole('admin')")
  @PutMapping("/api/business/member-level/{id}")
  public ApiResponse<?> updateMemberLevel(
    Authentication authentication,
    @PathVariable long id,
    @RequestBody WalletService.MemberLevelCommand body,
    HttpServletRequest request
  ) {
    service.saveMemberLevel(id, body);
    audit.operation(authentication, "business:member-level:update", "MEMBER_LEVEL", id, body.levelName(), request);
    return ApiResponse.ok();
  }

  @PreAuthorize("hasAuthority('business:member-level:status') or hasRole('admin')")
  @PutMapping("/api/business/member-level/{id}/status")
  public ApiResponse<?> memberLevelStatus(
    Authentication authentication,
    @PathVariable long id,
    @RequestBody Status body,
    HttpServletRequest request
  ) {
    service.setMemberLevelStatus(id, body.enabled());
    audit.operation(authentication, "business:member-level:status", "MEMBER_LEVEL", id, "enabled=" + body.enabled(), request);
    return ApiResponse.ok();
  }

  @PreAuthorize("hasAuthority('business:member-level:delete') or hasRole('admin')")
  @DeleteMapping("/api/business/member-level/{id}")
  public ApiResponse<?> deleteMemberLevel(
    Authentication authentication,
    @PathVariable long id,
    HttpServletRequest request
  ) {
    service.deleteMemberLevel(id);
    audit.operation(authentication, "business:member-level:delete", "MEMBER_LEVEL", id, "删除会员等级", request);
    return ApiResponse.ok();
  }

  private long uid(Authentication authentication) {
    return (Long) authentication.getPrincipal();
  }

  public record Recharge(long planId, String requestNo) {}

  public record Status(boolean enabled) {}
}
