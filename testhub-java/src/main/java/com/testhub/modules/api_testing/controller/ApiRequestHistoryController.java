package com.testhub.modules.api_testing.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.api_testing.domain.ApiRequestHistory;
import com.testhub.modules.api_testing.service.ApiRequestHistoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * API请求历史记录控制器
 */
@Tag(name = "API请求历史", description = "API请求执行历史记录管理")
@RestController
@RequestMapping("/api/api-request-histories")
@RequiredArgsConstructor
public class ApiRequestHistoryController {

    private final ApiRequestHistoryService apiRequestHistoryService;

    @GetMapping
    @Operation(summary = "分页查询请求历史")
    public Result<PageResult<ApiRequestHistory>> getHistoryPage(
            @RequestParam(required = false) Long requestId,
            @RequestParam(required = false) Long suiteExecutionId,
            @RequestParam(required = false) Boolean success,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "20") long size
    ) {
        IPage<ApiRequestHistory> page = apiRequestHistoryService.getHistoryPage(
                requestId, suiteExecutionId, success, keyword, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取历史记录详情")
    public Result<ApiRequestHistory> getHistoryDetail(@PathVariable Long id) {
        ApiRequestHistory history = apiRequestHistoryService.getHistoryDetail(id);
        return Result.success(history);
    }

    @GetMapping("/request/{requestId}")
    @Operation(summary = "获取请求的所有历史记录")
    public Result<List<ApiRequestHistory>> getHistoriesByRequest(@PathVariable Long requestId) {
        List<ApiRequestHistory> histories = apiRequestHistoryService.getHistoriesByRequest(requestId);
        return Result.success(histories);
    }

    @GetMapping("/suite-execution/{suiteExecutionId}")
    @Operation(summary = "获取套件执行的所有历史记录")
    public Result<List<ApiRequestHistory>> getHistoriesBySuiteExecution(@PathVariable Long suiteExecutionId) {
        List<ApiRequestHistory> histories = apiRequestHistoryService.getHistoriesBySuiteExecution(suiteExecutionId);
        return Result.success(histories);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除历史记录")
    public Result<Void> deleteHistory(@PathVariable Long id) {
        apiRequestHistoryService.deleteHistory(id);
        return Result.success();
    }

    @DeleteMapping("/batch")
    @Operation(summary = "批量删除历史记录")
    public Result<Void> deleteHistories(@RequestBody Map<String, List<Long>> request) {
        List<Long> ids = request.get("ids");
        if (ids != null && !ids.isEmpty()) {
            apiRequestHistoryService.deleteHistories(ids);
        }
        return Result.success();
    }

    @DeleteMapping("/request/{requestId}")
    @Operation(summary = "清理请求的所有历史记录")
    public Result<Void> clearHistory(@PathVariable Long requestId) {
        apiRequestHistoryService.clearHistory(requestId);
        return Result.success();
    }

    @DeleteMapping("/clear")
    @Operation(summary = "清理所有历史记录")
    public Result<Void> clearAllHistory() {
        apiRequestHistoryService.clearAllHistory();
        return Result.success();
    }
}
