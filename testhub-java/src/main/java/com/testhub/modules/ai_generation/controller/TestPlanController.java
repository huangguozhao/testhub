package com.testhub.modules.ai_generation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.ai_generation.domain.TestPlan;
import com.testhub.modules.ai_generation.dto.TestPlanDTO;
import com.testhub.modules.ai_generation.service.TestPlanService;
import com.testhub.modules.system.security.UserDetailsImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * 测试计划控制器
 */
@Tag(name = "测试计划", description = "测试计划管理")
@RestController
@RequestMapping("/api/test-plans")
@RequiredArgsConstructor
public class TestPlanController {

    private final TestPlanService testPlanService;

    @GetMapping
    @Operation(summary = "分页查询计划")
    public Result<PageResult<TestPlan>> getTestPlanPage(
            @Parameter(description = "项目ID") @RequestParam(required = false) Long projectId,
            @Parameter(description = "关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "状态") @RequestParam(required = false) String status,
            @Parameter(description = "当前页") @RequestParam(defaultValue = "1") long current,
            @Parameter(description = "页大小") @RequestParam(defaultValue = "10") long size) {
        IPage<TestPlan> page = testPlanService.getTestPlanPage(projectId, keyword, status, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取计划详情")
    public Result<TestPlan> getTestPlan(@PathVariable Long id) {
        TestPlan plan = testPlanService.getTestPlanDetail(id);
        if (plan == null) {
            return Result.error("计划不存在");
        }
        return Result.success(plan);
    }

    @PostMapping
    @Operation(summary = "创建计划")
    public Result<TestPlan> createTestPlan(
            @Valid @RequestBody TestPlanDTO dto,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        TestPlan plan = testPlanService.createTestPlan(dto);
        return Result.success(plan);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新计划")
    public Result<TestPlan> updateTestPlan(
            @PathVariable Long id,
            @Valid @RequestBody TestPlanDTO dto) {
        TestPlan plan = testPlanService.updateTestPlan(id, dto);
        return Result.success(plan);
    }

    @PatchMapping("/{id}")
    @Operation(summary = "部分更新计划")
    public Result<TestPlan> patchTestPlan(
            @PathVariable Long id,
            @RequestBody TestPlanDTO dto) {
        TestPlan plan = testPlanService.updateTestPlan(id, dto);
        return Result.success(plan);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除计划")
    public Result<Void> deleteTestPlan(@PathVariable Long id) {
        testPlanService.deleteTestPlan(id);
        return Result.success();
    }
}
