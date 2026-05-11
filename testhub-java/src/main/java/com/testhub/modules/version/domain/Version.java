package com.testhub.modules.version.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("prj_version")
public class Version {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long projectId;
    private String name;
    private String description;
    private String status;
    private LocalDate releaseDate;
    private Integer isBaseline;
    private Integer isDeleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    private Long createdBy;
    private Long updatedBy;
}
