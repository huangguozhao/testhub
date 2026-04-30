package com.testhub.modules.execution.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.execution.domain.TestRun;
import com.testhub.modules.execution.domain.TestRunCase;
import com.testhub.modules.execution.dto.TestRunDTO;
import com.testhub.modules.execution.service.TestRunService;
import com.testhub.modules.system.security.UserDetailsImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 测试执行控制器
 */
@Tag(name = "测试执行", description = "测试执行管理")
@RestController
@RequestMapping("/api/test-runs")
@RequiredArgsConstructor
public class TestRunController {

    private final TestRunService testRunService;

    @GetMapping
    @Operation(summary = "分页查询执行记录")
    public Result<PageResult<TestRun>> getTestRunPage(
            @Parameter(description = "计划ID") @RequestParam(required = false) Long planId,
            @Parameter(description = "套件ID") @RequestParam(required = false) Long suiteId,
            @Parameter(description = "状态") @RequestParam(required = false) String status,
            @Parameter(description = "当前页") @RequestParam(defaultValue = "1") long current,
            @Parameter(description = "页大小") @RequestParam(defaultValue = "10") long size) {
        IPage<TestRun> page = testRunService.getTestRunPage(planId, suiteId, status, current, size);
        return Result.success(PageResult.of(page));
    }

    @PostMapping
    @Operation(summary = "创建执行记录")
    public Result<TestRun> createTestRun(
            @RequestBody TestRunDTO dto,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        TestRun run = testRunService.createTestRun(dto.getPlanId(), dto.getSuiteId(), userDetails.getId());
        return Result.success(run);
    }

    @PostMapping("/{id}/start")
    @Operation(summary = "开始执行")
    public Result<TestRun> startRun(@PathVariable Long id) {
        TestRun run = testRunService.startRun(id);
        return Result.success(run);
    }

    @PostMapping("/{id}/complete")
    @Operation(summary = "完成执行")
    public Result<TestRun> completeRun(
            @PathVariable Long id,
            @RequestBody TestRunDTO dto) {
        TestRun run = testRunService.completeRun(id, dto.getPassedCount(), dto.getFailedCount());
        return Result.success(run);
    }

    @PostMapping("/{runId}/cases")
    @Operation(summary = "更新用例执行结果")
    public Result<Void> updateCaseResult(
            @PathVariable Long runId,
            @RequestBody TestRunDTO dto,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        testRunService.updateCaseResult(
                runId, dto.getCaseId(), dto.getCaseStatus(),
                dto.getResult(), dto.getBugIds(), userDetails.getId()
        );
        return Result.success();
    }

    @GetMapping("/{id}/cases")
    @Operation(summary = "获取执行的用例列表")
    public Result<List<TestRunCase>> getRunCases(@PathVariable Long id) {
        List<TestRunCase> cases = testRunService.getRunCases(id);
        return Result.success(cases);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除执行记录")
    public Result<Void> deleteTestRun(@PathVariable Long id) {
        testRunService.deleteTestRun(id);
        return Result.success();
    }
}
