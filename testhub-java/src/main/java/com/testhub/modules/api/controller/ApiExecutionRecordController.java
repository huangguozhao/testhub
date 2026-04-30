package com.testhub.modules.api.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.api.domain.ApiExecutionRecord;
import com.testhub.modules.api.service.ApiExecutionRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * API执行记录控制器
 */
@Tag(name = "API执行记录", description = "API执行记录管理")
@RestController
@RequestMapping("/api/api-execution-records")
@RequiredArgsConstructor
public class ApiExecutionRecordController {

    private final ApiExecutionRecordService apiExecutionRecordService;

    @GetMapping("/project/{projectId}")
    @Operation(summary = "获取项目的执行记录")
    public Result<List<ApiExecutionRecord>> getRecordsByProject(
            @PathVariable Long projectId,
            @RequestParam(required = false, defaultValue = "50") Integer limit) {
        List<ApiExecutionRecord> records = apiExecutionRecordService.getRecordsByProject(projectId, limit);
        return Result.success(records);
    }

    @GetMapping("/suite/{suiteId}")
    @Operation(summary = "获取套件的执行记录")
    public Result<List<ApiExecutionRecord>> getRecordsBySuite(
            @PathVariable Long suiteId,
            @RequestParam(required = false, defaultValue = "50") Integer limit) {
        List<ApiExecutionRecord> records = apiExecutionRecordService.getRecordsBySuite(suiteId, limit);
        return Result.success(records);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取记录详情")
    public Result<ApiExecutionRecord> getRecord(@PathVariable Long id) {
        ApiExecutionRecord record = apiExecutionRecordService.getRecord(id);
        return Result.success(record);
    }
}