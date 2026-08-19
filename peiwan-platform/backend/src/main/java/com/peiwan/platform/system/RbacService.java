package com.peiwan.platform.system;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.peiwan.platform.persistence.entity.SystemRoleEntity;
import com.peiwan.platform.persistence.entity.SystemUserEntity;
import com.peiwan.platform.persistence.entity.SystemMenuEntity;
import com.peiwan.platform.persistence.mapper.SystemRelationMapper;
import com.peiwan.platform.persistence.mapper.SystemRoleMapper;
import com.peiwan.platform.persistence.mapper.SystemUserMapper;
import com.peiwan.platform.persistence.mapper.SystemMenuMapper;
import com.peiwan.platform.persistence.mapper.SystemLogQueryMapper;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service
public class RbacService {
  private final RbacRepository repo;
  private final PasswordEncoder encoder;
  private final SystemUserMapper userMapper;
  private final SystemRoleMapper roleMapper;
  private final SystemMenuMapper menuMapper;
  private final SystemLogQueryMapper logQueries;
  private final SystemRelationMapper relations;
  public RbacService(RbacRepository repo, PasswordEncoder encoder, SystemUserMapper userMapper, SystemRoleMapper roleMapper, SystemMenuMapper menuMapper, SystemRelationMapper relations,SystemLogQueryMapper logQueries) {
    this.repo = repo; this.encoder = encoder; this.userMapper = userMapper; this.roleMapper = roleMapper; this.menuMapper = menuMapper; this.relations = relations;this.logQueries=logQueries;
  }

  public Map<String,Object> users(int current, int size, String userName, String userPhone, String userEmail, String status) {
    current = Math.max(current, 1); size = Math.min(Math.max(size, 1), 200);
    var query = new QueryWrapper<SystemUserEntity>().like("username", Objects.toString(userName, ""));
    if (userPhone != null && !userPhone.isBlank()) query.like("phone", userPhone.trim());
    if (userEmail != null && !userEmail.isBlank()) query.like("email", userEmail.trim());
    if (status != null && !status.isBlank()) query.eq("enabled", "1".equals(status));
    query.orderByAsc("id");
    var result = userMapper.selectPage(Page.of(current, size), query);
    var records = result.getRecords().stream().map(this::userView).toList();
    return page(records, current, size, result.getTotal());
  }

  public List<Map<String,Object>> roleOptions() {
    return roleMapper.selectList(new QueryWrapper<SystemRoleEntity>().orderByAsc("id")).stream().map(role -> {
      Map<String,Object> option = new LinkedHashMap<>();
      option.put("roleId", role.id);
      option.put("roleName", role.name);
      option.put("roleCode", role.code);
      option.put("enabled", role.enabled);
      return option;
    }).toList();
  }

  public Map<String,Object> loginLogs(int current,int size,String username,Boolean success){
    current=Math.max(current,1);size=Math.min(Math.max(size,1),200);var result=logQueries.loginLogs(new Page<>(current,size),Objects.toString(username,""),success);return page(result.getRecords().stream().map(this::loginLogView).toList(),current,size,result.getTotal());
  }

  public Map<String,Object> operationLogs(int current,int size,String operator,String operation,String targetType){
    current=Math.max(current,1);size=Math.min(Math.max(size,1),200);var result=logQueries.operationLogs(new Page<>(current,size),Objects.toString(operator,""),Objects.toString(operation,""),Objects.toString(targetType,""));return page(result.getRecords().stream().map(this::operationLogView).toList(),current,size,result.getTotal());
  }

  @Transactional
  public long createUser(UserCommand c) {
    validateUser(c, true);
    if (c.password() == null || c.password().length() < 8) throw new IllegalArgumentException("初始密码至少8位");
    try {
      var user = new SystemUserEntity(); user.username=c.userName(); user.password=encoder.encode(c.password());
      user.nickname=blankDefault(c.nickName(),c.userName()); user.email=c.userEmail(); user.phone=c.userPhone();
      user.gender=c.userGender(); user.avatar=c.avatar(); user.enabled=c.enabled(); userMapper.insert(user);
      replaceUserRoles(user.id, c.roleIds());
      return user.id;
    } catch (DuplicateKeyException e) { throw new IllegalArgumentException("用户名已存在"); }
  }

