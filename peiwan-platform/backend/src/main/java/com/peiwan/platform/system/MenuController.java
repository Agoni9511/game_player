package com.peiwan.platform.system;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.common.AuditService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
public class MenuController {
  private final RbacRepository repo; private final RbacService service; private final AuditService audit;
  public MenuController(RbacRepository repo,RbacService service,AuditService audit){this.repo=repo;this.service=service;this.audit=audit;}

  @GetMapping("/api/v3/system/menus")
  public ApiResponse<?> menus(Authentication auth){return ApiResponse.ok(tree(repo.menus((Long)auth.getPrincipal())));}

  @PreAuthorize("hasAuthority('system:menu:list') or hasRole('admin')")
  @GetMapping("/api/menu/tree") public ApiResponse<?> allMenus(){return ApiResponse.ok(tree(service.allMenuRows()));}

  @PreAuthorize("hasAuthority('system:menu:create') or hasRole('admin')")
  @PostMapping("/api/menu") public ApiResponse<?> create(Authentication auth,@RequestBody RbacService.MenuCommand body,HttpServletRequest req){long id=service.createMenu(body);audit.operation(auth,"system:menu:create","MENU",id,"创建 "+body.name(),req);return ApiResponse.ok(Map.of("id",id));}

  @PreAuthorize("hasAuthority('system:menu:update') or hasRole('admin')")
  @PutMapping("/api/menu/{id}") public ApiResponse<?> update(Authentication auth,@PathVariable long id,@RequestBody RbacService.MenuCommand body,HttpServletRequest req){service.updateMenu(id,body);audit.operation(auth,"system:menu:update","MENU",id,"更新 "+body.name(),req);return ApiResponse.ok();}

  @PreAuthorize("hasAuthority('system:menu:delete') or hasRole('admin')")
  @DeleteMapping("/api/menu/{id}") public ApiResponse<?> delete(Authentication auth,@PathVariable long id,HttpServletRequest req){service.deleteMenu(id);audit.operation(auth,"system:menu:delete","MENU",id,"删除菜单权限",req);return ApiResponse.ok();}

  @SuppressWarnings("unchecked")
  private List<Map<String,Object>> tree(List<Map<String,Object>> rows){
    var nodes=new LinkedHashMap<Long,Map<String,Object>>();var roots=new ArrayList<Map<String,Object>>();
    for(var r:rows)if(!"BUTTON".equals(r.get("type"))){long id=((Number)r.get("id")).longValue();var n=new LinkedHashMap<String,Object>();n.put("id",id);n.put("parentId",r.get("parent_id"));n.put("type",r.get("type"));n.put("name",r.get("name"));n.put("path",r.get("path"));n.put("component",r.get("component"));n.put("sortNo",r.get("sort_no"));n.put("enabled",r.get("enabled"));var meta=new LinkedHashMap<String,Object>();meta.put("title",r.get("title"));meta.put("icon",r.get("icon"));meta.put("isHide",r.get("hidden"));meta.put("keepAlive",r.get("keep_alive"));meta.put("authList",new ArrayList<>());n.put("meta",meta);n.put("children",new ArrayList<>());nodes.put(id,n);}
    for(var r:rows){long id=((Number)r.get("id")).longValue();Object parent=r.get("parent_id");if("BUTTON".equals(r.get("type"))){if(parent!=null&&nodes.containsKey(((Number)parent).longValue())){var auth=new LinkedHashMap<String,Object>();auth.put("id",id);auth.put("title",r.get("title"));auth.put("authMark",r.get("auth_mark"));auth.put("name",r.get("name"));auth.put("sortNo",r.get("sort_no"));auth.put("enabled",r.get("enabled"));((List<Map<String,Object>>)((Map<String,Object>)nodes.get(((Number)parent).longValue()).get("meta")).get("authList")).add(auth);}continue;}var n=nodes.get(id);if(parent==null)roots.add(n);else{var p=nodes.get(((Number)parent).longValue());if(p!=null)((List<Map<String,Object>>)p.get("children")).add(n);else roots.add(n);}}
    return roots;
  }
}
