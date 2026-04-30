package com.testhub.modules.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.testhub.common.constant.Constants;
import com.testhub.common.exception.BusinessException;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.domain.UserProfile;
import com.testhub.modules.system.dto.*;
import com.testhub.modules.system.mapper.TokenBlacklistMapper;
import com.testhub.modules.system.mapper.UserMapper;
import com.testhub.modules.system.mapper.UserProfileMapper;
import com.testhub.modules.system.security.JwtTokenProvider;
import com.testhub.modules.system.security.UserDetailsImpl;
import com.testhub.modules.system.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserMapper userMapper;
    private final UserProfileMapper userProfileMapper;
    private final TokenBlacklistMapper tokenBlacklistMapper;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final RedisTemplate<String, Object> redisTemplate;

    @Override
    @Transactional
    public TokenDTO register(RegisterDTO registerDTO) {
        // 检查用户名是否存在
        User existUser = userMapper.selectByUsername(registerDTO.getUsername());
        if (existUser != null) {
            throw new BusinessException("用户名已存在");
        }

        // 检查邮箱是否存在
        User existEmail = userMapper.selectByEmail(registerDTO.getEmail());
        if (existEmail != null) {
            throw new BusinessException("邮箱已被注册");
        }

        // 创建用户
        User user = new User();
        user.setUsername(registerDTO.getUsername());
        user.setEmail(registerDTO.getEmail());
        user.setPassword(passwordEncoder.encode(registerDTO.getPassword()));
        user.setRealName(registerDTO.getRealName());
        user.setPhone(registerDTO.getPhone());
        user.setStatus("enabled");
        user.setRoleName("USER");  // 默认普通用户角色
        user.setIsSuperuser(0);     // 默认非超级管理员
        user.setIsStaff(0);         // 默认不可登录管理后台
        userMapper.insert(user);

        // 创建用户配置
        UserProfile profile = new UserProfile();
        profile.setUserId(user.getId());
        profile.setTheme("light");
        profile.setLanguage("zh-hans");
        profile.setTimezone("Asia/Shanghai");
        userProfileMapper.insert(profile);

        // 生成Token
        return generateTokenResponse(user);
    }

    @Override
    public TokenDTO login(LoginDTO loginDTO) {
        // 验证用户名密码
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginDTO.getUsername(),
                        loginDTO.getPassword()
                )
        );

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

        // 检查用户状态
        if (!"enabled".equals(userDetails.getStatus())) {
            throw new BusinessException("用户已被禁用");
        }

        User user = userMapper.selectById(userDetails.getId());
        return generateTokenResponse(user);
    }

    @Override
    public TokenDTO refreshToken(String refreshToken) {
        // 验证刷新令牌
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new BusinessException("刷新令牌无效");
        }

        // 检查令牌类型
        String tokenType = jwtTokenProvider.getTokenType(refreshToken);
        if (!"refresh".equals(tokenType)) {
            throw new BusinessException("无效的刷新令牌");
        }

        // 检查是否在黑名单
        String tokenId = jwtTokenProvider.getTokenId(refreshToken);
        if (tokenBlacklistMapper.existsByTokenId(tokenId)) {
            throw new BusinessException("刷新令牌已失效");
        }

        // 检查是否过期
        if (jwtTokenProvider.isTokenExpired(refreshToken)) {
            throw new BusinessException("刷新令牌已过期");
        }

        // 获取用户信息
        Long userId = jwtTokenProvider.getUserIdFromToken(refreshToken);
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        if (!"enabled".equals(user.getStatus())) {
            throw new BusinessException("用户已被禁用");
        }

        // 将旧刷新令牌加入黑名单
        Date expireDate = jwtTokenProvider.getExpirationFromToken(refreshToken);
        LocalDateTime expireTime = LocalDateTime.ofInstant(expireDate.toInstant(), ZoneId.systemDefault());
        tokenBlacklistMapper.insert(new com.testhub.modules.system.domain.TokenBlacklist() {{
            setTokenId(tokenId);
            setUserId(userId);
            setExpireTime(expireTime);
            setCreatedAt(LocalDateTime.now());
        }});

        // 生成新Token
        return generateTokenResponse(user);
    }

    @Override
    public void logout(String accessToken) {
        if (accessToken != null && accessToken.startsWith("Bearer ")) {
            accessToken = accessToken.substring(7);
        }

        // 将访问令牌加入黑名单
        String tokenId = jwtTokenProvider.getTokenId(accessToken);
        Long userId = jwtTokenProvider.getUserIdFromToken(accessToken);
        Date expireDate = jwtTokenProvider.getExpirationFromToken(accessToken);
        LocalDateTime expireTime = LocalDateTime.ofInstant(expireDate.toInstant(), ZoneId.systemDefault());
        tokenBlacklistMapper.insert(new com.testhub.modules.system.domain.TokenBlacklist() {{
            setTokenId(tokenId);
            setUserId(userId);
            setExpireTime(expireTime);
            setCreatedAt(LocalDateTime.now());
        }});

        // 从Redis中删除
        String blacklistKey = Constants.BLACKLIST_PREFIX + tokenId;
        redisTemplate.opsForValue().set(blacklistKey, "1", 7, TimeUnit.DAYS);
    }

    @Override
    public UserInfoDTO getCurrentUser(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        return convertToUserInfoDTO(user);
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
    @Transactional
    public void changePassword(Long userId, ChangePasswordDTO dto) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        // 验证旧密码
        if (!passwordEncoder.matches(dto.getOldPassword(), user.getPassword())) {
            throw new BusinessException("旧密码不正确");
        }

        // 更新新密码
        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        userMapper.updateById(user);
    }

    private TokenDTO generateTokenResponse(User user) {
        String accessToken = jwtTokenProvider.generateAccessToken(user.getId(), user.getUsername());
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId(), user.getUsername());

        TokenDTO tokenDTO = new TokenDTO();
        tokenDTO.setAccessToken(accessToken);
        tokenDTO.setRefreshToken(refreshToken);
        tokenDTO.setTokenType("Bearer");
        tokenDTO.setExpiresIn(jwtTokenProvider.getAccessTokenExpiration());
        tokenDTO.setUser(convertToUserInfoDTO(user));

        return tokenDTO;
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