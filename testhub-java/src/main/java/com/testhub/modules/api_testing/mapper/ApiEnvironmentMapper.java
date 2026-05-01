package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.ApiEnvironment;
import org.apache.ibatis.annotations.Mapper;

/**
 * API环境 Mapper
 */
@Mapper
public interface ApiEnvironmentMapper extends BaseMapper<ApiEnvironment> {
}
