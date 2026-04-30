package com.testhub.modules.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.system.domain.TokenBlacklist;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface TokenBlacklistMapper extends BaseMapper<TokenBlacklist> {

    /**
     * 检查Token是否在黑名单中
     */
    @Select("SELECT COUNT(*) > 0 FROM sys_token_blacklist WHERE token_id = #{tokenId}")
    boolean existsByTokenId(@Param("tokenId") String tokenId);
}