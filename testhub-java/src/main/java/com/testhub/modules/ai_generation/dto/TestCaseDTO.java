package com.testhub.modules.ai_generation.dto;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

/**
 * 测试用例 DTO
 */
@Data
public class TestCaseDTO {

    private Long id;

    @NotNull(message = "项目ID不能为空")
    private Long projectId;

    @NotBlank(message = "用例标题不能为空")
    private String title;

    private String description;

    private String priority = "medium";

    private String type = "functional";

    private String status = "draft";

    private String precondition;

    private String expectedResult;

    private List<StepDTO> steps;

    /**
     * 步骤 DTO
     */
    @Data
    public static class StepDTO {
        private Long id;
        private Integer stepNumber;
        private String description;
        private String expectedResult;
    }
}
