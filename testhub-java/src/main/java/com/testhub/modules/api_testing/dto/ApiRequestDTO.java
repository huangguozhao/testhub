package com.testhub.modules.api_testing.dto;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * API请求 DTO
 */
@Data
public class ApiRequestDTO {

    private Long id;

    @NotNull(message = "集合ID不能为空")
    private Long collectionId;

    @NotBlank(message = "请求名称不能为空")
    private String name;

    @NotBlank(message = "HTTP方法不能为空")
    private String method = "GET";

    @NotBlank(message = "请求URL不能为空")
    private String url;

    private String headers;

    private String params;

    private String bodyType = "none";

    private String bodyContent;

    private String authType = "none";

    private String authConfig;

    private String preScript;

    private String postScript;

    private String assertions;

    private String extractors;

    private Integer sortOrder;
}
