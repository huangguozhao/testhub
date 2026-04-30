package com.testhub.modules.execution.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.execution.domain.TestRunCase;
import org.apache.ibatis.annotations.Mapper;

/**
 * 执行用例记录 Mapper
 */
@Mapper
public interface TestRunCaseMapper extends BaseMapper<TestRunCase> {
}
