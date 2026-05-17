package com.testhub.modules.ai_generation.version.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ai_generation.version.domain.Version;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface VersionMapper extends BaseMapper<Version> {
}