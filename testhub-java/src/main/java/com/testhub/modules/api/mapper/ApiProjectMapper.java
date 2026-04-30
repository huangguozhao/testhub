package com.testhub.modules.api.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api.domain.ApiProject;
import org.apache.ibatis.annotations.Mapper;

/**
 * API项目 Mapper
 */
@Mapper
public interface ApiProjectMapper extends BaseMapper<ApiProject> {
}
