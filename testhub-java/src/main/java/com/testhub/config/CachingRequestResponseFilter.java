package com.testhub.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;

/**
 * 请求/响应体缓存过滤器
 * 将HttpServletRequest和HttpServletResponse包装为ContentCaching版本
 * 以便可以多次读取body（拦截器需要读取body用于日志记录）
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class CachingRequestResponseFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest && response instanceof HttpServletResponse) {
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            HttpServletResponse httpResponse = (HttpServletResponse) response;

            String uri = httpRequest.getRequestURI();

            // SSE端点不能使用响应缓存（会破坏流式传输）
            if (uri.startsWith("/api/") && !uri.contains("/stream_progress")) {
                ContentCachingRequestWrapper wrappedRequest = new ContentCachingRequestWrapper(httpRequest);
                ContentCachingResponseWrapper wrappedResponse = new ContentCachingResponseWrapper(httpResponse);

                // 将包装后的响应保存到请求属性中，供拦截器使用
                httpRequest.setAttribute("cachingResponseWrapper", wrappedResponse);

                chain.doFilter(wrappedRequest, wrappedResponse);

                // 重要：需要复制内容到原始响应，否则响应体会为空
                wrappedResponse.copyBodyToResponse();
                return;
            }
        }
        chain.doFilter(request, response);
    }
}