  @Transactional
  public BatchUserResult batchCreateUsers(BatchUserCommand command) {
    if (command.phones() == null || command.phones().isEmpty()) throw new IllegalArgumentException("请至少输入一个手机号");
    if (command.phones().size() > 200) throw new IllegalArgumentException("单次最多创建200个用户");
    if (command.password() == null || command.password().length() < 8 || command.password().length() > 64) {
      throw new IllegalArgumentException("初始密码需为8-64位");
    }

    var uniquePhones = new LinkedHashSet<String>();
    var duplicatePhones = new LinkedHashSet<String>();
    var invalidPhones = new LinkedHashSet<String>();
    for (var rawPhone : command.phones()) {
      var phone = rawPhone == null ? "" : rawPhone.trim();
      if (!phone.matches("1[3-9]\\d{9}")) {
        if (!phone.isBlank()) invalidPhones.add(phone);
      } else if (!uniquePhones.add(phone)) {
        duplicatePhones.add(phone);
      }
    }

    var existingPhones = new LinkedHashSet<String>();
    if (!uniquePhones.isEmpty()) {
      var query = new QueryWrapper<SystemUserEntity>()
        .and(q -> q.in("username", uniquePhones).or().in("phone", uniquePhones));
      for (var existing : userMapper.selectList(query)) {
        if (existing.username != null && uniquePhones.contains(existing.username)) existingPhones.add(existing.username);
        if (existing.phone != null && uniquePhones.contains(existing.phone)) existingPhones.add(existing.phone);
      }
    }

    var customerRole = roleMapper.selectOne(new QueryWrapper<SystemRoleEntity>().eq("code", "customer").eq("enabled", true));
    if (customerRole == null) throw new IllegalArgumentException("普通用户角色不存在或已停用");

    var createdPhones = new ArrayList<String>();
    for (var phone : uniquePhones) {
      if (existingPhones.contains(phone)) continue;
      var user = new SystemUserEntity();
      user.username = phone;
      user.password = encoder.encode(command.password());
      user.nickname = "用户" + phone.substring(7);
      user.phone = phone;
      user.gender = "未知";
      user.enabled = true;
      userMapper.insert(user);
      relations.addUserRole(user.id, customerRole.id);
      createdPhones.add(phone);
    }
    return new BatchUserResult(command.phones().size(), createdPhones.size(), createdPhones, new ArrayList<>(existingPhones), new ArrayList<>(duplicatePhones), new ArrayList<>(invalidPhones));
  }

  @Transactional
  public void updateUser(long id, UserCommand c, long operatorId) {
    var old = requiredUser(id); validateUser(c, false);
    if (repo.isEnabledAdmin(id) && !c.enabled() && repo.enabledAdminCount() <= 1) throw new IllegalArgumentException("不能禁用最后一个超级管理员");
    if (id == operatorId && !c.enabled()) throw new IllegalArgumentException("不能禁用当前登录账号");
    try {
      var user=new SystemUserEntity(); user.id=id; user.username=c.userName(); user.nickname=blankDefault(c.nickName(),c.userName());
      user.email=c.userEmail(); user.phone=c.userPhone(); user.gender=c.userGender(); user.avatar=c.avatar(); user.enabled=c.enabled();
      user.updatedAt=java.time.LocalDateTime.now(); userMapper.updateById(user);
    } catch (DuplicateKeyException e) { throw new IllegalArgumentException("用户名已存在"); }
    if (c.roleIds() != null) assignUserRoles(id, c.roleIds(), operatorId);
  }

  @Transactional
  public void setUserStatus(long id, boolean enabled, long operatorId) {
    requiredUser(id);
    if (!enabled && repo.isEnabledAdmin(id) && repo.enabledAdminCount() <= 1) throw new IllegalArgumentException("不能禁用最后一个超级管理员");
    if (!enabled && id == operatorId) throw new IllegalArgumentException("不能禁用当前登录账号");
    var user=new SystemUserEntity();user.id=id;user.enabled=enabled;user.updatedAt=java.time.LocalDateTime.now();userMapper.updateById(user);
  }

  public void resetPassword(long id, String password) {
    requiredUser(id); if (password == null || password.length() < 8) throw new IllegalArgumentException("新密码至少8位");
    var user=new SystemUserEntity();user.id=id;user.password=encoder.encode(password);user.updatedAt=java.time.LocalDateTime.now();userMapper.updateById(user);
  }

  @Transactional
  public void deleteUser(long id, long operatorId) {
    requiredUser(id);
    if (id == operatorId) throw new IllegalArgumentException("不能删除当前登录账号");
    if (repo.isEnabledAdmin(id) && repo.enabledAdminCount() <= 1) throw new IllegalArgumentException("不能删除最后一个超级管理员");
    relations.deleteUserRoles(id);
    userMapper.deleteById(id);
  }

