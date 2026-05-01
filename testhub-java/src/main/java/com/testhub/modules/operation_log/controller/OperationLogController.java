package com.testhub.modules.operation_log.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.operation_log.domain.OperationLog;
import com.testhub.modules.operation_log.service.OperationLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 操作日志控制器
 */
@Tag(name = "操作日志", description = "操作日志查询和管理")
@RestController
@RequestMapping("/api/operation-logs")
@RequiredArgsConstructor
public class OperationLogController {

    private final OperationLogService operationLogService;

    @GetMapping
    @Operation(summary = "分页查询操作日志")
    public Result<PageResult<OperationLog>> getLogPage(
            @RequestParam(required = false) String operationType,
            @RequestParam(required = false) String resourceType,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Long resourceId,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "20") long size) {
        IPage<OperationLog> page = operationLogService.getLogPage(
                operationType, resourceType, userId, resourceId, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取日志详情")
    public Result<OperationLog> getLogDetail(@PathVariable Long id) {
        OperationLog log = operationLogService.getLogDetail(id);
        return Result.success(log);
    }

    @GetMapping("/resource/{resourceType}/{resourceId}")
    @Operation(summary = "获取资源的操作记录")
    public Result<List<OperationLog>> getLogsByResource(
            @PathVariable String resourceType,
            @PathVariable Long resourceId) {
        List<OperationLog> logs = operationLogService.getLogsByResource(resourceType, resourceId);
        return Result.success(logs);
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "获取用户的操作记录")
    public Result<List<OperationLog>> getLogsByUser(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "20") int limit) {
        List<OperationLog> logs = operationLogService.getLogsByUser(userId, limit);
        return Result.success(logs);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除日志")
    public Result<Void> deleteLog(@PathVariable Long id) {
        operationLogService.deleteLog(id);
        return Result.success();
    }

    @DeleteMapping("/clean")
    @Operation(summary = "清理旧日志")
    public Result<Void> cleanOldLogs(@RequestParam(defaultValue = "30") int days) {
        operationLogService.cleanOldLogs(days);
        return Result.success();
    }
}
