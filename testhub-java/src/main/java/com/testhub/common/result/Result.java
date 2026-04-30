package com.testhub.common.result;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Result<T> {

    private int code;
    private String message;
    private T data;
    private long timestamp;

    private Result() {
        this.timestamp = System.currentTimeMillis();
    }

    public static <T> Result<T> success() {
        Result<T> result = new Result<>();
        result.setCode(200);
        result.setMessage("success");
        return result;
    }

    public static <T> Result<T> success(T data) {
        Result<T> result = new Result<>();
        result.setCode(200);
        result.setMessage("success");
        result.setData(data);
        return result;
    }

    public static <T> Result<T> success(String message, T data) {
        Result<T> result = new Result<>();
        result.setCode(200);
        result.setMessage(message);
        result.setData(data);
        return result;
    }

    public static <T> Result<T> error(int code, String message) {
        Result<T> result = new Result<>();
        result.setCode(code);
        result.setMessage(message);
        return result;
    }

    public static <T> Result<T> error(String message) {
        return error(500, message);
    }

    // 认证相关错误 1000-1099
    public static <T> Result<T> unauthorized(String message) {
        return error(401, message);
    }

    public static <T> Result<T> tokenExpired() {
        return error(1001, "Token已过期");
    }

    public static <T> Result<T> tokenInvalid() {
        return error(1002, "Token无效");
    }

    // 权限相关错误 1100-1199
    public static <T> Result<T> forbidden(String message) {
        return error(403, message);
    }

    public static <T> Result<T> noPermission() {
        return error(1101, "没有权限访问该资源");
    }

    // 业务相关错误 2000-2999
    public static <T> Result<T> badRequest(String message) {
        return error(400, message);
    }

    public static <T> Result<T> notFound(String message) {
        return error(404, message);
    }

    public static <T> Result<T> businessError(String message) {
        return error(2001, message);
    }
}