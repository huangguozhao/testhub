package com.testhub.modules.api_testing.dto;

import lombok.Data;

/**
 * 变量函数DTO
 * 用于提供变量助手功能，如随机数、时间戳等
 */
@Data
public class VariableFunctionDTO {
    /**
     * 函数名称
     */
    private String name;

    /**
     * 语法模板
     */
    private String syntax;

    /**
     * 函数描述
     */
    private String desc;

    /**
     * 使用示例
     */
    private String example;

    /**
     * 分类：随机数、测试数据、字符串、编码转换、加密、Crontab、时间日期
     */
    private String category;
}