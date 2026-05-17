package com.testhub.modules.ui_automation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.ui_automation.domain.UITestSuite;
import com.testhub.modules.ui_automation.service.UITestSuiteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * UI自动化测试套件控制器
 */
@Tag(name = "UI测试套件", description = "UI自动化测试套件管理")
@RestController
@RequestMapping("/api/ui-automation/test-suites")
@RequiredArgsConstructor
public class UITestSuiteController {

    private final UITestSuiteService uiTestSuiteService;

    @GetMapping
    @Operation(summary = "分页查询测试套件列表")
    public Result<PageResult<UITestSuite>> getSuitePage(
            @RequestParam(required = false, defaultValue = "1") Long page,
            @RequestParam(required = false, defaultValue = "10") Long page_size,
            @RequestParam(required = false) Long project_id,
            @RequestParam(required = false) String keyword) {
        IPage<UITestSuite> result = uiTestSuiteService.getSuitePage(project_id, keyword, page, page_size);
        return Result.success(PageResult.of(result));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取测试套件详情")
    public Result<UITestSuite> getSuiteDetail(@PathVariable Long id) {
        UITestSuite suite = uiTestSuiteService.getById(id);
        return Result.success(suite);
    }

    @PostMapping
    @Operation(summary = "创建测试套件")
    public Result<UITestSuite> createSuite(@RequestBody UITestSuite suite) {
        UITestSuite created = uiTestSuiteService.createSuite(suite);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新测试套件")
    public Result<UITestSuite> updateSuite(@PathVariable Long id, @RequestBody UITestSuite suite) {
        UITestSuite updated = uiTestSuiteService.updateSuite(id, suite);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除测试套件")
    public Result<Void> deleteSuite(@PathVariable Long id) {
        uiTestSuiteService.deleteSuite(id);
        return Result.success();
    }

    @GetMapping("/all")
    @Operation(summary = "获取项目的所有测试套件")
    public Result<List<UITestSuite>> getAllSuites(@RequestParam Long project_id) {
        List<UITestSuite> suites = uiTestSuiteService.lambdaQuery()
                .eq(UITestSuite::getProjectId, project_id)
                .list();
        return Result.success(suites);
    }
}