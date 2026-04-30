package com.testhub.modules.testsuite.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.testsuite.domain.TestSuite;
import org.apache.ibatis.annotations.Mapper;

/**
 * 测试套件 Mapper
 */
@Mapper
public interface TestSuiteMapper extends BaseMapper<TestSuite> {
}
