package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.ApiExecutionRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * API执行记录Mapper
 */
@Mapper
public interface ApiExecutionRecordMapper extends BaseMapper<ApiExecutionRecord> {
}