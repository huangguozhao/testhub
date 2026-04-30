package com.testhub.modules.api.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.api.domain.ApiTestSuite;
import com.testhub.modules.api.http.ApiExecutor;
import com.testhub.modules.api.service.ApiTestSuiteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * API测试套件控制器
 */
@Tag(name = "API测试套件", description = "API测试套件管理")
@RestController
@RequestMapping("/api/api-test-suites")
@RequiredArgsConstructor
public class ApiTestSuiteController {

    private final ApiTestSuiteService apiTestSuiteService;
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
}