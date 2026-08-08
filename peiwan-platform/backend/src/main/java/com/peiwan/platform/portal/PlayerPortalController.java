package com.peiwan.platform.portal;

import com.peiwan.platform.common.*;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController @RequestMapping("/api/player")
public class PlayerPortalController {
  private final PlayerPortalService service;private final AuditService audit;
  public PlayerPortalController(PlayerPortalService service,AuditService audit){this.service=service;this.audit=audit;}
  @PreAuthorize("hasAuthority('player:workbench:view')") @GetMapping("/workbench") public ApiResponse<?> workbench(Authentication a){return ApiResponse.ok(service.workbench(uid(a)));}
  @PreAuthorize("hasAuthority('player:work-status:update')") @PutMapping("/work-status") public ApiResponse<?> status(Authentication a,@RequestBody StatusBody b,HttpServletRequest r){service.workStatus(uid(a),b.workStatus());audit.operation(a,"player:work-status:update","PLAYER",null,b.workStatus(),r);return ApiResponse.ok();}
  @PreAuthorize("hasAuthority('player:dispatch:list')") @GetMapping("/dispatch/pending") public ApiResponse<?> pending(Authentication a){return ApiResponse.ok(service.pendingDispatches(uid(a)));}
  @PreAuthorize("hasAuthority('player:dispatch:accept')") @PutMapping("/dispatch/{id}/accept") public ApiResponse<?> accept(Authentication a,@PathVariable long id,HttpServletRequest r){service.respond(uid(a),id,"ACCEPT","");audit.operation(a,"player:dispatch:accept","DISPATCH",id,"接受派单",r);return ApiResponse.ok();}
  @PreAuthorize("hasAuthority('player:dispatch:reject')") @PutMapping("/dispatch/{id}/reject") public ApiResponse<?> reject(Authentication a,@PathVariable long id,@RequestBody ReasonBody b,HttpServletRequest r){service.respond(uid(a),id,"REJECT",b.reason());audit.operation(a,"player:dispatch:reject","DISPATCH",id,b.reason(),r);return ApiResponse.ok();}
  @PreAuthorize("hasAuthority('player:order:list')") @GetMapping("/orders") public ApiResponse<?> orders(Authentication a,@RequestParam(defaultValue="1")int current,@RequestParam(defaultValue="20")int size,@RequestParam(required=false)String status){return ApiResponse.ok(service.ownOrders(uid(a),current,size,status));}
  @PreAuthorize("hasAuthority('player:order:detail')") @GetMapping("/orders/{id}") public ApiResponse<?> order(Authentication a,@PathVariable long id){return ApiResponse.ok(service.ownOrder(uid(a),id));}
  private long uid(Authentication a){return (Long)a.getPrincipal();} public record StatusBody(String workStatus){} public record ReasonBody(String reason){}
}
