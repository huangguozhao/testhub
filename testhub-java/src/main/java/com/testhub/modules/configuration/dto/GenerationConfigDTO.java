package com.testhub.modules.configuration.dto;

import lombok.Data;

@Data
public class GenerationConfigDTO {

    private String name;

    private String defaultOutputMode;

    private Boolean enableAutoReview;

    private Integer reviewTimeout;

    private Boolean isActive;
}
