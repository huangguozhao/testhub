package com.testhub.modules.testcase.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.testcase.domain.TestCaseStep;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用例步骤 Mapper
 */
@Mapper
public interface TestCaseStepMapper extends BaseMapper<TestCaseStep> {
}
