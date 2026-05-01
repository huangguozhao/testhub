package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.ApiRequest;
import org.apache.ibatis.annotations.Mapper;

/**
 * API请求 Mapper
 */
@Mapper
public interface ApiRequestMapper extends BaseMapper<ApiRequest> {
}
