package com.testhub.modules.api.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.api.domain.NotificationLog;
import com.testhub.modules.api.dto.SendNotificationDTO;
import com.testhub.modules.api.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 通知控制器
 */
@Tag(name = "通知", description = "通知发送和日志管理")
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping("/send")
    @Operation(summary = "发送通知")
    public Result<NotificationLog> sendNotification(@RequestBody SendNotificationDTO dto) {
        NotificationLog logEntry = notificationService.sendNotification(dto);
        return Result.success(logEntry);
    }

    @GetMapping("/logs")
    @Operation(summary = "分页查询通知日志")
    public Result<PageResult<NotificationLog>> getLogPage(
            @RequestParam(required = false) Long taskId,
            @RequestParam(required = false) String taskType,
            @RequestParam(required = false) String channel,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size) {
        IPage<NotificationLog> page = notificationService.getLogPage(taskId, taskType, channel, status, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/logs/{id}")
    @Operation(summary = "获取通知日志详情")
    public Result<NotificationLog> getLog(@PathVariable Long id) {
        NotificationLog logEntry = notificationService.getLog(id);
        return Result.success(logEntry);
    }

    @PostMapping("/logs/{id}/retry")
    @Operation(summary = "重试失败的通知")
    public Result<NotificationLog> retryNotification(@PathVariable Long id) {
        NotificationLog logEntry = notificationService.retryNotification(id);
        return Result.success(logEntry);
    }

    @DeleteMapping("/logs/{id}")
    @Operation(summary = "删除通知日志")
    public Result<Void> deleteLog(@PathVariable Long id) {
        notificationService.deleteLog(id);
        return Result.success();
    }
}
