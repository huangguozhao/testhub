package com.testhub.modules.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.common.exception.BusinessException;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.domain.UserProfile;
import com.testhub.modules.system.dto.UpdateProfileDTO;
import com.testhub.modules.system.dto.UserInfoDTO;
import com.testhub.modules.system.dto.UserProfileDTO;
import com.testhub.modules.system.mapper.UserMapper;
import com.testhub.modules.system.mapper.UserProfileMapper;
import com.testhub.modules.system.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final UserMapper userMapper;
    private final UserProfileMapper userProfileMapper;

    @Override
    public UserInfoDTO getUserInfo(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        return convertToUserInfoDTO(user);
    }

    @Override
    public User updateUser(Long userId, User user) {
        User existUser = userMapper.selectById(userId);
        if (existUser == null) {
            throw new BusinessException("用户不存在");
        }
        user.setId(userId);
        userMapper.updateById(user);
        return userMapper.selectById(userId);
    }

    @Override
    @Transactional
    public UserInfoDTO updateProfile(Long userId, UpdateProfileDTO dto) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        // 更新用户基本信息
        if (dto.getRealName() != null) {
            user.setRealName(dto.getRealName());
        }
        if (dto.getPhone() != null) {
            user.setPhone(dto.getPhone());
        }
        if (dto.getEmail() != null) {
            // 检查邮箱是否被其他用户占用
            User existingUser = userMapper.selectByEmail(dto.getEmail());
            if (existingUser != null && !existingUser.getId().equals(userId)) {
                throw new BusinessException("邮箱已被其他用户使用");
            }
            user.setEmail(dto.getEmail());
        }
        if (dto.getAvatar() != null) {
            user.setAvatar(dto.getAvatar());
        }
        userMapper.updateById(user);

        return convertToUserInfoDTO(user);
    }

    @Override
    public String updateAvatar(Long userId, String avatarUrl) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        user.setAvatar(avatarUrl);
        userMapper.updateById(user);
        return avatarUrl;
    }

    @Override
    public void disableUser(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        user.setStatus("disabled");
        userMapper.updateById(user);
    }

    @Override
    public void enableUser(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        user.setStatus("enabled");
        userMapper.updateById(user);
    }

    @Override
    public IPage<User> getUserPage(String keyword, long current, long size) {
        Page<User> page = new Page<>(current, size);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            wrapper.like(User::getUsername, keyword)
                    .or()
                    .like(User::getRealName, keyword)
                    .or()
                    .like(User::getEmail, keyword);
        }
        wrapper.eq(User::getStatus, "enabled");
        wrapper.orderByDesc(User::getCreatedAt);
        return userMapper.selectPage(page, wrapper);
    }

    @Override
    public User getByUsername(String username) {
        return userMapper.selectByUsername(username);
    }

    @Override
    public User getByEmail(String email) {
        return userMapper.selectByEmail(email);
    }

    private UserInfoDTO convertToUserInfoDTO(User user) {
        UserInfoDTO dto = new UserInfoDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setRealName(user.getRealName());
        dto.setPhone(user.getPhone());
        dto.setAvatar(user.getAvatar());
        dto.setStatus(user.getStatus());

        // 获取用户配置
        UserProfile profile = userProfileMapper.selectByUserId(user.getId());
        if (profile != null) {
            UserProfileDTO profileDTO = new UserProfileDTO();
            profileDTO.setTheme(profile.getTheme());
            profileDTO.setLanguage(profile.getLanguage());
            profileDTO.setTimezone(profile.getTimezone());
            profileDTO.setBio(profile.getBio());
            dto.setProfile(profileDTO);
        }

        return dto;
    }
}