package com.testhub.modules.system.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_user_profile")
public class UserProfile {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户 ID
     */
    private Long userId;

    /**
     * 主题：light=浅色, dark=深色
     */
    private String theme;

    /**
     * 语言：zh-hans=简体中文, en-us=英文
     */
    private String language;

    /**
     * 时区
     */
    private String timezone;

    /**
     * 个人简介
     */
    private String bio;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}