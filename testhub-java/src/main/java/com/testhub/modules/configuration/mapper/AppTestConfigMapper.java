package com.testhub.modules.configuration.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.configuration.domain.AppTestConfig;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AppTestConfigMapper extends BaseMapper<AppTestConfig> {
}
