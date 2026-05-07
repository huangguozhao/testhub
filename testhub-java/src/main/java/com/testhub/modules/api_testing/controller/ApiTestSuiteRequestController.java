package com.testhub.modules.api_testing.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.api_testing.domain.ApiTestSuiteRequest;
import com.testhub.modules.api_testing.service.ApiTestSuiteRequestService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "测试套件请求", description = "测试套件请求管理")
@RestController
@RequestMapping("/api/api-test-suite-requests")
@RequiredArgsConstructor
public class ApiTestSuiteRequestController {

    private final ApiTestSuiteRequestService apiTestSuiteRequestService;

    @PutMapping("/{id}")
    @Operation(summary = "更新套件请求")
    public Result<Void> updateSuiteRequest(
            @PathVariable Long id,
            @RequestBody ApiTestSuiteRequest suiteRequest) {
        apiTestSuiteRequestService.updateSuiteRequest(id, suiteRequest);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除套件请求")
    public Result<Void> deleteSuiteRequest(@PathVariable Long id) {
        apiTestSuiteRequestService.deleteSuiteRequest(id);
        return Result.success();
    }
}
