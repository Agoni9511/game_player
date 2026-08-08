package com.peiwan.platform.auth;

public class LoginFailedException extends RuntimeException {
  public LoginFailedException(){super("账号或密码错误");}
}
