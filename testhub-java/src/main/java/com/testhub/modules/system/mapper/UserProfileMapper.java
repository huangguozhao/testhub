package com.testhub.modules.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.system.domain.UserProfile;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserProfileMapper extends BaseMapper<UserProfile> {

    /**
     * 根据用户ID查询用户配置
     */
    @Select("SELECT * FROM sys_user_profile WHERE user_id = #{userId}")
    UserProfile selectByUserId(@Param("userId") Long userId);
}