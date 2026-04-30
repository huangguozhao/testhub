package com.testhub.modules.api.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api.domain.NotificationConfig;
import org.apache.ibatis.annotations.Mapper;

/**
 * 通知配置 Mapper
 */
@Mapper
public interface NotificationConfigMapper extends BaseMapper<NotificationConfig> {
}
