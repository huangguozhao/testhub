package com.testhub.modules.api_testing.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.api_testing.domain.TaskNotificationSetting;
import com.testhub.modules.api_testing.dto.TaskNotificationSettingDTO;
import com.testhub.modules.api_testing.service.TaskNotificationSettingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 定时任务通知设置控制器
 */
@Tag(name = "任务通知设置", description = "定时任务通知设置管理")
@RestController
@RequestMapping("/api/task-notification-settings")
@RequiredArgsConstructor
public class TaskNotificationSettingController {

    private final TaskNotificationSettingService taskNotificationSettingService;

    @GetMapping
    @Operation(summary = "根据任务ID查询通知设置")
    public Result<TaskNotificationSetting> getByTaskId(@RequestParam Long taskId) {
        TaskNotificationSetting setting = taskNotificationSettingService.getByTaskId(taskId);
        return Result.success(setting);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID获取通知设置详情")
    public Result<TaskNotificationSetting> getById(@PathVariable Long id) {
        TaskNotificationSetting setting = taskNotificationSettingService.getById(id);
        return Result.success(setting);
    }

    @PostMapping
    @Operation(summary = "创建通知设置")
    public Result<TaskNotificationSetting> create(@Valid @RequestBody TaskNotificationSettingDTO dto) {
        TaskNotificationSetting setting = taskNotificationSettingService.createOrUpdate(dto);
        return Result.success(setting);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新通知设置")
    public Result<TaskNotificationSetting> update(
            @PathVariable Long id,
            @Valid @RequestBody TaskNotificationSettingDTO dto) {
        dto.setId(id);
        TaskNotificationSetting setting = taskNotificationSettingService.createOrUpdate(dto);
        return Result.success(setting);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除通知设置")
    public Result<Void> delete(@PathVariable Long id) {
        taskNotificationSettingService.removeById(id);
        return Result.success();
    }
}
