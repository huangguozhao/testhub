package com.testhub.modules.api.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api.domain.NotificationLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 通知日志 Mapper
 */
@Mapper
public interface NotificationLogMapper extends BaseMapper<NotificationLog> {
}
