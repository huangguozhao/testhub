package com.testhub.modules.api_testing.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api_testing.domain.ApiRequestHistory;
import com.testhub.modules.api_testing.dto.ApiRequestHistoryDTO;
import com.testhub.modules.api_testing.http.ApiResponse;

import java.util.List;
import java.util.Map;

/**
 * API请求历史记录服务接口
 */
public interface ApiRequestHistoryService extends IService<ApiRequestHistory> {

    /**
     * 保存请求执行历史
     */
    ApiRequestHistory saveHistory(ApiRequestHistory history);

    /**
     * 快速保存历史记录 (从执行结果)
     */
    ApiRequestHistory saveFromExecution(
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
    );

    /**
     * 分页查询历史记录
     */
    IPage<ApiRequestHistory> getHistoryPage(
            Long requestId,
            Long suiteExecutionId,
            Boolean success,
            String keyword,
            long current,
            long size
    );

    /**
     * 获取历史记录详情
     */
    ApiRequestHistory getHistoryDetail(Long id);

    /**
     * 删除单条历史记录
     */
    void deleteHistory(Long id);

    /**
     * 批量删除历史记录
     */
    void deleteHistories(List<Long> ids);

    /**
     * 清理历史记录
     */
    void clearHistory(Long requestId);

    /**
     * 清理所有历史记录
     */
    void clearAllHistory();

    /**
     * 获取请求的所有历史记录
     */
    List<ApiRequestHistory> getHistoriesByRequest(Long requestId);

    /**
     * 获取套件执行的所有历史记录
     */
    List<ApiRequestHistory> getHistoriesBySuiteExecution(Long suiteExecutionId);
}
