package com.peiwan.platform.auth;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.common.AuditService;
import com.peiwan.platform.system.RbacRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
public class AuthController {
  private final RbacRepository repo;private final PasswordEncoder encoder;private final JwtService jwt;private final AuditService audit;
  public AuthController(RbacRepository repo,PasswordEncoder encoder,JwtService jwt,AuditService audit){this.repo=repo;this.encoder=encoder;this.jwt=jwt;this.audit=audit;}
  public record Login(@NotBlank String userName,@NotBlank String password){}

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
    data.put("userId",id);data.put("userName",u.get("username"));data.put("nickName",u.get("nickname"));data.put("email",u.get("email"));data.put("avatar",u.get("avatar"));data.put("roles",repo.roles(id));data.put("buttons",repo.buttons(id));return ApiResponse.ok(data);
  }
}
