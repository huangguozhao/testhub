package com.testhub.modules.configuration.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cfg_app_test_config")
public class AppTestConfig {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String adbPath;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
