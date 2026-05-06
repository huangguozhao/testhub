/*
 Navicat Premium Dump SQL

 Source Server         : localhost-3307
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : localhost:3307
 Source Schema         : testhub_java

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 05/05/2026 22:03:27
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for api_collection
-- ----------------------------
DROP TABLE IF EXISTS `api_collection`;
CREATE TABLE `api_collection`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '集合ID',
  `project_id` bigint NOT NULL COMMENT 'API项目ID',
  `suite_id` bigint NULL DEFAULT NULL COMMENT '测试套件ID',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父集合ID(用于树形结构)',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '集合名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '集合描述',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'API集合表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_collection
-- ----------------------------
INSERT INTO `api_collection` VALUES (1, 1, 3, NULL, 'UserModule', 'User related APIs', 0, 0, '2026-04-30 09:49:42', '2026-04-30 12:16:14', 4, 4);

-- ----------------------------
-- Table structure for api_environment
-- ----------------------------
DROP TABLE IF EXISTS `api_environment`;
CREATE TABLE `api_environment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '环境ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID(scope=LOCAL时必填)',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '环境名称',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '环境描述',
  `scope` varchar(10) NOT NULL DEFAULT 'LOCAL' COMMENT '作用域: GLOBAL=全局, LOCAL=项目级',
  `variables` json NOT NULL COMMENT '环境变量(JSON格式)',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否默认: 0=否, 1=是',
  `is_active` tinyint NOT NULL DEFAULT 0 COMMENT '是否激活: 0=否, 1=是',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_is_default`(`is_default` ASC) USING BTREE,
  INDEX `idx_scope`(`scope` ASC) USING BTREE,
  INDEX `idx_is_active`(`is_active` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'API环境表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_environment
-- ----------------------------
INSERT INTO `api_environment` VALUES (1, 7, 'TestEnv', 'Test environment', 'LOCAL', '{\"baseUrl\": \"https://httpbin.org\"}', 1, 1, 0, '2026-04-30 09:49:30', '2026-04-30 09:49:30', 4, 4);

-- ----------------------------
-- Table structure for api_execution_record
-- ----------------------------
DROP TABLE IF EXISTS `api_execution_record`;
CREATE TABLE `api_execution_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `suite_id` bigint NULL DEFAULT NULL COMMENT '测试套件ID',
  `executed_at` datetime NULL DEFAULT NULL COMMENT '执行时间',
  `total_count` int NULL DEFAULT NULL COMMENT '总请求数',
  `pass_count` int NULL DEFAULT NULL COMMENT '通过数',
  `fail_count` int NULL DEFAULT NULL COMMENT '失败数',
  `result_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '执行结果JSON',
  `status` tinyint NULL DEFAULT NULL COMMENT '执行状态(0=失败,1=成功)',
  `duration` bigint NULL DEFAULT NULL COMMENT '执行时长(毫秒)',
  `environment_id` bigint NULL DEFAULT NULL COMMENT '执行环境ID',
  `trigger_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '触发类型(manual/scheduled)',
  `trigger_id` bigint NULL DEFAULT NULL COMMENT '触发来源ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` bigint NULL DEFAULT NULL,
  `updated_by` bigint NULL DEFAULT NULL,
  `is_deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_executed_at`(`executed_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_execution_record
-- ----------------------------
INSERT INTO `api_execution_record` VALUES (1, 2, '2026-04-30 09:57:51', 2, 2, 0, '[{\"requestId\":1,\"requestName\":\"GetUser\",\"success\":true,\"statusCode\":200,\"responseTime\":1544,\"error\":null},{\"requestId\":2,\"requestName\":\"PostUser\",\"success\":true,\"statusCode\":200,\"responseTime\":299,\"error\":null}]', 1, 1902, 1, 'manual', NULL, '2026-04-30 09:57:51', '2026-04-30 09:57:51', 4, 4, 0);
INSERT INTO `api_execution_record` VALUES (2, 3, '2026-04-30 12:16:16', 5, 5, 0, '[{\"requestId\":1,\"requestName\":\"GetUser\",\"success\":true,\"statusCode\":200,\"responseTime\":777,\"error\":null,\"assertions\":null},{\"requestId\":2,\"requestName\":\"PostUser\",\"success\":true,\"statusCode\":200,\"responseTime\":278,\"error\":null,\"assertions\":null},{\"requestId\":3,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":544,\"error\":null,\"assertions\":null},{\"requestId\":4,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":225,\"error\":null,\"assertions\":null},{\"requestId\":5,\"requestName\":\"TestAssertionPass\",\"success\":true,\"statusCode\":200,\"responseTime\":431,\"error\":null,\"assertions\":[{\"name\":\"status_code\",\"passed\":true,\"expected\":\"200\",\"actual\":\"200\",\"error\":null},{\"name\":\"check-origin\",\"passed\":true,\"expected\":\"包含: httpbin\",\"actual\":\"包含\",\"error\":null}]}]', 1, 2312, 1, 'manual', NULL, '2026-04-30 12:16:16', '2026-04-30 12:16:16', 4, 4, 0);
INSERT INTO `api_execution_record` VALUES (3, 3, '2026-04-30 12:17:57', 6, 6, 0, '[{\"requestId\":1,\"requestName\":\"GetUser\",\"success\":true,\"statusCode\":200,\"responseTime\":738,\"error\":null,\"assertions\":null},{\"requestId\":2,\"requestName\":\"PostUser\",\"success\":true,\"statusCode\":200,\"responseTime\":240,\"error\":null,\"assertions\":null},{\"requestId\":3,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":237,\"error\":null,\"assertions\":null},{\"requestId\":4,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":239,\"error\":null,\"assertions\":null},{\"requestId\":5,\"requestName\":\"TestAssertionPass\",\"success\":true,\"statusCode\":200,\"responseTime\":245,\"error\":null,\"assertions\":[{\"name\":\"status_code\",\"passed\":true,\"expected\":\"200\",\"actual\":\"200\",\"error\":null},{\"name\":\"check-origin\",\"passed\":true,\"expected\":\"包含: httpbin\",\"actual\":\"包含\",\"error\":null}]},{\"requestId\":6,\"requestName\":\"ExtractToken\",\"success\":true,\"statusCode\":200,\"responseTime\":238,\"error\":null,\"assertions\":null}]', 1, 1971, 1, 'manual', NULL, '2026-04-30 12:17:57', '2026-04-30 12:17:57', 4, 4, 0);
INSERT INTO `api_execution_record` VALUES (4, 3, '2026-04-30 12:18:27', 8, 8, 0, '[{\"requestId\":1,\"requestName\":\"GetUser\",\"success\":true,\"statusCode\":200,\"responseTime\":1110,\"error\":null,\"assertions\":null},{\"requestId\":2,\"requestName\":\"PostUser\",\"success\":true,\"statusCode\":200,\"responseTime\":230,\"error\":null,\"assertions\":null},{\"requestId\":3,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":232,\"error\":null,\"assertions\":null},{\"requestId\":4,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":244,\"error\":null,\"assertions\":null},{\"requestId\":5,\"requestName\":\"TestAssertionPass\",\"success\":true,\"statusCode\":200,\"responseTime\":227,\"error\":null,\"assertions\":[{\"name\":\"status_code\",\"passed\":true,\"expected\":\"200\",\"actual\":\"200\",\"error\":null},{\"name\":\"check-origin\",\"passed\":true,\"expected\":\"包含: httpbin\",\"actual\":\"包含\",\"error\":null}]},{\"requestId\":6,\"requestName\":\"ExtractToken\",\"success\":true,\"statusCode\":200,\"responseTime\":585,\"error\":null,\"assertions\":null},{\"requestId\":7,\"requestName\":\"ExtractOrigin\",\"success\":true,\"statusCode\":200,\"responseTime\":226,\"error\":null,\"assertions\":null},{\"requestId\":8,\"requestName\":\"UseExtractedVar\",\"success\":true,\"statusCode\":200,\"responseTime\":232,\"error\":null,\"assertions\":null}]', 1, 3106, 1, 'manual', NULL, '2026-04-30 12:18:27', '2026-04-30 12:18:27', 4, 4, 0);

-- ----------------------------
-- Table structure for api_project
-- ----------------------------
DROP TABLE IF EXISTS `api_project`;
CREATE TABLE `api_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '关联项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'API项目名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目描述',
  `base_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '基础URL',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'API项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_project
-- ----------------------------
INSERT INTO `api_project` VALUES (1, 7, 'UserServiceAPI', 'User service API collection', 'https://httpbin.org', 0, '2026-04-30 09:49:29', '2026-04-30 09:49:29', 4, 4);

-- ----------------------------
-- Table structure for api_project_member
-- ----------------------------
DROP TABLE IF EXISTS `api_project_member`;
CREATE TABLE `api_project_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_id` bigint NOT NULL COMMENT 'API项目ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'member' COMMENT '角色: owner, admin, member',
  `joined_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `is_deleted` tinyint NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_user`(`project_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'API项目成员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of api_project_member
-- ----------------------------

-- ----------------------------
-- Table structure for api_request
-- ----------------------------
DROP TABLE IF EXISTS `api_request`;
CREATE TABLE `api_request`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '请求ID',
  `collection_id` bigint NOT NULL COMMENT '集合ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '请求名称',
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'HTTP方法: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS',
  `url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '请求URL',
  `headers` json NULL COMMENT '请求头',
  `params` json NULL COMMENT 'URL参数',
  `body_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求体类型: none, json, form, xml, raw, binary',
  `body_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求体内容',
  `auth_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '认证类型: none, basic, bearer, api_key, oauth2',
  `auth_config` json NULL COMMENT '认证配置',
  `pre_script` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '前置脚本',
  `post_script` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '后置脚本',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  `assertions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '断言规则(JSON)',
  `extractors` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '变量提取规则(JSON)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_collection_id`(`collection_id` ASC) USING BTREE,
  INDEX `idx_method`(`method` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'API请求表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_request
-- ----------------------------
INSERT INTO `api_request` VALUES (1, 1, 'GetUser', 'GET', 'https://httpbin.org/get', NULL, NULL, 'none', NULL, 'none', NULL, NULL, NULL, 0, 0, '2026-04-30 09:49:42', '2026-04-30 09:49:42', 4, 4, NULL, NULL);
INSERT INTO `api_request` VALUES (2, 1, 'PostUser', 'POST', 'https://httpbin.org/post', NULL, NULL, 'json', '{\"name\":\"test\",\"email\":\"test@test.com\"}', 'none', NULL, NULL, NULL, 1, 0, '2026-04-30 09:51:58', '2026-04-30 09:51:58', 4, 4, NULL, NULL);
INSERT INTO `api_request` VALUES (3, 1, 'TestAssertion', 'GET', 'https://httpbin.org/get', NULL, NULL, 'none', NULL, 'none', NULL, NULL, NULL, 10, 0, '2026-04-30 11:59:43', '2026-04-30 11:59:43', 4, 4, NULL, NULL);
INSERT INTO `api_request` VALUES (4, 1, 'TestAssertion', 'GET', 'https://httpbin.org/get', NULL, NULL, 'none', NULL, 'none', NULL, NULL, NULL, 20, 0, '2026-04-30 12:00:31', '2026-04-30 12:00:31', 4, 4, NULL, NULL);
INSERT INTO `api_request` VALUES (5, 1, 'TestAssertionPass', 'GET', 'https://httpbin.org/get', NULL, NULL, 'none', NULL, 'none', NULL, NULL, NULL, 30, 0, '2026-04-30 12:13:25', '2026-04-30 12:13:25', 4, 4, '[{\"type\":\"status_code\",\"expected\":200},{\"type\":\"contains\",\"name\":\"check-origin\",\"expected\":\"httpbin\"}]', NULL);
INSERT INTO `api_request` VALUES (6, 1, 'ExtractToken', 'POST', 'https://httpbin.org/post', NULL, NULL, 'json', '{\"username\":\"test\",\"token\":\"abc123\"}', 'none', NULL, NULL, NULL, 100, 0, '2026-04-30 12:17:55', '2026-04-30 12:17:55', 4, 4, NULL, '[{\"type\":\"json_path\",\"name\":\"extract-token\",\"path\":\"$.json.token\",\"variable\":\"extractedToken\"}]');
INSERT INTO `api_request` VALUES (7, 1, 'ExtractOrigin', 'GET', 'https://httpbin.org/get', NULL, NULL, 'none', NULL, 'none', NULL, NULL, NULL, 200, 0, '2026-04-30 12:18:24', '2026-04-30 12:18:24', 4, 4, NULL, '[{\"type\":\"json_path\",\"path\":\"$.origin\",\"variable\":\"serverOrigin\"}]');
INSERT INTO `api_request` VALUES (8, 1, 'UseExtractedVar', 'GET', 'https://httpbin.org/anything/{{serverOrigin}}', NULL, NULL, 'none', NULL, 'none', NULL, NULL, NULL, 201, 0, '2026-04-30 12:18:24', '2026-04-30 12:18:24', 4, 4, NULL, NULL);
INSERT INTO `api_request` VALUES (9, 1, 'GET /get', 'GET', 'https://httpbin.org/get', NULL, NULL, 'none', NULL, 'none', NULL, NULL, NULL, 0, 0, '2026-04-30 17:26:06', '2026-04-30 17:26:06', 5, 5, NULL, NULL);

-- ----------------------------
-- Table structure for api_request_history
-- ----------------------------
DROP TABLE IF EXISTS `api_request_history`;
CREATE TABLE `api_request_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '历史ID',
  `request_id` bigint NOT NULL COMMENT '请求ID',
  `suite_execution_id` bigint NULL DEFAULT NULL COMMENT '套件执行记录ID',
  `suite_id` bigint NULL DEFAULT NULL COMMENT '套件ID(如果通过套件执行)',
  `environment_id` bigint NULL DEFAULT NULL COMMENT '环境ID',
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'HTTP方法',
  `url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '请求URL',
  `request_headers` json NULL COMMENT '请求头',
  `request_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求体',
  `response_status_code` int NULL DEFAULT NULL COMMENT '响应状态码',
  `response_status` int NULL DEFAULT NULL COMMENT '响应状态码',
  `response_headers` json NULL COMMENT '响应头',
  `response_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '响应体',
  `response_time` int NULL DEFAULT NULL COMMENT '响应时间(毫秒)',
  `assertions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '断言结果(JSON)',
  `extracted_variables` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '提取变量(JSON)',
  `success` tinyint(1) NULL DEFAULT 0 COMMENT '是否成功',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `assertion_results` json NULL COMMENT '断言结果',
  `executed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间',
  `executed_by` bigint NULL DEFAULT NULL COMMENT '执行人ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `executor_id` bigint NULL DEFAULT NULL COMMENT '执行人ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_request_id`(`request_id` ASC) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_executed_at`(`executed_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'API请求历史表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_request_history
-- ----------------------------
INSERT INTO `api_request_history` VALUES (2, 9, NULL, NULL, NULL, 'GET', 'https://httpbin.org/get', NULL, NULL, 200, NULL, '{\"Date\": \"Thu, 30 Apr 2026 09:36:41 GMT\", \"Server\": \"gunicorn/19.9.0\", \"Connection\": \"keep-alive\", \"Content-Type\": \"application/json\", \"Content-Length\": \"348\", \"Access-Control-Allow-Origin\": \"*\", \"Access-Control-Allow-Credentials\": \"true\"}', '{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"text/plain, application/json, application/*+json, */*\", \n    \"Content-Type\": \"application/json\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"Java/17.0.14\", \n    \"X-Amzn-Trace-Id\": \"Root=1-69f322a9-4764dcaa0331a78229f8bafd\"\n  }, \n  \"origin\": \"223.73.113.231\", \n  \"url\": \"https://httpbin.org/get\"\n}\n', 825, NULL, '{}', 1, NULL, NULL, '2026-04-30 17:36:41', NULL, '2026-04-30 17:36:41', NULL);
INSERT INTO `api_request_history` VALUES (3, 9, NULL, NULL, NULL, 'GET', 'https://httpbin.org/get', NULL, NULL, 200, NULL, '{\"Date\": \"Thu, 30 Apr 2026 09:36:53 GMT\", \"Server\": \"gunicorn/19.9.0\", \"Connection\": \"keep-alive\", \"Content-Type\": \"application/json\", \"Content-Length\": \"348\", \"Access-Control-Allow-Origin\": \"*\", \"Access-Control-Allow-Credentials\": \"true\"}', '{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"text/plain, application/json, application/*+json, */*\", \n    \"Content-Type\": \"application/json\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"Java/17.0.14\", \n    \"X-Amzn-Trace-Id\": \"Root=1-69f322b5-6d9c6927161546ea44a3fe14\"\n  }, \n  \"origin\": \"223.73.113.231\", \n  \"url\": \"https://httpbin.org/get\"\n}\n', 991, NULL, '{}', 1, NULL, NULL, '2026-04-30 17:36:54', NULL, '2026-04-30 17:36:54', NULL);

