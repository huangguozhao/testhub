package com.testhub.modules.ui_automation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ui_automation.domain.UITestCase;
import org.apache.ibatis.annotations.Mapper;

/**
 * UI测试用例Mapper
 */
@Mapper
public interface UITestCaseMapper extends BaseMapper<UITestCase> {
}