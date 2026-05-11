package com.testhub.modules.version.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.version.domain.Version;
import com.testhub.modules.version.service.VersionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "版本管理", description = "项目版本管理")
@RestController
@RequestMapping("/api/versions")
@RequiredArgsConstructor
public class VersionController {

    private final VersionService versionService;

    @GetMapping
    @Operation(summary = "获取版本列表")
    public Result<Map<String, Object>> listVersions(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int page_size,
            @RequestParam(required = false) Long project_id,
            @RequestParam(required = false) String status) {
        Map<String, Object> result = versionService.listVersions(page, page_size, project_id, status);
        return Result.success(result);
    }

    @GetMapping("/projects/{projectId}/versions")
    @Operation(summary = "获取项目版本列表")
    public Result<List<Version>> getProjectVersions(@PathVariable Long projectId) {
        List<Version> versions = versionService.getProjectVersions(projectId);
        return Result.success(versions);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取版本详情")
    public Result<Version> getVersion(@PathVariable Long id) {
        Version version = versionService.getVersion(id);
        return Result.success(version);
    }

    @PostMapping
    @Operation(summary = "创建版本")
    public Result<Version> createVersion(@RequestBody Version version) {
        Version created = versionService.createVersion(version);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新版本")
    public Result<Version> updateVersion(@PathVariable Long id, @RequestBody Version version) {
        Version updated = versionService.updateVersion(id, version);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除版本")
    public Result<Void> deleteVersion(@PathVariable Long id) {
        versionService.deleteVersion(id);
        return Result.success();
    }
}
