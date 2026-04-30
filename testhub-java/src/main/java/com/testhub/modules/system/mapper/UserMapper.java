package com.testhub.modules.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.system.domain.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    /**
     * 根据用户名查询用户
     */
    User selectByUsername(@Param("username") String username);

    /**
     * 根据邮箱查询用户
     */
    User selectByEmail(@Param("email") String email);

    /**
     * 根据用户名或邮箱查询
     */
    User selectByUsernameOrEmail(@Param("username") String username, @Param("email") String email);

    /**
     * 查询用户列表（分页）
     */
    List<User> selectUserPage(@Param("keyword") String keyword, @Param("offset") long offset, @Param("limit") long limit);

    /**
     * 查询用户总数
     */
    long selectUserCount(@Param("keyword") String keyword);

    /**
     * 查询项目成员数量
     */
    Long selectProjectCountByUserId(@Param("userId") Long userId);
}