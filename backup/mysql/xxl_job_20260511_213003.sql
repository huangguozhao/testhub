-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: xxl_job
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `xxl_job`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `xxl_job` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `xxl_job`;

--
-- Table structure for table `xxl_job_group`
--

DROP TABLE IF EXISTS `xxl_job_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `xxl_job_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_name` varchar(64) NOT NULL COMMENT '忙鈥奥∨捗モ劉篓AppName',
  `title` varchar(64) NOT NULL,
  `address_type` tinyint NOT NULL DEFAULT '0',
  `address_list` varchar(512) DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xxl_job_group`
--

LOCK TABLES `xxl_job_group` WRITE;
/*!40000 ALTER TABLE `xxl_job_group` DISABLE KEYS */;
INSERT INTO `xxl_job_group` VALUES (1,'testhub-executor','TestHub',0,'http://10.202.29.103:9999/','2026-05-07 22:57:55');
/*!40000 ALTER TABLE `xxl_job_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xxl_job_info`
--

DROP TABLE IF EXISTS `xxl_job_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `xxl_job_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `job_group` int NOT NULL COMMENT '閹笛?閸ｃ劋瀵岄柨鐢€D',
  `job_desc` varchar(255) NOT NULL,
  `add_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `author` varchar(64) DEFAULT NULL COMMENT '娴ｆ粏?',
  `alarm_email` varchar(255) DEFAULT NULL COMMENT '閹躲儴?闁?娆?,
  `schedule_type` varchar(50) NOT NULL DEFAULT 'NONE' COMMENT '鐠嬪啫瀹崇猾璇茬€?,
  `schedule_conf` varchar(128) DEFAULT NULL COMMENT '鐠嬪啫瀹抽柊宥囩枂閿涘苯?閸?绠熼崣鏍у枀娴滃氦鐨熸惔锔捐閸?,
  `misfire_strategy` varchar(50) NOT NULL DEFAULT 'DO_NOTHING' COMMENT '鐠嬪啫瀹虫潻鍥ㄦ埂缁涙牜鏆?,
  `executor_route_strategy` varchar(50) DEFAULT NULL COMMENT '閹笛?閸ｃ劏鐭鹃悽杈╃摜閻?,
  `executor_handler` varchar(255) DEFAULT NULL COMMENT '閹笛?閸ｃ劋鎹㈤崝?andler',
  `executor_param` varchar(512) DEFAULT NULL COMMENT '閹笛?閸ｃ劋鎹㈤崝鈥冲棘閺?,
  `executor_block_strategy` varchar(50) DEFAULT NULL COMMENT '闂冭?婢跺嫮鎮婄粵鏍殣',
  `executor_timeout` int NOT NULL DEFAULT '0' COMMENT '娴犺濮熼幍褑?鐡掑懏妞傞弮鍫曟？閿涘苯宕熸担宥?',
  `executor_fail_retry_count` int NOT NULL DEFAULT '0' COMMENT '婢惰精瑙﹂柌宥堢槸濞嗏剝鏆?,
  `glue_type` varchar(50) NOT NULL DEFAULT 'BEAN' COMMENT 'GLUE缁鐎?,
  `glue_source` mediumtext COMMENT 'GLUE濠ф劒鍞惍',
  `glue_remark` varchar(128) DEFAULT NULL,
  `glue_updatetime` datetime DEFAULT NULL,
  `child_jobid` varchar(255) DEFAULT NULL,
  `trigger_status` tinyint NOT NULL DEFAULT '0' COMMENT '鐠嬪啫瀹抽悩鑸?閿?-閸嬫粍?閿?-鏉╂劘?',
  `trigger_last_time` bigint NOT NULL DEFAULT '0' COMMENT '娑撳﹥?鐠嬪啫瀹抽弮鍫曟？',
  `trigger_next_time` bigint NOT NULL DEFAULT '0' COMMENT '娑撳?鐠嬪啫瀹抽弮鍫曟？',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xxl_job_info`
--

LOCK TABLES `xxl_job_info` WRITE;
/*!40000 ALTER TABLE `xxl_job_info` DISABLE KEYS */;
INSERT INTO `xxl_job_info` VALUES (1,1,'API锟斤拷时锟斤拷锟斤拷-test(ID:5)','2026-05-07 22:59:10','2026-05-07 22:59:10','admin',NULL,'FIX_RATE','31536000','DO_NOTHING','FIRST','apiScheduledTaskJob','5','SERIAL_EXECUTION',0,0,'BEAN',NULL,NULL,'2026-05-07 22:59:10',NULL,0,0,0),(2,1,'API瀹氭椂浠诲姟-test(ID:6)','2026-05-07 23:02:48','2026-05-07 23:36:15','testhub',NULL,'FIX_RATE','66','DO_NOTHING','FIRST','apiScheduledTaskJob','6','SERIAL_EXECUTION',0,0,'BEAN',NULL,NULL,'2026-05-07 23:02:48',NULL,0,0,0);
/*!40000 ALTER TABLE `xxl_job_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xxl_job_lock`
--

DROP TABLE IF EXISTS `xxl_job_lock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `xxl_job_lock` (
  `lock_name` varchar(50) NOT NULL COMMENT '闁夸礁鎮曠粔',
  PRIMARY KEY (`lock_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xxl_job_lock`
--

LOCK TABLES `xxl_job_lock` WRITE;
/*!40000 ALTER TABLE `xxl_job_lock` DISABLE KEYS */;
/*!40000 ALTER TABLE `xxl_job_lock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xxl_job_log`
--

DROP TABLE IF EXISTS `xxl_job_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `xxl_job_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_group` int NOT NULL COMMENT '閹笛?閸ｃ劋瀵岄柨鐢€D',
  `job_id` int NOT NULL COMMENT '娴犺濮熼敍灞煎瘜闁跨攢D',
  `executor_address` varchar(255) DEFAULT NULL COMMENT '閹笛?閸ｃ劌婀撮崸?绱濋張??閹笛?閻ㄥ嫬婀撮崸',
  `executor_handler` varchar(255) DEFAULT NULL COMMENT '閹笛?閸ｃ劋鎹㈤崝?andler',
  `executor_param` varchar(512) DEFAULT NULL COMMENT '閹笛?閸ｃ劋鎹㈤崝鈥冲棘閺?,
  `executor_sharding_param` varchar(20) DEFAULT NULL COMMENT '閹笛?閸ｃ劋鎹㈤崝鈥冲瀻閻楀洤寮弫甯礉閺嶇厧绱℃俊?1/2',
  `executor_fail_retry_count` int NOT NULL DEFAULT '0' COMMENT '婢惰精瑙﹂柌宥堢槸濞嗏剝鏆?,
  `trigger_time` datetime DEFAULT NULL COMMENT '鐠嬪啫瀹?閺冨爼妫?,
  `trigger_code` int NOT NULL DEFAULT '0' COMMENT '鐠嬪啫瀹?缂佹挻鐏?,
  `trigger_msg` text COMMENT '鐠嬪啫瀹?閺冦儱绻?,
  `handle_time` datetime DEFAULT NULL COMMENT '閹笛?-閺冨爼妫?,
  `handle_code` int NOT NULL DEFAULT '0' COMMENT '閹笛?-閻樿埖?',
  `handle_msg` text COMMENT '閹笛?-閺冦儱绻?,
  `alarm_status` tinyint NOT NULL DEFAULT '0' COMMENT '閸涘﹨?閻樿埖?閿?-姒涙?閵?-閺冪娀娓堕崨濠?閵?-閸涘﹨?閹存劕濮涢妴?-閸涘﹨?婢惰精瑙?,
  PRIMARY KEY (`id`),
  KEY `I_trigger_time` (`trigger_time`),
  KEY `I_jobid_jobgroup` (`job_id`,`job_group`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xxl_job_log`
--

LOCK TABLES `xxl_job_log` WRITE;
/*!40000 ALTER TABLE `xxl_job_log` DISABLE KEYS */;
INSERT INTO `xxl_job_log` VALUES (1,1,2,'http://10.202.29.103:9999/','apiScheduledTaskJob','6',NULL,0,'2026-05-07 23:02:48',200,'浠诲姟瑙﹀彂绫诲瀷锛氭墜鍔ㄨЕ鍙?br>璋冨害鏈哄櫒锛?72.20.0.3<br>鎵ц鍣?娉ㄥ唽鏂瑰紡锛氳嚜鍔ㄦ敞鍐?br>鎵ц鍣?鍦板潃鍒楄〃锛歔http://10.202.29.103:9999/]<br>璺敱绛栫暐锛氱涓€涓?br>闃诲澶勭悊绛栫暐锛氬崟鏈轰覆琛?br>浠诲姟瓒呮椂鏃堕棿锛?<br>澶辫触閲嶈瘯娆℃暟锛?<br><br><span style=\"color:#00c0ef;\" > >>>>>>>>>>>瑙﹀彂璋冨害<<<<<<<<<<< </span><br>瑙﹀彂璋冨害锛?br>address锛歨ttp://10.202.29.103:9999/<br>code锛?00<br>msg锛歯ull','2026-05-07 23:02:56',200,'',0),(2,1,2,'http://10.202.29.103:9999/','apiScheduledTaskJob','6',NULL,0,'2026-05-07 23:36:05',200,'浠诲姟瑙﹀彂绫诲瀷锛欳ron瑙﹀彂<br>璋冨害鏈哄櫒锛?72.20.0.3<br>鎵ц鍣?娉ㄥ唽鏂瑰紡锛氳嚜鍔ㄦ敞鍐?br>鎵ц鍣?鍦板潃鍒楄〃锛歔http://10.202.29.103:9999/]<br>璺敱绛栫暐锛氱涓€涓?br>闃诲澶勭悊绛栫暐锛氬崟鏈轰覆琛?br>浠诲姟瓒呮椂鏃堕棿锛?<br>澶辫触閲嶈瘯娆℃暟锛?<br><br><span style=\"color:#00c0ef;\" > >>>>>>>>>>>瑙﹀彂璋冨害<<<<<<<<<<< </span><br>瑙﹀彂璋冨害锛?br>address锛歨ttp://10.202.29.103:9999/<br>code锛?00<br>msg锛歯ull','2026-05-07 23:36:15',200,'',0);
/*!40000 ALTER TABLE `xxl_job_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xxl_job_log_report`
--

DROP TABLE IF EXISTS `xxl_job_log_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `xxl_job_log_report` (
  `id` int NOT NULL AUTO_INCREMENT,
  `trigger_day` datetime DEFAULT NULL COMMENT '鐠嬪啫瀹?閺冨爼妫?,
  `running_count` int NOT NULL DEFAULT '0' COMMENT '鏉╂劘?娑?閺冦儱绻旈弫浼村櫤',
  `suc_count` int NOT NULL DEFAULT '0' COMMENT '閹笛?閹存劕濮?閺冦儱绻旈弫浼村櫤',
  `fail_count` int NOT NULL DEFAULT '0' COMMENT '閹笛?婢惰精瑙?閺冦儱绻旈弫浼村櫤',
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `i_trigger_day` (`trigger_day`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xxl_job_log_report`
--

LOCK TABLES `xxl_job_log_report` WRITE;
/*!40000 ALTER TABLE `xxl_job_log_report` DISABLE KEYS */;
INSERT INTO `xxl_job_log_report` VALUES (1,'2026-05-07 00:00:00',0,2,0,NULL),(2,'2026-05-06 00:00:00',0,0,0,NULL),(3,'2026-05-05 00:00:00',0,0,0,NULL),(4,'2026-05-08 00:00:00',0,0,0,NULL),(5,'2026-05-09 00:00:00',0,0,0,NULL),(6,'2026-05-10 00:00:00',0,0,0,NULL),(7,'2026-05-11 00:00:00',0,0,0,NULL);
/*!40000 ALTER TABLE `xxl_job_log_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xxl_job_user`
--

DROP TABLE IF EXISTS `xxl_job_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `xxl_job_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` tinyint NOT NULL,
  `permission` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xxl_job_user`
--

LOCK TABLES `xxl_job_user` WRITE;
/*!40000 ALTER TABLE `xxl_job_user` DISABLE KEYS */;
INSERT INTO `xxl_job_user` VALUES (1,'admin','e10adc3949ba59abbe56e057f20f883e',1,'ROLE_ADMIN');
/*!40000 ALTER TABLE `xxl_job_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'xxl_job'
--

--
-- Dumping routines for database 'xxl_job'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-11 13:30:06