  @Transactional
  public void assignUserRoles(long userId, Collection<Long> roleIds, long operatorId) {
    requiredUser(userId); var ids = cleanIds(roleIds); validateRoleIds(ids);
    boolean willBeAdmin = !ids.isEmpty() && roleMapper.selectCount(new QueryWrapper<SystemRoleEntity>().eq("code","admin").in("id",ids)) > 0;
    if (willBeAdmin && !repo.hasRole(operatorId, "admin")) throw new IllegalArgumentException("只有超级管理员可以分配超级管理员角色");
    if (repo.isEnabledAdmin(userId) && !willBeAdmin && repo.enabledAdminCount() <= 1) throw new IllegalArgumentException("不能移除最后一个超级管理员的管理员角色");
    replaceUserRoles(userId, ids);
  }

  private void replaceUserRoles(long userId, Collection<Long> roleIds) {
    var ids = cleanIds(roleIds); validateRoleIds(ids); relations.deleteUserRoles(userId);
    ids.forEach(roleId -> relations.addUserRole(userId, roleId));
  }

  public Map<String,Object> roles(int current, int size, String roleName, String roleCode, Boolean enabled) {
    current=Math.max(current,1);size=Math.min(Math.max(size,1),200);
    var query=new QueryWrapper<SystemRoleEntity>().like("name",Objects.toString(roleName,"")).like("code",Objects.toString(roleCode,""));
    if(enabled!=null)query.eq("enabled",enabled);query.orderByAsc("id");
    var result=roleMapper.selectPage(Page.of(current,size),query);
    return page(result.getRecords().stream().map(this::roleView).toList(),current,size,result.getTotal());
  }

  public long createRole(RoleCommand c) { validateRole(c);try{var role=new SystemRoleEntity();role.name=c.roleName();role.code=c.roleCode();role.description=c.description();role.enabled=c.enabled();role.builtIn=false;roleMapper.insert(role);return role.id;}catch(DuplicateKeyException e){throw new IllegalArgumentException("角色编码已存在");} }
  public void updateRole(long id, RoleCommand c) { var old=requiredRoleEntity(id);if(Boolean.TRUE.equals(old.builtIn)&&!Objects.equals(old.code,c.roleCode()))throw new IllegalArgumentException("内置角色编码不能修改");validateRole(c);try{old.name=c.roleName();old.code=c.roleCode();old.description=c.description();old.enabled=c.enabled();roleMapper.updateById(old);}catch(DuplicateKeyException e){throw new IllegalArgumentException("角色编码已存在");} }
  public void setRoleStatus(long id, boolean enabled) { var role=requiredRoleEntity(id);if(Boolean.TRUE.equals(role.builtIn)&&!enabled)throw new IllegalArgumentException("内置超级管理员角色不能禁用");role.enabled=enabled;roleMapper.updateById(role); }
  @Transactional public void deleteRole(long id) { var role=requiredRoleEntity(id);if(Boolean.TRUE.equals(role.builtIn)||"admin".equals(role.code))throw new IllegalArgumentException("内置超级管理员角色不能删除");relations.deleteRoleMenus(id);relations.deleteUsersByRole(id);roleMapper.deleteById(id); }
  public List<Long> roleMenus(long id) { requiredRoleEntity(id);return relations.roleMenuIds(id); }
  @Transactional public void assignRoleMenus(long id, Collection<Long> menuIds) { var role=requiredRoleEntity(id);if(Boolean.TRUE.equals(role.builtIn))throw new IllegalArgumentException("内置超级管理员默认拥有全部权限，无需授权");var ids=withAncestors(cleanIds(menuIds));validateMenuIds(ids);relations.deleteRoleMenus(id);ids.forEach(menuId->relations.addRoleMenu(id,menuId)); }

  public List<Map<String,Object>> allMenuRows() { return repo.allMenus(); }
  public long createMenu(MenuCommand c) { validateMenu(c,null);try{var menu=menuEntity(null,c);menuMapper.insert(menu);return menu.id;}catch(DuplicateKeyException e){throw new IllegalArgumentException("菜单唯一名称或按钮权限编码已存在");} }
  public void updateMenu(long id, MenuCommand c) { requiredMenuEntity(id);validateMenu(c,id);try{var menu=menuEntity(id,c);menu.updatedAt=java.time.LocalDateTime.now();menuMapper.updateById(menu);}catch(DuplicateKeyException e){throw new IllegalArgumentException("菜单唯一名称或按钮权限编码已存在");} }
  @Transactional public void deleteMenu(long id) { requiredMenuEntity(id);if(menuMapper.selectCount(new QueryWrapper<SystemMenuEntity>().eq("parent_id",id))>0)throw new IllegalArgumentException("请先删除子菜单或按钮权限");relations.deleteRolesByMenu(id);menuMapper.deleteById(id); }

