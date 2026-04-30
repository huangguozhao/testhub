package com.testhub.config;

import io.minio.MinioClient;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MinIO 对象存储配置
 *
 * MinIO Console: http://localhost:9001
 * 默认账号: minioadmin / minioadmin123
 */
@Slf4j
@Configuration
public class MinioConfig {

    @Getter
    @Value("${minio.endpoint:http://127.0.0.1:9000}")
    private String endpoint;

    @Value("${minio.access-key:minioadmin}")
    private String accessKey;

    @Value("${minio.secret-key:minioadmin123}")
    private String secretKey;

    @Getter
    @Value("${minio.bucket-name:testhub}")
    private String bucketName;

    @Bean
    public MinioClient minioClient() {
        log.info("========== MinIO 初始化配置 ==========");
        log.info("Endpoint: {}", endpoint);
        log.info("Bucket: {}", bucketName);

        return MinioClient.builder()
                .endpoint(endpoint)
                .credentials(accessKey, secretKey)
                .build();
    }

}
