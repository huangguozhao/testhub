package com.testhub.modules.system.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.system.dto.*;
import com.testhub.modules.system.security.UserDetailsImpl;
import com.testhub.modules.system.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "认证管理", description = "用户注册、登录、Token管理")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @Operation(summary = "用户注册")
    public Result<TokenDTO> register(@Valid @RequestBody RegisterDTO registerDTO) {
        TokenDTO tokenDTO = authService.register(registerDTO);
        return Result.success(tokenDTO);
    }

    @PostMapping("/login")
    @Operation(summary = "用户登录")
    public Result<TokenDTO> login(@Valid @RequestBody LoginDTO loginDTO) {
        TokenDTO tokenDTO = authService.login(loginDTO);
        return Result.success(tokenDTO);
    }

    @PostMapping("/refresh")
    @Operation(summary = "刷新Token")
    public Result<TokenDTO> refreshToken(@Valid @RequestBody RefreshTokenDTO refreshTokenDTO) {
        TokenDTO tokenDTO = authService.refreshToken(refreshTokenDTO.getRefreshToken());
        return Result.success(tokenDTO);
    }

    @PostMapping("/logout")
    @Operation(summary = "退出登录")
    public Result<Void> logout(@RequestHeader("Authorization") String accessToken) {
        authService.logout(accessToken);
        return Result.success();
    }

    @GetMapping("/me")
    @Operation(summary = "获取当前用户信息")
    public Result<UserInfoDTO> getCurrentUser(@AuthenticationPrincipal UserDetailsImpl userDetails) {
        UserInfoDTO userInfo = authService.getCurrentUser(userDetails.getId());
        return Result.success(userInfo);
    }

    @PutMapping("/profile")
    @Operation(summary = "更新个人资料")
    public Result<UserInfoDTO> updateProfile(
            @AuthenticationPrincipal UserDetailsImpl userDetails,
            @Valid @RequestBody UpdateProfileDTO dto) {
        UserInfoDTO userInfo = authService.updateProfile(userDetails.getId(), dto);
        return Result.success(userInfo);
    }

    @PutMapping("/password")
    @Operation(summary = "修改密码")
    public Result<Void> changePassword(
            @AuthenticationPrincipal UserDetailsImpl userDetails,
            @Valid @RequestBody ChangePasswordDTO dto) {
        authService.changePassword(userDetails.getId(), dto);
        return Result.success();
    }
}