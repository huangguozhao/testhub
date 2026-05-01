package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.ApiCollection;
import org.apache.ibatis.annotations.Mapper;

/**
 * API集合 Mapper
 */
@Mapper
public interface ApiCollectionMapper extends BaseMapper<ApiCollection> {
}
