package com.testhub.modules.ai_generation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ai_generation.domain.TestCaseStep;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用例步骤 Mapper
 */
@Mapper
public interface TestCaseStepMapper extends BaseMapper<TestCaseStep> {
}
