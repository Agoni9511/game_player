package com.peiwan.platform.auth;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.common.AuditService;
import com.peiwan.platform.system.RbacRepository;
import com.peiwan.platform.persistence.mapper.SystemUserMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
public class AuthController {
  private final RbacRepository repo;private final PasswordEncoder encoder;private final JwtService jwt;private final AuditService audit;private final SystemUserMapper users;
  public AuthController(RbacRepository repo,PasswordEncoder encoder,JwtService jwt,AuditService audit,SystemUserMapper users){this.repo=repo;this.encoder=encoder;this.jwt=jwt;this.audit=audit;this.users=users;}
  public record Login(@NotBlank String userName,@NotBlank String password){}
  public record ProfileUpdate(String nickName,String gender,String phone,String email,String avatar){}

  @PostMapping("/api/auth/login")
  public ApiResponse<?> login(@Valid @RequestBody Login body,HttpServletRequest request){
    var optional=repo.userByName(body.userName());
    if(optional.isEmpty()||!Boolean.TRUE.equals(optional.get().get("enabled"))||!encoder.matches(body.password(),String.valueOf(optional.get().get("password")))){
      audit.login(body.userName(),false,"账号或密码错误",request);throw new LoginFailedException();
    }
    var u=optional.get();long id=((Number)u.get("id")).longValue();audit.login(body.userName(),true,"登录成功",request);
    return ApiResponse.ok(Map.of("token",jwt.access(id,body.userName()),"refreshToken",jwt.refresh(id,body.userName())));
  }

  @GetMapping("/api/user/info")
  public ApiResponse<?> info(Authentication auth){
    long id=(Long)auth.getPrincipal();var u=repo.user(id).orElseThrow();var data=new LinkedHashMap<String,Object>();
    data.put("userId",id);data.put("userName",u.get("username"));data.put("nickName",u.get("nickname"));data.put("email",u.get("email"));data.put("phone",u.get("phone"));data.put("gender",u.get("gender"));data.put("avatar",u.get("avatar"));data.put("roles",repo.roles(id));data.put("buttons",repo.buttons(id));return ApiResponse.ok(data);
  }

  @PutMapping("/api/user/profile")
  public ApiResponse<?> updateProfile(Authentication auth,@RequestBody ProfileUpdate body,HttpServletRequest request){
    if(body.nickName()==null||body.nickName().isBlank())throw new IllegalArgumentException("昵称不能为空");
    if(body.nickName().length()>64)throw new IllegalArgumentException("昵称不能超过64个字符");
    if(body.gender()!=null&&!Set.of("UNKNOWN","MALE","FEMALE").contains(body.gender()))throw new IllegalArgumentException("性别选项无效");
    long id=(Long)auth.getPrincipal();var user=users.selectById(id);if(user==null)throw new IllegalArgumentException("用户不存在");
    user.nickname=body.nickName().trim();user.gender=blank(body.gender(),"UNKNOWN");user.phone=blank(body.phone(),null);user.email=blank(body.email(),null);user.avatar=blank(body.avatar(),null);user.updatedAt=java.time.LocalDateTime.now();users.updateById(user);
    audit.operation(auth,"user:profile:update","USER",id,"修改个人资料",request);return ApiResponse.ok();
  }

  private String blank(String value,String fallback){return value==null||value.isBlank()?fallback:value.trim();}
}
