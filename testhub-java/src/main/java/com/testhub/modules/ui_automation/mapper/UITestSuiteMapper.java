package com.testhub.modules.ui_automation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ui_automation.domain.UITestSuite;
import org.apache.ibatis.annotations.Mapper;

/**
 * UI测试套件Mapper
 */
@Mapper
public interface UITestSuiteMapper extends BaseMapper<UITestSuite> {
}