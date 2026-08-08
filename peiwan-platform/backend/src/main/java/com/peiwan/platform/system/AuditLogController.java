package com.peiwan.platform.system;

import com.peiwan.platform.common.ApiResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
public class AuditLogController {
  private final RbacService service;
  public AuditLogController(RbacService service){this.service=service;}

  @PreAuthorize("hasAuthority('system:login-log:list') or hasRole('admin')")
  @GetMapping("/api/login-log/list")
  public ApiResponse<?> loginLogs(@RequestParam(defaultValue="1") int current,@RequestParam(defaultValue="20") int size,@RequestParam(required=false) String username,@RequestParam(required=false) Boolean success){return ApiResponse.ok(service.loginLogs(current,size,username,success));}

  @PreAuthorize("hasAuthority('system:operation-log:list') or hasRole('admin')")
  @GetMapping("/api/operation-log/list")
  public ApiResponse<?> operationLogs(@RequestParam(defaultValue="1") int current,@RequestParam(defaultValue="20") int size,@RequestParam(required=false) String operator,@RequestParam(required=false) String operation,@RequestParam(required=false) String targetType){return ApiResponse.ok(service.operationLogs(current,size,operator,operation,targetType));}
}
