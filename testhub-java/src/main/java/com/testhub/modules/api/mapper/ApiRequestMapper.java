package com.testhub.modules.api.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api.domain.ApiRequest;
import org.apache.ibatis.annotations.Mapper;

/**
 * API请求 Mapper
 */
@Mapper
public interface ApiRequestMapper extends BaseMapper<ApiRequest> {
}
