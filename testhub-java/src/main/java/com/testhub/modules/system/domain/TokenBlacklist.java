package com.testhub.modules.system.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_token_blacklist")
public class TokenBlacklist {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * Token JTI（唯一标识）
     */
    private String tokenId;

    /**
     * 用户 ID
     */
    private Long userId;

    /**
     * 过期时间
     */
    private LocalDateTime expireTime;

    /**
     * 加入黑名单时间
     */
    private LocalDateTime createdAt;

    /**
     * 备注
     */
    private String remark;
}