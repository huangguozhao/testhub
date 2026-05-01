package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.ApiTestSuite;
import org.apache.ibatis.annotations.Mapper;

/**
 * API测试套件Mapper
 */
@Mapper
public interface ApiTestSuiteMapper extends BaseMapper<ApiTestSuite> {
}