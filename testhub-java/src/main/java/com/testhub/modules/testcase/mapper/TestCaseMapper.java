package com.testhub.modules.testcase.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.testcase.domain.TestCase;
import org.apache.ibatis.annotations.Mapper;

/**
 * 测试用例 Mapper
 */
@Mapper
public interface TestCaseMapper extends BaseMapper<TestCase> {
}
