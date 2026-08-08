package com.peiwan.platform.common;

import com.peiwan.platform.auth.LoginFailedException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {
  @ExceptionHandler(LoginFailedException.class)
  ResponseEntity<ApiResponse<Void>> loginFailed(LoginFailedException e){return ResponseEntity.status(401).body(ApiResponse.error(401,e.getMessage()));}
  @ExceptionHandler(IllegalArgumentException.class)
  ResponseEntity<ApiResponse<Void>> badRequest(IllegalArgumentException e){return ResponseEntity.badRequest().body(ApiResponse.error(400,e.getMessage()));}
  @ExceptionHandler(MethodArgumentNotValidException.class)
  ResponseEntity<ApiResponse<Void>> validation(MethodArgumentNotValidException e){var msg=e.getBindingResult().getFieldErrors().stream().findFirst().map(x->x.getDefaultMessage()).orElse("参数错误");return ResponseEntity.badRequest().body(ApiResponse.error(400,msg));}
  @ExceptionHandler(AccessDeniedException.class)
  ResponseEntity<ApiResponse<Void>> forbidden(AccessDeniedException e){return ResponseEntity.status(403).body(ApiResponse.error(403,"无权执行此操作"));}
  @ExceptionHandler(DataIntegrityViolationException.class)
  ResponseEntity<ApiResponse<Void>> conflict(DataIntegrityViolationException e){return ResponseEntity.badRequest().body(ApiResponse.error(400,"数据冲突，请检查唯一字段或关联关系"));}
}
