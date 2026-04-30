package com.testhub.modules.system.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.dto.UpdateProfileDTO;
import com.testhub.modules.system.dto.UserInfoDTO;

/**
 * 用户服务接口
 */
public interface UserService extends IService<User> {

    /**
     * 获取用户信息
     */
    UserInfoDTO getUserInfo(Long userId);

    /**
     * 更新用户
     */
    User updateUser(Long userId, User user);

    /**
     * 更新个人资料
     */
    UserInfoDTO updateProfile(Long userId, UpdateProfileDTO dto);

    /**
     * 更新头像
     */
    String updateAvatar(Long userId, String avatarUrl);

    /**
     * 禁用用户
     */
    void disableUser(Long userId);

    /**
     * 启用用户
     */
    void enableUser(Long userId);

    /**
     * 分页查询用户列表
     */
    IPage<User> getUserPage(String keyword, long current, long size);

    /**
     * 根据用户名查询
     */
    User getByUsername(String username);

    /**
     * 根据邮箱查询
     */
    User getByEmail(String email);
}