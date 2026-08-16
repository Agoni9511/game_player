package com.peiwan.platform.player;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.common.AuditService;
import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PlayerApplicationController {
  private final PlayerApplicationService service;
  private final AuditService audit;

  public PlayerApplicationController(PlayerApplicationService service, AuditService audit) {
    this.service = service;
    this.audit = audit;
  }

  @PreAuthorize("hasRole('customer')")
  @GetMapping("/api/customer/player-application")
  public ApiResponse<?> own(Authentication authentication) {
    return ApiResponse.ok(service.ownLatest(uid(authentication)));
  }

  @PreAuthorize("hasRole('customer')")
  @PostMapping("/api/customer/player-application")
  public ApiResponse<?> create(Authentication authentication, @RequestBody PlayerApplicationService.Command command, HttpServletRequest request) {
    long id = service.create(uid(authentication), command);
    audit.operation(authentication, "customer:player-application:create", "PLAYER_APPLICATION", id, "提交陪玩师入驻申请", request);
    return ApiResponse.ok(Map.of("id", id));
  }

  @PreAuthorize("hasAuthority('business:player:list') or hasRole('admin')")
  @GetMapping("/api/business/player-applications")
  public ApiResponse<?> list(@RequestParam(defaultValue = "1") int current, @RequestParam(defaultValue = "20") int size, @RequestParam(required = false) String keyword, @RequestParam(required = false) String status) {
    return ApiResponse.ok(service.list(current, size, keyword, status));
  }

  @PreAuthorize("hasAuthority('business:player:audit') or hasRole('admin')")
  @PutMapping("/api/business/player-applications/{id}")
  public ApiResponse<?> handle(Authentication authentication, @PathVariable long id, @RequestBody PlayerApplicationService.HandleCommand command, HttpServletRequest request) {
    service.handle(id, command, uid(authentication));
    audit.operation(authentication, "business:player:audit", "PLAYER_APPLICATION", id, command.status() + ":" + command.remark(), request);
    return ApiResponse.ok();
  }

  private long uid(Authentication authentication) {
    return ((Number) authentication.getPrincipal()).longValue();
  }
}

