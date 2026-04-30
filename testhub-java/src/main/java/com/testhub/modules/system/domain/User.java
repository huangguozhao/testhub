package com.testhub.modules.system.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_user")
public class User extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户名（唯一）
     */
    private String username;

    /**
     * 邮箱（唯一）
     */
    private String email;

    /**
     * 密码（加密存储）
     */
    private String password;

    /**
     * 真实姓名
     */
    private String realName;

    /**
     * 手机号
     */
    private String phone;

    /**
     * 头像 URL
     */
    private String avatar;

    /**
     * 状态：enabled=启用, disabled=禁用
     */
    private String status;

    /**
     * 角色：ADMIN=管理员, USER=普通用户
     */
    private String roleName;

    /**
     * 是否超级管理员
     */
    private Integer isSuperuser;

    /**
     * 是否可以登录管理后台
     */
    private Integer isStaff;

    /**
     * 最后登录时间
     */
    private LocalDateTime lastLoginTime;

    /**
     * 最后登录 IP
     */
    private String lastLoginIp;

    /**
     * 是否删除
     */
    @TableLogic
    private Integer isDeleted;
}