package com.testhub.modules.system.service;

import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.dto.*;

/**
 * 认证服务接口
 */
public interface AuthService {

    /**
     * 用户注册
     */
    TokenDTO register(RegisterDTO registerDTO);

    /**
     * 用户登录
     */
    TokenDTO login(LoginDTO loginDTO);

    /**
     * 刷新Token
     */
    TokenDTO refreshToken(String refreshToken);

    /**
     * 退出登录
     */
    void logout(String accessToken);

    /**
     * 获取当前用户信息
     */
    UserInfoDTO getCurrentUser(Long userId);

    /**
     * 更新个人资料
     */
    UserInfoDTO updateProfile(Long userId, UpdateProfileDTO dto);

    /**
     * 修改密码
     */
    void changePassword(Long userId, ChangePasswordDTO dto);
}