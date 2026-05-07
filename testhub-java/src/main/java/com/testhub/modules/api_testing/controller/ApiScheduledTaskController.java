package com.testhub.modules.api_testing.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.api_testing.domain.ApiScheduledTask;
import com.testhub.modules.api_testing.service.ApiScheduledTaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * API定时任务控制器
 */
@Tag(name = "API定时任务", description = "API定时任务管理")
@RestController
@RequestMapping("/api/api-scheduled-tasks")
@RequiredArgsConstructor
public class ApiScheduledTaskController {

    private final ApiScheduledTaskService apiScheduledTaskService;

    @GetMapping
    @Operation(summary = "获取项目的所有定时任务")
    public Result<List<ApiScheduledTask>> getTasks(@RequestParam(required = false) Long projectId) {
        List<ApiScheduledTask> tasks;
        if (projectId != null) {
            tasks = apiScheduledTaskService.getTasksByProject(projectId);
        } else {
            tasks = apiScheduledTaskService.list();
        }
        return Result.success(tasks);
    }

    @GetMapping("/suite/{suiteId}")
    @Operation(summary = "获取套件的所有定时任务")
    public Result<List<ApiScheduledTask>> getTasksBySuite(@PathVariable Long suiteId) {
        List<ApiScheduledTask> tasks = apiScheduledTaskService.getTasksBySuite(suiteId);
        return Result.success(tasks);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取任务详情")
    public Result<ApiScheduledTask> getTask(@PathVariable Long id) {
        ApiScheduledTask task = apiScheduledTaskService.getTask(id);
        return Result.success(task);
    }

    @PostMapping
    @Operation(summary = "创建定时任务")
    public Result<ApiScheduledTask> createTask(@Valid @RequestBody ApiScheduledTask task) {
        ApiScheduledTask created = apiScheduledTaskService.createTask(task);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新定时任务")
    public Result<ApiScheduledTask> updateTask(
            @PathVariable Long id,
            @Valid @RequestBody ApiScheduledTask task) {
        ApiScheduledTask updated = apiScheduledTaskService.updateTask(id, task);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除定时任务")
    public Result<Void> deleteTask(@PathVariable Long id) {
        apiScheduledTaskService.deleteTask(id);
        return Result.success();
    }

    @PutMapping("/{id}/enable")
    @Operation(summary = "启用任务")
    public Result<Void> enableTask(@PathVariable Long id) {
        apiScheduledTaskService.enableTask(id);
        return Result.success();
    }

    @PutMapping("/{id}/disable")
    @Operation(summary = "禁用任务")
    public Result<Void> disableTask(@PathVariable Long id) {
        apiScheduledTaskService.disableTask(id);
        return Result.success();
    }

    @PostMapping("/{id}/execute")
    @Operation(summary = "立即执行任务")
    public Result<Void> executeTaskNow(@PathVariable Long id) {
        apiScheduledTaskService.executeTaskNow(id);
        return Result.success();
    }
}