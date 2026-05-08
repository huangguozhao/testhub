package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.TaskNotificationSetting;
import org.apache.ibatis.annotations.Mapper;

/**
 * 定时任务通知设置 Mapper
 */
@Mapper
public interface TaskNotificationSettingMapper extends BaseMapper<TaskNotificationSetting> {
}
