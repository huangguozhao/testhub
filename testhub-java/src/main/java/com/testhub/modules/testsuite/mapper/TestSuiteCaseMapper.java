package com.testhub.modules.testsuite.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.testsuite.domain.TestSuiteCase;
import org.apache.ibatis.annotations.Mapper;

/**
 * 测试套件用例关联 Mapper
 */
@Mapper
public interface TestSuiteCaseMapper extends BaseMapper<TestSuiteCase> {
}
