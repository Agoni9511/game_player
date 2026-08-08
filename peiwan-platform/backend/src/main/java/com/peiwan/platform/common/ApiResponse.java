package com.peiwan.platform.common;
public record ApiResponse<T>(int code, String msg, T data) {
  public static <T> ApiResponse<T> ok(T data) { return new ApiResponse<>(200, "success", data); }
  public static ApiResponse<Void> ok() { return ok(null); }
  public static ApiResponse<Void> error(int code, String msg) { return new ApiResponse<>(code, msg, null); }
}
