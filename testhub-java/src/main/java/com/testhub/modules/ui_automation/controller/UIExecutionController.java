package com.testhub.modules.ui_automation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.ui_automation.domain.UIExecution;
import com.testhub.modules.ui_automation.service.UIExecutionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * UI自动化执行记录控制器
 */
@Tag(name = "UI执行记录", description = "UI自动化执行记录管理")
@RestController
@RequestMapping("/api/ui-automation/test-executions")
@RequiredArgsConstructor
public class UIExecutionController {

    private final UIExecutionService uiExecutionService;

    @GetMapping
    @Operation(summary = "分页查询执行记录列表")
    public Result<PageResult<UIExecution>> getExecutionPage(
            @RequestParam(required = false, defaultValue = "1") Long page,
            @RequestParam(required = false, defaultValue = "10") Long page_size,
            @RequestParam(required = false) Long project_id,
            @RequestParam(required = false) String keyword) {
        IPage<UIExecution> result = uiExecutionService.getExecutionPage(project_id, keyword, page, page_size);
        return Result.success(PageResult.of(result));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取执行记录详情")
    public Result<UIExecution> getExecutionDetail(@PathVariable Long id) {
        UIExecution execution = uiExecutionService.getById(id);
        return Result.success(execution);
    }

    @PostMapping
    @Operation(summary = "创建执行记录")
    public Result<UIExecution> createExecution(@RequestBody UIExecution execution) {
        UIExecution created = uiExecutionService.createExecution(execution);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新执行记录")
    public Result<UIExecution> updateExecution(@PathVariable Long id, @RequestBody UIExecution execution) {
        UIExecution updated = uiExecutionService.updateExecution(id, execution);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除执行记录")
    public Result<Void> deleteExecution(@PathVariable Long id) {
        uiExecutionService.deleteExecution(id);
        return Result.success();
    }

    @GetMapping("/all")
    @Operation(summary = "获取项目的所有执行记录")
    public Result<List<UIExecution>> getAllExecutions(@RequestParam(required = false) Long project_id) {
        List<UIExecution> executions;
        if (project_id != null) {
            executions = uiExecutionService.lambdaQuery()
                    .eq(UIExecution::getSuiteId, project_id)
                    .list();
        } else {
            executions = uiExecutionService.list();
        }
        return Result.success(executions);
    }
}