package com.testhub.modules.configuration.dto;

import lombok.Data;

@Data
public class PromptConfigDTO {

    private String name;

    private String promptType;

    private String content;

    private Boolean isActive;
}