-- ----------------------------
-- Table structure for api_scheduled_task
-- ----------------------------
DROP TABLE IF EXISTS `api_scheduled_task`;
CREATE TABLE `api_scheduled_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `suite_id` bigint NOT NULL COMMENT '套件ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `trigger_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发类型: cron=Cron表达式, interval=固定间隔, once=单次执行',
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Cron表达式',
  `interval_value` bigint NULL DEFAULT NULL COMMENT '间隔值',
  `interval_unit` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '间隔单位: seconds, minutes, hours',
  `once_time` datetime NULL DEFAULT NULL COMMENT '单次执行时间',
  `is_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
  `notification_config` json NULL COMMENT '通知配置',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `last_run_at` datetime NULL DEFAULT NULL COMMENT '上次执行时间',
  `next_run_at` datetime NULL DEFAULT NULL COMMENT '下次执行时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_is_enabled`(`is_enabled` ASC) USING BTREE,
  INDEX `idx_trigger_type`(`trigger_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'API定时任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_scheduled_task
-- ----------------------------
INSERT INTO `api_scheduled_task` VALUES (1, 1, 'DailyRegression', 'cron', '0 0 2 * * ?', NULL, NULL, NULL, 1, NULL, 1, NULL, NULL, '2026-04-30 09:52:19', '2026-04-30 09:52:31', 4, 4);

-- ----------------------------
-- Table structure for api_test_suite
-- ----------------------------
DROP TABLE IF EXISTS `api_test_suite`;
CREATE TABLE `api_test_suite`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '套件ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '套件名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '套件描述',
  `environment_id` bigint NULL DEFAULT NULL COMMENT '执行环境ID',
  `timeout` int NULL DEFAULT 30000 COMMENT '超时时间(毫秒)',
  `retry_count` int NULL DEFAULT 0 COMMENT '失败重试次数',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'API测试套件表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_test_suite
-- ----------------------------
INSERT INTO `api_test_suite` VALUES (1, 7, 'RegressionSuite', 'Regression test suite', 1, 30000, 0, 1, '2026-04-30 09:50:03', '2026-04-30 09:52:31', 4, 4);
INSERT INTO `api_test_suite` VALUES (2, 7, 'RegressionSuite', 'Regression test', 1, 30000, 0, 0, '2026-04-30 09:54:19', '2026-04-30 09:54:19', 4, 4);
INSERT INTO `api_test_suite` VALUES (3, 7, 'AssertionTestSuite', 'Test assertions', 1, 30000, 0, 0, '2026-04-30 12:16:14', '2026-04-30 12:16:14', 4, 4);

-- ----------------------------
-- Table structure for api_test_suite_request
-- ----------------------------
DROP TABLE IF EXISTS `api_test_suite_request`;
CREATE TABLE `api_test_suite_request`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `suite_id` bigint NOT NULL COMMENT '套件ID',
  `request_id` bigint NOT NULL COMMENT '请求ID',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '执行顺序',
  `assertions` json NULL COMMENT '断言配置',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_suite_request`(`suite_id` ASC, `request_id` ASC) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_request_id`(`request_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '套件请求关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_test_suite_request
-- ----------------------------

-- ----------------------------
-- Table structure for app_component
-- ----------------------------
DROP TABLE IF EXISTS `app_component`;
CREATE TABLE `app_component`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '组件ID',
  `project_id` bigint NOT NULL COMMENT 'APP项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组件名称',
  `component_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组件类型',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '组件描述',
  `config` json NULL COMMENT '组件配置',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP UI组件表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_component
-- ----------------------------

-- ----------------------------
-- Table structure for app_device
-- ----------------------------
DROP TABLE IF EXISTS `app_device`;
CREATE TABLE `app_device`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '设备ID',
  `project_id` bigint NOT NULL COMMENT 'APP项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备名称',
  `device_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备序列号',
  `connection_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'usb' COMMENT '连接类型: usb, wifi, emulator, remote',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'offline' COMMENT '状态: offline=离线, online=在线, busy=占用中, error=异常',
  `platform_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统版本',
  `resolution` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分辨率',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `locked_by` bigint NULL DEFAULT NULL COMMENT '锁定人ID',
  `locked_at` datetime NULL DEFAULT NULL COMMENT '锁定时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP设备表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_device
-- ----------------------------

-- ----------------------------
-- Table structure for app_element
-- ----------------------------
DROP TABLE IF EXISTS `app_element`;
CREATE TABLE `app_element`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '元素ID',
  `project_id` bigint NOT NULL COMMENT 'APP项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '元素名称',
  `locator_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '定位类型: image=图片, coordinate=坐标, region=区域',
  `locator_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '定位值(图片路径或坐标)',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '元素描述',
  `screenshot` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '截图路径',
  `usage_count` int NULL DEFAULT 0 COMMENT '使用次数',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_locator_type`(`locator_type` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP元素表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_element
-- ----------------------------

-- ----------------------------
-- Table structure for app_package
-- ----------------------------
DROP TABLE IF EXISTS `app_package`;
CREATE TABLE `app_package`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '包名ID',
  `project_id` bigint NOT NULL COMMENT 'APP项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '包名名称',
  `package_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '应用包名',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_package_name`(`package_name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP包名管理表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_package
-- ----------------------------

-- ----------------------------
-- Table structure for app_project
-- ----------------------------
DROP TABLE IF EXISTS `app_project`;
CREATE TABLE `app_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `project_id` bigint NOT NULL COMMENT '关联项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'APP项目名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目描述',
  `platform` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'android' COMMENT '平台: android, ios',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP自动化项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_project
-- ----------------------------

-- ----------------------------
-- Table structure for app_scheduled_task
-- ----------------------------
DROP TABLE IF EXISTS `app_scheduled_task`;
CREATE TABLE `app_scheduled_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `suite_id` bigint NOT NULL COMMENT '套件ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `trigger_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发类型: cron, interval, once',
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Cron表达式',
  `interval_value` bigint NULL DEFAULT NULL COMMENT '间隔值',
  `interval_unit` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '间隔单位',
  `once_time` datetime NULL DEFAULT NULL COMMENT '单次执行时间',
  `device_id` bigint NULL DEFAULT NULL COMMENT '指定设备ID',
  `is_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
  `notification_config` json NULL COMMENT '通知配置',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `last_run_at` datetime NULL DEFAULT NULL COMMENT '上次执行时间',
  `next_run_at` datetime NULL DEFAULT NULL COMMENT '下次执行时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_is_enabled`(`is_enabled` ASC) USING BTREE,
  INDEX `idx_trigger_type`(`trigger_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP定时任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_scheduled_task
-- ----------------------------

-- ----------------------------
-- Table structure for app_test_case
-- ----------------------------
DROP TABLE IF EXISTS `app_test_case`;
CREATE TABLE `app_test_case`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用例ID',
  `project_id` bigint NOT NULL COMMENT 'APP项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用例名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '用例描述',
  `ui_flow` json NOT NULL COMMENT 'UI流程配置(JSON)',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP测试用例表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_test_case
-- ----------------------------

-- ----------------------------
-- Table structure for app_test_execution
-- ----------------------------
DROP TABLE IF EXISTS `app_test_execution`;
CREATE TABLE `app_test_execution`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '执行ID',
  `suite_id` bigint NOT NULL COMMENT '套件ID',
  `device_id` bigint NOT NULL COMMENT '设备ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending, running, passed, failed, stopped',
  `executor_id` bigint NOT NULL COMMENT '执行人ID',
  `started_at` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `total_count` int NULL DEFAULT 0 COMMENT '总用例数',
  `passed_count` int NULL DEFAULT 0 COMMENT '通过数',
  `failed_count` int NULL DEFAULT 0 COMMENT '失败数',
  `report_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '报告路径',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_device_id`(`device_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_executor_id`(`executor_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP执行记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_test_execution
-- ----------------------------

-- ----------------------------
-- Table structure for app_test_suite
-- ----------------------------
DROP TABLE IF EXISTS `app_test_suite`;
CREATE TABLE `app_test_suite`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '套件ID',
  `project_id` bigint NOT NULL COMMENT 'APP项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '套件名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '套件描述',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP测试套件表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_test_suite
-- ----------------------------

-- ----------------------------
-- Table structure for app_test_suite_case
-- ----------------------------
DROP TABLE IF EXISTS `app_test_suite_case`;
CREATE TABLE `app_test_suite_case`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `suite_id` bigint NOT NULL COMMENT '套件ID',
  `case_id` bigint NOT NULL COMMENT '用例ID',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '执行顺序',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_suite_case`(`suite_id` ASC, `case_id` ASC) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_case_id`(`case_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP套件用例关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of app_test_suite_case
-- ----------------------------

-- ----------------------------
-- Table structure for ast_assistant_session
-- ----------------------------
DROP TABLE IF EXISTS `ast_assistant_session`;
CREATE TABLE `ast_assistant_session`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会话名称',
  `last_message_at` datetime NULL DEFAULT NULL COMMENT '最后消息时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_last_message_at`(`last_message_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI助手会话表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ast_assistant_session
-- ----------------------------

-- ----------------------------
-- Table structure for ast_chat_message
-- ----------------------------
DROP TABLE IF EXISTS `ast_chat_message`;
CREATE TABLE `ast_chat_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `session_id` bigint NOT NULL COMMENT '会话ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色: user, assistant, system',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_session_id`(`session_id` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI助手消息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ast_chat_message
-- ----------------------------

-- ----------------------------
-- Table structure for ast_dify_config
-- ----------------------------
DROP TABLE IF EXISTS `ast_dify_config`;
CREATE TABLE `ast_dify_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置名称',
  `api_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'API URL',
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'API Key',
  `app_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '应用ID',
  `is_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否默认: 0=否, 1=是',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_is_enabled`(`is_enabled` ASC) USING BTREE,
  INDEX `idx_is_default`(`is_default` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Dify配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ast_dify_config
-- ----------------------------

-- ----------------------------
-- Table structure for cfg_ai_model_config
-- ----------------------------
DROP TABLE IF EXISTS `cfg_ai_model_config`;
CREATE TABLE `cfg_ai_model_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型名称',
  `provider` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '提供商: deepseek=DeepSeek, qwen=通义千问, siliconflow=硅基流动, openai=OpenAI, anthropic=Anthropic',
  `model_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型名称',
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'API Key(加密存储)',
  `base_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'API Base URL',
  `temperature` decimal(3, 2) NULL DEFAULT 0.70 COMMENT '温度参数',
  `max_tokens` int NULL DEFAULT 2048 COMMENT '最大Token数',
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色: testcase_writer=用例编写, testcase_reviewer=用例评审, browser_use_text=Browser文本模式, browser_use_vision=Browser视觉模式',
  `is_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_provider`(`provider` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI模型配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cfg_ai_model_config
-- ----------------------------

-- ----------------------------
-- Table structure for cfg_notification_config
-- ----------------------------
DROP TABLE IF EXISTS `cfg_notification_config`;
CREATE TABLE `cfg_notification_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置名称',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型: webhook_feishu=飞书, webhook_wechat=企业微信, webhook_dingtalk=钉钉, email=邮件',
  `config` json NOT NULL COMMENT '配置内容(JSON格式)',
  `is_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否默认: 0=否, 1=是',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_is_enabled`(`is_enabled` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cfg_notification_config
-- ----------------------------

-- ----------------------------
-- Table structure for df_data_record
-- ----------------------------
DROP TABLE IF EXISTS `df_data_record`;
CREATE TABLE `df_data_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `tool_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工具名称',
  `tool_category` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工具分类: string=字符, encoding=编码, random=随机, encryption=加密, test_data=测试数据, json=JSON, crontab=Crontab',
  `tool_scenario` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '使用场景: data_generate=数据生成, format_convert=格式转换, data_validation=数据验证, encrypt=加密解密',
  `input_data` json NULL COMMENT '输入数据',
  `output_data` json NULL COMMENT '输出数据',
  `tags` json NULL COMMENT '标签',
  `is_saved` tinyint NOT NULL DEFAULT 0 COMMENT '是否保存: 0=否, 1=是',
  `usage_count` int NULL DEFAULT 0 COMMENT '使用次数',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_tool_name`(`tool_name` ASC) USING BTREE,
  INDEX `idx_tool_category`(`tool_category` ASC) USING BTREE,
  INDEX `idx_tool_scenario`(`tool_scenario` ASC) USING BTREE,
  INDEX `idx_is_saved`(`is_saved` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据工厂记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of df_data_record
-- ----------------------------

-- ----------------------------
-- Table structure for exec_test_plan
-- ----------------------------
DROP TABLE IF EXISTS `exec_test_plan`;
CREATE TABLE `exec_test_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '计划ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '计划名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '计划描述',
  `start_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待执行, in_progress=执行中, completed=已完成',
  `assignee_id` bigint NULL DEFAULT NULL COMMENT '负责人ID',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_assignee_id`(`assignee_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '测试计划表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of exec_test_plan
-- ----------------------------
INSERT INTO `exec_test_plan` VALUES (1, 6, 'V1.0回归测试', 'V1.0版本回归测试计划', NULL, NULL, 'pending', 3, 1, '2026-04-29 23:10:15', '2026-04-29 23:10:30', 3, 3);

-- ----------------------------
-- Table structure for exec_test_run
-- ----------------------------
DROP TABLE IF EXISTS `exec_test_run`;
CREATE TABLE `exec_test_run`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '执行ID',
  `plan_id` bigint NOT NULL COMMENT '计划ID',
  `suite_id` bigint NULL DEFAULT NULL COMMENT '套件ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待执行, running=执行中, completed=已完成, failed=失败',
  `executor_id` bigint NOT NULL COMMENT '执行人ID',
  `started_at` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_plan_id`(`plan_id` ASC) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_executor_id`(`executor_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '测试执行记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of exec_test_run
-- ----------------------------
INSERT INTO `exec_test_run` VALUES (1, 1, 1, 'failed', 3, '2026-04-29 23:10:50', '2026-04-29 23:10:55', 1, '2026-04-29 23:10:46', '2026-04-29 23:11:06', 3, 3);

-- ----------------------------
-- Table structure for exec_test_run_case
-- ----------------------------
DROP TABLE IF EXISTS `exec_test_run_case`;
CREATE TABLE `exec_test_run_case`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `run_id` bigint NOT NULL COMMENT '执行ID',
  `test_case_id` bigint NOT NULL COMMENT '用例ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'untested' COMMENT '状态: untested=未测试, passed=通过, failed=失败, blocked=阻塞, retest=重测',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '执行结果',
  `bug_ids` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联的缺陷ID(逗号分隔)',
  `executor_id` bigint NOT NULL COMMENT '执行人ID',
  `executed_at` datetime NULL DEFAULT NULL COMMENT '执行时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_run_id`(`run_id` ASC) USING BTREE,
  INDEX `idx_test_case_id`(`test_case_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '执行用例记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of exec_test_run_case
-- ----------------------------

-- ----------------------------
-- Table structure for lbl_label
-- ----------------------------
DROP TABLE IF EXISTS `lbl_label`;
CREATE TABLE `lbl_label`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标签名称',
  `color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '#666666' COMMENT '标签颜色',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_label`(`project_id` ASC, `name` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '标签表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of lbl_label
-- ----------------------------

-- ----------------------------
-- Table structure for notification_config
-- ----------------------------
DROP TABLE IF EXISTS `notification_config`;
CREATE TABLE `notification_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置名称',
  `config_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置类型: webhook_feishu, webhook_wechat, webhook_dingtalk, email',
  `webhook_config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'Webhook配置(JSON)',
  `is_default` tinyint(1) NULL DEFAULT 0 COMMENT '是否默认',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  `is_deleted` tinyint(1) NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_config_type`(`config_type` ASC) USING BTREE,
  INDEX `idx_is_default`(`is_default` ASC) USING BTREE,
  INDEX `idx_is_active`(`is_active` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notification_config
-- ----------------------------
INSERT INTO `notification_config` VALUES (1, 'Updated Feishu Bot', 'webhook_feishu', '{\"webhook\": \"https://open.feishu.cn/open-apis/bot/v2/hook/yyy\"}', 1, 0, 'Updated config', '2026-04-30 18:43:16', '2026-04-30 18:43:46', 5, 5, 1);

-- ----------------------------
-- Table structure for notification_log
-- ----------------------------
DROP TABLE IF EXISTS `notification_log`;
CREATE TABLE `notification_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` bigint NULL DEFAULT NULL COMMENT '关联任务ID',
  `task_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务类型: api_test, ui_automation, app_automation',
  `notification_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'manual' COMMENT '通知类型: task_execution, system_alert, manual',
  `channel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知渠道: feishu, wechat, dingtalk, email',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '发送状态: pending, sending, success, failed',
  `config_id` bigint NULL DEFAULT NULL COMMENT '通知配置ID',
  `recipient_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '收件人信息(JSON)',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '通知内容(JSON)',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `retry_count` int NULL DEFAULT 0 COMMENT '重试次数',
  `sent_at` datetime NULL DEFAULT NULL COMMENT '发送时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  `is_deleted` tinyint(1) NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_task_type`(`task_type` ASC) USING BTREE,
  INDEX `idx_channel`(`channel` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notification_log
-- ----------------------------
INSERT INTO `notification_log` VALUES (1, NULL, NULL, 'manual', 'feishu', 'success', 1, NULL, '{\"title\":\"Test Notification\",\"content\":\"This is a test notification from TestHub\"}', NULL, 0, '2026-04-30 18:43:26', '2026-04-30 18:43:26', '2026-04-30 18:43:26', 5, 5, 0);

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `operation_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型: create, edit, delete, execute, run, save',
  `resource_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资源类型: project, collection, request, suite, environment, task, execution',
  `resource_id` bigint NULL DEFAULT NULL COMMENT '资源ID',
  `resource_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '资源名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '操作描述',
  `user_id` bigint NULL DEFAULT NULL COMMENT '操作用户ID',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作用户名',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户代理',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  `is_deleted` tinyint(1) NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_operation_type`(`operation_type` ASC) USING BTREE,
  INDEX `idx_resource_type`(`resource_type` ASC) USING BTREE,
  INDEX `idx_resource_id`(`resource_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_log
-- ----------------------------

-- ----------------------------
-- Table structure for prj_project
-- ----------------------------
DROP TABLE IF EXISTS `prj_project`;
CREATE TABLE `prj_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目描述',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'active' COMMENT '状态: active=进行中, paused=暂停, completed=已完成, archived=已归档',
  `owner_id` bigint NOT NULL COMMENT '项目负责人ID',
  `icon` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目图标',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `include_test_cases` tinyint NOT NULL DEFAULT 1 COMMENT '是否包含测试用例: 0=否, 1=是',
  `include_automated_tests` tinyint NOT NULL DEFAULT 0 COMMENT '是否包含自动化测试: 0=否, 1=是',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_owner_id`(`owner_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of prj_project
-- ----------------------------
INSERT INTO `prj_project` VALUES (4, '更新后的项目名称', '更新后的项目描述', 'completed', 3, NULL, 0, 1, 0, 1, '2026-04-29 17:26:35', '2026-04-29 21:18:14', NULL, NULL);
INSERT INTO `prj_project` VALUES (5, '我的测试项目1777469162', '这是一个测试项目', 'active', 3, NULL, 0, 1, 0, 1, '2026-04-29 21:26:02', '2026-04-29 21:26:12', NULL, NULL);
INSERT INTO `prj_project` VALUES (6, '我的测试项目1777469202', '这是一个测试项目', 'active', 3, NULL, 0, 1, 0, 0, '2026-04-29 21:26:42', '2026-04-29 21:26:42', NULL, NULL);
INSERT INTO `prj_project` VALUES (7, 'TestProject001', 'API Testing Project', 'active', 4, NULL, 0, 1, 0, 0, '2026-04-30 09:49:21', '2026-04-30 09:49:21', 4, 4);

-- ----------------------------
-- Table structure for prj_project_environment
-- ----------------------------
DROP TABLE IF EXISTS `prj_project_environment`;
CREATE TABLE `prj_project_environment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '环境ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '环境名称',
  `base_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '基础URL',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '环境描述',
  `variables` json NULL COMMENT '环境变量(JSON格式)',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否默认环境: 0=否, 1=是',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目环境表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of prj_project_environment
-- ----------------------------
INSERT INTO `prj_project_environment` VALUES (1, 4, '默认环境', '', NULL, NULL, 1, 0, 0, '2026-04-29 17:26:35', '2026-04-29 17:26:35', NULL, NULL);
INSERT INTO `prj_project_environment` VALUES (2, 5, '默认环境', '', NULL, NULL, 1, 0, 0, '2026-04-29 21:26:02', '2026-04-29 21:26:02', NULL, NULL);
INSERT INTO `prj_project_environment` VALUES (3, 6, '默认环境', '', NULL, NULL, 0, 0, 0, '2026-04-29 21:26:42', '2026-04-29 21:26:42', NULL, NULL);
INSERT INTO `prj_project_environment` VALUES (4, 6, '更新的环境名称', '', '更新的环境描述', '{}', 1, 0, 1, '2026-04-29 21:51:17', '2026-04-29 21:51:32', NULL, NULL);
INSERT INTO `prj_project_environment` VALUES (5, 7, '默认环境', '', NULL, NULL, 1, 0, 0, '2026-04-30 09:49:21', '2026-04-30 09:49:21', 4, 4);

-- ----------------------------
-- Table structure for prj_project_member
-- ----------------------------
DROP TABLE IF EXISTS `prj_project_member`;
CREATE TABLE `prj_project_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'tester' COMMENT '角色: owner=负责人, admin=管理员, developer=开发者, tester=测试者, viewer=观察者',
  `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_user`(`project_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目成员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of prj_project_member
-- ----------------------------
INSERT INTO `prj_project_member` VALUES (2, 4, 3, 'developer', '2026-04-29 17:26:35', 0, '2026-04-29 17:26:35', '2026-04-29 17:26:35', NULL, NULL);
INSERT INTO `prj_project_member` VALUES (3, 5, 3, 'owner', '2026-04-29 21:26:02', 0, '2026-04-29 21:26:02', '2026-04-29 21:26:02', NULL, NULL);
INSERT INTO `prj_project_member` VALUES (4, 6, 3, 'owner', '2026-04-29 21:26:42', 0, '2026-04-29 21:26:42', '2026-04-29 21:26:42', NULL, NULL);
INSERT INTO `prj_project_member` VALUES (5, 6, 2, 'tester', '2026-04-29 21:27:41', 1, '2026-04-29 21:27:41', '2026-04-29 21:46:35', NULL, NULL);
INSERT INTO `prj_project_member` VALUES (6, 7, 4, 'owner', '2026-04-30 09:49:21', 0, '2026-04-30 09:49:21', '2026-04-30 09:49:21', 4, 4);

-- ----------------------------
-- Table structure for prj_version
-- ----------------------------
DROP TABLE IF EXISTS `prj_version`;
CREATE TABLE `prj_version`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '版本ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '版本名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '版本描述',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'planning' COMMENT '状态: planning=规划中, released=已发布, archived=已归档',
  `release_date` date NULL DEFAULT NULL COMMENT '发布日期',
  `is_baseline` tinyint NOT NULL DEFAULT 0 COMMENT '是否基线版本: 0=否, 1=是',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '版本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of prj_version
-- ----------------------------

-- ----------------------------
-- Table structure for req_analysis
-- ----------------------------
DROP TABLE IF EXISTS `req_analysis`;
CREATE TABLE `req_analysis`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分析ID',
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending, running, completed, failed',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '解析后的内容',
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'AI生成的摘要',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_document_id`(`document_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '需求分析记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of req_analysis
-- ----------------------------

-- ----------------------------
-- Table structure for req_business_requirement
-- ----------------------------
DROP TABLE IF EXISTS `req_business_requirement`;
CREATE TABLE `req_business_requirement`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '需求ID',
  `analysis_id` bigint NOT NULL COMMENT '分析ID',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父需求ID(用于层级结构)',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '需求标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '需求描述',
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'medium' COMMENT '优先级: low, medium, high, critical',
  `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '来源',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_analysis_id`(`analysis_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_priority`(`priority` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '业务需求表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of req_business_requirement
-- ----------------------------

-- ----------------------------
-- Table structure for req_document
-- ----------------------------
DROP TABLE IF EXISTS `req_document`;
CREATE TABLE `req_document`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '文档ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文档名称',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件路径',
  `file_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件类型: pdf, docx, txt, markdown',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待解析, parsing=解析中, parsed=已解析, failed=失败',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_file_type`(`file_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '需求文档表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of req_document
-- ----------------------------

-- ----------------------------
-- Table structure for req_generated_test_case
-- ----------------------------
DROP TABLE IF EXISTS `req_generated_test_case`;
CREATE TABLE `req_generated_test_case`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '生成ID',
  `requirement_id` bigint NOT NULL COMMENT '需求ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用例标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '用例描述',
  `precondition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '前置条件',
  `steps` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '测试步骤',
  `expected_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '预期结果',
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'medium' COMMENT '优先级',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'generated' COMMENT '状态: generated=已生成, imported=已导入用例库, rejected=已拒绝',
  `test_case_id` bigint NULL DEFAULT NULL COMMENT '关联的测试用例ID(导入后)',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_requirement_id`(`requirement_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_test_case_id`(`test_case_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '生成的测试用例表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of req_generated_test_case
-- ----------------------------

-- ----------------------------
-- Table structure for rpt_test_report
-- ----------------------------
DROP TABLE IF EXISTS `rpt_test_report`;
CREATE TABLE `rpt_test_report`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '报告ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '报告名称',
  `report_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '报告类型: execution=执行报告, summary=汇总报告',
  `content` json NULL COMMENT '报告内容(JSON格式)',
  `generated_by` bigint NOT NULL COMMENT '生成人',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_generated_by`(`generated_by` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '测试报告表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rpt_test_report
-- ----------------------------

-- ----------------------------
-- Table structure for rv_review_assignment
-- ----------------------------
DROP TABLE IF EXISTS `rv_review_assignment`;
CREATE TABLE `rv_review_assignment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `review_id` bigint NOT NULL COMMENT '评审ID',
  `test_case_id` bigint NOT NULL COMMENT '用例ID',
  `reviewer_id` bigint NOT NULL COMMENT '评审人ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待评审, approved=通过, rejected=拒绝, needs_revision=需修改',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_review_case`(`review_id` ASC, `test_case_id` ASC) USING BTREE,
  INDEX `idx_review_id`(`review_id` ASC) USING BTREE,
  INDEX `idx_test_case_id`(`test_case_id` ASC) USING BTREE,
  INDEX `idx_reviewer_id`(`reviewer_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评审分配表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rv_review_assignment
-- ----------------------------

-- ----------------------------
-- Table structure for rv_review_comment
-- ----------------------------
DROP TABLE IF EXISTS `rv_review_comment`;
CREATE TABLE `rv_review_comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `assignment_id` bigint NOT NULL COMMENT '分配ID',
  `test_case_step_id` bigint NULL DEFAULT NULL COMMENT '用例步骤ID(可为NULL表示整体意见)',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `is_resolved` tinyint NOT NULL DEFAULT 0 COMMENT '是否已解决: 0=否, 1=是',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_assignment_id`(`assignment_id` ASC) USING BTREE,
  INDEX `idx_test_case_step_id`(`test_case_step_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评审意见表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rv_review_comment
-- ----------------------------

-- ----------------------------
-- Table structure for rv_review_template
-- ----------------------------
DROP TABLE IF EXISTS `rv_review_template`;
CREATE TABLE `rv_review_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模板名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '模板描述',
  `checklist` json NULL COMMENT '检查清单(JSON格式)',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否默认模板: 0=否, 1=是',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评审模板表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rv_review_template
-- ----------------------------

-- ----------------------------
-- Table structure for rv_test_case_review
-- ----------------------------
DROP TABLE IF EXISTS `rv_test_case_review`;
CREATE TABLE `rv_test_case_review`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评审ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评审名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '评审描述',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待评审, in_progress=评审中, passed=通过, rejected=拒绝, needs_revision=需修改',
  `template_id` bigint NULL DEFAULT NULL COMMENT '评审模板ID',
  `assignee_id` bigint NULL DEFAULT NULL COMMENT '评审人ID',
  `due_date` date NULL DEFAULT NULL COMMENT '截止日期',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_assignee_id`(`assignee_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '测试用例评审表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rv_test_case_review
-- ----------------------------

-- ----------------------------
-- Table structure for sys_token_blacklist
-- ----------------------------
DROP TABLE IF EXISTS `sys_token_blacklist`;
CREATE TABLE `sys_token_blacklist`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `token_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Token JTI(唯一标识)',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `expire_time` datetime NOT NULL COMMENT 'Token过期时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入黑名单时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `token_id`(`token_id` ASC) USING BTREE,
  INDEX `idx_token_id`(`token_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_expire_time`(`expire_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Token黑名单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_token_blacklist
-- ----------------------------
INSERT INTO `sys_token_blacklist` VALUES (1, 'c35111c4-2940-4387-af27-fe016fb1c1af', 2, '2026-05-06 16:32:44', '2026-04-29 16:33:28', NULL);
INSERT INTO `sys_token_blacklist` VALUES (2, 'fa6630ee-1bc6-4731-9c29-aef8aaf09835', 2, '2026-04-29 16:48:27', '2026-04-29 16:33:37', NULL);
INSERT INTO `sys_token_blacklist` VALUES (3, '65db83f4-b95a-4f66-a3eb-7bb0e8e09bf3', 2, '2026-04-29 16:48:57', '2026-04-29 16:34:05', NULL);
INSERT INTO `sys_token_blacklist` VALUES (4, '5043a8f1-41d8-4592-8061-7f433ddb9db8', 2, '2026-04-29 16:58:26', '2026-04-29 16:43:35', NULL);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '邮箱',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(BCrypt加密)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'enabled' COMMENT '状态: enabled=启用, disabled=禁用',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'USER' COMMENT '角色',
  `is_superuser` tinyint NULL DEFAULT 0 COMMENT '是否超级管理员',
  `is_staff` tinyint NULL DEFAULT 0 COMMENT '是否可以登录管理后台',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_email`(`email` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (2, 'testuser1777451358', 'updated@test.com', '$2a$10$arsXJLYbH4lPKACfJVgfk.2JEmUyTol2K8OGkrcDQRSiDIXzySIIG', '更新的姓名', '13900139000', NULL, 'enabled', NULL, NULL, 0, '2026-04-29 16:29:20', '2026-04-29 17:13:07', NULL, NULL, 'USER', 0, 0);
INSERT INTO `sys_user` VALUES (3, 'admin', 'admin@test.com', '$2a$10$arsXJLYbH4lPKACfJVgfk.2JEmUyTol2K8OGkrcDQRSiDIXzySIIG', '管理员', '13700000000', NULL, 'enabled', NULL, NULL, 0, '2026-04-29 16:53:59', '2026-04-29 17:13:10', NULL, NULL, 'USER', 1, 0);
INSERT INTO `sys_user` VALUES (4, 'testapi002', 'testapi002@test.com', '$2a$10$YU647zaJ5lh2eEJRfMq9leDvQ4Z0uj0JFyO.1e5rgOW/R0VafYWDu', NULL, NULL, NULL, 'enabled', NULL, NULL, 0, '2026-04-30 09:48:41', '2026-04-30 09:48:41', NULL, NULL, 'USER', 0, 0);
INSERT INTO `sys_user` VALUES (5, 'testuser', 'test@test.com', '$2a$10$QUsPS4dprjiy9FhKxzXqRuYs0VdfSFTmCqfTiq8gntwzT.3E3XjHC', 'Test User', NULL, NULL, 'enabled', NULL, NULL, 0, '2026-04-30 17:24:04', '2026-04-30 17:24:04', NULL, NULL, 'USER', 0, 0);

-- ----------------------------
-- Table structure for sys_user_profile
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_profile`;
CREATE TABLE `sys_user_profile`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `theme` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'light' COMMENT '主题: light=浅色, dark=深色',
  `language` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'zh-hans' COMMENT '语言: zh-hans=简体中文, en-us=英文',
  `timezone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'Asia/Shanghai' COMMENT '时区',
  `bio` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '个人简介',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_profile
-- ----------------------------
INSERT INTO `sys_user_profile` VALUES (2, 2, 'light', 'zh-hans', 'Asia/Shanghai', NULL, '2026-04-29 16:29:19', '2026-04-29 16:29:19');
INSERT INTO `sys_user_profile` VALUES (3, 3, 'light', 'zh-hans', 'Asia/Shanghai', NULL, '2026-04-29 16:53:59', '2026-04-29 16:53:59');
INSERT INTO `sys_user_profile` VALUES (4, 4, 'light', 'zh-hans', 'Asia/Shanghai', NULL, '2026-04-30 09:48:40', '2026-04-30 09:48:40');
INSERT INTO `sys_user_profile` VALUES (5, 5, 'light', 'zh-hans', 'Asia/Shanghai', NULL, '2026-04-30 17:24:03', '2026-04-30 17:24:03');

-- ----------------------------
-- Table structure for tc_test_case
-- ----------------------------
DROP TABLE IF EXISTS `tc_test_case`;
CREATE TABLE `tc_test_case`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用例ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用例标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '用例描述',
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'medium' COMMENT '优先级: low=低, medium=中, high=高, critical=紧急',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'functional' COMMENT '类型: functional=功能测试, integration=集成测试, api=API测试, ui=UI测试, performance=性能测试, security=安全测试',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'draft' COMMENT '状态: draft=草稿, active=激活, deprecated=废弃',
  `precondition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '前置条件',
  `expected_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '预期结果',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_priority`(`priority` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_title`(`title` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '测试用例表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tc_test_case
-- ----------------------------
INSERT INTO `tc_test_case` VALUES (1, 6, '登录功能测试', '测试用户登录功能', 'high', 'functional', 'draft', '用户已注册', '登录成功', 1, '2026-04-29 22:59:08', '2026-04-29 23:09:32', NULL, 3);
INSERT INTO `tc_test_case` VALUES (2, 6, '登录功能测试', '测试用户登录功能', 'high', 'functional', 'draft', '用户已注册', '登录成功', 0, '2026-04-29 23:08:54', '2026-04-29 23:08:54', 3, 3);

-- ----------------------------
-- Table structure for tc_test_case_attachment
-- ----------------------------
DROP TABLE IF EXISTS `tc_test_case_attachment`;
CREATE TABLE `tc_test_case_attachment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '附件ID',
  `test_case_id` bigint NOT NULL COMMENT '用例ID',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件名',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件路径',
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件类型',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小(字节)',
  `uploaded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_test_case_id`(`test_case_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用例附件表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tc_test_case_attachment
-- ----------------------------

-- ----------------------------
-- Table structure for tc_test_case_comment
-- ----------------------------
DROP TABLE IF EXISTS `tc_test_case_comment`;
CREATE TABLE `tc_test_case_comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `test_case_id` bigint NOT NULL COMMENT '用例ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父评论ID(回复)',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_test_case_id`(`test_case_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用例评论表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tc_test_case_comment
-- ----------------------------

-- ----------------------------
-- Table structure for tc_test_case_label
-- ----------------------------
DROP TABLE IF EXISTS `tc_test_case_label`;
CREATE TABLE `tc_test_case_label`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `test_case_id` bigint NOT NULL COMMENT '用例ID',
  `label_id` bigint NOT NULL COMMENT '标签ID',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_test_case_id`(`test_case_id` ASC) USING BTREE,
  INDEX `idx_label_id`(`label_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用例标签关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tc_test_case_label
-- ----------------------------

-- ----------------------------
-- Table structure for tc_test_case_step
-- ----------------------------
DROP TABLE IF EXISTS `tc_test_case_step`;
CREATE TABLE `tc_test_case_step`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '步骤ID',
  `test_case_id` bigint NOT NULL COMMENT '用例ID',
  `step_number` int NOT NULL COMMENT '步骤序号',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '步骤描述',
  `expected_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '预期结果',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_test_case_id`(`test_case_id` ASC) USING BTREE,
  INDEX `idx_step_number`(`step_number` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用例步骤表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tc_test_case_step
-- ----------------------------
INSERT INTO `tc_test_case_step` VALUES (1, 1, 1, '输入用户名', '用户名显示在输入框', 1, '2026-04-29 22:59:08', '2026-04-29 23:09:32', NULL, NULL);
INSERT INTO `tc_test_case_step` VALUES (2, 1, 2, '输入密码', '密码显示为***', 1, '2026-04-29 22:59:08', '2026-04-29 23:09:32', NULL, NULL);
INSERT INTO `tc_test_case_step` VALUES (3, 1, 3, '点击登录按钮', '跳转到首页', 1, '2026-04-29 22:59:08', '2026-04-29 23:09:32', NULL, NULL);
INSERT INTO `tc_test_case_step` VALUES (4, 2, 1, '输入用户名', '用户名显示在输入框', 0, '2026-04-29 23:08:54', '2026-04-29 23:08:54', 3, 3);
INSERT INTO `tc_test_case_step` VALUES (5, 2, 2, '输入密码', '密码显示为***', 0, '2026-04-29 23:08:54', '2026-04-29 23:08:54', 3, 3);
INSERT INTO `tc_test_case_step` VALUES (6, 2, 3, '点击登录按钮', '跳转到首页', 0, '2026-04-29 23:08:54', '2026-04-29 23:08:54', 3, 3);

-- ----------------------------
-- Table structure for ts_test_suite
-- ----------------------------
DROP TABLE IF EXISTS `ts_test_suite`;
CREATE TABLE `ts_test_suite`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '套件ID',
  `project_id` bigint NOT NULL COMMENT '项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '套件名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '套件描述',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '测试套件表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ts_test_suite
-- ----------------------------
INSERT INTO `ts_test_suite` VALUES (1, 6, '登录功能套件', '包含所有登录相关用例', 0, 1, '2026-04-29 23:09:46', '2026-04-29 23:10:00', 3, 3);

-- ----------------------------
-- Table structure for ts_test_suite_case
-- ----------------------------
DROP TABLE IF EXISTS `ts_test_suite_case`;
CREATE TABLE `ts_test_suite_case`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `suite_id` bigint NOT NULL COMMENT '套件ID',
  `test_case_id` bigint NOT NULL COMMENT '用例ID',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_suite_case`(`suite_id` ASC, `test_case_id` ASC) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_test_case_id`(`test_case_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '套件用例关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ts_test_suite_case
-- ----------------------------

-- ----------------------------
-- Table structure for ui_ai_config
-- ----------------------------
DROP TABLE IF EXISTS `ui_ai_config`;
CREATE TABLE `ui_ai_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `project_id` bigint NOT NULL COMMENT 'UI项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置名称',
  `ai_model_config_id` bigint NULL DEFAULT NULL COMMENT 'AI模型配置ID',
  `mode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'text' COMMENT '模式: text=文本模式, vision=视觉模式',
  `prompt_template` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '提示词模板',
  `is_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_is_enabled`(`is_enabled` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI AI智能模式配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_ai_config
-- ----------------------------

-- ----------------------------
-- Table structure for ui_ai_execution
-- ----------------------------
DROP TABLE IF EXISTS `ui_ai_execution`;
CREATE TABLE `ui_ai_execution`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '执行ID',
  `config_id` bigint NOT NULL COMMENT 'AI配置ID',
  `task_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务描述',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待执行, running=执行中, completed=已完成, failed=失败',
  `steps` json NULL COMMENT '执行步骤',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '执行结果',
  `executor_id` bigint NOT NULL COMMENT '执行人ID',
  `started_at` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_config_id`(`config_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI AI执行记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_ai_execution
-- ----------------------------

-- ----------------------------
-- Table structure for ui_element
-- ----------------------------
DROP TABLE IF EXISTS `ui_element`;
CREATE TABLE `ui_element`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '元素ID',
  `project_id` bigint NOT NULL COMMENT 'UI项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '元素名称',
  `locator_strategy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '定位策略: id, css, xpath, name, class_name, tag_name, link_text, partial_link_text',
  `locator_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '定位器值',
  `element_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '元素类型: input, button, link, dropdown, checkbox, radio, text, image, container, table, form, modal',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '元素描述',
  `screenshot` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '截图路径',
  `usage_count` int NULL DEFAULT 0 COMMENT '使用次数',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_locator_strategy`(`locator_strategy` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI元素表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_element
-- ----------------------------

-- ----------------------------
-- Table structure for ui_element_backup
-- ----------------------------
DROP TABLE IF EXISTS `ui_element_backup`;
CREATE TABLE `ui_element_backup`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `element_id` bigint NOT NULL COMMENT '元素ID',
  `locator_strategy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '备用定位策略',
  `locator_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '备用定位器值',
  `priority` int NOT NULL DEFAULT 1 COMMENT '优先级',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_element_id`(`element_id` ASC) USING BTREE,
  INDEX `idx_priority`(`priority` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI元素备用定位器表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_element_backup
-- ----------------------------

-- ----------------------------
-- Table structure for ui_element_group
-- ----------------------------
DROP TABLE IF EXISTS `ui_element_group`;
CREATE TABLE `ui_element_group`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分组ID',
  `project_id` bigint NOT NULL COMMENT 'UI项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分组名称',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父分组ID',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI元素分组表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_element_group
-- ----------------------------

-- ----------------------------
-- Table structure for ui_page_object
-- ----------------------------
DROP TABLE IF EXISTS `ui_page_object`;
CREATE TABLE `ui_page_object`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '页面对象ID',
  `project_id` bigint NOT NULL COMMENT 'UI项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '页面对象名称',
  `url_pattern` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'URL模式',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '页面描述',
  `elements` json NULL COMMENT '页面元素配置',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI页面对象表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_page_object
-- ----------------------------

-- ----------------------------
-- Table structure for ui_project
-- ----------------------------
DROP TABLE IF EXISTS `ui_project`;
CREATE TABLE `ui_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `project_id` bigint NOT NULL COMMENT '关联项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'UI项目名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目描述',
  `engine` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'selenium' COMMENT '自动化引擎: selenium, playwright',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI自动化项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_project
-- ----------------------------

-- ----------------------------
-- Table structure for ui_scheduled_task
-- ----------------------------
DROP TABLE IF EXISTS `ui_scheduled_task`;
CREATE TABLE `ui_scheduled_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `suite_id` bigint NOT NULL COMMENT '套件ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `trigger_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发类型: cron, interval, once',
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Cron表达式',
  `interval_value` bigint NULL DEFAULT NULL COMMENT '间隔值',
  `interval_unit` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '间隔单位',
  `once_time` datetime NULL DEFAULT NULL COMMENT '单次执行时间',
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'chromium' COMMENT '浏览器',
  `headless` tinyint NOT NULL DEFAULT 0 COMMENT '是否无头模式',
  `is_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否启用: 0=禁用, 1=启用',
  `notification_config` json NULL COMMENT '通知配置',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `last_run_at` datetime NULL DEFAULT NULL COMMENT '上次执行时间',
  `next_run_at` datetime NULL DEFAULT NULL COMMENT '下次执行时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_is_enabled`(`is_enabled` ASC) USING BTREE,
  INDEX `idx_trigger_type`(`trigger_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI定时任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_scheduled_task
-- ----------------------------

-- ----------------------------
-- Table structure for ui_test_execution
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_execution`;
CREATE TABLE `ui_test_execution`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '执行ID',
  `suite_id` bigint NOT NULL COMMENT '套件ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending=待执行, running=执行中, passed=通过, failed=失败, stopped=已停止',
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浏览器',
  `headless` tinyint NOT NULL DEFAULT 0 COMMENT '是否无头模式',
  `executor_id` bigint NOT NULL COMMENT '执行人ID',
  `started_at` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `total_count` int NULL DEFAULT 0 COMMENT '总用例数',
  `passed_count` int NULL DEFAULT 0 COMMENT '通过数',
  `failed_count` int NULL DEFAULT 0 COMMENT '失败数',
  `report_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '报告路径',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_executor_id`(`executor_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI测试执行记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_test_execution
-- ----------------------------

-- ----------------------------
-- Table structure for ui_test_script
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_script`;
CREATE TABLE `ui_test_script`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '脚本ID',
  `project_id` bigint NOT NULL COMMENT 'UI项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '脚本名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '脚本描述',
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'chromium' COMMENT '浏览器: chromium, firefox, webkit, edge',
  `steps` json NOT NULL COMMENT '执行步骤(JSON格式)',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI测试脚本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_test_script
-- ----------------------------

-- ----------------------------
-- Table structure for ui_test_suite
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_suite`;
CREATE TABLE `ui_test_suite`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '套件ID',
  `project_id` bigint NOT NULL COMMENT 'UI项目ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '套件名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '套件描述',
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'chromium' COMMENT '浏览器',
  `headless` tinyint NOT NULL DEFAULT 0 COMMENT '是否无头模式: 0=否, 1=是',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI测试套件表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_test_suite
-- ----------------------------

-- ----------------------------
-- Table structure for ui_test_suite_script
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_suite_script`;
CREATE TABLE `ui_test_suite_script`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `suite_id` bigint NOT NULL COMMENT '套件ID',
  `script_id` bigint NOT NULL COMMENT '脚本ID',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '执行顺序',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_suite_script`(`suite_id` ASC, `script_id` ASC) USING BTREE,
  INDEX `idx_suite_id`(`suite_id` ASC) USING BTREE,
  INDEX `idx_script_id`(`script_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'UI套件脚本关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ui_test_suite_script
-- ----------------------------

-- ----------------------------
-- Migration: 环境管理升级 - 添加 scope 和 is_active 字段
-- 适用于已有数据库的升级（如果表已存在）
-- ----------------------------
-- ALTER TABLE `api_environment` ADD COLUMN `scope` varchar(10) NOT NULL DEFAULT 'LOCAL' COMMENT '作用域: GLOBAL=全局, LOCAL=项目级' AFTER `description`;
-- ALTER TABLE `api_environment` ADD COLUMN `is_active` tinyint NOT NULL DEFAULT 0 COMMENT '是否激活: 0=否, 1=是' AFTER `is_default`;
-- ALTER TABLE `api_environment` MODIFY COLUMN `project_id` bigint NULL DEFAULT NULL COMMENT '项目ID(scope=LOCAL时必填)';
-- ALTER TABLE `api_environment` ADD INDEX `idx_scope`(`scope`);
-- ALTER TABLE `api_environment` ADD INDEX `idx_is_active`(`is_active`);

-- Migration: api_project.project_id 改为可空
-- ALTER TABLE `api_project` MODIFY COLUMN `project_id` bigint NULL DEFAULT NULL COMMENT '关联项目ID';

SET FOREIGN_KEY_CHECKS = 1;
