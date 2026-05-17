package com.testhub.modules.ui_automation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.ui_automation.domain.UIProject;
import com.testhub.modules.ui_automation.service.UIProjectService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * UI自动化项目控制器
 */
@Tag(name = "UI项目", description = "UI自动化项目管理")
@RestController
@RequestMapping("/api/ui-automation/projects")
@RequiredArgsConstructor
public class UIProjectController {

    private final UIProjectService uiProjectService;

    @GetMapping
    @Operation(summary = "分页查询UI项目列表")
    public Result<PageResult<UIProject>> getProjectPage(
            @RequestParam(required = false, defaultValue = "1") Long page,
            @RequestParam(required = false, defaultValue = "10") Long page_size,
            @RequestParam(required = false) Long project_id,
            @RequestParam(required = false) String keyword) {
        IPage<UIProject> result = uiProjectService.getProjectPage(project_id, keyword, page, page_size);
        return Result.success(PageResult.of(result));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取UI项目详情")
    public Result<UIProject> getProjectDetail(@PathVariable Long id) {
        UIProject project = uiProjectService.getById(id);
        return Result.success(project);
    }

    @PostMapping
    @Operation(summary = "创建UI项目")
    public Result<UIProject> createProject(@RequestBody UIProject project) {
        UIProject created = uiProjectService.createProject(project);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新UI项目")
    public Result<UIProject> updateProject(@PathVariable Long id, @RequestBody UIProject project) {
        UIProject updated = uiProjectService.updateProject(id, project);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除UI项目")
    public Result<Void> deleteProject(@PathVariable Long id) {
        uiProjectService.deleteProject(id);
        return Result.success();
    }

    @GetMapping("/all")
    @Operation(summary = "获取所有UI项目列表")
    public Result<List<UIProject>> getAllProjects() {
        List<UIProject> projects = uiProjectService.list();
        return Result.success(projects);
    }
}