package com.testhub.modules.ui_automation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ui_automation.domain.UIExecution;
import org.apache.ibatis.annotations.Mapper;

/**
 * UI执行记录Mapper
 */
@Mapper
public interface UIExecutionMapper extends BaseMapper<UIExecution> {
}