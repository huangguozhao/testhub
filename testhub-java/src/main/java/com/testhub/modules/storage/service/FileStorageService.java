package com.testhub.modules.storage.service;

import java.io.InputStream;

/**
 * 文件存储服务接口
 */
public interface FileStorageService {

    /**
     * 上传文件
     *
     * @param bucket   存储桶名称
     * @param objectName 对象名称
     * @param inputStream 输入流
     * @param contentType 内容类型
     * @param size 文件大小
     * @return 文件访问URL
     */
    String uploadFile(String bucket, String objectName, InputStream inputStream, String contentType, long size);

    /**
     * 上传文件（使用默认存储桶）
     */
    String uploadFile(String objectName, InputStream inputStream, String contentType, long size);

    /**
     * 获取文件访问URL
     */
    String getFileUrl(String bucket, String objectName);

    /**
     * 获取文件访问URL（使用默认存储桶）
     */
    String getFileUrl(String objectName);

    /**
     * 删除文件
     */
    void deleteFile(String bucket, String objectName);

    /**
     * 删除文件（使用默认存储桶）
     */
    void deleteFile(String objectName);

    /**
     * 检查文件是否存在
     */
    boolean fileExists(String bucket, String objectName);

    /**
     * 创建存储桶（如果不存在）
     */
    void createBucketIfNotExist(String bucket);
}
