package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.ApiTestSuiteRequest;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ApiTestSuiteRequestMapper extends BaseMapper<ApiTestSuiteRequest> {
}
