package com.testhub.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.nio.charset.StandardCharsets;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

/**
 * API请求日志拦截器
 * 记录请求进入和响应返回的完整日志
 */
@Slf4j
@Component
public class ApiLoggingInterceptor implements HandlerInterceptor {

    private static final String START_TIME = "loggingStartTime";

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // 记录开始时间
        request.setAttribute(START_TIME, System.currentTimeMillis());

        // 记录请求基本信息
        String requestInfo = buildRequestInfo(request);
        log.info("\n{}", requestInfo);

        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        long startTime = (Long) request.getAttribute(START_TIME);
        long duration = System.currentTimeMillis() - startTime;

        // 获取缓存的响应体
        String responseBody = getCachedResponseBody(request);

        // 构建响应日志
        StringBuilder logBuilder = new StringBuilder();
        logBuilder.append("\n========== API响应日志 ==========\n");
        logBuilder.append(String.format("URL: %s %s\n", request.getMethod(), request.getRequestURI()));
        logBuilder.append(String.format("状态: %d\n", response.getStatus()));
        logBuilder.append(String.format("耗时: %dms\n", duration));

        if (ex != null) {
            logBuilder.append(String.format("异常: %s\n", ex.getMessage()));
        }

        if (responseBody != null && !responseBody.isEmpty()) {
            // 响应体可能很大，限制显示长度
            String displayBody = responseBody;
            if (displayBody.length() > 500) {
                displayBody = displayBody.substring(0, 500) + "...(省略 " + (displayBody.length() - 500) + " 字符)";
            }
            logBuilder.append(String.format("响应体:\n%s\n", displayBody));
        }

        logBuilder.append("==================================");

        log.info("{}", logBuilder.toString());
    }

    private String getCachedResponseBody(HttpServletRequest request) {
        ContentCachingResponseWrapper cachingResponse =
                (ContentCachingResponseWrapper) request.getAttribute("cachingResponseWrapper");

        if (cachingResponse != null) {
            byte[] buf = cachingResponse.getContentAsByteArray();
            if (buf.length > 0) {
                return new String(buf, StandardCharsets.UTF_8);
            }
        }
        return null;
    }

    private String buildRequestInfo(HttpServletRequest request) {
        StringBuilder logBuilder = new StringBuilder();
        logBuilder.append("\n========== API请求日志 ==========\n");
        logBuilder.append(String.format("URL: %s %s\n", request.getMethod(), request.getRequestURI()));
        logBuilder.append(String.format("Content-Type: %s\n", request.getContentType()));
        logBuilder.append(String.format("Content-Length: %d\n", request.getContentLength()));

        // 记录请求头（排除一些不重要的）
        Map<String, String> headers = new HashMap<>();
        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String name = headerNames.nextElement();
            // 跳过一些可能很大或不重要的头
            if (!name.equalsIgnoreCase("cookie") && !name.equalsIgnoreCase("authorization")) {
                headers.put(name, request.getHeader(name));
            }
        }
        logBuilder.append("请求头:\n");
        headers.forEach((k, v) -> logBuilder.append(String.format("  %s: %s\n", k, v)));

        // 记录请求参数
        Map<String, String[]> paramMap = request.getParameterMap();
        if (!paramMap.isEmpty()) {
            logBuilder.append("请求参数:\n");
            paramMap.forEach((k, v) -> logBuilder.append(String.format("  %s: %s\n", k, String.join(", ", v))));
        }

        // 获取请求体（如果有）
        if (request instanceof ContentCachingRequestWrapper) {
            ContentCachingRequestWrapper wrapper = (ContentCachingRequestWrapper) request;
            byte[] buf = wrapper.getContentAsByteArray();
            if (buf.length > 0) {
                String body = new String(buf, StandardCharsets.UTF_8);
                // 请求体可能很大，限制显示长度
                String displayBody = body;
                if (displayBody.length() > 500) {
                    displayBody = displayBody.substring(0, 500) + "...(省略 " + (displayBody.length() - 500) + " 字符)";
                }
                logBuilder.append(String.format("请求体:\n%s\n", displayBody));
            }
        }

        logBuilder.append("=================================");

        return logBuilder.toString();
    }
}
