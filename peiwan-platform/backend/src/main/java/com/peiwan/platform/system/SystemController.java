package com.peiwan.platform.system;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.common.AuditService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
public class SystemController {
  private final RbacService service; private final AuditService audit;
  public SystemController(RbacService service, AuditService audit) { this.service=service; this.audit=audit; }

  @PreAuthorize("hasAuthority('system:user:list') or hasRole('admin')")
  @GetMapping("/api/user/list")
  public ApiResponse<?> users(@RequestParam(defaultValue="1") int current,@RequestParam(defaultValue="20") int size,@RequestParam(required=false) String userName,@RequestParam(required=false) String userPhone,@RequestParam(required=false) String userEmail,@RequestParam(required=false) String status) { return ApiResponse.ok(service.users(current,size,userName,userPhone,userEmail,status)); }

  @PreAuthorize("hasAnyAuthority('system:user:create','system:user:update','system:user:assign-role') or hasRole('admin')")
  @GetMapping("/api/role/options") public ApiResponse<?> roleOptions() { return ApiResponse.ok(service.roleOptions()); }

  @PreAuthorize("hasAuthority('system:user:create') or hasRole('admin')")
  @PostMapping("/api/user") public ApiResponse<?> createUser(Authentication auth,@Valid @RequestBody RbacService.UserCommand body,HttpServletRequest req) { long id=service.createUser(body);audit.operation(auth,"system:user:create","USER",id,"创建用户 "+body.userName(),req);return ApiResponse.ok(Map.of("id",id)); }

  @PreAuthorize("hasAuthority('system:user:create') or hasRole('admin')")
  @PostMapping("/api/user/batch") public ApiResponse<?> batchCreateUsers(Authentication auth,@Valid @RequestBody RbacService.BatchUserCommand body,HttpServletRequest req) { var result=service.batchCreateUsers(body);audit.operation(auth,"system:user:create","USER_BATCH",null,"批量创建用户：成功="+result.createdCount()+"，已存在="+result.existingPhones().size()+"，无效="+result.invalidPhones().size(),req);return ApiResponse.ok(result); }

  @PreAuthorize("hasAuthority('system:user:update') or hasRole('admin')")
  @PutMapping("/api/user/{id}") public ApiResponse<?> updateUser(Authentication auth,@PathVariable long id,@Valid @RequestBody RbacService.UserCommand body,HttpServletRequest req) { service.updateUser(id,body,(Long)auth.getPrincipal());audit.operation(auth,"system:user:update","USER",id,"更新用户 "+body.userName(),req);return ApiResponse.ok(); }

  @PreAuthorize("hasAuthority('system:user:status') or hasRole('admin')")
  @PutMapping("/api/user/{id}/status") public ApiResponse<?> userStatus(Authentication auth,@PathVariable long id,@RequestBody StatusBody body,HttpServletRequest req) { service.setUserStatus(id,body.enabled(),(Long)auth.getPrincipal());audit.operation(auth,"system:user:status","USER",id,"enabled="+body.enabled(),req);return ApiResponse.ok(); }

  @PreAuthorize("hasAuthority('system:user:reset-password') or hasRole('admin')")
  @PutMapping("/api/user/{id}/password") public ApiResponse<?> resetPassword(Authentication auth,@PathVariable long id,@RequestBody PasswordBody body,HttpServletRequest req) { service.resetPassword(id,body.password());audit.operation(auth,"system:user:reset-password","USER",id,"重置密码",req);return ApiResponse.ok(); }

  @PreAuthorize("hasAuthority('system:user:assign-role') or hasRole('admin')")
  @PutMapping("/api/user/{id}/roles") public ApiResponse<?> assignUserRoles(Authentication auth,@PathVariable long id,@RequestBody IdsBody body,HttpServletRequest req) { service.assignUserRoles(id,body.ids(),(Long)auth.getPrincipal());audit.operation(auth,"system:user:assign-role","USER",id,"roleIds="+body.ids(),req);return ApiResponse.ok(); }

  @PreAuthorize("hasAuthority('system:user:delete') or hasRole('admin')")
  @DeleteMapping("/api/user/{id}") public ApiResponse<?> deleteUser(Authentication auth,@PathVariable long id,HttpServletRequest req) { service.deleteUser(id,(Long)auth.getPrincipal());audit.operation(auth,"system:user:delete","USER",id,"删除用户",req);return ApiResponse.ok(); }

  @PreAuthorize("hasAuthority('system:role:list') or hasRole('admin')")
  @GetMapping("/api/role/list") public ApiResponse<?> roles(@RequestParam(defaultValue="1") int current,@RequestParam(defaultValue="20") int size,@RequestParam(required=false) String roleName,@RequestParam(required=false) String roleCode,@RequestParam(required=false) Boolean enabled) { return ApiResponse.ok(service.roles(current,size,roleName,roleCode,enabled)); }

  @PreAuthorize("hasAuthority('system:role:create') or hasRole('admin')")
  @PostMapping("/api/role") public ApiResponse<?> createRole(Authentication auth,@RequestBody RbacService.RoleCommand body,HttpServletRequest req) { long id=service.createRole(body);audit.operation(auth,"system:role:create","ROLE",id,"创建角色 "+body.roleCode(),req);return ApiResponse.ok(Map.of("id",id)); }

  @PreAuthorize("hasAuthority('system:role:update') or hasRole('admin')")
  @PutMapping("/api/role/{id}") public ApiResponse<?> updateRole(Authentication auth,@PathVariable long id,@RequestBody RbacService.RoleCommand body,HttpServletRequest req) { service.updateRole(id,body);audit.operation(auth,"system:role:update","ROLE",id,"更新角色 "+body.roleCode(),req);return ApiResponse.ok(); }

  @PreAuthorize("hasAuthority('system:role:status') or hasRole('admin')")
  @PutMapping("/api/role/{id}/status") public ApiResponse<?> roleStatus(Authentication auth,@PathVariable long id,@RequestBody StatusBody body,HttpServletRequest req) { service.setRoleStatus(id,body.enabled());audit.operation(auth,"system:role:status","ROLE",id,"enabled="+body.enabled(),req);return ApiResponse.ok(); }

  @PreAuthorize("hasAuthority('system:role:delete') or hasRole('admin')")
  @DeleteMapping("/api/role/{id}") public ApiResponse<?> deleteRole(Authentication auth,@PathVariable long id,HttpServletRequest req) { service.deleteRole(id);audit.operation(auth,"system:role:delete","ROLE",id,"删除角色",req);return ApiResponse.ok(); }

  @PreAuthorize("hasAuthority('system:role:assign') or hasRole('admin')")
  @GetMapping("/api/role/{id}/menus") public ApiResponse<?> roleMenus(@PathVariable long id) { return ApiResponse.ok(service.roleMenus(id)); }

  @PreAuthorize("hasAuthority('system:role:assign') or hasRole('admin')")
  @PutMapping("/api/role/{id}/menus") public ApiResponse<?> assignMenus(Authentication auth,@PathVariable long id,@RequestBody IdsBody body,HttpServletRequest req) { service.assignRoleMenus(id,body.ids());audit.operation(auth,"system:role:assign","ROLE",id,"menuIds="+body.ids(),req);return ApiResponse.ok(); }

  public record StatusBody(boolean enabled) {}
  public record PasswordBody(@NotBlank String password) {}
  public record IdsBody(List<Long> ids) { public IdsBody { ids = ids == null ? List.of() : ids; } }
}
