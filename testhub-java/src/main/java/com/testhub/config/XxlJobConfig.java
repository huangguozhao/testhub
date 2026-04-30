package com.testhub.config;

import com.xxl.job.core.executor.impl.XxlJobSpringExecutor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * XXL-JOB 分布式任务调度配置
 *
 * XXL-JOB Admin 地址: http://localhost:8080/xxl-job-admin
 * 默认账号: admin / 123456
 */
@Slf4j
@Configuration
public class XxlJobConfig {

    @Value("${xxl-job.admin.addresses:http://127.0.0.1:8080/xxl-job-admin}")
    private String adminAddresses;

    @Value("${xxl-job.accessToken:}")
    private String accessToken;

    @Value("${xxl-job.executor.app-name:testhub-executor}")
    private String appName;

    @Value("${xxl-job.executor.port:9999}")
    private int port;

    @Value("${xxl-job.executor.log-path:./logs/xxl-job/jobhandler}")
    private String logPath;

    @Value("${xxl-job.executor.log-retention-days:30}")
    private int logRetentionDays;

    @Bean
    public XxlJobSpringExecutor xxlJobExecutor() {
        log.info("========== XXL-JOB 初始化配置 ==========");
        log.info("Admin Addresses: {}", adminAddresses);
        log.info("App Name: {}", appName);
        log.info("Executor Port: {}", port);

        XxlJobSpringExecutor xxlJobSpringExecutor = new XxlJobSpringExecutor();
        xxlJobSpringExecutor.setAdminAddresses(adminAddresses);
        xxlJobSpringExecutor.setAccessToken(accessToken);
        xxlJobSpringExecutor.setAppname(appName);
        xxlJobSpringExecutor.setPort(port);
        xxlJobSpringExecutor.setLogPath(logPath);
        xxlJobSpringExecutor.setLogRetentionDays(logRetentionDays);

        return xxlJobSpringExecutor;
    }
}
