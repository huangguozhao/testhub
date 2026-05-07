package com.testhub.config;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

/**
 * Jackson 配置
 * 配置 JSON 序列化为下划线命名（与前端保持一致）
 */
@Configuration
public class JacksonConfig {

    private static final ZoneId SHANGHAI_ZONE = ZoneId.of("Asia/Shanghai");
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss[.SSS][XXX][X]['Z']");

    @Bean
    @Primary
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.setPropertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);

        // 注册自定义 LocalDateTime 反序列化器，支持带时区的 ISO-8601 格式
        SimpleModule module = new SimpleModule();
        module.addDeserializer(LocalDateTime.class, new LocalDateTimeDeserializer(FORMATTER) {
            @Override
            public LocalDateTime deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
                String text = p.getText().trim();
                if (text == null || text.isEmpty()) return null;

                // 处理带 Z 后缀的 UTC 时间（如 "2026-05-07T14:40:00.000Z"）
                if (text.endsWith("Z") || text.endsWith("z")) {
                    try {
                        ZonedDateTime zdt = ZonedDateTime.parse(text, DateTimeFormatter.ISO_INSTANT.withZone(SHANGHAI_ZONE));
                        return zdt.withZoneSameInstant(SHANGHAI_ZONE).toLocalDateTime();
                    } catch (DateTimeParseException ignored) {}
                }

                // 处理带时区偏移的时间（如 "2026-05-07T22:40:00+08:00"）
                if (text.contains("+") || text.lastIndexOf('-') > 10) {
                    try {
                        ZonedDateTime zdt = ZonedDateTime.parse(text);
                        return zdt.withZoneSameInstant(SHANGHAI_ZONE).toLocalDateTime();
                    } catch (DateTimeParseException ignored) {}
                }

                // 普通 LocalDateTime 格式（如 "2026-05-07T22:40:00"）
                try {
                    return LocalDateTime.parse(text, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                } catch (DateTimeParseException e) {
                    return super.deserialize(p, ctxt);
                }
            }
        });
        // 先注册 JavaTimeModule，再用自定义模块覆盖 LocalDateTime 反序列化器
        mapper.registerModule(new JavaTimeModule());
        mapper.registerModule(module);
        mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        return mapper;
    }
}
