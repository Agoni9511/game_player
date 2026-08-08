package com.peiwan.platform.auth;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

@Service
public class JwtService {
  private final SecretKey key;
  private final long accessMinutes;
  private final long refreshDays;
  public JwtService(@Value("${app.jwt.secret}") String secret, @Value("${app.jwt.access-minutes}") long accessMinutes,
                    @Value("${app.jwt.refresh-days}") long refreshDays) {
    this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    this.accessMinutes = accessMinutes; this.refreshDays = refreshDays;
  }
  public String access(long userId, String username) { return token(userId, username, "access", accessMinutes * 60); }
  public String refresh(long userId, String username) { return token(userId, username, "refresh", refreshDays * 86400); }
  private String token(long id, String username, String type, long seconds) {
    var now = Instant.now();
    return Jwts.builder().subject(Long.toString(id)).claim("username", username).claim("type", type)
      .issuedAt(Date.from(now)).expiration(Date.from(now.plusSeconds(seconds))).signWith(key).compact();
  }
  public Long parseAccess(String value) {
    var claims = Jwts.parser().verifyWith(key).build().parseSignedClaims(value).getPayload();
    if (!"access".equals(claims.get("type", String.class))) throw new IllegalArgumentException("无效令牌");
    return Long.valueOf(claims.getSubject());
  }
}
