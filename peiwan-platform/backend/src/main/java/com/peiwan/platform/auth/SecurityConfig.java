package com.peiwan.platform.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.peiwan.platform.common.ApiResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {
  @Bean PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(); }
  @Bean SecurityFilterChain security(HttpSecurity http, JwtFilter filter, ObjectMapper mapper) throws Exception {
    return http.csrf(x -> x.disable()).cors(x -> {}).sessionManagement(x -> x.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
      .authorizeHttpRequests(x -> x.requestMatchers("/api/auth/login", "/uploads/**", "/error").permitAll().anyRequest().authenticated())
      .exceptionHandling(x -> x
        .authenticationEntryPoint((req,res,e) -> write(res, mapper, 401, "登录已失效"))
        .accessDeniedHandler((req,res,e) -> write(res, mapper, 403, "无权执行此操作")))
      .addFilterBefore(filter, UsernamePasswordAuthenticationFilter.class).build();
  }
  private void write(jakarta.servlet.http.HttpServletResponse response, ObjectMapper mapper, int code, String message) throws java.io.IOException {
    response.setStatus(code); response.setCharacterEncoding("UTF-8"); response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    mapper.writeValue(response.getOutputStream(), ApiResponse.error(code, message));
  }
}
