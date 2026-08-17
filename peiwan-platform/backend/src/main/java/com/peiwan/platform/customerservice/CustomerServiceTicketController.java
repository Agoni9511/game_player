package com.peiwan.platform.customerservice;

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
public class CustomerServiceTicketController {
  private final CustomerServiceTicketService service;
  private final AuditService audit;

  public CustomerServiceTicketController(CustomerServiceTicketService service, AuditService audit) {
    this.service = service;
    this.audit = audit;
  }

  @PreAuthorize("hasAnyRole('customer','player')")
  @PostMapping("/api/customer-service/tickets")
  public ApiResponse<?> create(Authentication authentication, @RequestBody CustomerServiceTicketService.CreateCommand command, HttpServletRequest request) {
    long id = service.create(uid(authentication), command);
    audit.operation(authentication, "customer-service:ticket:create", "CUSTOMER_SERVICE_TICKET", id, command.subject(), request);
    return ApiResponse.ok(Map.of("id", id));
  }

  @PreAuthorize("hasAnyRole('customer','player')")
  @GetMapping("/api/customer-service/tickets")
  public ApiResponse<?> ownList(Authentication authentication, @RequestParam(defaultValue = "1") int current, @RequestParam(defaultValue = "20") int size) {
    return ApiResponse.ok(service.ownList(uid(authentication), current, size));
  }

  @PreAuthorize("hasAnyRole('customer','player')")
  @GetMapping("/api/customer-service/tickets/{id}")
  public ApiResponse<?> ownDetail(Authentication authentication, @PathVariable long id) {
    return ApiResponse.ok(service.ownDetail(uid(authentication), id));
  }

  @PreAuthorize("hasAnyRole('customer','player')")
  @PostMapping("/api/customer-service/tickets/{id}/messages")
  public ApiResponse<?> customerReply(Authentication authentication, @PathVariable long id,
      @RequestBody CustomerServiceTicketService.ReplyCommand command, HttpServletRequest request) {
    service.customerReply(uid(authentication), id, command.content());
    audit.operation(authentication, "customer-service:ticket:reply", "CUSTOMER_SERVICE_TICKET", id, "用户回复", request);
    return ApiResponse.ok();
  }

  @PreAuthorize("hasAuthority('business:customer-service:list') or hasRole('admin')")
  @GetMapping("/api/business/customer-service/tickets")
  public ApiResponse<?> adminList(@RequestParam(defaultValue = "1") int current, @RequestParam(defaultValue = "20") int size,
      @RequestParam(required = false) String keyword, @RequestParam(required = false) String status,
      @RequestParam(required = false) String category) {
    return ApiResponse.ok(service.adminList(current, size, keyword, status, category));
  }

  @PreAuthorize("hasAuthority('business:customer-service:list') or hasRole('admin')")
  @GetMapping("/api/business/customer-service/tickets/{id}")
  public ApiResponse<?> adminDetail(@PathVariable long id) {
    return ApiResponse.ok(service.adminDetail(id));
  }

  @PreAuthorize("hasAuthority('business:customer-service:reply') or hasRole('admin')")
  @PostMapping("/api/business/customer-service/tickets/{id}/messages")
  public ApiResponse<?> adminReply(Authentication authentication, @PathVariable long id,
      @RequestBody CustomerServiceTicketService.ReplyCommand command, HttpServletRequest request) {
    service.adminReply(id, uid(authentication), command.content());
    audit.operation(authentication, "business:customer-service:reply", "CUSTOMER_SERVICE_TICKET", id, "客服回复", request);
    return ApiResponse.ok();
  }

  @PreAuthorize("hasAuthority('business:customer-service:status') or hasRole('admin')")
  @PutMapping("/api/business/customer-service/tickets/{id}/status")
  public ApiResponse<?> changeStatus(Authentication authentication, @PathVariable long id,
      @RequestBody CustomerServiceTicketService.StatusCommand command, HttpServletRequest request) {
    service.changeStatus(id, uid(authentication), command.status());
    audit.operation(authentication, "business:customer-service:status", "CUSTOMER_SERVICE_TICKET", id, command.status(), request);
    return ApiResponse.ok();
  }

  private long uid(Authentication authentication) {
    return ((Number) authentication.getPrincipal()).longValue();
  }
}
