package com.peiwan.platform.auth;

import com.peiwan.platform.system.RbacRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.ArrayList;

@Component
public class JwtFilter extends OncePerRequestFilter {
  private final JwtService jwt;
  private final RbacRepository repo;
  public JwtFilter(JwtService jwt, RbacRepository repo) { this.jwt = jwt; this.repo = repo; }
  @Override protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain) throws ServletException, IOException {
    var header = req.getHeader("Authorization");
    if (header != null && !header.isBlank()) {
      try {
        var raw = header.startsWith("Bearer ") ? header.substring(7) : header;
        var id = jwt.parseAccess(raw);
        if (repo.userEnabled(id)) {
          var authorities = new ArrayList<SimpleGrantedAuthority>();
          repo.roles(id).forEach(role -> authorities.add(new SimpleGrantedAuthority("ROLE_" + role)));
          repo.buttons(id).forEach(permission -> authorities.add(new SimpleGrantedAuthority(permission)));
          SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(id, null, authorities));
        }
      } catch (Exception ignored) { SecurityContextHolder.clearContext(); }
    }
    chain.doFilter(req, res);
  }
}
