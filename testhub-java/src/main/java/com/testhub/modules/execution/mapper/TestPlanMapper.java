package com.testhub.modules.execution.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.execution.domain.TestPlan;
import org.apache.ibatis.annotations.Mapper;

/**
 * 测试计划 Mapper
 */
@Mapper
public interface TestPlanMapper extends BaseMapper<TestPlan> {
}
