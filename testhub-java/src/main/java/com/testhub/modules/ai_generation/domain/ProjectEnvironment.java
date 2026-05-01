package com.testhub.modules.ai_generation.domain;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.io.IOException;

@Data
@TableName("prj_project_environment")
public class ProjectEnvironment extends BaseEntity {

    /**
     * 项目ID
     */
    private Long projectId;

    /**
     * 环境名称
     */
    private String name;

    /**
     * 基础 URL
     */
    private String baseUrl;

    /**
     * 环境描述
     */
    private String description;

    /**
     * 环境变量（JSON格式）
     */
    @JsonDeserialize(using = VariablesDeserializer.class)
    private String variables;

    /**
     * 是否默认环境
     */
    private Boolean isDefault;

    /**
     * 排序
     */
    private Integer sortOrder;

    /**
     * 自定义反序列化器，处理前端发送的 {} 空对象或字符串
     */
    public static class VariablesDeserializer extends JsonDeserializer<String> {
        @Override
        public String deserialize(com.fasterxml.jackson.core.JsonParser p, DeserializationContext ctxt)
                throws IOException {
            JsonToken token = p.currentToken();
            if (token == JsonToken.START_OBJECT) {
                // 空对象 {} 转为空字符串
                return "{}";
            } else if (token == JsonToken.VALUE_STRING) {
                return p.getValueAsString();
            } else if (token == JsonToken.VALUE_NULL) {
                return null;
            }
            // 其他情况尝试直接转为字符串
            return p.getValueAsString();
        }
    }
}