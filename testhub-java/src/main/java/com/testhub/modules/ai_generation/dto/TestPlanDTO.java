package com.testhub.modules.ai_generation.dto;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 测试计划 DTO
 */
@Data
public class TestPlanDTO {

    private Long id;

    @NotNull(message = "项目ID不能为空")
    private Long projectId;

    @NotBlank(message = "计划名称不能为空")
    private String name;

    private String description;

    private LocalDateTime startDate;

    private LocalDateTime endDate;

    private String status;

    private Long assigneeId;

    private List<Long> suiteIds;
}
