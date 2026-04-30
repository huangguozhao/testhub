package com.testhub.modules.system.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateProfileDTO {

    @Size(max = 50, message = "真实姓名长度不能超过50个字符")
    private String realName;

    @Size(max = 20, message = "手机号长度不能超过20个字符")
    private String phone;

    @Email(message = "邮箱格式不正确")
    private String email;

    private String avatar;
}