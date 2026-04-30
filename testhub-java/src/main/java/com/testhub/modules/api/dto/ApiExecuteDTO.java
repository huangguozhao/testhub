package com.testhub.modules.api.dto;

import lombok.Data;

/**
 * API执行请求 DTO
 */
@Data
public class ApiExecuteDTO {

    private Long requestId;

    private Long environmentId;

    /**
     * 覆盖的环境变量 (JSON)
     */
    private String overrideVariables;
}
