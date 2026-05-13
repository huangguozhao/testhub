package com.testhub.modules.ai_generation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.ai_generation.domain.TestSuite;
import com.testhub.modules.ai_generation.dto.TestSuiteDTO;
import com.testhub.modules.ai_generation.service.TestSuiteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 测试套件控制器
 */
@Tag(name = "测试套件", description = "测试套件管理")
@RestController
@RequestMapping("/api/testsuites")
@RequiredArgsConstructor
public class TestSuiteController {

    private final TestSuiteService testSuiteService;

    @GetMapping
    @Operation(summary = "分页查询套件")
    public Result<PageResult<TestSuite>> getTestSuitePage(
            @Parameter(description = "项目ID") @RequestParam(required = false) Long projectId,
            @Parameter(description = "关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "当前页") @RequestParam(defaultValue = "1") long current,
            @Parameter(description = "页大小") @RequestParam(defaultValue = "10") long size) {
        IPage<TestSuite> page = testSuiteService.getTestSuitePage(projectId, keyword, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取套件详情")
    public Result<TestSuite> getTestSuite(@PathVariable Long id) {
        TestSuite suite = testSuiteService.getById(id);
        if (suite == null) {
            return Result.error("套件不存在");
        }
        return Result.success(suite);
    }

    @PostMapping
    @Operation(summary = "创建套件")
    public Result<TestSuite> createTestSuite(@Valid @RequestBody TestSuiteDTO dto) {
        TestSuite suite = testSuiteService.createTestSuite(dto);
        return Result.success(suite);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新套件")
    public Result<TestSuite> updateTestSuite(
            @PathVariable Long id,
            @Valid @RequestBody TestSuiteDTO dto) {
        TestSuite suite = testSuiteService.updateTestSuite(id, dto);
        return Result.success(suite);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除套件")
    public Result<Void> deleteTestSuite(@PathVariable Long id) {
        testSuiteService.deleteTestSuite(id);
        return Result.success();
    }

    @GetMapping("/{id:\\d+}/cases")
    @Operation(summary = "获取套件的用例ID列表")
    public Result<List<Long>> getSuiteCaseIds(@PathVariable Long id) {
        List<Long> caseIds = testSuiteService.getSuiteCaseIds(id);
        return Result.success(caseIds);
    }

    @PostMapping("/{id:\\d+}/cases")
    @Operation(summary = "添加用例到套件")
    public Result<Void> addCases(
            @PathVariable Long id,
            @RequestBody List<Long> caseIds) {
        testSuiteService.addCases(id, caseIds);
        return Result.success();
    }

    @DeleteMapping("/{id:\\d+}/cases")
    @Operation(summary = "从套件移除用例")
    public Result<Void> removeCases(
            @PathVariable Long id,
            @RequestBody List<Long> caseIds) {
        testSuiteService.removeCases(id, caseIds);
        return Result.success();
    }
}
