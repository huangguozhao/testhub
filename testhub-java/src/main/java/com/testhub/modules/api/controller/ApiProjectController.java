package com.testhub.modules.api.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.api.domain.ApiProject;
import com.testhub.modules.api.service.ApiProjectService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * API项目管理控制器
 */
@Tag(name = "API项目", description = "API项目管理")
@RestController
@RequestMapping("/api/api-projects")
@RequiredArgsConstructor
public class ApiProjectController {

    private final ApiProjectService apiProjectService;

    @GetMapping
    @Operation(summary = "分页查询API项目")
    public Result<PageResult<ApiProject>> getApiProjectPage(
            @RequestParam(required = false) Long projectId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size) {
        IPage<ApiProject> page = apiProjectService.getApiProjectPage(projectId, keyword, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取API项目详情")
    public Result<ApiProject> getApiProject(@PathVariable Long id) {
        ApiProject project = apiProjectService.getById(id);
        return Result.success(project);
    }

    @PostMapping
    @Operation(summary = "创建API项目")
    public Result<ApiProject> createApiProject(@Valid @RequestBody ApiProject apiProject) {
        ApiProject created = apiProjectService.createApiProject(apiProject);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新API项目")
    public Result<ApiProject> updateApiProject(
            @PathVariable Long id,
            @Valid @RequestBody ApiProject apiProject) {
        ApiProject updated = apiProjectService.updateApiProject(id, apiProject);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除API项目")
    public Result<Void> deleteApiProject(@PathVariable Long id) {
        apiProjectService.deleteApiProject(id);
        return Result.success();
    }
}
