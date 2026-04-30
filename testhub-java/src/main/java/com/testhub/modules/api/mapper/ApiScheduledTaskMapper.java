package com.testhub.modules.api.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api.domain.ApiScheduledTask;
import org.apache.ibatis.annotations.Mapper;

/**
 * API定时任务Mapper
 */
@Mapper
public interface ApiScheduledTaskMapper extends BaseMapper<ApiScheduledTask> {
}