package com.testhub.modules.configuration.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.configuration.domain.NotificationConfig;
import org.apache.ibatis.annotations.Mapper;

/**
 * 通知配置 Mapper
 */
@Mapper
public interface NotificationConfigMapper extends BaseMapper<NotificationConfig> {
}
