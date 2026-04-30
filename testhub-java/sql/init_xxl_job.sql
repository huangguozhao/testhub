-- =========================================
-- XXL-JOB 数据库表结构
-- XXL-JOB v2.4.0
-- 官方 SQL 来源: https://github.com/xuxueli/xxl-job
-- =========================================

CREATE DATABASE IF NOT EXISTS xxl_job DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE xxl_job;

-- ----------------------------
-- Table structure: xxl_job_info
-- ----------------------------
CREATE TABLE `xxl_job_info` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `job_group` BIGINT NOT NULL COMMENT '执行器主键ID',
  `job_desc` VARCHAR(255) NOT NULL COMMENT '任务描述',
  `add_time` DATETIME DEFAULT NULL COMMENT '创建时间',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  `author` VARCHAR(64) DEFAULT NULL COMMENT '作者',
  `alarm_email` VARCHAR(255) DEFAULT NULL COMMENT '报警邮件',
  `schedule_type` VARCHAR(50) NOT NULL DEFAULT 'NONE' COMMENT '调度类型',
  `schedule_conf` VARCHAR(255) DEFAULT NULL COMMENT '调度配置',
  `misfire_strategy` VARCHAR(50) NOT NULL DEFAULT 'DO_NOTHING' COMMENT '调度失效策略',
  `executor_route_strategy` VARCHAR(100) DEFAULT NULL COMMENT '执行器路由策略',
  `executor_handler` VARCHAR(255) DEFAULT NULL COMMENT '执行器handler',
  `executor_param` VARCHAR(512) DEFAULT NULL COMMENT '执行器参数',
  `executor_block_strategy` VARCHAR(50) DEFAULT NULL COMMENT '阻塞处理策略',
  `executor_timeout` INT NOT NULL DEFAULT '0' COMMENT '执行器超时时间',
  `executor_fail_retry_count` INT NOT NULL DEFAULT '0' COMMENT '失败重试次数',
  `glue_type` VARCHAR(50) NOT NULL COMMENT 'GLUE类型',
  `glue_source` MEDIUMTEXT COMMENT 'GLUE源代码',
  `glue_remark` VARCHAR(128) DEFAULT NULL COMMENT 'GLUE备注',
  `glue_updatetime` DATETIME DEFAULT NULL COMMENT 'GLUE更新时间',
  `child_jobid` VARCHAR(255) DEFAULT NULL COMMENT '子任务ID',
  `trigger_status` TINYINT NOT NULL DEFAULT '0' COMMENT '调度状态',
  `trigger_last_time` BIGINT NOT NULL DEFAULT '0' COMMENT '上次调度时间',
  `trigger_next_time` BIGINT NOT NULL DEFAULT '0' COMMENT '下次调度时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务信息表';

-- ----------------------------
-- Table structure: xxl_job_log
-- ----------------------------
CREATE TABLE `xxl_job_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `job_group` BIGINT NOT NULL COMMENT '执行器主键ID',
  `job_id` BIGINT NOT NULL COMMENT '任务ID',
  `executor_address` VARCHAR(255) DEFAULT NULL COMMENT '执行器地址',
  `executor_handler` VARCHAR(255) DEFAULT NULL COMMENT '执行器handler',
  `executor_param` VARCHAR(512) DEFAULT NULL COMMENT '执行器参数',
  `executor_sharding_param` VARCHAR(255) DEFAULT NULL COMMENT '执行器分片参数',
  `executor_fail_retry_count` TINYINT NOT NULL DEFAULT '0' COMMENT '失败重试次数',
  `trigger_time` DATETIME DEFAULT NULL COMMENT '调度-时间',
  `trigger_code` INT NOT NULL COMMENT '调度-结果',
  `trigger_msg` TEXT COMMENT '调度-日志',
  `handle_time` DATETIME DEFAULT NULL COMMENT '执行-时间',
  `handle_code` INT NOT NULL COMMENT '执行-状态',
  `handle_msg` TEXT COMMENT '执行-日志',
  `handle_console_url` VARCHAR(255) DEFAULT NULL COMMENT '操作控制台URL',
  `handle_process_id` INT DEFAULT NULL COMMENT '执行进程ID',
  `handle_cost_time` INT DEFAULT NULL COMMENT '执行耗时',
  `alarm_status` TINYINT NOT NULL DEFAULT '0' COMMENT '报警状态',
  PRIMARY KEY (`id`),
  KEY `idx_job_group` (`job_group`),
  KEY `idx_job_id` (`job_id`),
  KEY `idx_trigger_time` (`trigger_time`),
  KEY `idx_handle_time` (`handle_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务日志表';

-- ----------------------------
-- Table structure: xxl_job_log_report
-- ----------------------------
CREATE TABLE `xxl_job_log_report` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `trigger_day` DATETIME DEFAULT NULL COMMENT '调度时间',
  `running_count` INT NOT NULL DEFAULT '0' COMMENT '运行中数量',
  `success_count` INT NOT NULL DEFAULT '0' COMMENT '成功数量',
  `fail_count` INT NOT NULL DEFAULT '0' COMMENT '失败数量',
  `updatetime` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_trigger_day` (`trigger_day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务日志报告表';

-- ----------------------------
-- Table structure: xxl_job_registry
-- ----------------------------
CREATE TABLE `xxl_job_registry` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `registry_group` VARCHAR(50) NOT NULL COMMENT '注册分组',
  `registry_key` VARCHAR(255) NOT NULL COMMENT '注册Key',
  `registry_value` VARCHAR(255) NOT NULL COMMENT '注册值',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_registry_group` (`registry_group`),
  KEY `idx_registry_key` (`registry_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='执行器注册表';

-- ----------------------------
-- Table structure: xxl_job_group
-- ----------------------------
CREATE TABLE `xxl_job_group` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_name` VARCHAR(255) NOT NULL COMMENT '执行器AppName',
  `title` VARCHAR(255) NOT NULL COMMENT '执行器名称',
  `address_type` TINYINT NOT NULL DEFAULT '0' COMMENT '地址类型',
  `address_list` VARCHAR(512) DEFAULT NULL COMMENT '执行器地址列表',
  `update_time` DATETIME DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='执行器组表';

-- ----------------------------
-- Table structure: xxl_job_user
-- ----------------------------
CREATE TABLE `xxl_job_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` VARCHAR(255) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码',
  `role` TINYINT NOT NULL COMMENT '角色',
  `permission` VARCHAR(255) DEFAULT NULL COMMENT '权限',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ----------------------------
-- Table structure: xxl_job_lock
-- ----------------------------
CREATE TABLE `xxl_job_lock` (
  `lock_name` VARCHAR(50) NOT NULL COMMENT '锁名称',
  PRIMARY KEY (`lock_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务锁表';

-- ----------------------------
-- Initial data for xxl_job_user
-- ----------------------------
INSERT INTO `xxl_job_user` (`id`, `username`, `password`, `role`, `permission`) VALUES
(1, 'admin', '$2a$10$X1NWkn/zA7zDmV9p6N6K4uPFQq3R4G7Gqz/sZj1cLCcL2R6H8J5V0i', 1, NULL);

-- ----------------------------
-- Initial data for xxl_job_group (sample executor)
-- ----------------------------
INSERT INTO `xxl_job_group` (`id`, `app_name`, `title`, `address_type`, `address_list`) VALUES
(1, 'testhub-executor', 'TestHub执行器', 1, NULL);
