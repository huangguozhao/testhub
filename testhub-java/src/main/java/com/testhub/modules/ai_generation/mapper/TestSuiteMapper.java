package com.testhub.modules.ai_generation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ai_generation.domain.TestSuite;
import org.apache.ibatis.annotations.Mapper;

/**
 * 测试套件 Mapper
 */
@Mapper
public interface TestSuiteMapper extends BaseMapper<TestSuite> {
}
