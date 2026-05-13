package com.testhub.modules.ai_generation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.ai_generation.domain.TestCase;
import com.testhub.modules.ai_generation.domain.TestCaseStep;
import com.testhub.modules.ai_generation.dto.TestCaseDTO;
import com.testhub.modules.ai_generation.service.TestCaseService;
import com.testhub.modules.system.security.UserDetailsImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 测试用例控制器
 */
@Tag(name = "测试用例", description = "测试用例管理")
@RestController
@RequestMapping("/api/testcases")
@RequiredArgsConstructor
public class TestCaseController {

    private final TestCaseService testCaseService;

    @GetMapping
    @Operation(summary = "分页查询用例")
    public Result<PageResult<TestCase>> getTestCasePage(
            @Parameter(description = "项目ID") @RequestParam(required = false) Long projectId,
            @Parameter(description = "关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "优先级") @RequestParam(required = false) String priority,
            @Parameter(description = "状态") @RequestParam(required = false) String status,
            @Parameter(description = "当前页") @RequestParam(defaultValue = "1") long current,
            @Parameter(description = "页大小") @RequestParam(defaultValue = "10") long size) {
        IPage<TestCase> page = testCaseService.getTestCasePage(projectId, keyword, priority, status, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取用例详情")
    public Result<TestCaseDTO> getTestCaseDetail(@PathVariable Long id) {
        TestCaseDTO detail = testCaseService.getTestCaseDetail(id);
        return Result.success(detail);
    }

    @PostMapping
    @Operation(summary = "创建用例")
    public Result<TestCase> createTestCase(
            @Valid @RequestBody TestCaseDTO dto,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        TestCase testCase = testCaseService.createTestCase(dto, userDetails.getId());
        return Result.success(testCase);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新用例")
    public Result<TestCase> updateTestCase(
            @PathVariable Long id,
            @Valid @RequestBody TestCaseDTO dto,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        TestCase testCase = testCaseService.updateTestCase(id, dto, userDetails.getId());
        return Result.success(testCase);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除用例")
    public Result<Void> deleteTestCase(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        testCaseService.deleteTestCase(id, userDetails.getId());
        return Result.success();
    }

    @GetMapping("/{id:\\d+}/steps")
    @Operation(summary = "获取用例步骤")
    public Result<List<TestCaseStep>> getTestCaseSteps(@PathVariable Long id) {
        List<TestCaseStep> steps = testCaseService.getTestCaseSteps(id);
        return Result.success(steps);
    }
}
