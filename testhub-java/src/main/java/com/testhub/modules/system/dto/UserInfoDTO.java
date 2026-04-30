package com.testhub.modules.system.dto;

import lombok.Data;

@Data
public class UserInfoDTO {

    private Long id;
    private String username;
    private String email;
    private String realName;
    private String phone;
    private String avatar;
    private String status;
    private String roleName;
    private UserProfileDTO profile;
}