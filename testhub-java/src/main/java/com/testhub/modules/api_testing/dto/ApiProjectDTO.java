package com.testhub.modules.api_testing.dto;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * API项目 DTO（用于列表返回，包含嵌套的 owner 和 members）
 */
@Data
public class ApiProjectDTO {

    private Long id;
    private Long projectId;
    private String name;
    private String description;
    private String projectType;
    private String status;
    private LocalDate startDate;
    private LocalDate endDate;
    private Long ownerId;
    private String baseUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long createdBy;
    private Long updatedBy;
    private Integer isDeleted;

    /**
     * 负责人信息
     */
    private UserDTO owner;

    /**
     * 成员列表
     */
    private List<UserDTO> members;

    @Data
    public static class UserDTO {
        private Long id;
        private String username;
        private String email;
        private String realName;
        private String phone;
        private String avatar;
        private String status;
    }
}
