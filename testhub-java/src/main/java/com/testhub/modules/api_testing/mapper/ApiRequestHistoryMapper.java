package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.ApiRequestHistory;
import org.apache.ibatis.annotations.Mapper;

/**
 * API请求历史记录 Mapper
 */
@Mapper
public interface ApiRequestHistoryMapper extends BaseMapper<ApiRequestHistory> {
}
