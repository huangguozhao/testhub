package com.testhub.modules.api.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api.domain.ApiEnvironment;
import org.apache.ibatis.annotations.Mapper;

/**
 * API环境 Mapper
 */
@Mapper
public interface ApiEnvironmentMapper extends BaseMapper<ApiEnvironment> {
}
