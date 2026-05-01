package com.testhub.modules.ai_generation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ai_generation.domain.TestPlan;
import org.apache.ibatis.annotations.Mapper;

/**
 * 测试计划 Mapper
 */
@Mapper
public interface TestPlanMapper extends BaseMapper<TestPlan> {
}
