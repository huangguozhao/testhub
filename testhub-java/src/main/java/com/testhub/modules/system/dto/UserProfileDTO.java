package com.testhub.modules.system.dto;

import lombok.Data;

@Data
public class UserProfileDTO {

    private String theme;
    private String language;
    private String timezone;
    private String bio;
}