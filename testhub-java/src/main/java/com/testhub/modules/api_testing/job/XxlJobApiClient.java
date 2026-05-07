package com.testhub.modules.api_testing.job;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

/**
 * XXL-JOB Admin REST API 客户端
 * 通过表单登录获取 session，再调用管理接口
 */
@Slf4j
@Service
public class XxlJobApiClient {

    private final RestTemplate restTemplate;
    private final String adminAddresses;
    private String sessionCookie;

    public XxlJobApiClient(@Value("${xxl-job.admin.addresses}") String adminAddresses) {
        this.restTemplate = new RestTemplate();
        this.adminAddresses = adminAddresses.endsWith("/") ? adminAddresses.substring(0, adminAddresses.length() - 1) : adminAddresses;
    }

    /**
     * 添加任务
     * @return XXL-JOB 返回的 job ID，失败返回 null
     */
    public Long addJob(int jobGroup, String jobDesc, String executorHandler, String jobParam,
                       String scheduleType, String scheduleConf) {
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("jobGroup", String.valueOf(jobGroup));
        params.add("jobDesc", jobDesc);
        params.add("author", "testhub");
        params.add("executorHandler", executorHandler);
        params.add("executorParam", jobParam);
        params.add("scheduleType", scheduleType);
        params.add("scheduleConf", scheduleConf);
        params.add("misfireStrategy", "DO_NOTHING");
        params.add("executorRouteStrategy", "FIRST");
        params.add("executorBlockStrategy", "SERIAL_EXECUTION");
        params.add("executorTimeout", "0");
        params.add("executorFailRetryCount", "0");
        params.add("glueType", "BEAN");

        String result = postForm("/jobinfo/add", params);
        if (result != null && result.contains("\"code\":200")) {
            // 解析 content 字段获取 job ID
            try {
                String contentStr = result.replaceAll(".*\"content\":\"?(\\d+)\"?.*", "$1");
                return Long.parseLong(contentStr);
            } catch (Exception e) {
                log.warn("解析XXL-JOB返回的jobId失败: {}", result);
                return 0L; // 成功但无法解析ID
            }
        }
        log.error("添加XXL-JOB任务失败: {}", result);
        return null;
    }

    /**
     * 移除任务
     */
    public boolean removeJob(long jobId) {
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("id", String.valueOf(jobId));
        String result = postForm("/jobinfo/remove", params);
        return result != null && result.contains("\"code\":200");
    }

    /**
     * 启动任务
     */
    public boolean startJob(long jobId) {
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("id", String.valueOf(jobId));
        String result = postForm("/jobinfo/start", params);
        return result != null && result.contains("\"code\":200");
    }

    /**
     * 停止任务
     */
    public boolean stopJob(long jobId) {
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("id", String.valueOf(jobId));
        String result = postForm("/jobinfo/stop", params);
        return result != null && result.contains("\"code\":200");
    }

    /**
     * 触发任务（立即执行一次）
     */
    public boolean triggerJob(long jobId, String executorParam) {
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("id", String.valueOf(jobId));
        params.add("executorParam", executorParam);
        String result = postForm("/jobinfo/trigger", params);
        return result != null && result.contains("\"code\":200");
    }

    /**
     * 更新任务
     */
    public boolean updateJob(long jobId, int jobGroup, String jobDesc, String executorHandler,
                             String jobParam, String scheduleType, String scheduleConf) {
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("id", String.valueOf(jobId));
        params.add("jobGroup", String.valueOf(jobGroup));
        params.add("jobDesc", jobDesc);
        params.add("author", "testhub");
        params.add("executorHandler", executorHandler);
        params.add("executorParam", jobParam);
        params.add("scheduleType", scheduleType);
        params.add("scheduleConf", scheduleConf);
        params.add("misfireStrategy", "DO_NOTHING");
        params.add("executorRouteStrategy", "FIRST");
        params.add("executorBlockStrategy", "SERIAL_EXECUTION");
        params.add("executorTimeout", "0");
        params.add("executorFailRetryCount", "0");
        params.add("glueType", "BEAN");

        String result = postForm("/jobinfo/update", params);
        return result != null && result.contains("\"code\":200");
    }

    /**
     * 发送表单 POST 请求（带 session cookie）
     */
    private String postForm(String path, MultiValueMap<String, String> params) {
        ensureLogin();
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            if (sessionCookie != null) {
                headers.set("Cookie", sessionCookie);
            }
            HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(params, headers);
            ResponseEntity<String> response = restTemplate.exchange(adminAddresses + path, HttpMethod.POST, entity, String.class);
            return response.getBody();
        } catch (Exception e) {
            log.error("调用XXL-JOB API失败: path={}, error={}", path, e.getMessage());
            // 可能 session 过期，清除重试
            sessionCookie = null;
            return null;
        }
    }

    /**
     * 确保已登录 XXL-JOB admin
     */
    private void ensureLogin() {
        if (sessionCookie != null) return;
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            MultiValueMap<String, String> loginParams = new LinkedMultiValueMap<>();
            loginParams.add("userName", "admin");
            loginParams.add("password", "123456");
            HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(loginParams, headers);
            ResponseEntity<String> response = restTemplate.exchange(adminAddresses + "/login", HttpMethod.POST, entity, String.class);

            // 从 Set-Cookie 头获取 session
            String setCookie = response.getHeaders().getFirst(HttpHeaders.SET_COOKIE);
            if (setCookie != null) {
                // 提取 JSESSIONID
                String jsessionId = setCookie.split(";")[0];
                sessionCookie = jsessionId;
                log.info("XXL-JOB admin 登录成功");
            }
        } catch (Exception e) {
            log.error("XXL-JOB admin 登录失败: {}", e.getMessage());
        }
    }
}
