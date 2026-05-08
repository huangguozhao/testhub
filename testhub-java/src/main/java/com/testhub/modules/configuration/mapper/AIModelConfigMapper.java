package com.testhub.modules.configuration.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.configuration.domain.AIModelConfig;
import org.apache.ibatis.annotations.Mapper;

/**
 * AI模型配置 Mapper
 */
@Mapper
public interface AIModelConfigMapper extends BaseMapper<AIModelConfig> {
}
