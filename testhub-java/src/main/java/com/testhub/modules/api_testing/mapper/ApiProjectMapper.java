package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.ApiProject;
import org.apache.ibatis.annotations.Mapper;

/**
 * API项目 Mapper
 */
@Mapper
public interface ApiProjectMapper extends BaseMapper<ApiProject> {
}
