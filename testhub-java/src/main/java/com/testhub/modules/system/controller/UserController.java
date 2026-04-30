package com.testhub.modules.system.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.dto.UserInfoDTO;
import com.testhub.modules.system.security.UserDetailsImpl;
import com.testhub.modules.system.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "用户管理", description = "用户CRUD管理")
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    @Operation(summary = "获取当前用户")
    public Result<UserInfoDTO> getCurrentUser(@AuthenticationPrincipal UserDetailsImpl userDetails) {
        UserInfoDTO userInfo = userService.getUserInfo(userDetails.getId());
        return Result.success(userInfo);
    }

    @GetMapping
    @Operation(summary = "获取用户列表")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<PageResult<User>> getUserList(
            @Parameter(description = "关键词搜索") @RequestParam(required = false) String keyword,
            @Parameter(description = "当前页") @RequestParam(defaultValue = "1") long current,
            @Parameter(description = "每页大小") @RequestParam(defaultValue = "20") long size) {
        IPage<User> page = userService.getUserPage(keyword, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取用户详情")
    public Result<UserInfoDTO> getUserById(@PathVariable Long id) {
        UserInfoDTO userInfo = userService.getUserInfo(id);
        return Result.success(userInfo);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新用户")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<User> updateUser(
            @PathVariable Long id,
            @RequestBody User user) {
        User updatedUser = userService.updateUser(id, user);
        return Result.success(updatedUser);
    }

    @PutMapping("/{id}/avatar")
    @Operation(summary = "更新头像")
    public Result<String> updateAvatar(
            @PathVariable Long id,
            @RequestParam String avatarUrl) {
        String avatar = userService.updateAvatar(id, avatarUrl);
        return Result.success(avatar);
    }

    @PutMapping("/{id}/disable")
    @Operation(summary = "禁用用户")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> disableUser(@PathVariable Long id) {
        userService.disableUser(id);
        return Result.success();
    }

    @PutMapping("/{id}/enable")
    @Operation(summary = "启用用户")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> enableUser(@PathVariable Long id) {
        userService.enableUser(id);
        return Result.success();
    }
}