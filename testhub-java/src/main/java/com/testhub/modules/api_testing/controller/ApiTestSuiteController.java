package com.testhub.modules.api_testing.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.api_testing.domain.ApiTestSuite;
import com.testhub.modules.api_testing.domain.ApiTestSuiteRequest;
import com.testhub.modules.api_testing.http.ApiExecutor;
import com.testhub.modules.api_testing.service.ApiTestSuiteRequestService;
import com.testhub.modules.api_testing.service.ApiTestSuiteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * API测试套件控制器
 */
@Tag(name = "API测试套件", description = "API测试套件管理")
@RestController
@RequestMapping("/api/api-test-suites")
@RequiredArgsConstructor
public class ApiTestSuiteController {

    private final ApiTestSuiteService apiTestSuiteService;
    private final ApiTestSuiteRequestService apiTestSuiteRequestService;
    private final ApiExecutor apiExecutor;

    @GetMapping
    @Operation(summary = "获取项目的所有测试套件")
    public Result<List<ApiTestSuite>> getTestSuites(@RequestParam Long projectId) {
        List<ApiTestSuite> suites = apiTestSuiteService.getTestSuitesByProject(projectId);
        return Result.success(suites);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取套件详情")
    public Result<ApiTestSuite> getTestSuite(@PathVariable Long id) {
        ApiTestSuite suite = apiTestSuiteService.getTestSuite(id);
        return Result.success(suite);
    }

    @PostMapping
    @Operation(summary = "创建测试套件")
    public Result<ApiTestSuite> createTestSuite(@Valid @RequestBody ApiTestSuite suite) {
        ApiTestSuite created = apiTestSuiteService.createTestSuite(suite);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新测试套件")
    public Result<ApiTestSuite> updateTestSuite(
            @PathVariable Long id,
            @Valid @RequestBody ApiTestSuite suite) {
        ApiTestSuite updated = apiTestSuiteService.updateTestSuite(id, suite);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除测试套件")
    public Result<Void> deleteTestSuite(@PathVariable Long id) {
        apiTestSuiteService.deleteTestSuite(id);
        return Result.success();
    }

    @PostMapping("/{id}/execute")
    @Operation(summary = "执行测试套件")
    public Result<ApiExecutor.SuiteExecutionResult> executeTestSuite(@PathVariable Long id) {
        ApiExecutor.SuiteExecutionResult result = apiExecutor.executeSuite(id);
        return Result.success(result);
    }

    @PostMapping("/{id}/add-requests")
    @Operation(summary = "添加请求到测试套件")
    public Result<Void> addRequestsToSuite(
            @PathVariable Long id,
            @RequestBody Map<String, List<Long>> body) {
        List<Long> requestIds = body.get("request_ids");
        if (requestIds == null || requestIds.isEmpty()) {
            return Result.error("请求ID列表不能为空");
        }
        apiTestSuiteRequestService.addRequestsToSuite(id, requestIds);
        return Result.success();
    }

    @GetMapping("/{id}/requests")
    @Operation(summary = "获取套件的所有请求")
    public Result<List<ApiTestSuiteRequest>> getSuiteRequests(@PathVariable Long id) {
        List<ApiTestSuiteRequest> requests = apiTestSuiteRequestService.getRequestsBySuite(id);
        return Result.success(requests);
    }
}