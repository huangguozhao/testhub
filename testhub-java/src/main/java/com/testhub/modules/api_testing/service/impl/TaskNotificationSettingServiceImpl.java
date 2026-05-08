package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.TaskNotificationSetting;
import com.testhub.modules.api_testing.dto.TaskNotificationSettingDTO;
import com.testhub.modules.api_testing.mapper.TaskNotificationSettingMapper;
import com.testhub.modules.api_testing.service.TaskNotificationSettingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 定时任务通知设置服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TaskNotificationSettingServiceImpl
        extends ServiceImpl<TaskNotificationSettingMapper, TaskNotificationSetting>
        implements TaskNotificationSettingService {

    @Override
    public TaskNotificationSetting getByTaskId(Long taskId) {
        return this.getOne(new LambdaQueryWrapper<TaskNotificationSetting>()
                .eq(TaskNotificationSetting::getTaskId, taskId));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public TaskNotificationSetting createOrUpdate(TaskNotificationSettingDTO dto) {
        TaskNotificationSetting setting;

        if (dto.getId() != null) {
            // 更新已有设置
            setting = this.getById(dto.getId());
            if (setting == null) {
                throw new RuntimeException("通知设置不存在: " + dto.getId());
            }
        } else if (dto.getTaskId() != null) {
            // 按 taskId 查找已有设置（一个任务只有一条设置）
            setting = this.getByTaskId(dto.getTaskId());
        } else {
            throw new RuntimeException("必须提供 taskId 或 id");
        }

        if (setting == null) {
            // 新建
            setting = new TaskNotificationSetting();
            setting.setTaskId(dto.getTaskId());
            applyDto(setting, dto);
            this.save(setting);
            log.info("创建任务通知设置: taskId={}, id={}", dto.getTaskId(), setting.getId());
        } else {
            // 更新
            applyDto(setting, dto);
            this.updateById(setting);
            log.info("更新任务通知设置: id={}", setting.getId());
        }

        return setting;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteByTaskId(Long taskId) {
        TaskNotificationSetting setting = this.getByTaskId(taskId);
        if (setting != null) {
            this.removeById(setting.getId());
            log.info("删除任务通知设置: taskId={}", taskId);
        }
    }

    @Override
    public boolean shouldNotify(TaskNotificationSetting setting, String executionStatus) {
        if (setting == null || !Boolean.TRUE.equals(setting.getIsEnabled())) {
            return false;
        }

        return switch (executionStatus) {
            case "success" -> Boolean.TRUE.equals(setting.getNotifyOnSuccess());
            case "failed" -> Boolean.TRUE.equals(setting.getNotifyOnFailure());
            case "timeout" -> Boolean.TRUE.equals(setting.getNotifyOnTimeout());
            case "error" -> Boolean.TRUE.equals(setting.getNotifyOnError());
            default -> false;
        };
    }

    private void applyDto(TaskNotificationSetting setting, TaskNotificationSettingDTO dto) {
        if (dto.getNotificationType() != null) {
            setting.setNotificationType(dto.getNotificationType());
        }
        if (dto.getNotificationConfigId() != null) {
            setting.setNotificationConfigId(dto.getNotificationConfigId());
        }
        if (dto.getIsEnabled() != null) {
            setting.setIsEnabled(dto.getIsEnabled());
        }
        if (dto.getNotifyOnSuccess() != null) {
            setting.setNotifyOnSuccess(dto.getNotifyOnSuccess());
        }
        if (dto.getNotifyOnFailure() != null) {
            setting.setNotifyOnFailure(dto.getNotifyOnFailure());
        }
        if (dto.getNotifyOnTimeout() != null) {
            setting.setNotifyOnTimeout(dto.getNotifyOnTimeout());
        }
        if (dto.getNotifyOnError() != null) {
            setting.setNotifyOnError(dto.getNotifyOnError());
        }
        if (dto.getCustomWebhookBots() != null) {
            setting.setCustomWebhookBots(dto.getCustomWebhookBots());
        }
        if (dto.getCustomRecipients() != null) {
            setting.setCustomRecipients(dto.getCustomRecipients());
        }
    }
}
