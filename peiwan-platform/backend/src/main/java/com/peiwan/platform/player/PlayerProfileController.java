package com.peiwan.platform.player;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.common.AuditService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PlayerProfileController {
  private final PlayerProfileDraftService service;
  private final AuditService audit;

  public PlayerProfileController(PlayerProfileDraftService service, AuditService audit) {
    this.service = service;
    this.audit = audit;
  }

  @PreAuthorize("hasRole('player')")
  @GetMapping("/api/player/profile")
  public ApiResponse<?> own(Authentication authentication) {
    return ApiResponse.ok(service.ownProfile(uid(authentication)));
  }

  @PreAuthorize("hasRole('player')")
  @GetMapping("/api/player/profile/options")
  public ApiResponse<?> options() {
    return ApiResponse.ok(service.options());
  }

  @PreAuthorize("hasRole('player')")
  @PutMapping("/api/player/profile/draft")
  public ApiResponse<?> save(Authentication authentication, @RequestBody PlayerProfileDraftService.SelfProfileCommand body) {
    service.save(uid(authentication), body);
    return ApiResponse.ok();
  }

  @PreAuthorize("hasRole('player')")
  @PostMapping("/api/player/profile/submit")
  public ApiResponse<?> submit(Authentication authentication) {
    service.submit(uid(authentication));
    return ApiResponse.ok();
  }

  @PreAuthorize("hasAuthority('business:player:audit') or hasRole('admin')")
  @GetMapping("/api/business/player-profile-draft/list")
  public ApiResponse<?> list(@RequestParam(required = false) String status) {
    return ApiResponse.ok(service.auditList(status));
  }

  @PreAuthorize("hasAuthority('business:player:audit') or hasRole('admin')")
  @GetMapping("/api/business/player-profile-draft/{id}")
  public ApiResponse<?> detail(@PathVariable long id) {
    return ApiResponse.ok(service.auditDetail(id));
  }

  @PreAuthorize("hasAuthority('business:player:audit') or hasRole('admin')")
  @PutMapping("/api/business/player-profile-draft/{id}/audit")
  public ApiResponse<?> review(
      Authentication authentication,
      @PathVariable long id,
      @RequestBody AuditBody body,
      HttpServletRequest request) {
    service.audit(id, body.action(), body.remark(), uid(authentication));
    audit.operation(authentication, "business:player:audit", "PLAYER_PROFILE_DRAFT", id, body.action(), request);
    return ApiResponse.ok();
  }

  private long uid(Authentication authentication) { return (Long) authentication.getPrincipal(); }
  public record AuditBody(String action, String remark) {}
}
