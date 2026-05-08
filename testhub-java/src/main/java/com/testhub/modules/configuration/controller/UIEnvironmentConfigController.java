package com.testhub.modules.configuration.controller;

import com.testhub.common.result.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.IOException;
import java.util.*;

@Slf4j
@Tag(name = "UI环境配置", description = "UI自动化环境检测和驱动安装")
@RestController
@RequestMapping("/api/ui-automation/config/environment")
@RequiredArgsConstructor
public class UIEnvironmentConfigController {

    @Value("${playwright.cache-dir:}")
    private String playwrightCacheDir;

    @GetMapping("/check-environment")
    @Operation(summary = "检测环境状态")
    public Result<Map<String, Object>> checkEnvironment() {
        Map<String, Object> result = new HashMap<>();
        String os = System.getProperty("os.name").toLowerCase();
        boolean isWindows = os.contains("windows");
        boolean isMac = os.contains("mac");

        result.put("os", System.getProperty("os.name"));

        // 检测系统浏览器
        List<Map<String, Object>> systemBrowsers = new ArrayList<>();
        systemBrowsers.add(checkSystemBrowser("chrome", isWindows, isMac));
        systemBrowsers.add(checkSystemBrowser("firefox", isWindows, isMac));
        systemBrowsers.add(checkSystemBrowser("edge", isWindows, isMac));
        if (isMac) {
            systemBrowsers.add(checkSystemBrowser("safari", isWindows, isMac));
        }
        result.put("system_browsers", systemBrowsers);

        // 检测 Playwright 浏览器
        List<Map<String, Object>> playwrightBrowsers = new ArrayList<>();
        String cacheDir = getPlaywrightCacheDir(isWindows);
        playwrightBrowsers.add(checkPlaywrightBrowser("chromium", cacheDir));
        playwrightBrowsers.add(checkPlaywrightBrowser("firefox", cacheDir));
        playwrightBrowsers.add(checkPlaywrightBrowser("webkit", cacheDir));
        result.put("playwright_browsers", playwrightBrowsers);

        return Result.success(result);
    }

    @PostMapping("/install-driver")
    @Operation(summary = "安装浏览器驱动")
    public Result<Map<String, String>> installDriver(@RequestBody Map<String, String> body) {
        String browser = body.get("browser");
        if (browser == null || browser.isBlank()) {
            return Result.error("Browser name is required");
        }

        try {
            ProcessBuilder pb = new ProcessBuilder("playwright", "install", browser);
            pb.inheritIO();
            Process process = pb.start();
            int exitCode = process.waitFor();

            if (exitCode == 0) {
                return Result.success(Map.of("message", "Successfully installed driver for " + browser));
            } else {
                return Result.error("Installation failed with exit code: " + exitCode);
            }
        } catch (IOException | InterruptedException e) {
            log.error("安装驱动失败", e);
            return Result.error("Installation error: " + e.getMessage());
        }
    }

    private Map<String, Object> checkSystemBrowser(String browser, boolean isWindows, boolean isMac) {
        Map<String, Object> info = new HashMap<>();
        info.put("name", browser);

        boolean installed = false;
        String installCmd = "";

        switch (browser) {
            case "chrome" -> {
                if (isWindows) {
                    installed = fileExists(
                            "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
                            "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe");
                    installCmd = "请下载 Chrome 安装包安装";
                } else if (isMac) {
                    installed = fileExists("/Applications/Google Chrome.app");
                    installCmd = "brew install --cask google-chrome";
                } else {
                    installed = fileExists(
                            "/usr/bin/google-chrome",
                            "/usr/bin/google-chrome-stable",
                            "/usr/bin/chromium-browser");
                    installCmd = "sudo dnf install google-chrome-stable";
                }
            }
            case "firefox" -> {
                if (isWindows) {
                    installed = fileExists(
                            "C:\\Program Files\\Mozilla Firefox\\firefox.exe",
                            "C:\\Program Files (x86)\\Mozilla Firefox\\firefox.exe");
                    installCmd = "请下载 Firefox 安装包安装";
                } else if (isMac) {
                    installed = fileExists("/Applications/Firefox.app");
                    installCmd = "brew install --cask firefox";
                } else {
                    installed = fileExists("/usr/bin/firefox", "/usr/bin/firefox-esr");
                    installCmd = "sudo dnf install firefox";
                }
            }
            case "edge" -> {
                if (isWindows) {
                    installed = fileExists(
                            "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
                            "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe");
                    installCmd = "请下载 Edge 安装包安装";
                } else if (isMac) {
                    installed = fileExists("/Applications/Microsoft Edge.app");
                    installCmd = "brew install --cask microsoft-edge";
                } else {
                    installed = fileExists("/usr/bin/microsoft-edge", "/usr/bin/microsoft-edge-stable");
                    installCmd = "从微软官网下载 Edge Linux 版本";
                }
            }
            case "safari" -> {
                installed = isMac && fileExists("/Applications/Safari.app");
                installCmd = "系统自带";
            }
        }

        info.put("installed", installed);
        info.put("version", null);
        info.put("install_cmd", installCmd);
        return info;
    }

    private Map<String, Object> checkPlaywrightBrowser(String browser, String cacheDir) {
        Map<String, Object> info = new HashMap<>();
        info.put("name", browser);
        info.put("install_cmd", "playwright install " + browser);

        boolean installed = false;
        String version = null;

        if (cacheDir != null && !cacheDir.isBlank()) {
            File dir = new File(cacheDir);
            if (dir.exists() && dir.isDirectory()) {
                File[] matches = dir.listFiles((d, name) -> name.startsWith(browser + "-"));
                if (matches != null && matches.length > 0) {
                    installed = true;
                    version = matches[0].getName().substring(browser.length() + 1);
                }
            }
        }

        info.put("installed", installed);
        info.put("version", version);
        return info;
    }

    private String getPlaywrightCacheDir(boolean isWindows) {
        if (playwrightCacheDir != null && !playwrightCacheDir.isBlank()) {
            return playwrightCacheDir;
        }
        if (isWindows) {
            return System.getenv("LOCALAPPDATA") + "\\ms-playwright";
        } else if (System.getProperty("os.name").toLowerCase().contains("mac")) {
            return System.getProperty("user.home") + "/Library/Caches/ms-playwright";
        } else {
            return System.getProperty("user.home") + "/.cache/ms-playwright";
        }
    }

    private boolean fileExists(String... paths) {
        for (String path : paths) {
            if (new File(path).exists()) return true;
        }
        return false;
    }
}
