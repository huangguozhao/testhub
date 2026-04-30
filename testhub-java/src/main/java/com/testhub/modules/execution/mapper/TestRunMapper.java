package com.testhub.modules.execution.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.execution.domain.TestRun;
import org.apache.ibatis.annotations.Mapper;

/**
 * 测试执行记录 Mapper
 */
@Mapper
public interface TestRunMapper extends BaseMapper<TestRun> {
}
