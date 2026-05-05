package com.testhub.modules.api_testing.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.api_testing.domain.ApiEnvironment;
import com.testhub.modules.api_testing.service.ApiEnvironmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * API环境控制器
 */
@Tag(name = "API环境", description = "API环境管理")
@RestController
@RequestMapping("/api/api-environments")
@RequiredArgsConstructor
public class ApiEnvironmentController {

    private final ApiEnvironmentService apiEnvironmentService;

    @GetMapping
    @Operation(summary = "获取项目的所有环境")
    public Result<List<ApiEnvironment>> getEnvironments(@RequestParam(required = false) Long projectId) {
        List<ApiEnvironment> environments;
        if (projectId != null) {
            environments = apiEnvironmentService.getEnvironmentsByProject(projectId);
        } else {
            environments = apiEnvironmentService.list();
        }
        return Result.success(environments);
    }

    @GetMapping("/default")
    @Operation(summary = "获取项目默认环境")
    public Result<ApiEnvironment> getDefaultEnvironment(@RequestParam Long projectId) {
        ApiEnvironment environment = apiEnvironmentService.getDefaultEnvironment(projectId);
        return Result.success(environment);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取环境详情")
    public Result<ApiEnvironment> getEnvironment(@PathVariable Long id) {
        ApiEnvironment environment = apiEnvironmentService.getById(id);
        return Result.success(environment);
    }

    @PostMapping
    @Operation(summary = "创建环境")
    public Result<ApiEnvironment> createEnvironment(@Valid @RequestBody ApiEnvironment environment) {
        ApiEnvironment created = apiEnvironmentService.createEnvironment(environment);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新环境")
    public Result<ApiEnvironment> updateEnvironment(
            @PathVariable Long id,
            @Valid @RequestBody ApiEnvironment environment) {
        ApiEnvironment updated = apiEnvironmentService.updateEnvironment(id, environment);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除环境")
    public Result<Void> deleteEnvironment(@PathVariable Long id) {
        apiEnvironmentService.deleteEnvironment(id);
        return Result.success();
    }

    @PutMapping("/{id}/default")
    @Operation(summary = "设置默认环境")
    public Result<Void> setDefaultEnvironment(
            @PathVariable Long id,
            @RequestParam Long projectId) {
        apiEnvironmentService.setDefaultEnvironment(id, projectId);
        return Result.success();
    }
}
