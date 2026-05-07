package com.testhub.modules.storage.service.impl;

import com.testhub.modules.storage.service.FileStorageService;
import io.minio.*;
import io.minio.http.Method;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.util.concurrent.TimeUnit;

/**
 * MinIO 文件存储服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FileStorageServiceImpl implements FileStorageService {

    private final MinioClient minioClient;

    @Value("${minio.bucket-name:testhub}")
    private String defaultBucket;

    @Value("${minio.url-expiration:7}")
    private int urlExpiration;

    @Override
    public String uploadFile(String bucket, String objectName, InputStream inputStream, String contentType, long size) {
        try {
            createBucketIfNotExist(bucket);

            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(bucket)
                            .object(objectName)
                            .stream(inputStream, size, -1)
                            .contentType(contentType)
                            .build()
            );

            log.info("文件上传成功: bucket={}, object={}", bucket, objectName);
            return getFileUrl(bucket, objectName);
        } catch (Exception e) {
            log.error("文件上传失败: bucket={}, object={}", bucket, objectName, e);
            throw new RuntimeException("文件上传失败: " + e.getMessage(), e);
        }
    }

    @Override
    public String uploadFile(String objectName, InputStream inputStream, String contentType, long size) {
        return uploadFile(defaultBucket, objectName, inputStream, contentType, size);
    }

    @Override
    public String getFileUrl(String bucket, String objectName) {
        try {
            return minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .method(Method.GET)
                            .bucket(bucket)
                            .object(objectName)
                            .expiry(urlExpiration, TimeUnit.DAYS)
                            .build()
            );
        } catch (Exception e) {
            log.error("获取文件URL失败: bucket={}, object={}", bucket, objectName, e);
            throw new RuntimeException("获取文件URL失败: " + e.getMessage(), e);
        }
    }

    @Override
    public String getFileUrl(String objectName) {
        return getFileUrl(defaultBucket, objectName);
    }

    @Override
    public void deleteFile(String bucket, String objectName) {
        try {
            minioClient.removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(bucket)
                            .object(objectName)
                            .build()
            );
            log.info("文件删除成功: bucket={}, object={}", bucket, objectName);
        } catch (Exception e) {
            log.error("文件删除失败: bucket={}, object={}", bucket, objectName, e);
            throw new RuntimeException("文件删除失败: " + e.getMessage(), e);
        }
    }

    @Override
    public void deleteFile(String objectName) {
        deleteFile(defaultBucket, objectName);
    }

    @Override
    public boolean fileExists(String bucket, String objectName) {
        try {
            minioClient.statObject(
                    StatObjectArgs.builder()
                            .bucket(bucket)
                            .object(objectName)
                            .build()
            );
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public void createBucketIfNotExist(String bucket) {
        try {
            boolean exists = minioClient.bucketExists(
                    BucketExistsArgs.builder().bucket(bucket).build()
            );
            if (!exists) {
                minioClient.makeBucket(
                        MakeBucketArgs.builder().bucket(bucket).build()
                );
                log.info("创建存储桶成功: {}", bucket);
            }
            // 设置公开读取策略
            setPublicReadPolicy(bucket);
        } catch (Exception e) {
            log.error("创建存储桶失败: {}", bucket, e);
            throw new RuntimeException("创建存储桶失败: " + e.getMessage(), e);
        }
    }

    /**
     * 设置存储桶公开读取策略
     */
    private void setPublicReadPolicy(String bucket) {
        try {
            String policy = """
                {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {"AWS": ["*"]},
                            "Action": ["s3:GetObject"],
                            "Resource": ["arn:aws:s3:::%s/*"]
                        }
                    ]
                }
                """.formatted(bucket);
            minioClient.setBucketPolicy(
                    SetBucketPolicyArgs.builder().bucket(bucket).config(policy).build()
            );
            log.info("设置存储桶公开读取策略成功: {}", bucket);
        } catch (Exception e) {
            log.warn("设置存储桶公开读取策略失败: {}", bucket, e);
        }
    }
}
