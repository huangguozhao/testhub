package com.testhub.modules.configuration.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.configuration.domain.AppTestConfig;
import com.testhub.modules.configuration.mapper.AppTestConfigMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@Tag(name = "APP测试配置", description = "APP自动化测试配置管理")
@RestController
@RequestMapping("/api/app-automation/config")
@RequiredArgsConstructor
public class AppTestConfigController {

    private final AppTestConfigMapper appTestConfigMapper;

    @GetMapping("/current")
    @Operation(summary = "获取当前配置")
    public Result<AppTestConfig> getCurrentConfig() {
        AppTestConfig config = appTestConfigMapper.selectById(1L);
        if (config == null) {
            // 不存在则创建默认配置
            config = new AppTestConfig();
            config.setId(1L);
            config.setAdbPath("adb");
            appTestConfigMapper.insert(config);
        }
        return Result.success(config);
    }

    @PostMapping("/save")
    @Operation(summary = "保存配置")
    public Result<AppTestConfig> saveConfig(@RequestBody Map<String, String> body) {
        AppTestConfig config = appTestConfigMapper.selectById(1L);
        if (config == null) {
            config = new AppTestConfig();
            config.setId(1L);
            config.setAdbPath(body.getOrDefault("adb_path", "adb"));
            appTestConfigMapper.insert(config);
        } else {
            if (body.containsKey("adb_path")) {
                config.setAdbPath(body.get("adb_path"));
            }
            appTestConfigMapper.updateById(config);
        }
        log.info("保存APP测试配置: adb_path={}", config.getAdbPath());
        return Result.success(config);
    }
}
