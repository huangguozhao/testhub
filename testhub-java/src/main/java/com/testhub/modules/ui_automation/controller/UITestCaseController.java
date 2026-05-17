package com.testhub.modules.ui_automation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.ui_automation.domain.UITestCase;
import com.testhub.modules.ui_automation.service.UITestCaseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * UI自动化测试用例控制器
 */
@Tag(name = "UI测试用例", description = "UI自动化测试用例管理")
@RestController
@RequestMapping("/api/ui-automation/test-cases")
@RequiredArgsConstructor
public class UITestCaseController {

    private final UITestCaseService uiTestCaseService;

    @GetMapping
    @Operation(summary = "分页查询测试用例列表")
    public Result<PageResult<UITestCase>> getTestCasePage(
            @RequestParam(required = false, defaultValue = "1") Long page,
            @RequestParam(required = false, defaultValue = "10") Long page_size,
            @RequestParam(required = false) Long project_id,
            @RequestParam(required = false) String keyword) {
        IPage<UITestCase> result = uiTestCaseService.getTestCasePage(project_id, keyword, page, page_size);
        return Result.success(PageResult.of(result));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取测试用例详情")
    public Result<UITestCase> getTestCaseDetail(@PathVariable Long id) {
        UITestCase testCase = uiTestCaseService.getById(id);
        return Result.success(testCase);
    }

    @PostMapping
    @Operation(summary = "创建测试用例")
    public Result<UITestCase> createTestCase(@RequestBody UITestCase testCase) {
        UITestCase created = uiTestCaseService.createTestCase(testCase);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新测试用例")
    public Result<UITestCase> updateTestCase(@PathVariable Long id, @RequestBody UITestCase testCase) {
        UITestCase updated = uiTestCaseService.updateTestCase(id, testCase);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除测试用例")
    public Result<Void> deleteTestCase(@PathVariable Long id) {
        uiTestCaseService.deleteTestCase(id);
        return Result.success();
    }

    @GetMapping("/all")
    @Operation(summary = "获取项目的所有测试用例")
    public Result<List<UITestCase>> getAllTestCases(@RequestParam Long project_id) {
        List<UITestCase> testCases = uiTestCaseService.lambdaQuery()
                .eq(UITestCase::getProjectId, project_id)
                .list();
        return Result.success(testCases);
    }
}