  private void validateMenu(MenuCommand c, Long selfId) { if(c.name()==null||c.name().isBlank()||c.title()==null||c.title().isBlank())throw new IllegalArgumentException("菜单名称和标题不能为空");if(!Set.of("DIRECTORY","MENU","BUTTON").contains(c.type()))throw new IllegalArgumentException("菜单类型无效");if("BUTTON".equals(c.type())&&(c.authMark()==null||!c.authMark().matches("[a-z][a-z0-9-]*:[a-z][a-z0-9-]*:[a-z][a-z0-9-]*")))throw new IllegalArgumentException("按钮权限编码必须使用 模块:资源:动作 格式");if(!"BUTTON".equals(c.type())&&c.authMark()!=null&&!c.authMark().isBlank())throw new IllegalArgumentException("目录和菜单不能设置按钮权限编码");if(c.parentId()!=null){if(selfId!=null&&Objects.equals(c.parentId(),selfId))throw new IllegalArgumentException("不能将自身设为父节点");requiredMenu(c.parentId());if(selfId!=null&&descendantIds(selfId).contains(c.parentId()))throw new IllegalArgumentException("不能将节点移动到自己的子节点下");} }
  private String permissionMark(MenuCommand c){return "BUTTON".equals(c.type())?c.authMark():null;}
  private Set<Long> descendantIds(long id){var result=new HashSet<Long>();var queue=new ArrayDeque<Long>();queue.add(id);while(!queue.isEmpty()){var children=menuMapper.selectList(new QueryWrapper<SystemMenuEntity>().select("id").eq("parent_id",queue.remove()));for(var child:children)if(result.add(child.id))queue.add(child.id);}return result;}
  private Set<Long> withAncestors(Set<Long> ids){var all=new LinkedHashSet<>(ids);for(var id:new ArrayList<>(ids)){var cursor=id;while(true){var menu=menuMapper.selectById(cursor);if(menu==null||menu.parentId==null)break;if(!all.add(menu.parentId))break;cursor=menu.parentId;}}return all;}
  private void validateUser(UserCommand c,boolean creating){if(c.userName()==null||!c.userName().matches("[A-Za-z0-9_.-]{3,64}"))throw new IllegalArgumentException("用户名需为3-64位字母、数字或_.-");}
  private void validateRole(RoleCommand c){if(c.roleName()==null||c.roleName().isBlank())throw new IllegalArgumentException("角色名称不能为空");if(c.roleCode()==null||!c.roleCode().matches("[a-z][a-z0-9_-]{1,63}"))throw new IllegalArgumentException("角色编码格式不正确");}
  private void validateRoleIds(Set<Long> ids){if(ids.isEmpty())return;long count=roleMapper.selectCount(new QueryWrapper<SystemRoleEntity>().in("id",ids));if(count!=ids.size())throw new IllegalArgumentException("包含不存在的角色");}
  private void validateMenuIds(Set<Long> ids){if(ids.isEmpty())return;long count=menuMapper.selectCount(new QueryWrapper<SystemMenuEntity>().in("id",ids));if(count!=ids.size())throw new IllegalArgumentException("包含不存在的菜单权限");}
  private Map<String,Object> requiredUser(long id){return repo.user(id).orElseThrow(()->new IllegalArgumentException("用户不存在"));} private Map<String,Object> requiredRole(long id){return repo.role(id).orElseThrow(()->new IllegalArgumentException("角色不存在"));} private Map<String,Object> requiredMenu(long id){return repo.menu(id).orElseThrow(()->new IllegalArgumentException("菜单权限不存在"));}
  private SystemRoleEntity requiredRoleEntity(long id){var role=roleMapper.selectById(id);if(role==null)throw new IllegalArgumentException("角色不存在");return role;}
  private SystemMenuEntity requiredMenuEntity(long id){var menu=menuMapper.selectById(id);if(menu==null)throw new IllegalArgumentException("菜单权限不存在");return menu;}
  private SystemMenuEntity menuEntity(Long id,MenuCommand c){var m=new SystemMenuEntity();m.id=id;m.parentId=c.parentId();m.type=c.type();m.name=c.name();m.path=c.path();m.component=c.component();m.title=c.title();m.icon=c.icon();m.authMark=permissionMark(c);m.sortNo=c.sortNo();m.hidden=c.hidden();m.enabled=c.enabled();m.keepAlive=c.keepAlive();return m;}
  private Set<Long> cleanIds(Collection<Long> ids){return ids==null?new LinkedHashSet<>():new LinkedHashSet<>(ids.stream().filter(Objects::nonNull).toList());} private String placeholders(int n){return String.join(",",Collections.nCopies(n,"?"));} private String blankDefault(String value,String fallback){return value==null||value.isBlank()?fallback:value;}
  private Map<String,Object> page(Object records,int current,int size,long total){return Map.of("records",records,"current",current,"size",size,"total",total);}
  private Map<String,Object> roleView(Map<String,Object> r){var x=new LinkedHashMap<String,Object>();x.put("roleId",r.get("id"));x.put("roleName",r.get("name"));x.put("roleCode",r.get("code"));x.put("description",Objects.toString(r.get("description"),""));x.put("enabled",r.get("enabled"));x.put("builtIn",r.get("built_in"));x.put("createTime",r.get("created_at"));return x;}
  private Map<String,Object> roleView(SystemRoleEntity r){var x=new LinkedHashMap<String,Object>();x.put("roleId",r.id);x.put("roleName",r.name);x.put("roleCode",r.code);x.put("description",Objects.toString(r.description,""));x.put("enabled",r.enabled);x.put("builtIn",r.builtIn);x.put("createTime",r.createdAt);return x;}
  private Map<String,Object> loginLogView(Map<String,Object> r){var x=new LinkedHashMap<String,Object>();x.put("id",r.get("id"));x.put("username",r.get("username"));x.put("success",r.get("success"));x.put("ipAddress",r.get("ip_address"));x.put("userAgent",r.get("user_agent"));x.put("message",r.get("message"));x.put("createTime",r.get("created_at"));return x;}
  private Map<String,Object> operationLogView(Map<String,Object> r){var x=new LinkedHashMap<String,Object>();x.put("id",r.get("id"));x.put("operatorId",r.get("operator_id"));x.put("operatorName",Objects.toString(r.get("operator_name"),"未知用户"));x.put("operation",r.get("operation"));x.put("targetType",r.get("target_type"));x.put("targetId",r.get("target_id"));x.put("detail",r.get("detail"));x.put("ipAddress",r.get("ip_address"));x.put("createTime",r.get("created_at"));return x;}
  private Map<String,Object> userView(Map<String,Object> r,List<String> roles){var x=new LinkedHashMap<String,Object>();x.put("id",r.get("id"));x.put("avatar",r.get("avatar"));x.put("status",Boolean.TRUE.equals(r.get("enabled"))?"1":"2");x.put("enabled",r.get("enabled"));x.put("userName",r.get("username"));x.put("userGender",r.get("gender"));x.put("nickName",r.get("nickname"));x.put("userPhone",r.get("phone"));x.put("userEmail",r.get("email"));x.put("userRoles",roles);x.put("roleIds",repo.roleIds(((Number)r.get("id")).longValue()));x.put("createTime",r.get("created_at"));x.put("updateTime",r.get("updated_at"));return x;}
  private Map<String,Object> userView(SystemUserEntity r){var x=new LinkedHashMap<String,Object>();x.put("id",r.id);x.put("avatar",r.avatar);x.put("status",Boolean.TRUE.equals(r.enabled)?"1":"2");x.put("enabled",r.enabled);x.put("userName",r.username);x.put("userGender",r.gender);x.put("nickName",r.nickname);x.put("userPhone",r.phone);x.put("userEmail",r.email);x.put("userRoles",repo.roles(r.id));x.put("roleIds",repo.roleIds(r.id));x.put("createTime",r.createdAt);x.put("updateTime",r.updatedAt);return x;}

  public record UserCommand(String userName,String password,String nickName,String userPhone,String userEmail,String userGender,String avatar,boolean enabled,List<Long> roleIds){}
  public record BatchUserCommand(@jakarta.validation.constraints.NotEmpty List<String> phones,@jakarta.validation.constraints.NotBlank String password){}
  public record BatchUserResult(int inputCount,int createdCount,List<String> createdPhones,List<String> existingPhones,List<String> duplicatePhones,List<String> invalidPhones){}
  public record RoleCommand(String roleName,String roleCode,String description,boolean enabled){}
  public record MenuCommand(Long parentId,String type,String name,String path,String component,String title,String icon,String authMark,int sortNo,boolean hidden,boolean enabled,boolean keepAlive){}
}
