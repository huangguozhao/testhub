/*
 Navicat Premium Dump SQL

 Source Server         : 127.0.0.1
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : localhost:3306
 Source Schema         : testhub

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 12/04/2026 17:41:52
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ai_model_config
-- ----------------------------
DROP TABLE IF EXISTS `ai_model_config`;
CREATE TABLE `ai_model_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `api_key` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `base_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `max_tokens` int NOT NULL,
  `temperature` double NOT NULL,
  `top_p` double NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ai_model_config_created_by_id_bd66969a_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  CONSTRAINT `ai_model_config_created_by_id_bd66969a_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for analysis_tasks
-- ----------------------------
DROP TABLE IF EXISTS `analysis_tasks`;
CREATE TABLE `analysis_tasks`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `progress` int UNSIGNED NOT NULL,
  `result` json NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `started_at` datetime(6) NULL DEFAULT NULL,
  `completed_at` datetime(6) NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `document_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `task_id`(`task_id` ASC) USING BTREE,
  INDEX `analysis_tasks_document_id_df7edd04_fk_requirement_documents_id`(`document_id` ASC) USING BTREE,
  CONSTRAINT `analysis_tasks_document_id_df7edd04_fk_requirement_documents_id` FOREIGN KEY (`document_id`) REFERENCES `requirement_documents` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `analysis_tasks_chk_1` CHECK (`progress` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_ai_service_configs
-- ----------------------------
DROP TABLE IF EXISTS `api_ai_service_configs`;
CREATE TABLE `api_ai_service_configs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `service_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `base_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `max_tokens` int NOT NULL,
  `temperature` double NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_ai_service_configs_created_by_id_1c0d5c11_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `api_ai_serv_service_7ca1bd_idx`(`service_type` ASC, `role` ASC) USING BTREE,
  INDEX `api_ai_serv_is_acti_1b99e3_idx`(`is_active` ASC) USING BTREE,
  CONSTRAINT `api_ai_service_configs_created_by_id_1c0d5c11_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_collections
-- ----------------------------
DROP TABLE IF EXISTS `api_collections`;
CREATE TABLE `api_collections`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `order` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `parent_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_collections_parent_id_d4218833_fk_api_collections_id`(`parent_id` ASC) USING BTREE,
  INDEX `api_collections_project_id_9edf34bf_fk_api_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `api_collections_parent_id_d4218833_fk_api_collections_id` FOREIGN KEY (`parent_id`) REFERENCES `api_collections` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_collections_project_id_9edf34bf_fk_api_projects_id` FOREIGN KEY (`project_id`) REFERENCES `api_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_environments
-- ----------------------------
DROP TABLE IF EXISTS `api_environments`;
CREATE TABLE `api_environments`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `scope` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `variables` json NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_environments_created_by_id_109aa38e_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `api_environments_project_id_2f2a6c42_fk_api_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `api_environments_created_by_id_109aa38e_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_environments_project_id_2f2a6c42_fk_api_projects_id` FOREIGN KEY (`project_id`) REFERENCES `api_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_notification_logs
-- ----------------------------
DROP TABLE IF EXISTS `api_notification_logs`;
CREATE TABLE `api_notification_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `notification_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_email` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_info` json NOT NULL,
  `webhook_bot_info` json NULL,
  `notification_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `response_info` json NULL,
  `created_at` datetime(6) NOT NULL,
  `sent_at` datetime(6) NULL DEFAULT NULL,
  `retry_count` int NOT NULL,
  `is_retried` tinyint(1) NOT NULL,
  `task_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_notification_logs_task_id_fba9f818_fk_api_scheduled_tasks_id`(`task_id` ASC) USING BTREE,
  INDEX `api_notific_status_3bb8ea_idx`(`status` ASC) USING BTREE,
  INDEX `api_notific_notific_6c611c_idx`(`notification_type` ASC) USING BTREE,
  INDEX `api_notific_created_45cb75_idx`(`created_at` ASC) USING BTREE,
  CONSTRAINT `api_notification_logs_task_id_fba9f818_fk_api_scheduled_tasks_id` FOREIGN KEY (`task_id`) REFERENCES `api_scheduled_tasks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_operation_logs
-- ----------------------------
DROP TABLE IF EXISTS `api_operation_logs`;
CREATE TABLE `api_operation_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `operation_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `resource_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `resource_id` int NOT NULL,
  `resource_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_operati_created_f5f80f_idx`(`created_at` DESC) USING BTREE,
  INDEX `api_operati_resourc_de446f_idx`(`resource_type` ASC, `resource_id` ASC) USING BTREE,
  INDEX `api_operati_user_id_072297_idx`(`user_id` ASC, `created_at` DESC) USING BTREE,
  CONSTRAINT `api_operation_logs_user_id_99306ef9_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_projects
-- ----------------------------
DROP TABLE IF EXISTS `api_projects`;
CREATE TABLE `api_projects`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `project_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NULL DEFAULT NULL,
  `end_date` date NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `owner_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_projects_owner_id_4f7882e5_fk_users_user_id`(`owner_id` ASC) USING BTREE,
  CONSTRAINT `api_projects_owner_id_4f7882e5_fk_users_user_id` FOREIGN KEY (`owner_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_projects_members
-- ----------------------------
DROP TABLE IF EXISTS `api_projects_members`;
CREATE TABLE `api_projects_members`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `apiproject_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `api_projects_members_apiproject_id_user_id_7b4db34c_uniq`(`apiproject_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `api_projects_members_user_id_1b6ada40_fk_users_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `api_projects_members_apiproject_id_bf72a46a_fk_api_projects_id` FOREIGN KEY (`apiproject_id`) REFERENCES `api_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_projects_members_user_id_1b6ada40_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_request_histories
-- ----------------------------
DROP TABLE IF EXISTS `api_request_histories`;
CREATE TABLE `api_request_histories`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `request_data` json NOT NULL,
  `response_data` json NULL,
  `status_code` int NULL DEFAULT NULL,
  `response_time` double NULL DEFAULT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `assertions_results` json NULL,
  `executed_at` datetime(6) NOT NULL,
  `environment_id` bigint NULL DEFAULT NULL,
  `executed_by_id` bigint NOT NULL,
  `request_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_request_historie_environment_id_544a1b01_fk_api_envir`(`environment_id` ASC) USING BTREE,
  INDEX `api_request_histories_executed_by_id_53b7a41f_fk_users_user_id`(`executed_by_id` ASC) USING BTREE,
  INDEX `api_request_histories_request_id_716f7a22_fk_api_requests_id`(`request_id` ASC) USING BTREE,
  CONSTRAINT `api_request_historie_environment_id_544a1b01_fk_api_envir` FOREIGN KEY (`environment_id`) REFERENCES `api_environments` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_request_histories_executed_by_id_53b7a41f_fk_users_user_id` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_request_histories_request_id_716f7a22_fk_api_requests_id` FOREIGN KEY (`request_id`) REFERENCES `api_requests` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_requests
-- ----------------------------
DROP TABLE IF EXISTS `api_requests`;
CREATE TABLE `api_requests`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `request_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `headers` json NOT NULL,
  `params` json NOT NULL,
  `body` json NOT NULL,
  `auth` json NOT NULL,
  `pre_request_script` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_request_script` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `assertions` json NOT NULL,
  `order` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `collection_id` bigint NULL DEFAULT NULL,
  `created_by_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_requests_collection_id_53976f2a_fk_api_collections_id`(`collection_id` ASC) USING BTREE,
  INDEX `api_requests_created_by_id_e8cf0e50_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  CONSTRAINT `api_requests_collection_id_53976f2a_fk_api_collections_id` FOREIGN KEY (`collection_id`) REFERENCES `api_collections` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_requests_created_by_id_e8cf0e50_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_scheduled_tasks
-- ----------------------------
DROP TABLE IF EXISTS `api_scheduled_tasks`;
CREATE TABLE `api_scheduled_tasks`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `trigger_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `interval_seconds` int NULL DEFAULT NULL,
  `execute_at` datetime(6) NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_run_time` datetime(6) NULL DEFAULT NULL,
  `next_run_time` datetime(6) NULL DEFAULT NULL,
  `total_runs` int NOT NULL,
  `successful_runs` int NOT NULL,
  `failed_runs` int NOT NULL,
  `last_result` json NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notify_on_success` tinyint(1) NOT NULL,
  `notify_on_failure` tinyint(1) NOT NULL,
  `notify_emails` json NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `api_request_id` bigint NULL DEFAULT NULL,
  `created_by_id` bigint NOT NULL,
  `environment_id` bigint NULL DEFAULT NULL,
  `test_suite_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_scheduled_tasks_api_request_id_2b5ffa7d_fk_api_requests_id`(`api_request_id` ASC) USING BTREE,
  INDEX `api_scheduled_tasks_created_by_id_345a8294_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `api_scheduled_tasks_environment_id_5f680d8f_fk_api_envir`(`environment_id` ASC) USING BTREE,
  INDEX `api_scheduled_tasks_test_suite_id_147d1f26_fk_api_test_suites_id`(`test_suite_id` ASC) USING BTREE,
  CONSTRAINT `api_scheduled_tasks_api_request_id_2b5ffa7d_fk_api_requests_id` FOREIGN KEY (`api_request_id`) REFERENCES `api_requests` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_scheduled_tasks_created_by_id_345a8294_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_scheduled_tasks_environment_id_5f680d8f_fk_api_envir` FOREIGN KEY (`environment_id`) REFERENCES `api_environments` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_scheduled_tasks_test_suite_id_147d1f26_fk_api_test_suites_id` FOREIGN KEY (`test_suite_id`) REFERENCES `api_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_task_execution_logs
-- ----------------------------
DROP TABLE IF EXISTS `api_task_execution_logs`;
CREATE TABLE `api_task_execution_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` datetime(6) NULL DEFAULT NULL,
  `end_time` datetime(6) NULL DEFAULT NULL,
  `duration` double NULL DEFAULT NULL,
  `result` json NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `executed_by_id` bigint NULL DEFAULT NULL,
  `task_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_task_execution_logs_executed_by_id_84c374b6_fk_users_user_id`(`executed_by_id` ASC) USING BTREE,
  INDEX `api_task_execution_l_task_id_a040d961_fk_api_sched`(`task_id` ASC) USING BTREE,
  CONSTRAINT `api_task_execution_l_task_id_a040d961_fk_api_sched` FOREIGN KEY (`task_id`) REFERENCES `api_scheduled_tasks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_task_execution_logs_executed_by_id_84c374b6_fk_users_user_id` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_task_notification_settings
-- ----------------------------
DROP TABLE IF EXISTS `api_task_notification_settings`;
CREATE TABLE `api_task_notification_settings`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `notification_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_enabled` tinyint(1) NOT NULL,
  `notify_on_success` tinyint(1) NOT NULL,
  `notify_on_failure` tinyint(1) NOT NULL,
  `notify_on_timeout` tinyint(1) NOT NULL,
  `notify_on_error` tinyint(1) NOT NULL,
  `custom_webhook_bots` json NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `notification_config_id` bigint NULL DEFAULT NULL,
  `task_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `api_task_notification_settings_task_id_8478cf77_uniq`(`task_id` ASC) USING BTREE,
  INDEX `api_task_notificatio_notification_config__77d3fe52_fk_unified_n`(`notification_config_id` ASC) USING BTREE,
  CONSTRAINT `api_task_notificatio_notification_config__77d3fe52_fk_unified_n` FOREIGN KEY (`notification_config_id`) REFERENCES `unified_notification_configs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_task_notificatio_task_id_8478cf77_fk_api_sched` FOREIGN KEY (`task_id`) REFERENCES `api_scheduled_tasks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_task_notification_settings_custom_recipients
-- ----------------------------
DROP TABLE IF EXISTS `api_task_notification_settings_custom_recipients`;
CREATE TABLE `api_task_notification_settings_custom_recipients`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tasknotificationsetting_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `api_task_notification_se_tasknotificationsetting__78874d26_uniq`(`tasknotificationsetting_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `api_task_notificatio_user_id_855afd86_fk_users_use`(`user_id` ASC) USING BTREE,
  CONSTRAINT `api_task_notificatio_tasknotificationsett_2090d51a_fk_api_task_` FOREIGN KEY (`tasknotificationsetting_id`) REFERENCES `api_task_notification_settings` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_task_notificatio_user_id_855afd86_fk_users_use` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_test_executions
-- ----------------------------
DROP TABLE IF EXISTS `api_test_executions`;
CREATE TABLE `api_test_executions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` datetime(6) NULL DEFAULT NULL,
  `end_time` datetime(6) NULL DEFAULT NULL,
  `total_requests` int NOT NULL,
  `passed_requests` int NOT NULL,
  `failed_requests` int NOT NULL,
  `results` json NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `executed_by_id` bigint NOT NULL,
  `test_suite_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_test_executions_executed_by_id_6cdbbd58_fk_users_user_id`(`executed_by_id` ASC) USING BTREE,
  INDEX `api_test_executions_test_suite_id_588c9dab_fk_api_test_suites_id`(`test_suite_id` ASC) USING BTREE,
  CONSTRAINT `api_test_executions_executed_by_id_6cdbbd58_fk_users_user_id` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_test_executions_test_suite_id_588c9dab_fk_api_test_suites_id` FOREIGN KEY (`test_suite_id`) REFERENCES `api_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_test_suite_requests
-- ----------------------------
DROP TABLE IF EXISTS `api_test_suite_requests`;
CREATE TABLE `api_test_suite_requests`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order` int NOT NULL,
  `assertions` json NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `request_id` bigint NOT NULL,
  `test_suite_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `api_test_suite_requests_test_suite_id_request_id_25a3cd33_uniq`(`test_suite_id` ASC, `request_id` ASC) USING BTREE,
  INDEX `api_test_suite_requests_request_id_307cd4e0_fk_api_requests_id`(`request_id` ASC) USING BTREE,
  CONSTRAINT `api_test_suite_reque_test_suite_id_7dd50d77_fk_api_test_` FOREIGN KEY (`test_suite_id`) REFERENCES `api_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_test_suite_requests_request_id_307cd4e0_fk_api_requests_id` FOREIGN KEY (`request_id`) REFERENCES `api_requests` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for api_test_suites
-- ----------------------------
DROP TABLE IF EXISTS `api_test_suites`;
CREATE TABLE `api_test_suites`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  `environment_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `api_test_suites_created_by_id_63aa8fad_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `api_test_suites_environment_id_6a8dd602_fk_api_environments_id`(`environment_id` ASC) USING BTREE,
  INDEX `api_test_suites_project_id_f83c9318_fk_api_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `api_test_suites_created_by_id_63aa8fad_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_test_suites_environment_id_6a8dd602_fk_api_environments_id` FOREIGN KEY (`environment_id`) REFERENCES `api_environments` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_test_suites_project_id_f83c9318_fk_api_projects_id` FOREIGN KEY (`project_id`) REFERENCES `api_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_component_packages
-- ----------------------------
DROP TABLE IF EXISTS `app_component_packages`;
CREATE TABLE `app_component_packages`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `manifest` json NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `app_component_packages_created_by_id_cf4c0571_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  CONSTRAINT `app_component_packages_created_by_id_cf4c0571_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_components
-- ----------------------------
DROP TABLE IF EXISTS `app_components`;
CREATE TABLE `app_components`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema` json NOT NULL,
  `default_config` json NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `sort_order` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `type`(`type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_custom_components
-- ----------------------------
DROP TABLE IF EXISTS `app_custom_components`;
CREATE TABLE `app_custom_components`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `schema` json NOT NULL,
  `default_config` json NOT NULL,
  `steps` json NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `sort_order` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `type`(`type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_devices
-- ----------------------------
DROP TABLE IF EXISTS `app_devices`;
CREATE TABLE `app_devices`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `android_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `port` int NOT NULL,
  `locked_at` datetime(6) NULL DEFAULT NULL,
  `max_allocation_time` int NOT NULL,
  `device_specs` json NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `locked_by_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `device_id`(`device_id` ASC) USING BTREE,
  INDEX `app_devices_locked_by_id_adbc4a36_fk_users_user_id`(`locked_by_id` ASC) USING BTREE,
  INDEX `app_devices_status_9e09a1_idx`(`status` ASC) USING BTREE,
  INDEX `app_devices_device__1b1f25_idx`(`device_id` ASC) USING BTREE,
  CONSTRAINT `app_devices_locked_by_id_adbc4a36_fk_users_user_id` FOREIGN KEY (`locked_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_elements
-- ----------------------------
DROP TABLE IF EXISTS `app_elements`;
CREATE TABLE `app_elements`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `element_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tags` json NOT NULL,
  `config` json NOT NULL,
  `resolution_configs` json NOT NULL,
  `usage_count` int NOT NULL,
  `last_used_at` datetime(6) NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_by_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE,
  INDEX `app_elements_created_by_id_0a5efbac_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `app_elements_project_id_69fb7fcc_fk_app_projects_id`(`project_id` ASC) USING BTREE,
  INDEX `app_element_element_c563e9_idx`(`element_type` ASC) USING BTREE,
  INDEX `app_element_name_0cb360_idx`(`name` ASC) USING BTREE,
  INDEX `app_element_is_acti_772d00_idx`(`is_active` ASC) USING BTREE,
  CONSTRAINT `app_elements_created_by_id_0a5efbac_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_elements_project_id_69fb7fcc_fk_app_projects_id` FOREIGN KEY (`project_id`) REFERENCES `app_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_notification_logs
-- ----------------------------
DROP TABLE IF EXISTS `app_notification_logs`;
CREATE TABLE `app_notification_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_email` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_info` json NOT NULL,
  `webhook_bot_info` json NOT NULL,
  `notification_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `response_info` json NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `sent_at` datetime(6) NULL DEFAULT NULL,
  `retry_count` int NOT NULL,
  `is_retried` tinyint(1) NOT NULL,
  `task_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `app_notification_logs_task_id_60b09253_fk_app_scheduled_tasks_id`(`task_id` ASC) USING BTREE,
  INDEX `app_notific_status_b1a744_idx`(`status` ASC) USING BTREE,
  INDEX `app_notific_notific_b8d115_idx`(`notification_type` ASC) USING BTREE,
  INDEX `app_notific_created_35637c_idx`(`created_at` ASC) USING BTREE,
  CONSTRAINT `app_notification_logs_task_id_60b09253_fk_app_scheduled_tasks_id` FOREIGN KEY (`task_id`) REFERENCES `app_scheduled_tasks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_packages
-- ----------------------------
DROP TABLE IF EXISTS `app_packages`;
CREATE TABLE `app_packages`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `package_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `package_name`(`package_name` ASC) USING BTREE,
  INDEX `app_packages_created_by_id_f239ed63_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `app_package_package_555fb1_idx`(`package_name` ASC) USING BTREE,
  INDEX `app_package_name_cecc0d_idx`(`name` ASC) USING BTREE,
  CONSTRAINT `app_packages_created_by_id_f239ed63_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_projects
-- ----------------------------
DROP TABLE IF EXISTS `app_projects`;
CREATE TABLE `app_projects`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NULL DEFAULT NULL,
  `end_date` date NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `owner_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `app_projects_owner_id_efef315b_fk_users_user_id`(`owner_id` ASC) USING BTREE,
  CONSTRAINT `app_projects_owner_id_efef315b_fk_users_user_id` FOREIGN KEY (`owner_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_projects_members
-- ----------------------------
DROP TABLE IF EXISTS `app_projects_members`;
CREATE TABLE `app_projects_members`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `appproject_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `app_projects_members_appproject_id_user_id_854a1b52_uniq`(`appproject_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `app_projects_members_user_id_076dad76_fk_users_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `app_projects_members_appproject_id_10d8cb8e_fk_app_projects_id` FOREIGN KEY (`appproject_id`) REFERENCES `app_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_projects_members_user_id_076dad76_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_scheduled_tasks
-- ----------------------------
DROP TABLE IF EXISTS `app_scheduled_tasks`;
CREATE TABLE `app_scheduled_tasks`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `trigger_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `interval_seconds` int NULL DEFAULT NULL,
  `execute_at` datetime(6) NULL DEFAULT NULL,
  `notify_on_success` tinyint(1) NOT NULL,
  `notify_on_failure` tinyint(1) NOT NULL,
  `notification_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notify_emails` json NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_run_time` datetime(6) NULL DEFAULT NULL,
  `next_run_time` datetime(6) NULL DEFAULT NULL,
  `total_runs` int NOT NULL,
  `successful_runs` int NOT NULL,
  `failed_runs` int NOT NULL,
  `last_result` json NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `app_package_id` bigint NULL DEFAULT NULL,
  `created_by_id` bigint NOT NULL,
  `device_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  `test_case_id` bigint NULL DEFAULT NULL,
  `test_suite_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `app_scheduled_tasks_app_package_id_915de24a_fk_app_packages_id`(`app_package_id` ASC) USING BTREE,
  INDEX `app_scheduled_tasks_created_by_id_158c0cb9_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `app_scheduled_tasks_device_id_6bfef0b6_fk_app_devices_id`(`device_id` ASC) USING BTREE,
  INDEX `app_scheduled_tasks_project_id_60710198_fk_app_projects_id`(`project_id` ASC) USING BTREE,
  INDEX `app_scheduled_tasks_test_case_id_38b6b389_fk_app_test_cases_id`(`test_case_id` ASC) USING BTREE,
  INDEX `app_scheduled_tasks_test_suite_id_0beb984e_fk_app_test_suites_id`(`test_suite_id` ASC) USING BTREE,
  CONSTRAINT `app_scheduled_tasks_app_package_id_915de24a_fk_app_packages_id` FOREIGN KEY (`app_package_id`) REFERENCES `app_packages` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_scheduled_tasks_created_by_id_158c0cb9_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_scheduled_tasks_device_id_6bfef0b6_fk_app_devices_id` FOREIGN KEY (`device_id`) REFERENCES `app_devices` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_scheduled_tasks_project_id_60710198_fk_app_projects_id` FOREIGN KEY (`project_id`) REFERENCES `app_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_scheduled_tasks_test_case_id_38b6b389_fk_app_test_cases_id` FOREIGN KEY (`test_case_id`) REFERENCES `app_test_cases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_scheduled_tasks_test_suite_id_0beb984e_fk_app_test_suites_id` FOREIGN KEY (`test_suite_id`) REFERENCES `app_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_test_cases
-- ----------------------------
DROP TABLE IF EXISTS `app_test_cases`;
CREATE TABLE `app_test_cases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ui_flow` json NOT NULL,
  `variables` json NOT NULL,
  `timeout` int NOT NULL,
  `retry_count` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `app_package_id` bigint NULL DEFAULT NULL,
  `created_by_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `app_test_cases_app_package_id_104eb635_fk_app_packages_id`(`app_package_id` ASC) USING BTREE,
  INDEX `app_test_cases_created_by_id_56e1dad3_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `app_test_cases_project_id_b7e36740_fk_app_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `app_test_cases_app_package_id_104eb635_fk_app_packages_id` FOREIGN KEY (`app_package_id`) REFERENCES `app_packages` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_test_cases_created_by_id_56e1dad3_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_test_cases_project_id_b7e36740_fk_app_projects_id` FOREIGN KEY (`project_id`) REFERENCES `app_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_test_config
-- ----------------------------
DROP TABLE IF EXISTS `app_test_config`;
CREATE TABLE `app_test_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `adb_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_test_executions
-- ----------------------------
DROP TABLE IF EXISTS `app_test_executions`;
CREATE TABLE `app_test_executions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `result` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `progress` int NOT NULL,
  `started_at` datetime(6) NULL DEFAULT NULL,
  `finished_at` datetime(6) NULL DEFAULT NULL,
  `duration` double NOT NULL,
  `report_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_steps` int NOT NULL,
  `passed_steps` int NOT NULL,
  `failed_steps` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `device_id` bigint NULL DEFAULT NULL,
  `test_case_id` bigint NULL DEFAULT NULL,
  `test_suite_id` bigint NULL DEFAULT NULL,
  `user_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `app_test_executions_device_id_e1c4ae25_fk_app_devices_id`(`device_id` ASC) USING BTREE,
  INDEX `app_test_executions_test_case_id_785a04aa_fk_app_test_cases_id`(`test_case_id` ASC) USING BTREE,
  INDEX `app_test_executions_test_suite_id_da088a1b_fk_app_test_suites_id`(`test_suite_id` ASC) USING BTREE,
  INDEX `app_test_executions_user_id_0ab50bee_fk_users_user_id`(`user_id` ASC) USING BTREE,
  INDEX `app_test_ex_status_9ca315_idx`(`status` ASC) USING BTREE,
  INDEX `app_test_ex_created_05ebca_idx`(`created_at` DESC) USING BTREE,
  CONSTRAINT `app_test_executions_device_id_e1c4ae25_fk_app_devices_id` FOREIGN KEY (`device_id`) REFERENCES `app_devices` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_test_executions_test_case_id_785a04aa_fk_app_test_cases_id` FOREIGN KEY (`test_case_id`) REFERENCES `app_test_cases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_test_executions_test_suite_id_da088a1b_fk_app_test_suites_id` FOREIGN KEY (`test_suite_id`) REFERENCES `app_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_test_executions_user_id_0ab50bee_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_test_suite_cases
-- ----------------------------
DROP TABLE IF EXISTS `app_test_suite_cases`;
CREATE TABLE `app_test_suite_cases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order` int NOT NULL,
  `test_case_id` bigint NOT NULL,
  `test_suite_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `app_test_suite_cases_test_suite_id_test_case_id_d133d73b_uniq`(`test_suite_id` ASC, `test_case_id` ASC) USING BTREE,
  INDEX `app_test_suite_cases_test_case_id_5e043730_fk_app_test_cases_id`(`test_case_id` ASC) USING BTREE,
  CONSTRAINT `app_test_suite_cases_test_case_id_5e043730_fk_app_test_cases_id` FOREIGN KEY (`test_case_id`) REFERENCES `app_test_cases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_test_suite_cases_test_suite_id_4ab6440a_fk_app_test_` FOREIGN KEY (`test_suite_id`) REFERENCES `app_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for app_test_suites
-- ----------------------------
DROP TABLE IF EXISTS `app_test_suites`;
CREATE TABLE `app_test_suites`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `execution_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `execution_result` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `passed_count` int NOT NULL,
  `failed_count` int NOT NULL,
  `last_run_at` datetime(6) NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `app_test_suites_created_by_id_67f20a59_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `app_test_suites_project_id_d6ab5615_fk_app_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `app_test_suites_created_by_id_67f20a59_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `app_test_suites_project_id_d6ab5615_fk_app_projects_id` FOREIGN KEY (`project_id`) REFERENCES `app_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for assistant_messages
-- ----------------------------
DROP TABLE IF EXISTS `assistant_messages`;
CREATE TABLE `assistant_messages`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `message_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `session_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `assistant_messages_session_id_c98830bc_fk_assistant_sessions_id`(`session_id` ASC) USING BTREE,
  CONSTRAINT `assistant_messages_session_id_c98830bc_fk_assistant_sessions_id` FOREIGN KEY (`session_id`) REFERENCES `assistant_sessions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for assistant_sessions
-- ----------------------------
DROP TABLE IF EXISTS `assistant_sessions`;
CREATE TABLE `assistant_sessions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `session_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `conversation_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `assistant_sessions_user_id_b1b9e816_fk_users_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `assistant_sessions_user_id_b1b9e816_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for auth_group
-- ----------------------------
DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE `auth_group`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for auth_group_permissions
-- ----------------------------
DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE `auth_group_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_group_permissions_group_id_permission_id_0cd325b0_uniq`(`group_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for auth_permission
-- ----------------------------
DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE `auth_permission`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_permission_content_type_id_codename_01ab375a_uniq`(`content_type_id` ASC, `codename` ASC) USING BTREE,
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 393 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for authtoken_token
-- ----------------------------
DROP TABLE IF EXISTS `authtoken_token`;
CREATE TABLE `authtoken_token`  (
  `key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created` datetime(6) NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`key`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `authtoken_token_user_id_35299eff_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for business_requirements
-- ----------------------------
DROP TABLE IF EXISTS `business_requirements`;
CREATE TABLE `business_requirements`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `requirement_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requirement_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requirement_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `module` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requirement_level` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reviewer` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `estimated_hours` int UNSIGNED NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `acceptance_criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `analysis_id` bigint NOT NULL,
  `parent_requirement_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `business_requirements_analysis_id_requirement_id_c80f8648_uniq`(`analysis_id` ASC, `requirement_id` ASC) USING BTREE,
  INDEX `business_requirement_parent_requirement_i_61a32b32_fk_business_`(`parent_requirement_id` ASC) USING BTREE,
  CONSTRAINT `business_requirement_analysis_id_fc27ee8c_fk_requireme` FOREIGN KEY (`analysis_id`) REFERENCES `requirement_analyses` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `business_requirement_parent_requirement_i_61a32b32_fk_business_` FOREIGN KEY (`parent_requirement_id`) REFERENCES `business_requirements` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `business_requirements_chk_1` CHECK (`estimated_hours` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for chat_messages
-- ----------------------------
DROP TABLE IF EXISTS `chat_messages`;
CREATE TABLE `chat_messages`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `conversation_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `message_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `session_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `chat_messages_session_id_c5afc568_fk_assistant_sessions_id`(`session_id` ASC) USING BTREE,
  CONSTRAINT `chat_messages_session_id_c5afc568_fk_assistant_sessions_id` FOREIGN KEY (`session_id`) REFERENCES `assistant_sessions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for data_factory_record
-- ----------------------------
DROP TABLE IF EXISTS `data_factory_record`;
CREATE TABLE `data_factory_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tool_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tool_category` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tool_scenario` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `input_data` json NULL,
  `output_data` json NOT NULL,
  `is_saved` tinyint(1) NOT NULL,
  `tags` json NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `data_factor_user_id_7c734a_idx`(`user_id` ASC, `created_at` DESC) USING BTREE,
  INDEX `data_factor_tool_ca_c12b1d_idx`(`tool_category` ASC) USING BTREE,
  INDEX `data_factor_tool_sc_820bde_idx`(`tool_scenario` ASC) USING BTREE,
  INDEX `data_factor_user_id_c91ac7_idx`(`user_id` ASC, `tool_category` ASC) USING BTREE,
  INDEX `data_factor_user_id_580464_idx`(`user_id` ASC, `tool_scenario` ASC) USING BTREE,
  INDEX `data_factor_user_id_454377_idx`(`user_id` ASC, `is_saved` ASC) USING BTREE,
  CONSTRAINT `data_factory_record_user_id_7217efae_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dify_configs
-- ----------------------------
DROP TABLE IF EXISTS `dify_configs`;
CREATE TABLE `dify_configs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `api_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for django_admin_log
-- ----------------------------
DROP TABLE IF EXISTS `django_admin_log`;
CREATE TABLE `django_admin_log`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `object_repr` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_flag` smallint UNSIGNED NOT NULL,
  `change_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int NULL DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `django_admin_log_content_type_id_c4bce8eb_fk_django_co`(`content_type_id` ASC) USING BTREE,
  INDEX `django_admin_log_user_id_c564eba6_fk_users_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `django_admin_log_chk_1` CHECK (`action_flag` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for django_content_type
-- ----------------------------
DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE `django_content_type`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `django_content_type_app_label_model_76bd3d3b_uniq`(`app_label` ASC, `model` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 99 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for django_migrations
-- ----------------------------
DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE `django_migrations`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 62 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for django_session
-- ----------------------------
DROP TABLE IF EXISTS `django_session`;
CREATE TABLE `django_session`  (
  `session_key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`) USING BTREE,
  INDEX `django_session_expire_date_a5c62663`(`expire_date` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for generated_test_cases
-- ----------------------------
DROP TABLE IF EXISTS `generated_test_cases`;
CREATE TABLE `generated_test_cases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `case_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `precondition` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `test_steps` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expected_result` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `generated_by_ai` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reviewed_by_ai` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `review_comments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `requirement_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `generated_test_cases_requirement_id_case_id_44afdfd2_uniq`(`requirement_id` ASC, `case_id` ASC) USING BTREE,
  CONSTRAINT `generated_test_cases_requirement_id_314ce156_fk_business_` FOREIGN KEY (`requirement_id`) REFERENCES `business_requirements` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for generation_config
-- ----------------------------
DROP TABLE IF EXISTS `generation_config`;
CREATE TABLE `generation_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `default_output_mode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `enable_auto_review` tinyint(1) NOT NULL,
  `review_timeout` int NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for locator_strategies
-- ----------------------------
DROP TABLE IF EXISTS `locator_strategies`;
CREATE TABLE `locator_strategies`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for project_environments
-- ----------------------------
DROP TABLE IF EXISTS `project_environments`;
CREATE TABLE `project_environments`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `base_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `variables` json NOT NULL,
  `is_default` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `project_environments_project_id_d68d08ff_fk_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `project_environments_project_id_d68d08ff_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for project_members
-- ----------------------------
DROP TABLE IF EXISTS `project_members`;
CREATE TABLE `project_members`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `joined_at` datetime(6) NOT NULL,
  `project_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `project_members_project_id_user_id_ab18bfcc_uniq`(`project_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `project_members_user_id_2e9d44b1_fk_users_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `project_members_project_id_bf2e42ec_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `project_members_user_id_2e9d44b1_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for projects
-- ----------------------------
DROP TABLE IF EXISTS `projects`;
CREATE TABLE `projects`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `owner_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `projects_owner_id_a6ce54bc_fk_users_user_id`(`owner_id` ASC) USING BTREE,
  CONSTRAINT `projects_owner_id_a6ce54bc_fk_users_user_id` FOREIGN KEY (`owner_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for prompt_config
-- ----------------------------
DROP TABLE IF EXISTS `prompt_config`;
CREATE TABLE `prompt_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `prompt_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `prompt_config_created_by_id_3b45d21f_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  CONSTRAINT `prompt_config_created_by_id_3b45d21f_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for report_templates
-- ----------------------------
DROP TABLE IF EXISTS `report_templates`;
CREATE TABLE `report_templates`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_config` json NOT NULL,
  `is_default` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `report_templates_created_by_id_a75b451c_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  CONSTRAINT `report_templates_created_by_id_a75b451c_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for requirement_analyses
-- ----------------------------
DROP TABLE IF EXISTS `requirement_analyses`;
CREATE TABLE `requirement_analyses`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `analysis_report` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requirements_count` int UNSIGNED NOT NULL,
  `analysis_time` double NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `document_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `document_id`(`document_id` ASC) USING BTREE,
  CONSTRAINT `requirement_analyses_document_id_bc29cd8c_fk_requireme` FOREIGN KEY (`document_id`) REFERENCES `requirement_documents` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `requirement_analyses_chk_1` CHECK (`requirements_count` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for requirement_documents
-- ----------------------------
DROP TABLE IF EXISTS `requirement_documents`;
CREATE TABLE `requirement_documents`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `file_size` int UNSIGNED NULL DEFAULT NULL,
  `extracted_text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  `uploaded_by_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `requirement_documents_project_id_ce88c910_fk_projects_id`(`project_id` ASC) USING BTREE,
  INDEX `requirement_documents_uploaded_by_id_8160b579_fk_users_user_id`(`uploaded_by_id` ASC) USING BTREE,
  CONSTRAINT `requirement_documents_project_id_ce88c910_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `requirement_documents_uploaded_by_id_8160b579_fk_users_user_id` FOREIGN KEY (`uploaded_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `requirement_documents_chk_1` CHECK (`file_size` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for review_assignments
-- ----------------------------
DROP TABLE IF EXISTS `review_assignments`;
CREATE TABLE `review_assignments`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `checklist_results` json NOT NULL,
  `reviewed_at` datetime(6) NULL DEFAULT NULL,
  `assigned_at` datetime(6) NOT NULL,
  `review_id` bigint NOT NULL,
  `reviewer_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `review_assignments_review_id_reviewer_id_58523697_uniq`(`review_id` ASC, `reviewer_id` ASC) USING BTREE,
  INDEX `review_assignments_reviewer_id_19101223_fk_users_user_id`(`reviewer_id` ASC) USING BTREE,
  CONSTRAINT `review_assignments_review_id_f987a44e_fk_testcase_reviews_id` FOREIGN KEY (`review_id`) REFERENCES `testcase_reviews` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `review_assignments_reviewer_id_19101223_fk_users_user_id` FOREIGN KEY (`reviewer_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for review_comments
-- ----------------------------
DROP TABLE IF EXISTS `review_comments`;
CREATE TABLE `review_comments`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `comment_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_number` int UNSIGNED NULL DEFAULT NULL,
  `is_resolved` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `author_id` bigint NOT NULL,
  `review_id` bigint NOT NULL,
  `testcase_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `review_comments_author_id_ee230d87_fk_users_user_id`(`author_id` ASC) USING BTREE,
  INDEX `review_comments_review_id_23d4a9aa_fk_testcase_reviews_id`(`review_id` ASC) USING BTREE,
  INDEX `review_comments_testcase_id_7a5e8ad0_fk_testcases_id`(`testcase_id` ASC) USING BTREE,
  CONSTRAINT `review_comments_author_id_ee230d87_fk_users_user_id` FOREIGN KEY (`author_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `review_comments_review_id_23d4a9aa_fk_testcase_reviews_id` FOREIGN KEY (`review_id`) REFERENCES `testcase_reviews` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `review_comments_testcase_id_7a5e8ad0_fk_testcases_id` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `review_comments_chk_1` CHECK (`step_number` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for review_templates
-- ----------------------------
DROP TABLE IF EXISTS `review_templates`;
CREATE TABLE `review_templates`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `checklist` json NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `creator_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `review_templates_creator_id_39fe0c75_fk_users_user_id`(`creator_id` ASC) USING BTREE,
  CONSTRAINT `review_templates_creator_id_39fe0c75_fk_users_user_id` FOREIGN KEY (`creator_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for review_templates_default_reviewers
-- ----------------------------
DROP TABLE IF EXISTS `review_templates_default_reviewers`;
CREATE TABLE `review_templates_default_reviewers`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `reviewtemplate_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `review_templates_default_reviewtemplate_id_user_i_83114e10_uniq`(`reviewtemplate_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `review_templates_def_user_id_f58f47dc_fk_users_use`(`user_id` ASC) USING BTREE,
  CONSTRAINT `review_templates_def_reviewtemplate_id_4fc8bdbe_fk_review_te` FOREIGN KEY (`reviewtemplate_id`) REFERENCES `review_templates` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `review_templates_def_user_id_f58f47dc_fk_users_use` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for review_templates_project
-- ----------------------------
DROP TABLE IF EXISTS `review_templates_project`;
CREATE TABLE `review_templates_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `reviewtemplate_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `review_templates_project_reviewtemplate_id_projec_e4f3f8db_uniq`(`reviewtemplate_id` ASC, `project_id` ASC) USING BTREE,
  INDEX `review_templates_project_project_id_3985e699_fk_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `review_templates_pro_reviewtemplate_id_74503277_fk_review_te` FOREIGN KEY (`reviewtemplate_id`) REFERENCES `review_templates` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `review_templates_project_project_id_3985e699_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for test_plans
-- ----------------------------
DROP TABLE IF EXISTS `test_plans`;
CREATE TABLE `test_plans`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `creator_id` bigint NOT NULL,
  `version_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `test_plans_creator_id_0b41847d_fk_users_user_id`(`creator_id` ASC) USING BTREE,
  INDEX `test_plans_version_id_5123f6e5_fk_versions_id`(`version_id` ASC) USING BTREE,
  CONSTRAINT `test_plans_creator_id_0b41847d_fk_users_user_id` FOREIGN KEY (`creator_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_plans_version_id_5123f6e5_fk_versions_id` FOREIGN KEY (`version_id`) REFERENCES `versions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for test_plans_assignees
-- ----------------------------
DROP TABLE IF EXISTS `test_plans_assignees`;
CREATE TABLE `test_plans_assignees`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `testplan_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `test_plans_assignees_testplan_id_user_id_4ff28dca_uniq`(`testplan_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `test_plans_assignees_user_id_f1246af8_fk_users_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `test_plans_assignees_testplan_id_52586d00_fk_test_plans_id` FOREIGN KEY (`testplan_id`) REFERENCES `test_plans` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_plans_assignees_user_id_f1246af8_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for test_plans_projects
-- ----------------------------
DROP TABLE IF EXISTS `test_plans_projects`;
CREATE TABLE `test_plans_projects`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `testplan_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `test_plans_projects_testplan_id_project_id_a2919c7e_uniq`(`testplan_id` ASC, `project_id` ASC) USING BTREE,
  INDEX `test_plans_projects_project_id_edf5883f_fk_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `test_plans_projects_project_id_edf5883f_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_plans_projects_testplan_id_d543fc14_fk_test_plans_id` FOREIGN KEY (`testplan_id`) REFERENCES `test_plans` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for test_reports
-- ----------------------------
DROP TABLE IF EXISTS `test_reports`;
CREATE TABLE `test_reports`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` json NOT NULL,
  `content` json NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `execution_id` bigint NULL DEFAULT NULL,
  `generated_by_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `execution_id`(`execution_id` ASC) USING BTREE,
  INDEX `test_reports_generated_by_id_5ef140b2_fk_users_user_id`(`generated_by_id` ASC) USING BTREE,
  INDEX `test_reports_project_id_499ac458_fk_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `test_reports_execution_id_ac2e448a_fk_test_runs_id` FOREIGN KEY (`execution_id`) REFERENCES `test_runs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_reports_generated_by_id_5ef140b2_fk_users_user_id` FOREIGN KEY (`generated_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_reports_project_id_499ac458_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for test_run_case_history
-- ----------------------------
DROP TABLE IF EXISTS `test_run_case_history`;
CREATE TABLE `test_run_case_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `actual_result` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `executed_at` datetime(6) NOT NULL,
  `executed_by_id` bigint NOT NULL,
  `run_case_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `test_run_case_history_executed_by_id_a6ac417c_fk_users_user_id`(`executed_by_id` ASC) USING BTREE,
  INDEX `test_run_case_history_run_case_id_4c7e4b57_fk_test_run_cases_id`(`run_case_id` ASC) USING BTREE,
  CONSTRAINT `test_run_case_history_executed_by_id_a6ac417c_fk_users_user_id` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_run_case_history_run_case_id_4c7e4b57_fk_test_run_cases_id` FOREIGN KEY (`run_case_id`) REFERENCES `test_run_cases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for test_run_cases
-- ----------------------------
DROP TABLE IF EXISTS `test_run_cases`;
CREATE TABLE `test_run_cases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `actual_result` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `defects` json NOT NULL,
  `elapsed_time` bigint NULL DEFAULT NULL,
  `executed_at` datetime(6) NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `executed_by_id` bigint NULL DEFAULT NULL,
  `test_run_id` bigint NOT NULL,
  `testcase_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `test_run_cases_test_run_id_testcase_id_50af2bb4_uniq`(`test_run_id` ASC, `testcase_id` ASC) USING BTREE,
  INDEX `test_run_cases_executed_by_id_113935f1_fk_users_user_id`(`executed_by_id` ASC) USING BTREE,
  INDEX `test_run_cases_testcase_id_0266e718_fk_testcases_id`(`testcase_id` ASC) USING BTREE,
  CONSTRAINT `test_run_cases_executed_by_id_113935f1_fk_users_user_id` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_run_cases_test_run_id_81fff9b4_fk_test_runs_id` FOREIGN KEY (`test_run_id`) REFERENCES `test_runs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_run_cases_testcase_id_0266e718_fk_testcases_id` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for test_runs
-- ----------------------------
DROP TABLE IF EXISTS `test_runs`;
CREATE TABLE `test_runs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `started_at` datetime(6) NULL DEFAULT NULL,
  `completed_at` datetime(6) NULL DEFAULT NULL,
  `due_date` datetime(6) NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `assignee_id` bigint NOT NULL,
  `creator_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  `test_plan_id` bigint NOT NULL,
  `version_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `test_runs_assignee_id_97fa9190_fk_users_user_id`(`assignee_id` ASC) USING BTREE,
  INDEX `test_runs_creator_id_5e0386f4_fk_users_user_id`(`creator_id` ASC) USING BTREE,
  INDEX `test_runs_project_id_dc61b42a_fk_projects_id`(`project_id` ASC) USING BTREE,
  INDEX `test_runs_test_plan_id_165c8672_fk_test_plans_id`(`test_plan_id` ASC) USING BTREE,
  INDEX `test_runs_version_id_556adf57_fk_versions_id`(`version_id` ASC) USING BTREE,
  CONSTRAINT `test_runs_assignee_id_97fa9190_fk_users_user_id` FOREIGN KEY (`assignee_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_runs_creator_id_5e0386f4_fk_users_user_id` FOREIGN KEY (`creator_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_runs_project_id_dc61b42a_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_runs_test_plan_id_165c8672_fk_test_plans_id` FOREIGN KEY (`test_plan_id`) REFERENCES `test_plans` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `test_runs_version_id_556adf57_fk_versions_id` FOREIGN KEY (`version_id`) REFERENCES `versions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testcase_attachments
-- ----------------------------
DROP TABLE IF EXISTS `testcase_attachments`;
CREATE TABLE `testcase_attachments`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_at` datetime(6) NOT NULL,
  `testcase_id` bigint NOT NULL,
  `uploaded_by_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `testcase_attachments_testcase_id_7aaee8b8_fk_testcases_id`(`testcase_id` ASC) USING BTREE,
  INDEX `testcase_attachments_uploaded_by_id_c44903c6_fk_users_user_id`(`uploaded_by_id` ASC) USING BTREE,
  CONSTRAINT `testcase_attachments_testcase_id_7aaee8b8_fk_testcases_id` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_attachments_uploaded_by_id_c44903c6_fk_users_user_id` FOREIGN KEY (`uploaded_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testcase_comments
-- ----------------------------
DROP TABLE IF EXISTS `testcase_comments`;
CREATE TABLE `testcase_comments`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `author_id` bigint NOT NULL,
  `testcase_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `testcase_comments_author_id_d47d17d8_fk_users_user_id`(`author_id` ASC) USING BTREE,
  INDEX `testcase_comments_testcase_id_1ad0db48_fk_testcases_id`(`testcase_id` ASC) USING BTREE,
  CONSTRAINT `testcase_comments_author_id_d47d17d8_fk_users_user_id` FOREIGN KEY (`author_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_comments_testcase_id_1ad0db48_fk_testcases_id` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testcase_generation_task
-- ----------------------------
DROP TABLE IF EXISTS `testcase_generation_task`;
CREATE TABLE `testcase_generation_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `requirement_text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `progress` int NOT NULL,
  `output_mode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `stream_buffer` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `stream_position` int NOT NULL,
  `last_stream_update` datetime(6) NULL DEFAULT NULL,
  `generated_test_cases` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `review_feedback` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `final_test_cases` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `generation_log` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `completed_at` datetime(6) NULL DEFAULT NULL,
  `is_saved_to_records` tinyint(1) NOT NULL,
  `saved_at` datetime(6) NULL DEFAULT NULL,
  `created_by_id` bigint NOT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  `reviewer_model_config_id` bigint NULL DEFAULT NULL,
  `reviewer_prompt_config_id` bigint NULL DEFAULT NULL,
  `writer_model_config_id` bigint NULL DEFAULT NULL,
  `writer_prompt_config_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `task_id`(`task_id` ASC) USING BTREE,
  INDEX `testcase_generation_task_created_by_id_477439c8_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `testcase_generation_task_project_id_7ccee820_fk_projects_id`(`project_id` ASC) USING BTREE,
  INDEX `testcase_generation__reviewer_model_confi_d6577dcc_fk_ai_model_`(`reviewer_model_config_id` ASC) USING BTREE,
  INDEX `testcase_generation__reviewer_prompt_conf_d1aaacdb_fk_prompt_co`(`reviewer_prompt_config_id` ASC) USING BTREE,
  INDEX `testcase_generation__writer_model_config__c5113766_fk_ai_model_`(`writer_model_config_id` ASC) USING BTREE,
  INDEX `testcase_generation__writer_prompt_config_ffaa03ea_fk_prompt_co`(`writer_prompt_config_id` ASC) USING BTREE,
  CONSTRAINT `testcase_generation__reviewer_model_confi_d6577dcc_fk_ai_model_` FOREIGN KEY (`reviewer_model_config_id`) REFERENCES `ai_model_config` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_generation__reviewer_prompt_conf_d1aaacdb_fk_prompt_co` FOREIGN KEY (`reviewer_prompt_config_id`) REFERENCES `prompt_config` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_generation__writer_model_config__c5113766_fk_ai_model_` FOREIGN KEY (`writer_model_config_id`) REFERENCES `ai_model_config` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_generation__writer_prompt_config_ffaa03ea_fk_prompt_co` FOREIGN KEY (`writer_prompt_config_id`) REFERENCES `prompt_config` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_generation_task_created_by_id_477439c8_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_generation_task_project_id_7ccee820_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testcase_reviews
-- ----------------------------
DROP TABLE IF EXISTS `testcase_reviews`;
CREATE TABLE `testcase_reviews`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `deadline` datetime(6) NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `completed_at` datetime(6) NULL DEFAULT NULL,
  `creator_id` bigint NOT NULL,
  `template_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `testcase_reviews_creator_id_aa3a15c6_fk_users_user_id`(`creator_id` ASC) USING BTREE,
  INDEX `testcase_reviews_template_id_9603ee51_fk_review_templates_id`(`template_id` ASC) USING BTREE,
  CONSTRAINT `testcase_reviews_creator_id_aa3a15c6_fk_users_user_id` FOREIGN KEY (`creator_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_reviews_template_id_9603ee51_fk_review_templates_id` FOREIGN KEY (`template_id`) REFERENCES `review_templates` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testcase_reviews_projects
-- ----------------------------
DROP TABLE IF EXISTS `testcase_reviews_projects`;
CREATE TABLE `testcase_reviews_projects`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `testcasereview_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `testcase_reviews_project_testcasereview_id_projec_d12c486f_uniq`(`testcasereview_id` ASC, `project_id` ASC) USING BTREE,
  INDEX `testcase_reviews_projects_project_id_8d169b8a_fk_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `testcase_reviews_pro_testcasereview_id_684d7c0b_fk_testcase_` FOREIGN KEY (`testcasereview_id`) REFERENCES `testcase_reviews` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_reviews_projects_project_id_8d169b8a_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testcase_reviews_testcases
-- ----------------------------
DROP TABLE IF EXISTS `testcase_reviews_testcases`;
CREATE TABLE `testcase_reviews_testcases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `testcasereview_id` bigint NOT NULL,
  `testcase_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `testcase_reviews_testcas_testcasereview_id_testca_7100ae89_uniq`(`testcasereview_id` ASC, `testcase_id` ASC) USING BTREE,
  INDEX `testcase_reviews_testcases_testcase_id_760893f4_fk_testcases_id`(`testcase_id` ASC) USING BTREE,
  CONSTRAINT `testcase_reviews_tes_testcasereview_id_a7eb2102_fk_testcase_` FOREIGN KEY (`testcasereview_id`) REFERENCES `testcase_reviews` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_reviews_testcases_testcase_id_760893f4_fk_testcases_id` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testcase_steps
-- ----------------------------
DROP TABLE IF EXISTS `testcase_steps`;
CREATE TABLE `testcase_steps`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `step_number` int UNSIGNED NOT NULL,
  `action` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expected` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `testcase_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `testcase_steps_testcase_id_step_number_2a8f492f_uniq`(`testcase_id` ASC, `step_number` ASC) USING BTREE,
  CONSTRAINT `testcase_steps_testcase_id_03e3bf23_fk_testcases_id` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcase_steps_chk_1` CHECK (`step_number` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testcases
-- ----------------------------
DROP TABLE IF EXISTS `testcases`;
CREATE TABLE `testcases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `preconditions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `steps` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expected_result` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `test_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tags` json NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `assignee_id` bigint NULL DEFAULT NULL,
  `author_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `testcases_assignee_id_0eba9dac_fk_users_user_id`(`assignee_id` ASC) USING BTREE,
  INDEX `testcases_author_id_6feeebaa_fk_users_user_id`(`author_id` ASC) USING BTREE,
  INDEX `testcases_project_id_e201e15a_fk_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `testcases_assignee_id_0eba9dac_fk_users_user_id` FOREIGN KEY (`assignee_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcases_author_id_6feeebaa_fk_users_user_id` FOREIGN KEY (`author_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcases_project_id_e201e15a_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 76 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testcases_versions
-- ----------------------------
DROP TABLE IF EXISTS `testcases_versions`;
CREATE TABLE `testcases_versions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `testcase_id` bigint NOT NULL,
  `version_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `testcases_versions_testcase_id_version_id_6e878ca3_uniq`(`testcase_id` ASC, `version_id` ASC) USING BTREE,
  INDEX `testcases_versions_version_id_60eb189c_fk_versions_id`(`version_id` ASC) USING BTREE,
  CONSTRAINT `testcases_versions_testcase_id_91daa3a1_fk_testcases_id` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testcases_versions_version_id_60eb189c_fk_versions_id` FOREIGN KEY (`version_id`) REFERENCES `versions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testsuite_cases
-- ----------------------------
DROP TABLE IF EXISTS `testsuite_cases`;
CREATE TABLE `testsuite_cases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order` int UNSIGNED NOT NULL,
  `testcase_id` bigint NOT NULL,
  `testsuite_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `testsuite_cases_testsuite_id_testcase_id_f8e7a958_uniq`(`testsuite_id` ASC, `testcase_id` ASC) USING BTREE,
  INDEX `testsuite_cases_testcase_id_77586494_fk_testcases_id`(`testcase_id` ASC) USING BTREE,
  CONSTRAINT `testsuite_cases_testcase_id_77586494_fk_testcases_id` FOREIGN KEY (`testcase_id`) REFERENCES `testcases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testsuite_cases_testsuite_id_7c989690_fk_testsuites_id` FOREIGN KEY (`testsuite_id`) REFERENCES `testsuites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testsuite_cases_chk_1` CHECK (`order` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for testsuites
-- ----------------------------
DROP TABLE IF EXISTS `testsuites`;
CREATE TABLE `testsuites`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `author_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `testsuites_author_id_004d6e7d_fk_users_user_id`(`author_id` ASC) USING BTREE,
  INDEX `testsuites_project_id_e6d73db7_fk_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `testsuites_author_id_004d6e7d_fk_users_user_id` FOREIGN KEY (`author_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `testsuites_project_id_e6d73db7_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for token_blacklist_blacklistedtoken
-- ----------------------------
DROP TABLE IF EXISTS `token_blacklist_blacklistedtoken`;
CREATE TABLE `token_blacklist_blacklistedtoken`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `blacklisted_at` datetime(6) NOT NULL,
  `token_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `token_id`(`token_id` ASC) USING BTREE,
  CONSTRAINT `token_blacklist_blacklistedtoken_token_id_3cc7fe56_fk` FOREIGN KEY (`token_id`) REFERENCES `token_blacklist_outstandingtoken` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for token_blacklist_outstandingtoken
-- ----------------------------
DROP TABLE IF EXISTS `token_blacklist_outstandingtoken`;
CREATE TABLE `token_blacklist_outstandingtoken`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `token` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NULL DEFAULT NULL,
  `expires_at` datetime(6) NOT NULL,
  `user_id` bigint NULL DEFAULT NULL,
  `jti` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `token_blacklist_outstandingtoken_jti_hex_d9bdf6f7_uniq`(`jti` ASC) USING BTREE,
  INDEX `token_blacklist_outs_user_id_83bc629a_fk_users_use`(`user_id` ASC) USING BTREE,
  CONSTRAINT `token_blacklist_outs_user_id_83bc629a_fk_users_use` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_ai_cases
-- ----------------------------
DROP TABLE IF EXISTS `ui_ai_cases`;
CREATE TABLE `ui_ai_cases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `task_description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_ai_cases_created_by_id_42270acd_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `ui_ai_cases_project_id_6038a0be_fk_ui_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `ui_ai_cases_created_by_id_42270acd_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_ai_cases_project_id_6038a0be_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_ai_execution_records
-- ----------------------------
DROP TABLE IF EXISTS `ui_ai_execution_records`;
CREATE TABLE `ui_ai_execution_records`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `case_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `execution_mode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` datetime(6) NOT NULL,
  `end_time` datetime(6) NULL DEFAULT NULL,
  `duration` double NULL DEFAULT NULL,
  `logs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `steps_completed` json NOT NULL,
  `planned_tasks` json NOT NULL,
  `gif_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `screenshots_sequence` json NOT NULL,
  `ai_case_id` bigint NULL DEFAULT NULL,
  `executed_by_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_ai_execution_records_ai_case_id_8018500d_fk_ui_ai_cases_id`(`ai_case_id` ASC) USING BTREE,
  INDEX `ui_ai_execution_records_executed_by_id_1d12e50c_fk_users_user_id`(`executed_by_id` ASC) USING BTREE,
  INDEX `ui_ai_execution_records_project_id_eb10bc6e_fk_ui_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `ui_ai_execution_records_ai_case_id_8018500d_fk_ui_ai_cases_id` FOREIGN KEY (`ai_case_id`) REFERENCES `ui_ai_cases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_ai_execution_records_executed_by_id_1d12e50c_fk_users_user_id` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_ai_execution_records_project_id_eb10bc6e_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_element_groups
-- ----------------------------
DROP TABLE IF EXISTS `ui_element_groups`;
CREATE TABLE `ui_element_groups`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `order` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `parent_group_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_element_groups_parent_group_id_a134b235_fk_ui_elemen`(`parent_group_id` ASC) USING BTREE,
  INDEX `ui_element_groups_project_id_5d069352_fk_ui_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `ui_element_groups_parent_group_id_a134b235_fk_ui_elemen` FOREIGN KEY (`parent_group_id`) REFERENCES `ui_element_groups` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_element_groups_project_id_5d069352_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_elements
-- ----------------------------
DROP TABLE IF EXISTS `ui_elements`;
CREATE TABLE `ui_elements`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `element_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `locator_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `backup_locators` json NULL,
  `page` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `component_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_unique` tinyint(1) NOT NULL,
  `wait_timeout` int NOT NULL,
  `is_visible` tinyint(1) NOT NULL,
  `is_enabled` tinyint(1) NOT NULL,
  `force_action` tinyint(1) NOT NULL,
  `usage_count` int NOT NULL,
  `last_validated` datetime(6) NULL DEFAULT NULL,
  `validation_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `validation_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NULL DEFAULT NULL,
  `group_id` bigint NULL DEFAULT NULL,
  `locator_strategy_id` bigint NOT NULL,
  `parent_element_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_elements_created_by_id_02be5cc3_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `ui_elements_group_id_4591e5a2_fk_ui_element_groups_id`(`group_id` ASC) USING BTREE,
  INDEX `ui_elements_locator_strategy_id_3133967e_fk_locator_s`(`locator_strategy_id` ASC) USING BTREE,
  INDEX `ui_elements_parent_element_id_897d5856_fk_ui_elements_id`(`parent_element_id` ASC) USING BTREE,
  INDEX `ui_elements_project_26e1bb_idx`(`project_id` ASC, `page` ASC) USING BTREE,
  INDEX `ui_elements_project_1fb22d_idx`(`project_id` ASC, `element_type` ASC) USING BTREE,
  INDEX `ui_elements_validat_479f58_idx`(`validation_status` ASC) USING BTREE,
  CONSTRAINT `ui_elements_created_by_id_02be5cc3_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_elements_group_id_4591e5a2_fk_ui_element_groups_id` FOREIGN KEY (`group_id`) REFERENCES `ui_element_groups` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_elements_locator_strategy_id_3133967e_fk_locator_s` FOREIGN KEY (`locator_strategy_id`) REFERENCES `locator_strategies` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_elements_parent_element_id_897d5856_fk_ui_elements_id` FOREIGN KEY (`parent_element_id`) REFERENCES `ui_elements` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_elements_project_id_0f213de0_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_notification_logs
-- ----------------------------
DROP TABLE IF EXISTS `ui_notification_logs`;
CREATE TABLE `ui_notification_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `notification_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_email` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_info` json NOT NULL,
  `webhook_bot_info` json NULL,
  `notification_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `response_info` json NULL,
  `created_at` datetime(6) NOT NULL,
  `sent_at` datetime(6) NULL DEFAULT NULL,
  `retry_count` int NOT NULL,
  `is_retried` tinyint(1) NOT NULL,
  `task_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_notification_logs_task_id_cca23a45_fk_ui_scheduled_tasks_id`(`task_id` ASC) USING BTREE,
  INDEX `ui_notifica_status_2f9a84_idx`(`status` ASC) USING BTREE,
  INDEX `ui_notifica_notific_8889ee_idx`(`notification_type` ASC) USING BTREE,
  INDEX `ui_notifica_created_6577cc_idx`(`created_at` ASC) USING BTREE,
  CONSTRAINT `ui_notification_logs_task_id_cca23a45_fk_ui_scheduled_tasks_id` FOREIGN KEY (`task_id`) REFERENCES `ui_scheduled_tasks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_operation_record
-- ----------------------------
DROP TABLE IF EXISTS `ui_operation_record`;
CREATE TABLE `ui_operation_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `operation_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `resource_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `resource_id` int NOT NULL,
  `resource_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_operatio_created_735396_idx`(`created_at` DESC) USING BTREE,
  INDEX `ui_operatio_resourc_cb1b52_idx`(`resource_type` ASC, `resource_id` ASC) USING BTREE,
  INDEX `ui_operatio_user_id_1217fc_idx`(`user_id` ASC, `created_at` DESC) USING BTREE,
  CONSTRAINT `ui_operation_record_user_id_30c2bdd8_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_page_object_elements
-- ----------------------------
DROP TABLE IF EXISTS `ui_page_object_elements`;
CREATE TABLE `ui_page_object_elements`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `method_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_property` tinyint(1) NOT NULL,
  `order` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `element_id` bigint NOT NULL,
  `page_object_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ui_page_object_elements_page_object_id_method_name_01b35ff4_uniq`(`page_object_id` ASC, `method_name` ASC) USING BTREE,
  INDEX `ui_page_object_elements_element_id_74147df3_fk_ui_elements_id`(`element_id` ASC) USING BTREE,
  CONSTRAINT `ui_page_object_eleme_page_object_id_2c7205b0_fk_ui_page_o` FOREIGN KEY (`page_object_id`) REFERENCES `ui_page_objects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_page_object_elements_element_id_74147df3_fk_ui_elements_id` FOREIGN KEY (`element_id`) REFERENCES `ui_elements` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_page_objects
-- ----------------------------
DROP TABLE IF EXISTS `ui_page_objects`;
CREATE TABLE `ui_page_objects`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `class_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `url_pattern` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_code` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ui_page_objects_project_id_name_f0081948_uniq`(`project_id` ASC, `name` ASC) USING BTREE,
  INDEX `ui_page_objects_created_by_id_1f51382d_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  CONSTRAINT `ui_page_objects_created_by_id_1f51382d_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_page_objects_project_id_cc5d1b52_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_projects
-- ----------------------------
DROP TABLE IF EXISTS `ui_projects`;
CREATE TABLE `ui_projects`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `base_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NULL DEFAULT NULL,
  `end_date` date NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `owner_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_projects_owner_id_6af1b220_fk_users_user_id`(`owner_id` ASC) USING BTREE,
  CONSTRAINT `ui_projects_owner_id_6af1b220_fk_users_user_id` FOREIGN KEY (`owner_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_projects_members
-- ----------------------------
DROP TABLE IF EXISTS `ui_projects_members`;
CREATE TABLE `ui_projects_members`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `uiproject_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ui_projects_members_uiproject_id_user_id_d4633cbd_uniq`(`uiproject_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `ui_projects_members_user_id_11d775ee_fk_users_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `ui_projects_members_uiproject_id_a1e7d6ea_fk_ui_projects_id` FOREIGN KEY (`uiproject_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_projects_members_user_id_11d775ee_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_scheduled_tasks
-- ----------------------------
DROP TABLE IF EXISTS `ui_scheduled_tasks`;
CREATE TABLE `ui_scheduled_tasks`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `trigger_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `interval_seconds` int NULL DEFAULT NULL,
  `execute_at` datetime(6) NULL DEFAULT NULL,
  `test_cases` json NOT NULL,
  `engine` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `headless` tinyint(1) NOT NULL,
  `notify_on_success` tinyint(1) NOT NULL,
  `notify_on_failure` tinyint(1) NOT NULL,
  `notification_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notify_emails` json NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_run_time` datetime(6) NULL DEFAULT NULL,
  `next_run_time` datetime(6) NULL DEFAULT NULL,
  `total_runs` int NOT NULL,
  `successful_runs` int NOT NULL,
  `failed_runs` int NOT NULL,
  `last_result` json NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  `test_suite_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_scheduled_tasks_created_by_id_933e56fd_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `ui_scheduled_tasks_project_id_55a2e2b4_fk_ui_projects_id`(`project_id` ASC) USING BTREE,
  INDEX `ui_scheduled_tasks_test_suite_id_5c7b6557_fk_ui_test_suites_id`(`test_suite_id` ASC) USING BTREE,
  CONSTRAINT `ui_scheduled_tasks_created_by_id_933e56fd_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_scheduled_tasks_project_id_55a2e2b4_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_scheduled_tasks_test_suite_id_5c7b6557_fk_ui_test_suites_id` FOREIGN KEY (`test_suite_id`) REFERENCES `ui_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_screenshots
-- ----------------------------
DROP TABLE IF EXISTS `ui_screenshots`;
CREATE TABLE `ui_screenshots`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `image` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `captured_at` datetime(6) NOT NULL,
  `execution_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_screenshots_execution_id_effb465b_fk_ui_test_executions_id`(`execution_id` ASC) USING BTREE,
  CONSTRAINT `ui_screenshots_execution_id_effb465b_fk_ui_test_executions_id` FOREIGN KEY (`execution_id`) REFERENCES `ui_test_executions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_script_element_usages
-- ----------------------------
DROP TABLE IF EXISTS `ui_script_element_usages`;
CREATE TABLE `ui_script_element_usages`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `usage_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `line_number` int NOT NULL,
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `frequency` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `element_id` bigint NOT NULL,
  `script_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ui_script_element_usages_script_id_element_id_lin_ec3e3397_uniq`(`script_id` ASC, `element_id` ASC, `line_number` ASC) USING BTREE,
  INDEX `ui_script_element_usages_element_id_db726848_fk_ui_elements_id`(`element_id` ASC) USING BTREE,
  CONSTRAINT `ui_script_element_us_script_id_79c43115_fk_ui_test_s` FOREIGN KEY (`script_id`) REFERENCES `ui_test_scripts` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_script_element_usages_element_id_db726848_fk_ui_elements_id` FOREIGN KEY (`element_id`) REFERENCES `ui_elements` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_script_steps
-- ----------------------------
DROP TABLE IF EXISTS `ui_script_steps`;
CREATE TABLE `ui_script_steps`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `step_order` int NOT NULL,
  `action_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_params` json NULL,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expected_result` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `wait_before` int NOT NULL,
  `wait_after` int NOT NULL,
  `retry_count` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `page_object_id` bigint NULL DEFAULT NULL,
  `script_id` bigint NOT NULL,
  `target_element_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ui_script_steps_script_id_step_order_b5e46118_uniq`(`script_id` ASC, `step_order` ASC) USING BTREE,
  INDEX `ui_script_steps_page_object_id_be875456_fk_ui_page_objects_id`(`page_object_id` ASC) USING BTREE,
  INDEX `ui_script_steps_target_element_id_b43f50d7_fk_ui_elements_id`(`target_element_id` ASC) USING BTREE,
  CONSTRAINT `ui_script_steps_page_object_id_be875456_fk_ui_page_objects_id` FOREIGN KEY (`page_object_id`) REFERENCES `ui_page_objects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_script_steps_script_id_026a853d_fk_ui_test_scripts_id` FOREIGN KEY (`script_id`) REFERENCES `ui_test_scripts` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_script_steps_target_element_id_b43f50d7_fk_ui_elements_id` FOREIGN KEY (`target_element_id`) REFERENCES `ui_elements` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_task_notification_settings
-- ----------------------------
DROP TABLE IF EXISTS `ui_task_notification_settings`;
CREATE TABLE `ui_task_notification_settings`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `notification_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_enabled` tinyint(1) NOT NULL,
  `notify_on_success` tinyint(1) NOT NULL,
  `notify_on_failure` tinyint(1) NOT NULL,
  `notify_on_timeout` tinyint(1) NOT NULL,
  `notify_on_error` tinyint(1) NOT NULL,
  `custom_webhook_bots` json NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `notification_config_id` bigint NULL DEFAULT NULL,
  `task_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ui_task_notification_settings_task_id_cdffe2dc_uniq`(`task_id` ASC) USING BTREE,
  INDEX `ui_task_notification_notification_config__4cf96ba5_fk_unified_n`(`notification_config_id` ASC) USING BTREE,
  CONSTRAINT `ui_task_notification_notification_config__4cf96ba5_fk_unified_n` FOREIGN KEY (`notification_config_id`) REFERENCES `unified_notification_configs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_task_notification_task_id_cdffe2dc_fk_ui_schedu` FOREIGN KEY (`task_id`) REFERENCES `ui_scheduled_tasks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_task_notification_settings_custom_recipients
-- ----------------------------
DROP TABLE IF EXISTS `ui_task_notification_settings_custom_recipients`;
CREATE TABLE `ui_task_notification_settings_custom_recipients`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `uitasknotificationsetting_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ui_task_notification_set_uitasknotificationsettin_e56732f8_uniq`(`uitasknotificationsetting_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `ui_task_notification_user_id_88e1f0f0_fk_users_use`(`user_id` ASC) USING BTREE,
  CONSTRAINT `ui_task_notification_uitasknotificationse_e6226d67_fk_ui_task_n` FOREIGN KEY (`uitasknotificationsetting_id`) REFERENCES `ui_task_notification_settings` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_task_notification_user_id_88e1f0f0_fk_users_use` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_test_case_executions
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_case_executions`;
CREATE TABLE `ui_test_case_executions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `execution_source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `engine` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `headless` tinyint(1) NOT NULL,
  `execution_logs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `screenshots` json NOT NULL,
  `execution_time` double NULL DEFAULT NULL,
  `started_at` datetime(6) NULL DEFAULT NULL,
  `finished_at` datetime(6) NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  `test_case_id` bigint NOT NULL,
  `test_suite_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_test_case_executions_created_by_id_bc347021_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `ui_test_case_executions_project_id_fb080a47_fk_ui_projects_id`(`project_id` ASC) USING BTREE,
  INDEX `ui_test_case_executi_test_case_id_c10f9551_fk_ui_test_c`(`test_case_id` ASC) USING BTREE,
  INDEX `ui_test_case_executi_test_suite_id_4027873e_fk_ui_test_s`(`test_suite_id` ASC) USING BTREE,
  CONSTRAINT `ui_test_case_executi_test_case_id_c10f9551_fk_ui_test_c` FOREIGN KEY (`test_case_id`) REFERENCES `ui_test_cases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_case_executi_test_suite_id_4027873e_fk_ui_test_s` FOREIGN KEY (`test_suite_id`) REFERENCES `ui_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_case_executions_created_by_id_bc347021_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_case_executions_project_id_fb080a47_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_test_case_steps
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_case_steps`;
CREATE TABLE `ui_test_case_steps`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `step_number` int NOT NULL,
  `action_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `input_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `wait_time` int NOT NULL,
  `assert_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `assert_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `element_id` bigint NULL DEFAULT NULL,
  `test_case_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ui_test_case_steps_test_case_id_step_number_c1be50c4_uniq`(`test_case_id` ASC, `step_number` ASC) USING BTREE,
  INDEX `ui_test_case_steps_element_id_4da11f6d_fk_ui_elements_id`(`element_id` ASC) USING BTREE,
  CONSTRAINT `ui_test_case_steps_element_id_4da11f6d_fk_ui_elements_id` FOREIGN KEY (`element_id`) REFERENCES `ui_elements` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_case_steps_test_case_id_690c69f2_fk_ui_test_cases_id` FOREIGN KEY (`test_case_id`) REFERENCES `ui_test_cases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_test_cases
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_cases`;
CREATE TABLE `ui_test_cases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_test_cases_created_by_id_c947f274_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  INDEX `ui_test_cases_project_id_b5eec585_fk_ui_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `ui_test_cases_created_by_id_c947f274_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_cases_project_id_b5eec585_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_test_environments
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_environments`;
CREATE TABLE `ui_test_environments`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `browser_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `browser_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `resolution` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `os_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `os_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `capabilities` json NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_test_executions
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_executions`;
CREATE TABLE `ui_test_executions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `environment` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_cases` int NOT NULL,
  `passed_cases` int NOT NULL,
  `failed_cases` int NOT NULL,
  `skipped_cases` int NOT NULL,
  `started_at` datetime(6) NULL DEFAULT NULL,
  `finished_at` datetime(6) NULL DEFAULT NULL,
  `duration` double NOT NULL,
  `engine` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `headless` tinyint(1) NOT NULL,
  `result_data` json NULL,
  `error_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `executed_by_id` bigint NULL DEFAULT NULL,
  `project_id` bigint NOT NULL,
  `test_script_id` bigint NULL DEFAULT NULL,
  `test_suite_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_test_executions_executed_by_id_6c96f503_fk_users_user_id`(`executed_by_id` ASC) USING BTREE,
  INDEX `ui_test_executions_project_id_618469e9_fk_ui_projects_id`(`project_id` ASC) USING BTREE,
  INDEX `ui_test_executions_test_script_id_3a01eeeb_fk_ui_test_scripts_id`(`test_script_id` ASC) USING BTREE,
  INDEX `ui_test_executions_test_suite_id_ab94e7e2_fk_ui_test_suites_id`(`test_suite_id` ASC) USING BTREE,
  CONSTRAINT `ui_test_executions_executed_by_id_6c96f503_fk_users_user_id` FOREIGN KEY (`executed_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_executions_project_id_618469e9_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_executions_test_script_id_3a01eeeb_fk_ui_test_scripts_id` FOREIGN KEY (`test_script_id`) REFERENCES `ui_test_scripts` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_executions_test_suite_id_ab94e7e2_fk_ui_test_suites_id` FOREIGN KEY (`test_suite_id`) REFERENCES `ui_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_test_scripts
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_scripts`;
CREATE TABLE `ui_test_scripts`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `script_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `language` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `framework` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_test_scripts_project_id_119dc165_fk_ui_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `ui_test_scripts_project_id_119dc165_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_test_suite_scripts
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_suite_scripts`;
CREATE TABLE `ui_test_suite_scripts`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order` int NOT NULL,
  `test_script_id` bigint NOT NULL,
  `test_suite_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_test_suite_script_test_script_id_1b3ca49b_fk_ui_test_s`(`test_script_id` ASC) USING BTREE,
  INDEX `ui_test_suite_script_test_suite_id_ff9f16d3_fk_ui_test_s`(`test_suite_id` ASC) USING BTREE,
  CONSTRAINT `ui_test_suite_script_test_script_id_1b3ca49b_fk_ui_test_s` FOREIGN KEY (`test_script_id`) REFERENCES `ui_test_scripts` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_suite_script_test_suite_id_ff9f16d3_fk_ui_test_s` FOREIGN KEY (`test_suite_id`) REFERENCES `ui_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_test_suite_test_cases
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_suite_test_cases`;
CREATE TABLE `ui_test_suite_test_cases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order` int NOT NULL,
  `test_case_id` bigint NOT NULL,
  `test_suite_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ui_test_suite_test_cases_test_suite_id_test_case__5b85d915_uniq`(`test_suite_id` ASC, `test_case_id` ASC) USING BTREE,
  INDEX `ui_test_suite_test_c_test_case_id_9c19017d_fk_ui_test_c`(`test_case_id` ASC) USING BTREE,
  CONSTRAINT `ui_test_suite_test_c_test_case_id_9c19017d_fk_ui_test_c` FOREIGN KEY (`test_case_id`) REFERENCES `ui_test_cases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ui_test_suite_test_c_test_suite_id_d0de8c20_fk_ui_test_s` FOREIGN KEY (`test_suite_id`) REFERENCES `ui_test_suites` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ui_test_suites
-- ----------------------------
DROP TABLE IF EXISTS `ui_test_suites`;
CREATE TABLE `ui_test_suites`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `execution_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `passed_count` int NOT NULL,
  `failed_count` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ui_test_suites_project_id_da89ed98_fk_ui_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `ui_test_suites_project_id_da89ed98_fk_ui_projects_id` FOREIGN KEY (`project_id`) REFERENCES `ui_projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for unified_notification_configs
-- ----------------------------
DROP TABLE IF EXISTS `unified_notification_configs`;
CREATE TABLE `unified_notification_configs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `config_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `webhook_bots` json NULL,
  `is_default` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `unified_not_config__ff7bfc_idx`(`config_type` ASC) USING BTREE,
  INDEX `unified_not_is_defa_2f6e9a_idx`(`is_default` ASC) USING BTREE,
  INDEX `unified_not_is_acti_5d6fa0_idx`(`is_active` ASC) USING BTREE,
  INDEX `unified_not_created_a454b7_idx`(`created_by_id` ASC) USING BTREE,
  CONSTRAINT `unified_notification_created_by_id_24879741_fk_users_use` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_profiles
-- ----------------------------
DROP TABLE IF EXISTS `user_profiles`;
CREATE TABLE `user_profiles`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `theme` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `language` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `timezone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notifications` json NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `user_profiles_user_id_8c5ab5fe_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for users_user
-- ----------------------------
DROP TABLE IF EXISTS `users_user`;
CREATE TABLE `users_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login` datetime(6) NULL DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `position` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for users_user_groups
-- ----------------------------
DROP TABLE IF EXISTS `users_user_groups`;
CREATE TABLE `users_user_groups`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `users_user_groups_user_id_group_id_b88eab82_uniq`(`user_id` ASC, `group_id` ASC) USING BTREE,
  INDEX `users_user_groups_group_id_9afc8d0e_fk_auth_group_id`(`group_id` ASC) USING BTREE,
  CONSTRAINT `users_user_groups_group_id_9afc8d0e_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `users_user_groups_user_id_5f6f5a90_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for users_user_user_permissions
-- ----------------------------
DROP TABLE IF EXISTS `users_user_user_permissions`;
CREATE TABLE `users_user_user_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `users_user_user_permissions_user_id_permission_id_43338c45_uniq`(`user_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `users_user_user_perm_permission_id_0b93982e_fk_auth_perm`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `users_user_user_perm_permission_id_0b93982e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `users_user_user_permissions_user_id_20aca447_fk_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for versions
-- ----------------------------
DROP TABLE IF EXISTS `versions`;
CREATE TABLE `versions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_baseline` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `versions_created_by_id_e920cbae_fk_users_user_id`(`created_by_id` ASC) USING BTREE,
  CONSTRAINT `versions_created_by_id_e920cbae_fk_users_user_id` FOREIGN KEY (`created_by_id`) REFERENCES `users_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for versions_projects
-- ----------------------------
DROP TABLE IF EXISTS `versions_projects`;
CREATE TABLE `versions_projects`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `version_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `versions_projects_version_id_project_id_99ad7525_uniq`(`version_id` ASC, `project_id` ASC) USING BTREE,
  INDEX `versions_projects_project_id_d8209c18_fk_projects_id`(`project_id` ASC) USING BTREE,
  CONSTRAINT `versions_projects_project_id_d8209c18_fk_projects_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `versions_projects_version_id_1b7ea744_fk_versions_id` FOREIGN KEY (`version_id`) REFERENCES `versions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
