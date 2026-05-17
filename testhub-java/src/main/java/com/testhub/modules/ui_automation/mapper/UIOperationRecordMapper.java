package com.testhub.modules.ui_automation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ui_automation.domain.UIOperationRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * UI操作记录Mapper
 */
@Mapper
public interface UIOperationRecordMapper extends BaseMapper<UIOperationRecord> {
}