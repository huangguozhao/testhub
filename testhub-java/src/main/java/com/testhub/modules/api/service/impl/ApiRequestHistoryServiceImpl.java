package com.testhub.modules.api.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.api.domain.ApiRequestHistory;
import com.testhub.modules.api.http.ApiResponse;
import com.testhub.modules.api.mapper.ApiRequestHistoryMapper;
import com.testhub.modules.api.service.ApiRequestHistoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * API请求历史记录服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiRequestHistoryServiceImpl extends ServiceImpl<ApiRequestHistoryMapper, ApiRequestHistory>
        implements ApiRequestHistoryService {

    private final ObjectMapper objectMapper;

    @Override
    public ApiRequestHistory saveHistory(ApiRequestHistory history) {
        if (history.getExecutedAt() == null) {
            history.setExecutedAt(LocalDateTime.now());
        }
        if (history.getCreatedAt() == null) {
            history.setCreatedAt(LocalDateTime.now());
        }
        this.save(history);
        log.info("保存请求历史: id={}, requestId={}", history.getId(), history.getRequestId());
        return history;
    }

    @Override
    public ApiRequestHistory saveFromExecution(
            Long requestId,
            String method,
            String url,
            String requestHeaders,
            String requestBody,
            ApiResponse response,
            String assertions,
            Map<String, String> extractedVariables,
            Long suiteExecutionId,
            Long executedBy
    ) {
        ApiRequestHistory history = new ApiRequestHistory();
        history.setRequestId(requestId);
        history.setSuiteExecutionId(suiteExecutionId);
        history.setMethod(method);
        history.setUrl(url);
        history.setRequestHeaders(requestHeaders);
        history.setRequestBody(requestBody);
        history.setResponseStatusCode(response.getStatusCode());
        history.setResponseHeaders(toJson(response.getHeaders()));
        history.setResponseBody(truncateBody(response.getBody()));
        history.setResponseTime(response.getResponseTime());
        history.setAssertions(assertions);
        history.setExtractedVariables(toJson(extractedVariables));
        history.setSuccess(response.isSuccess());
        history.setErrorMessage(response.getError());
        history.setExecutedAt(LocalDateTime.now());
        history.setExecutedBy(executedBy);
        history.setCreatedAt(LocalDateTime.now());

        return this.saveHistory(history);
    }

    @Override
    public IPage<ApiRequestHistory> getHistoryPage(
            Long requestId,
            Long suiteExecutionId,
            Boolean success,
            String keyword,
            long current,
            long size
    ) {
        Page<ApiRequestHistory> page = new Page<>(current, size);
        LambdaQueryWrapper<ApiRequestHistory> wrapper = new LambdaQueryWrapper<>();

        if (requestId != null) {
            wrapper.eq(ApiRequestHistory::getRequestId, requestId);
        }

        if (suiteExecutionId != null) {
            wrapper.eq(ApiRequestHistory::getSuiteExecutionId, suiteExecutionId);
        }

        if (success != null) {
            wrapper.eq(ApiRequestHistory::getSuccess, success);
        }

        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like(ApiRequestHistory::getUrl, keyword)
                    .or()
                    .like(ApiRequestHistory::getErrorMessage, keyword));
        }

        wrapper.orderByDesc(ApiRequestHistory::getExecutedAt);
        return this.page(page, wrapper);
    }

    @Override
    public ApiRequestHistory getHistoryDetail(Long id) {
        return this.getById(id);
    }

    @Override
    public void deleteHistory(Long id) {
        this.removeById(id);
        log.info("删除请求历史: id={}", id);
    }

    @Override
    public void deleteHistories(List<Long> ids) {
        this.removeByIds(ids);
        log.info("批量删除请求历史: count={}", ids.size());
    }

    @Override
    public void clearHistory(Long requestId) {
        LambdaQueryWrapper<ApiRequestHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ApiRequestHistory::getRequestId, requestId);
        this.remove(wrapper);
        log.info("清理请求历史: requestId={}", requestId);
    }

    @Override
    public void clearAllHistory() {
        this.remove(null);
        log.info("清理所有请求历史");
    }

    @Override
    public List<ApiRequestHistory> getHistoriesByRequest(Long requestId) {
        return this.list(new LambdaQueryWrapper<ApiRequestHistory>()
                .eq(ApiRequestHistory::getRequestId, requestId)
                .orderByDesc(ApiRequestHistory::getExecutedAt));
    }

    @Override
    public List<ApiRequestHistory> getHistoriesBySuiteExecution(Long suiteExecutionId) {
        return this.list(new LambdaQueryWrapper<ApiRequestHistory>()
                .eq(ApiRequestHistory::getSuiteExecutionId, suiteExecutionId)
                .orderByAsc(ApiRequestHistory::getExecutedAt));
    }

    /**
     * 将对象转换为JSON字符串
     */
    private String toJson(Object obj) {
        if (obj == null) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            log.warn("转换JSON失败: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 截断响应体 (避免存储过大)
     */
    private String truncateBody(String body) {
        if (body == null) {
            return null;
        }
        int maxLength = 100 * 1024; // 100KB
        if (body.length() > maxLength) {
            return body.substring(0, maxLength) + "...[truncated]";
        }
        return body;
    }
}
