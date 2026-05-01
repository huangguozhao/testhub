package com.testhub.modules.ai_generation.dto;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

/**
 * 测试套件 DTO
 */
@Data
public class TestSuiteDTO {

    private Long id;

    @NotNull(message = "项目ID不能为空")
    private Long projectId;

    @NotBlank(message = "套件名称不能为空")
    private String name;

    private String description;

    private Integer sortOrder;

    private List<Long> caseIds;
}
