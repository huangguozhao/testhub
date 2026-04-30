package com.testhub.modules.api.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api.domain.ApiCollection;
import org.apache.ibatis.annotations.Mapper;

/**
 * API集合 Mapper
 */
@Mapper
public interface ApiCollectionMapper extends BaseMapper<ApiCollection> {
}
