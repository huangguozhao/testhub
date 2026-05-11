-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: testhub_java
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
-- Current Database: `testhub_java`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `testhub_java` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `testhub_java`;

--
-- Table structure for table `api_collection`
--

DROP TABLE IF EXISTS `api_collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_collection` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '闆嗗悎ID',
  `project_id` bigint NOT NULL COMMENT 'API椤圭洰ID',
  `suite_id` bigint DEFAULT NULL COMMENT '娴嬭瘯濂椾欢ID',
  `parent_id` bigint DEFAULT NULL COMMENT '鐖堕泦鍚圛D(鐢ㄤ簬鏍戝舰缁撴瀯)',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '闆嗗悎鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '闆嗗悎鎻忚堪',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎺掑簭',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='API闆嗗悎琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_collection`
--

LOCK TABLES `api_collection` WRITE;
/*!40000 ALTER TABLE `api_collection` DISABLE KEYS */;
INSERT INTO `api_collection` VALUES (1,1,3,NULL,'UserModule','User related APIs',0,0,'2026-04-30 09:49:42','2026-04-30 12:16:14',4,4);
/*!40000 ALTER TABLE `api_collection` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_environment`
--

DROP TABLE IF EXISTS `api_environment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_environment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐜ID',
  `project_id` bigint DEFAULT NULL COMMENT '椤圭洰ID(scope=LOCAL鏃跺繀濉?',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐜鍚嶇О',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐜鎻忚堪',
  `scope` varchar(10) NOT NULL DEFAULT 'LOCAL' COMMENT '浣滅敤鍩? GLOBAL=鍏ㄥ眬,\r\n      LOCAL=椤圭洰绾?,
  `variables` json NOT NULL COMMENT '鐜鍙橀噺(JSON鏍煎紡)',
  `is_default` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁榛樿: 0=鍚? 1=鏄?,
  `is_active` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁婵€娲? 0=鍚? 1=鏄?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_is_default` (`is_default`) USING BTREE,
  KEY `idx_scope` (`scope`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='API鐜琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_environment`
--

LOCK TABLES `api_environment` WRITE;
/*!40000 ALTER TABLE `api_environment` DISABLE KEYS */;
INSERT INTO `api_environment` VALUES (1,7,'TestEnv','Test environment','LOCAL','{\"baseUrl\": \"https://httpbin.org\"}',1,0,0,'2026-04-30 09:49:30','2026-04-30 09:49:30',4,4);
/*!40000 ALTER TABLE `api_environment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_execution_record`
--

DROP TABLE IF EXISTS `api_execution_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_execution_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `suite_id` bigint DEFAULT NULL COMMENT '娴嬭瘯濂椾欢ID',
  `executed_at` datetime DEFAULT NULL COMMENT '鎵ц鏃堕棿',
  `total_count` int DEFAULT NULL COMMENT '鎬昏姹傛暟',
  `pass_count` int DEFAULT NULL COMMENT '閫氳繃鏁?,
  `fail_count` int DEFAULT NULL COMMENT '澶辫触鏁?,
  `result_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '鎵ц缁撴灉JSON',
  `status` tinyint DEFAULT NULL COMMENT '鎵ц鐘舵€?0=澶辫触,1=鎴愬姛)',
  `duration` bigint DEFAULT NULL COMMENT '鎵ц鏃堕暱(姣)',
  `environment_id` bigint DEFAULT NULL COMMENT '鎵ц鐜ID',
  `trigger_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '瑙﹀彂绫诲瀷(manual/scheduled)',
  `trigger_id` bigint DEFAULT NULL COMMENT '瑙﹀彂鏉ユ簮ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` bigint DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  `is_deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_executed_at` (`executed_at`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_execution_record`
--

LOCK TABLES `api_execution_record` WRITE;
/*!40000 ALTER TABLE `api_execution_record` DISABLE KEYS */;
INSERT INTO `api_execution_record` VALUES (1,2,'2026-04-30 09:57:51',2,2,0,'[{\"requestId\":1,\"requestName\":\"GetUser\",\"success\":true,\"statusCode\":200,\"responseTime\":1544,\"error\":null},{\"requestId\":2,\"requestName\":\"PostUser\",\"success\":true,\"statusCode\":200,\"responseTime\":299,\"error\":null}]',1,1902,1,'manual',NULL,'2026-04-30 09:57:51','2026-04-30 09:57:51',4,4,0),(2,3,'2026-04-30 12:16:16',5,5,0,'[{\"requestId\":1,\"requestName\":\"GetUser\",\"success\":true,\"statusCode\":200,\"responseTime\":777,\"error\":null,\"assertions\":null},{\"requestId\":2,\"requestName\":\"PostUser\",\"success\":true,\"statusCode\":200,\"responseTime\":278,\"error\":null,\"assertions\":null},{\"requestId\":3,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":544,\"error\":null,\"assertions\":null},{\"requestId\":4,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":225,\"error\":null,\"assertions\":null},{\"requestId\":5,\"requestName\":\"TestAssertionPass\",\"success\":true,\"statusCode\":200,\"responseTime\":431,\"error\":null,\"assertions\":[{\"name\":\"status_code\",\"passed\":true,\"expected\":\"200\",\"actual\":\"200\",\"error\":null},{\"name\":\"check-origin\",\"passed\":true,\"expected\":\"鍖呭惈: httpbin\",\"actual\":\"鍖呭惈\",\"error\":null}]}]',1,2312,1,'manual',NULL,'2026-04-30 12:16:16','2026-04-30 12:16:16',4,4,0),(3,3,'2026-04-30 12:17:57',6,6,0,'[{\"requestId\":1,\"requestName\":\"GetUser\",\"success\":true,\"statusCode\":200,\"responseTime\":738,\"error\":null,\"assertions\":null},{\"requestId\":2,\"requestName\":\"PostUser\",\"success\":true,\"statusCode\":200,\"responseTime\":240,\"error\":null,\"assertions\":null},{\"requestId\":3,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":237,\"error\":null,\"assertions\":null},{\"requestId\":4,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":239,\"error\":null,\"assertions\":null},{\"requestId\":5,\"requestName\":\"TestAssertionPass\",\"success\":true,\"statusCode\":200,\"responseTime\":245,\"error\":null,\"assertions\":[{\"name\":\"status_code\",\"passed\":true,\"expected\":\"200\",\"actual\":\"200\",\"error\":null},{\"name\":\"check-origin\",\"passed\":true,\"expected\":\"鍖呭惈: httpbin\",\"actual\":\"鍖呭惈\",\"error\":null}]},{\"requestId\":6,\"requestName\":\"ExtractToken\",\"success\":true,\"statusCode\":200,\"responseTime\":238,\"error\":null,\"assertions\":null}]',1,1971,1,'manual',NULL,'2026-04-30 12:17:57','2026-04-30 12:17:57',4,4,0),(4,3,'2026-04-30 12:18:27',8,8,0,'[{\"requestId\":1,\"requestName\":\"GetUser\",\"success\":true,\"statusCode\":200,\"responseTime\":1110,\"error\":null,\"assertions\":null},{\"requestId\":2,\"requestName\":\"PostUser\",\"success\":true,\"statusCode\":200,\"responseTime\":230,\"error\":null,\"assertions\":null},{\"requestId\":3,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":232,\"error\":null,\"assertions\":null},{\"requestId\":4,\"requestName\":\"TestAssertion\",\"success\":true,\"statusCode\":200,\"responseTime\":244,\"error\":null,\"assertions\":null},{\"requestId\":5,\"requestName\":\"TestAssertionPass\",\"success\":true,\"statusCode\":200,\"responseTime\":227,\"error\":null,\"assertions\":[{\"name\":\"status_code\",\"passed\":true,\"expected\":\"200\",\"actual\":\"200\",\"error\":null},{\"name\":\"check-origin\",\"passed\":true,\"expected\":\"鍖呭惈: httpbin\",\"actual\":\"鍖呭惈\",\"error\":null}]},{\"requestId\":6,\"requestName\":\"ExtractToken\",\"success\":true,\"statusCode\":200,\"responseTime\":585,\"error\":null,\"assertions\":null},{\"requestId\":7,\"requestName\":\"ExtractOrigin\",\"success\":true,\"statusCode\":200,\"responseTime\":226,\"error\":null,\"assertions\":null},{\"requestId\":8,\"requestName\":\"UseExtractedVar\",\"success\":true,\"statusCode\":200,\"responseTime\":232,\"error\":null,\"assertions\":null}]',1,3106,1,'manual',NULL,'2026-04-30 12:18:27','2026-04-30 12:18:27',4,4,0);
/*!40000 ALTER TABLE `api_execution_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_project`
--

DROP TABLE IF EXISTS `api_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_project` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '椤圭洰ID',
  `project_id` bigint NOT NULL COMMENT '鍏宠仈椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'API椤圭洰鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '椤圭洰鎻忚堪',
  `base_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍩虹URL',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  `project_type` varchar(50) DEFAULT 'HTTP' COMMENT '茅隆鹿莽鈥郝甭幻ヅ锯€? HTTP, WEBSOCKET',
  `status` varchar(20) DEFAULT 'active' COMMENT '莽艩露忙鈧?,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `owner_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='API椤圭洰琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_project`
--

LOCK TABLES `api_project` WRITE;
/*!40000 ALTER TABLE `api_project` DISABLE KEYS */;
INSERT INTO `api_project` VALUES (1,7,'UserServiceAPI','User service API collection','https://httpbin.org',0,'2026-04-30 09:49:29','2026-04-30 09:49:29',4,4,'HTTP','active',NULL,NULL,NULL);
/*!40000 ALTER TABLE `api_project` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_project_member`
--

DROP TABLE IF EXISTS `api_project_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_project_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `project_id` bigint NOT NULL COMMENT 'API椤圭洰ID',
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'member' COMMENT '瑙掕壊: owner, admin, member',
  `joined_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍔犲叆鏃堕棿',
  `is_deleted` tinyint DEFAULT '0' COMMENT '鏄惁鍒犻櫎',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_project_user` (`project_id`,`user_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='API椤圭洰鎴愬憳琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_project_member`
--

LOCK TABLES `api_project_member` WRITE;
/*!40000 ALTER TABLE `api_project_member` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_project_member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_request`
--

DROP TABLE IF EXISTS `api_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_request` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璇锋眰ID',
  `collection_id` bigint NOT NULL COMMENT '闆嗗悎ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璇锋眰鍚嶇О',
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'HTTP鏂规硶: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS',
  `url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璇锋眰URL',
  `headers` json DEFAULT NULL COMMENT '璇锋眰澶?,
  `params` json DEFAULT NULL COMMENT 'URL鍙傛暟',
  `body_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璇锋眰浣撶被鍨? none, json, form, xml, raw, binary',
  `body_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '璇锋眰浣撳唴瀹?,
  `auth_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璁よ瘉绫诲瀷: none, basic, bearer, api_key, oauth2',
  `auth_config` json DEFAULT NULL COMMENT '璁よ瘉閰嶇疆',
  `pre_script` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鍓嶇疆鑴氭湰',
  `post_script` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鍚庣疆鑴氭湰',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎺掑簭',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  `assertions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鏂█瑙勫垯(JSON)',
  `extractors` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鍙橀噺鎻愬彇瑙勫垯(JSON)',
  `request_type` varchar(20) DEFAULT 'HTTP' COMMENT '璇锋眰绫诲瀷: HTTP, WEBSOCKET',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_collection_id` (`collection_id`) USING BTREE,
  KEY `idx_method` (`method`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='API璇锋眰琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_request`
--

LOCK TABLES `api_request` WRITE;
/*!40000 ALTER TABLE `api_request` DISABLE KEYS */;
INSERT INTO `api_request` VALUES (1,1,'GetUser','GET','https://httpbin.org/get',NULL,NULL,'none',NULL,'none',NULL,NULL,NULL,0,0,'2026-04-30 09:49:42','2026-04-30 09:49:42',4,4,NULL,NULL,'HTTP'),(2,1,'PostUser','POST','https://httpbin.org/post',NULL,NULL,'json','{\"name\":\"test\",\"email\":\"test@test.com\"}','none',NULL,NULL,NULL,1,0,'2026-04-30 09:51:58','2026-04-30 09:51:58',4,4,NULL,NULL,'HTTP'),(3,1,'TestAssertion','GET','https://httpbin.org/get',NULL,NULL,'none',NULL,'none',NULL,NULL,NULL,10,0,'2026-04-30 11:59:43','2026-04-30 11:59:43',4,4,NULL,NULL,'HTTP'),(4,1,'TestAssertion','GET','https://httpbin.org/get',NULL,NULL,'none',NULL,'none',NULL,NULL,NULL,20,0,'2026-04-30 12:00:31','2026-04-30 12:00:31',4,4,NULL,NULL,'HTTP'),(5,1,'TestAssertionPass','GET','https://httpbin.org/get',NULL,NULL,'none',NULL,'none',NULL,NULL,NULL,30,0,'2026-04-30 12:13:25','2026-04-30 12:13:25',4,4,'[{\"type\":\"status_code\",\"expected\":200},{\"type\":\"contains\",\"name\":\"check-origin\",\"expected\":\"httpbin\"}]',NULL,'HTTP'),(6,1,'ExtractToken','POST','https://httpbin.org/post',NULL,NULL,'json','{\"username\":\"test\",\"token\":\"abc123\"}','none',NULL,NULL,NULL,100,0,'2026-04-30 12:17:55','2026-04-30 12:17:55',4,4,NULL,'[{\"type\":\"json_path\",\"name\":\"extract-token\",\"path\":\"$.json.token\",\"variable\":\"extractedToken\"}]','HTTP'),(7,1,'ExtractOrigin','GET','https://httpbin.org/get',NULL,NULL,'none',NULL,'none',NULL,NULL,NULL,200,0,'2026-04-30 12:18:24','2026-04-30 12:18:24',4,4,NULL,'[{\"type\":\"json_path\",\"path\":\"$.origin\",\"variable\":\"serverOrigin\"}]','HTTP'),(8,1,'UseExtractedVar','GET','https://httpbin.org/anything/{{serverOrigin}}',NULL,NULL,'none',NULL,'none',NULL,NULL,NULL,201,0,'2026-04-30 12:18:24','2026-04-30 12:18:24',4,4,NULL,NULL,'HTTP'),(9,1,'GET /get','GET','https://httpbin.org/get',NULL,NULL,'none',NULL,'none',NULL,NULL,NULL,0,0,'2026-04-30 17:26:06','2026-04-30 17:26:06',5,5,NULL,NULL,'HTTP');
/*!40000 ALTER TABLE `api_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_request_history`
--

DROP TABLE IF EXISTS `api_request_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_request_history` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍘嗗彶ID',
  `request_id` bigint NOT NULL COMMENT '璇锋眰ID',
  `suite_execution_id` bigint DEFAULT NULL COMMENT '濂椾欢鎵ц璁板綍ID',
  `suite_id` bigint DEFAULT NULL COMMENT '濂椾欢ID(濡傛灉閫氳繃濂椾欢鎵ц)',
  `environment_id` bigint DEFAULT NULL COMMENT '鐜ID',
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'HTTP鏂规硶',
  `url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璇锋眰URL',
  `request_headers` json DEFAULT NULL COMMENT '璇锋眰澶?,
  `request_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '璇锋眰浣?,
  `response_status_code` int DEFAULT NULL COMMENT '鍝嶅簲鐘舵€佺爜',
  `response_status` int DEFAULT NULL COMMENT '鍝嶅簲鐘舵€佺爜',
  `response_headers` json DEFAULT NULL COMMENT '鍝嶅簲澶?,
  `response_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鍝嶅簲浣?,
  `response_time` int DEFAULT NULL COMMENT '鍝嶅簲鏃堕棿(姣)',
  `assertions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鏂█缁撴灉(JSON)',
  `extracted_variables` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鎻愬彇鍙橀噺(JSON)',
  `success` tinyint(1) DEFAULT '0' COMMENT '鏄惁鎴愬姛',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '閿欒淇℃伅',
  `assertion_results` json DEFAULT NULL COMMENT '鏂█缁撴灉',
  `executed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鎵ц鏃堕棿',
  `executed_by` bigint DEFAULT NULL COMMENT '鎵ц浜篒D',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `executor_id` bigint DEFAULT NULL COMMENT '鎵ц浜篒D',
  `request_type` varchar(20) DEFAULT 'HTTP' COMMENT '璇锋眰绫诲瀷: HTTP,\r\n  WEBSOCKET',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_request_id` (`request_id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_executed_at` (`executed_at`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='API璇锋眰鍘嗗彶琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_request_history`
--

LOCK TABLES `api_request_history` WRITE;
/*!40000 ALTER TABLE `api_request_history` DISABLE KEYS */;
INSERT INTO `api_request_history` VALUES (2,9,NULL,NULL,NULL,'GET','https://httpbin.org/get',NULL,NULL,200,NULL,'{\"Date\": \"Thu, 30 Apr 2026 09:36:41 GMT\", \"Server\": \"gunicorn/19.9.0\", \"Connection\": \"keep-alive\", \"Content-Type\": \"application/json\", \"Content-Length\": \"348\", \"Access-Control-Allow-Origin\": \"*\", \"Access-Control-Allow-Credentials\": \"true\"}','{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"text/plain, application/json, application/*+json, */*\", \n    \"Content-Type\": \"application/json\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"Java/17.0.14\", \n    \"X-Amzn-Trace-Id\": \"Root=1-69f322a9-4764dcaa0331a78229f8bafd\"\n  }, \n  \"origin\": \"223.73.113.231\", \n  \"url\": \"https://httpbin.org/get\"\n}\n',825,NULL,'{}',1,NULL,NULL,'2026-04-30 17:36:41',NULL,'2026-04-30 17:36:41',NULL,'HTTP'),(3,9,NULL,NULL,NULL,'GET','https://httpbin.org/get',NULL,NULL,200,NULL,'{\"Date\": \"Thu, 30 Apr 2026 09:36:53 GMT\", \"Server\": \"gunicorn/19.9.0\", \"Connection\": \"keep-alive\", \"Content-Type\": \"application/json\", \"Content-Length\": \"348\", \"Access-Control-Allow-Origin\": \"*\", \"Access-Control-Allow-Credentials\": \"true\"}','{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"text/plain, application/json, application/*+json, */*\", \n    \"Content-Type\": \"application/json\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"Java/17.0.14\", \n    \"X-Amzn-Trace-Id\": \"Root=1-69f322b5-6d9c6927161546ea44a3fe14\"\n  }, \n  \"origin\": \"223.73.113.231\", \n  \"url\": \"https://httpbin.org/get\"\n}\n',991,NULL,'{}',1,NULL,NULL,'2026-04-30 17:36:54',NULL,'2026-04-30 17:36:54',NULL,'HTTP'),(4,9,NULL,NULL,NULL,'GET','https://httpbin.org/get',NULL,NULL,200,NULL,'{\"Date\": \"Wed, 06 May 2026 02:59:20 GMT\", \"Server\": \"gunicorn/19.9.0\", \"Connection\": \"keep-alive\", \"Content-Type\": \"application/json\", \"Content-Length\": \"346\", \"Access-Control-Allow-Origin\": \"*\", \"Access-Control-Allow-Credentials\": \"true\"}','{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"text/plain, application/json, application/*+json, */*\", \n    \"Content-Type\": \"application/json\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"Java/17.0.14\", \n    \"X-Amzn-Trace-Id\": \"Root=1-69faae88-50d7fb6715e08d0a12cb1f31\"\n  }, \n  \"origin\": \"183.9.226.83\", \n  \"url\": \"https://httpbin.org/get\"\n}\n',13085,NULL,'{}',1,NULL,NULL,'2026-05-06 10:59:27',NULL,'2026-05-06 10:59:27',NULL,'HTTP'),(5,9,NULL,NULL,NULL,'GET','https://httpbin.org/get',NULL,NULL,200,NULL,'{\"Date\": \"Wed, 06 May 2026 03:08:28 GMT\", \"Server\": \"gunicorn/19.9.0\", \"Connection\": \"keep-alive\", \"Content-Type\": \"application/json\", \"Content-Length\": \"346\", \"Access-Control-Allow-Origin\": \"*\", \"Access-Control-Allow-Credentials\": \"true\"}','{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"text/plain, application/json, application/*+json, */*\", \n    \"Content-Type\": \"application/json\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"Java/17.0.14\", \n    \"X-Amzn-Trace-Id\": \"Root=1-69fab0ac-47383f9e7105420e5c0d5885\"\n  }, \n  \"origin\": \"183.9.226.83\", \n  \"url\": \"https://httpbin.org/get\"\n}\n',12542,NULL,'{}',1,NULL,NULL,'2026-05-06 11:08:36',NULL,'2026-05-06 11:08:36',NULL,'HTTP'),(6,9,NULL,NULL,NULL,'GET','https://httpbin.org/get',NULL,NULL,200,NULL,'{\"Date\": \"Wed, 06 May 2026 03:20:29 GMT\", \"Server\": \"gunicorn/19.9.0\", \"Connection\": \"keep-alive\", \"Content-Type\": \"application/json\", \"Content-Length\": \"346\", \"Access-Control-Allow-Origin\": \"*\", \"Access-Control-Allow-Credentials\": \"true\"}','{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"text/plain, application/json, application/*+json, */*\", \n    \"Content-Type\": \"application/json\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"Java/17.0.14\", \n    \"X-Amzn-Trace-Id\": \"Root=1-69fab37d-42338ec9653e9f3d5bac9593\"\n  }, \n  \"origin\": \"183.9.226.83\", \n  \"url\": \"https://httpbin.org/get\"\n}\n',12943,NULL,'{}',1,NULL,NULL,'2026-05-06 11:20:36',NULL,'2026-05-06 11:20:36',NULL,'HTTP');
/*!40000 ALTER TABLE `api_request_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_scheduled_task`
--

DROP TABLE IF EXISTS `api_scheduled_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_scheduled_task` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '浠诲姟ID',
  `suite_id` bigint NOT NULL COMMENT '濂椾欢ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浠诲姟鍚嶇О',
  `trigger_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙﹀彂绫诲瀷: cron=Cron琛ㄨ揪寮? interval=鍥哄畾闂撮殧, once=鍗曟鎵ц',
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Cron琛ㄨ揪寮?,
  `interval_value` bigint DEFAULT NULL COMMENT '闂撮殧鍊?,
  `interval_unit` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '闂撮殧鍗曚綅: seconds, minutes, hours',
  `once_time` datetime DEFAULT NULL COMMENT '鍗曟鎵ц鏃堕棿',
  `is_enabled` tinyint NOT NULL DEFAULT '1' COMMENT '鏄惁鍚敤: 0=绂佺敤, 1=鍚敤',
  `notification_config` json DEFAULT NULL COMMENT '閫氱煡閰嶇疆',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `last_run_at` datetime DEFAULT NULL COMMENT '涓婃鎵ц鏃堕棿',
  `next_run_at` datetime DEFAULT NULL COMMENT '涓嬫鎵ц鏃堕棿',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_is_enabled` (`is_enabled`) USING BTREE,
  KEY `idx_trigger_type` (`trigger_type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='API瀹氭椂浠诲姟琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_scheduled_task`
--

LOCK TABLES `api_scheduled_task` WRITE;
/*!40000 ALTER TABLE `api_scheduled_task` DISABLE KEYS */;
INSERT INTO `api_scheduled_task` VALUES (1,1,'DailyRegression','cron','0 0 2 * * ?',NULL,NULL,NULL,1,NULL,1,NULL,NULL,'2026-04-30 09:52:19','2026-04-30 09:52:31',4,4);
/*!40000 ALTER TABLE `api_scheduled_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_test_suite`
--

DROP TABLE IF EXISTS `api_test_suite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_test_suite` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '濂椾欢ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '濂椾欢鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '濂椾欢鎻忚堪',
  `environment_id` bigint DEFAULT NULL COMMENT '鎵ц鐜ID',
  `timeout` int DEFAULT '30000' COMMENT '瓒呮椂鏃堕棿(姣)',
  `retry_count` int DEFAULT '0' COMMENT '澶辫触閲嶈瘯娆℃暟',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='API娴嬭瘯濂椾欢琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_test_suite`
--

LOCK TABLES `api_test_suite` WRITE;
/*!40000 ALTER TABLE `api_test_suite` DISABLE KEYS */;
INSERT INTO `api_test_suite` VALUES (1,7,'RegressionSuite','Regression test suite',1,30000,0,1,'2026-04-30 09:50:03','2026-04-30 09:52:31',4,4),(2,7,'RegressionSuite','Regression test',1,30000,0,0,'2026-04-30 09:54:19','2026-04-30 09:54:19',4,4),(3,7,'AssertionTestSuite','Test assertions',1,30000,0,0,'2026-04-30 12:16:14','2026-04-30 12:16:14',4,4);
/*!40000 ALTER TABLE `api_test_suite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_test_suite_request`
--

DROP TABLE IF EXISTS `api_test_suite_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_test_suite_request` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `suite_id` bigint NOT NULL COMMENT '濂椾欢ID',
  `request_id` bigint NOT NULL COMMENT '璇锋眰ID',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎵ц椤哄簭',
  `assertions` json DEFAULT NULL COMMENT '鏂█閰嶇疆',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_suite_request` (`suite_id`,`request_id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_request_id` (`request_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='濂椾欢璇锋眰鍏宠仈琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_test_suite_request`
--

LOCK TABLES `api_test_suite_request` WRITE;
/*!40000 ALTER TABLE `api_test_suite_request` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_test_suite_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_component`
--

DROP TABLE IF EXISTS `app_component`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_component` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '缁勪欢ID',
  `project_id` bigint NOT NULL COMMENT 'APP椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '缁勪欢鍚嶇О',
  `component_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '缁勪欢绫诲瀷',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '缁勪欢鎻忚堪',
  `config` json DEFAULT NULL COMMENT '缁勪欢閰嶇疆',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP UI缁勪欢琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_component`
--

LOCK TABLES `app_component` WRITE;
/*!40000 ALTER TABLE `app_component` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_component` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_device`
--

DROP TABLE IF EXISTS `app_device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_device` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璁惧ID',
  `project_id` bigint NOT NULL COMMENT 'APP椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璁惧鍚嶇О',
  `device_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璁惧搴忓垪鍙?,
  `connection_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'usb' COMMENT '杩炴帴绫诲瀷: usb, wifi, emulator, remote',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'offline' COMMENT '鐘舵€? offline=绂荤嚎, online=鍦ㄧ嚎, busy=鍗犵敤涓? error=寮傚父',
  `platform_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '绯荤粺鐗堟湰',
  `resolution` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍒嗚鲸鐜?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `locked_by` bigint DEFAULT NULL COMMENT '閿佸畾浜篒D',
  `locked_at` datetime DEFAULT NULL COMMENT '閿佸畾鏃堕棿',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_device_id` (`device_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP璁惧琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_device`
--

LOCK TABLES `app_device` WRITE;
/*!40000 ALTER TABLE `app_device` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_device` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_element`
--

DROP TABLE IF EXISTS `app_element`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_element` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍏冪礌ID',
  `project_id` bigint NOT NULL COMMENT 'APP椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍏冪礌鍚嶇О',
  `locator_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀹氫綅绫诲瀷: image=鍥剧墖, coordinate=鍧愭爣, region=鍖哄煙',
  `locator_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀹氫綅鍊?鍥剧墖璺緞鎴栧潗鏍?',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍏冪礌鎻忚堪',
  `screenshot` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎴浘璺緞',
  `usage_count` int DEFAULT '0' COMMENT '浣跨敤娆℃暟',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_locator_type` (`locator_type`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP鍏冪礌琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_element`
--

LOCK TABLES `app_element` WRITE;
/*!40000 ALTER TABLE `app_element` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_element` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_package`
--

DROP TABLE IF EXISTS `app_package`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_package` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍖呭悕ID',
  `project_id` bigint NOT NULL COMMENT 'APP椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍖呭悕鍚嶇О',
  `package_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '搴旂敤鍖呭悕',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎻忚堪',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_package_name` (`package_name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP鍖呭悕绠＄悊琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_package`
--

LOCK TABLES `app_package` WRITE;
/*!40000 ALTER TABLE `app_package` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_package` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_project`
--

DROP TABLE IF EXISTS `app_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_project` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '椤圭洰ID',
  `project_id` bigint NOT NULL COMMENT '鍏宠仈椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'APP椤圭洰鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '椤圭洰鎻忚堪',
  `platform` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'android' COMMENT '骞冲彴: android, ios',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP鑷姩鍖栭」鐩〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_project`
--

LOCK TABLES `app_project` WRITE;
/*!40000 ALTER TABLE `app_project` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_project` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_scheduled_task`
--

DROP TABLE IF EXISTS `app_scheduled_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_scheduled_task` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '浠诲姟ID',
  `suite_id` bigint NOT NULL COMMENT '濂椾欢ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浠诲姟鍚嶇О',
  `trigger_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙﹀彂绫诲瀷: cron, interval, once',
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Cron琛ㄨ揪寮?,
  `interval_value` bigint DEFAULT NULL COMMENT '闂撮殧鍊?,
  `interval_unit` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '闂撮殧鍗曚綅',
  `once_time` datetime DEFAULT NULL COMMENT '鍗曟鎵ц鏃堕棿',
  `device_id` bigint DEFAULT NULL COMMENT '鎸囧畾璁惧ID',
  `is_enabled` tinyint NOT NULL DEFAULT '1' COMMENT '鏄惁鍚敤: 0=绂佺敤, 1=鍚敤',
  `notification_config` json DEFAULT NULL COMMENT '閫氱煡閰嶇疆',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `last_run_at` datetime DEFAULT NULL COMMENT '涓婃鎵ц鏃堕棿',
  `next_run_at` datetime DEFAULT NULL COMMENT '涓嬫鎵ц鏃堕棿',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_is_enabled` (`is_enabled`) USING BTREE,
  KEY `idx_trigger_type` (`trigger_type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP瀹氭椂浠诲姟琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_scheduled_task`
--

LOCK TABLES `app_scheduled_task` WRITE;
/*!40000 ALTER TABLE `app_scheduled_task` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_scheduled_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_test_case`
--

DROP TABLE IF EXISTS `app_test_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_test_case` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐢ㄤ緥ID',
  `project_id` bigint NOT NULL COMMENT 'APP椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄤ緥鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鐢ㄤ緥鎻忚堪',
  `ui_flow` json NOT NULL COMMENT 'UI娴佺▼閰嶇疆(JSON)',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP娴嬭瘯鐢ㄤ緥琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_test_case`
--

LOCK TABLES `app_test_case` WRITE;
/*!40000 ALTER TABLE `app_test_case` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_test_case` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_test_execution`
--

DROP TABLE IF EXISTS `app_test_execution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_test_execution` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鎵цID',
  `suite_id` bigint NOT NULL COMMENT '濂椾欢ID',
  `device_id` bigint NOT NULL COMMENT '璁惧ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '鐘舵€? pending, running, passed, failed, stopped',
  `executor_id` bigint NOT NULL COMMENT '鎵ц浜篒D',
  `started_at` datetime DEFAULT NULL COMMENT '寮€濮嬫椂闂?,
  `completed_at` datetime DEFAULT NULL COMMENT '瀹屾垚鏃堕棿',
  `total_count` int DEFAULT '0' COMMENT '鎬荤敤渚嬫暟',
  `passed_count` int DEFAULT '0' COMMENT '閫氳繃鏁?,
  `failed_count` int DEFAULT '0' COMMENT '澶辫触鏁?,
  `report_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎶ュ憡璺緞',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_device_id` (`device_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_executor_id` (`executor_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP鎵ц璁板綍琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_test_execution`
--

LOCK TABLES `app_test_execution` WRITE;
/*!40000 ALTER TABLE `app_test_execution` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_test_execution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_test_suite`
--

DROP TABLE IF EXISTS `app_test_suite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_test_suite` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '濂椾欢ID',
  `project_id` bigint NOT NULL COMMENT 'APP椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '濂椾欢鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '濂椾欢鎻忚堪',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP娴嬭瘯濂椾欢琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_test_suite`
--

LOCK TABLES `app_test_suite` WRITE;
/*!40000 ALTER TABLE `app_test_suite` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_test_suite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_test_suite_case`
--

DROP TABLE IF EXISTS `app_test_suite_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_test_suite_case` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `suite_id` bigint NOT NULL COMMENT '濂椾欢ID',
  `case_id` bigint NOT NULL COMMENT '鐢ㄤ緥ID',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎵ц椤哄簭',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_suite_case` (`suite_id`,`case_id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_case_id` (`case_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='APP濂椾欢鐢ㄤ緥鍏宠仈琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_test_suite_case`
--

LOCK TABLES `app_test_suite_case` WRITE;
/*!40000 ALTER TABLE `app_test_suite_case` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_test_suite_case` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ast_assistant_session`
--

DROP TABLE IF EXISTS `ast_assistant_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ast_assistant_session` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '浼氳瘽ID',
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浼氳瘽鍚嶇О',
  `last_message_at` datetime DEFAULT NULL COMMENT '鏈€鍚庢秷鎭椂闂?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_last_message_at` (`last_message_at`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='AI鍔╂墜浼氳瘽琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ast_assistant_session`
--

LOCK TABLES `ast_assistant_session` WRITE;
/*!40000 ALTER TABLE `ast_assistant_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `ast_assistant_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ast_chat_message`
--

DROP TABLE IF EXISTS `ast_chat_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ast_chat_message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '娑堟伅ID',
  `session_id` bigint NOT NULL COMMENT '浼氳瘽ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙掕壊: user, assistant, system',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '娑堟伅鍐呭',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_session_id` (`session_id`) USING BTREE,
  KEY `idx_role` (`role`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='AI鍔╂墜娑堟伅琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ast_chat_message`
--

LOCK TABLES `ast_chat_message` WRITE;
/*!40000 ALTER TABLE `ast_chat_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `ast_chat_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ast_dify_config`
--

DROP TABLE IF EXISTS `ast_dify_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ast_dify_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '閰嶇疆ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閰嶇疆鍚嶇О',
  `api_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'API URL',
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'API Key',
  `app_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '搴旂敤ID',
  `is_enabled` tinyint NOT NULL DEFAULT '1' COMMENT '鏄惁鍚敤: 0=绂佺敤, 1=鍚敤',
  `is_default` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁榛樿: 0=鍚? 1=鏄?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_is_enabled` (`is_enabled`) USING BTREE,
  KEY `idx_is_default` (`is_default`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Dify閰嶇疆琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ast_dify_config`
--

LOCK TABLES `ast_dify_config` WRITE;
/*!40000 ALTER TABLE `ast_dify_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `ast_dify_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cfg_ai_model_config`
--

DROP TABLE IF EXISTS `cfg_ai_model_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cfg_ai_model_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '閰嶇疆ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '妯″瀷鍚嶇О',
  `provider` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎻愪緵鍟? deepseek=DeepSeek, qwen=閫氫箟鍗冮棶, siliconflow=纭呭熀娴佸姩, openai=OpenAI, anthropic=Anthropic',
  `model_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '妯″瀷鍚嶇О',
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'API Key(鍔犲瘑瀛樺偍)',
  `base_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'API Base URL',
  `temperature` decimal(3,2) DEFAULT '0.70' COMMENT '娓╁害鍙傛暟',
  `max_tokens` int DEFAULT '2048' COMMENT '鏈€澶oken鏁?,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙掕壊: testcase_writer=鐢ㄤ緥缂栧啓, testcase_reviewer=鐢ㄤ緥璇勫, browser_use_text=Browser鏂囨湰妯″紡, browser_use_vision=Browser瑙嗚妯″紡',
  `is_enabled` tinyint NOT NULL DEFAULT '1' COMMENT '鏄惁鍚敤: 0=绂佺敤, 1=鍚敤',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_provider` (`provider`) USING BTREE,
  KEY `idx_role` (`role`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='AI妯″瀷閰嶇疆琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cfg_ai_model_config`
--

LOCK TABLES `cfg_ai_model_config` WRITE;
/*!40000 ALTER TABLE `cfg_ai_model_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `cfg_ai_model_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cfg_notification_config`
--

DROP TABLE IF EXISTS `cfg_notification_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cfg_notification_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '閰嶇疆ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閰嶇疆鍚嶇О',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '绫诲瀷: webhook_feishu=椋炰功, webhook_wechat=浼佷笟寰俊, webhook_dingtalk=閽夐拤, email=閭欢',
  `config` json NOT NULL COMMENT '閰嶇疆鍐呭(JSON鏍煎紡)',
  `is_enabled` tinyint NOT NULL DEFAULT '1' COMMENT '鏄惁鍚敤: 0=绂佺敤, 1=鍚敤',
  `is_default` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁榛樿: 0=鍚? 1=鏄?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_type` (`type`) USING BTREE,
  KEY `idx_is_enabled` (`is_enabled`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='閫氱煡閰嶇疆琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cfg_notification_config`
--

LOCK TABLES `cfg_notification_config` WRITE;
/*!40000 ALTER TABLE `cfg_notification_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `cfg_notification_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `df_data_record`
--

DROP TABLE IF EXISTS `df_data_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `df_data_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璁板綍ID',
  `tool_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '宸ュ叿鍚嶇О',
  `tool_category` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '宸ュ叿鍒嗙被: string=瀛楃, encoding=缂栫爜, random=闅忔満, encryption=鍔犲瘑, test_data=娴嬭瘯鏁版嵁, json=JSON, crontab=Crontab',
  `tool_scenario` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浣跨敤鍦烘櫙: data_generate=鏁版嵁鐢熸垚, format_convert=鏍煎紡杞崲, data_validation=鏁版嵁楠岃瘉, encrypt=鍔犲瘑瑙ｅ瘑',
  `input_data` json DEFAULT NULL COMMENT '杈撳叆鏁版嵁',
  `output_data` json DEFAULT NULL COMMENT '杈撳嚭鏁版嵁',
  `tags` json DEFAULT NULL COMMENT '鏍囩',
  `is_saved` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁淇濆瓨: 0=鍚? 1=鏄?,
  `usage_count` int DEFAULT '0' COMMENT '浣跨敤娆℃暟',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_tool_name` (`tool_name`) USING BTREE,
  KEY `idx_tool_category` (`tool_category`) USING BTREE,
  KEY `idx_tool_scenario` (`tool_scenario`) USING BTREE,
  KEY `idx_is_saved` (`is_saved`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鏁版嵁宸ュ巶璁板綍琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `df_data_record`
--

LOCK TABLES `df_data_record` WRITE;
/*!40000 ALTER TABLE `df_data_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `df_data_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exec_test_plan`
--

DROP TABLE IF EXISTS `exec_test_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exec_test_plan` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璁″垝ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璁″垝鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '璁″垝鎻忚堪',
  `start_date` datetime DEFAULT NULL COMMENT '寮€濮嬫棩鏈?,
  `end_date` datetime DEFAULT NULL COMMENT '缁撴潫鏃ユ湡',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '鐘舵€? pending=寰呮墽琛? in_progress=鎵ц涓? completed=宸插畬鎴?,
  `assignee_id` bigint DEFAULT NULL COMMENT '璐熻矗浜篒D',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_assignee_id` (`assignee_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='娴嬭瘯璁″垝琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exec_test_plan`
--

LOCK TABLES `exec_test_plan` WRITE;
/*!40000 ALTER TABLE `exec_test_plan` DISABLE KEYS */;
INSERT INTO `exec_test_plan` VALUES (1,6,'V1.0鍥炲綊娴嬭瘯','V1.0鐗堟湰鍥炲綊娴嬭瘯璁″垝',NULL,NULL,'pending',3,1,'2026-04-29 23:10:15','2026-04-29 23:10:30',3,3);
/*!40000 ALTER TABLE `exec_test_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exec_test_run`
--

DROP TABLE IF EXISTS `exec_test_run`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exec_test_run` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鎵цID',
  `plan_id` bigint NOT NULL COMMENT '璁″垝ID',
  `suite_id` bigint DEFAULT NULL COMMENT '濂椾欢ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '鐘舵€? pending=寰呮墽琛? running=鎵ц涓? completed=宸插畬鎴? failed=澶辫触',
  `executor_id` bigint NOT NULL COMMENT '鎵ц浜篒D',
  `started_at` datetime DEFAULT NULL COMMENT '寮€濮嬫椂闂?,
  `completed_at` datetime DEFAULT NULL COMMENT '瀹屾垚鏃堕棿',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_plan_id` (`plan_id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_executor_id` (`executor_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='娴嬭瘯鎵ц璁板綍琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exec_test_run`
--

LOCK TABLES `exec_test_run` WRITE;
/*!40000 ALTER TABLE `exec_test_run` DISABLE KEYS */;
INSERT INTO `exec_test_run` VALUES (1,1,1,'failed',3,'2026-04-29 23:10:50','2026-04-29 23:10:55',1,'2026-04-29 23:10:46','2026-04-29 23:11:06',3,3);
/*!40000 ALTER TABLE `exec_test_run` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exec_test_run_case`
--

DROP TABLE IF EXISTS `exec_test_run_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exec_test_run_case` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `run_id` bigint NOT NULL COMMENT '鎵цID',
  `test_case_id` bigint NOT NULL COMMENT '鐢ㄤ緥ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'untested' COMMENT '鐘舵€? untested=鏈祴璇? passed=閫氳繃, failed=澶辫触, blocked=闃诲, retest=閲嶆祴',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鎵ц缁撴灉',
  `bug_ids` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍏宠仈鐨勭己闄稩D(閫楀彿鍒嗛殧)',
  `executor_id` bigint NOT NULL COMMENT '鎵ц浜篒D',
  `executed_at` datetime DEFAULT NULL COMMENT '鎵ц鏃堕棿',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_run_id` (`run_id`) USING BTREE,
  KEY `idx_test_case_id` (`test_case_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鎵ц鐢ㄤ緥璁板綍琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exec_test_run_case`
--

LOCK TABLES `exec_test_run_case` WRITE;
/*!40000 ALTER TABLE `exec_test_run_case` DISABLE KEYS */;
/*!40000 ALTER TABLE `exec_test_run_case` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lbl_label`
--

DROP TABLE IF EXISTS `lbl_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lbl_label` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏍囩ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏍囩鍚嶇О',
  `color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '#666666' COMMENT '鏍囩棰滆壊',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_project_label` (`project_id`,`name`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鏍囩琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lbl_label`
--

LOCK TABLES `lbl_label` WRITE;
/*!40000 ALTER TABLE `lbl_label` DISABLE KEYS */;
/*!40000 ALTER TABLE `lbl_label` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_config`
--

DROP TABLE IF EXISTS `notification_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閰嶇疆鍚嶇О',
  `config_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閰嶇疆绫诲瀷: webhook_feishu, webhook_wechat, webhook_dingtalk, email',
  `webhook_config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Webhook閰嶇疆(JSON)',
  `is_default` tinyint(1) DEFAULT '0' COMMENT '鏄惁榛樿',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '鏄惁鍚敤',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '澶囨敞',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '鏄惁鍒犻櫎',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_config_type` (`config_type`) USING BTREE,
  KEY `idx_is_default` (`is_default`) USING BTREE,
  KEY `idx_is_active` (`is_active`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='閫氱煡閰嶇疆琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_config`
--

LOCK TABLES `notification_config` WRITE;
/*!40000 ALTER TABLE `notification_config` DISABLE KEYS */;
INSERT INTO `notification_config` VALUES (1,'Updated Feishu Bot','webhook_feishu','{\"webhook\": \"https://open.feishu.cn/open-apis/bot/v2/hook/yyy\"}',1,0,'Updated config','2026-04-30 18:43:16','2026-04-30 18:43:46',5,5,1);
/*!40000 ALTER TABLE `notification_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_log`
--

DROP TABLE IF EXISTS `notification_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `task_id` bigint DEFAULT NULL COMMENT '鍏宠仈浠诲姟ID',
  `task_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '浠诲姟绫诲瀷: api_test, ui_automation, app_automation',
  `notification_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'manual' COMMENT '閫氱煡绫诲瀷: task_execution, system_alert, manual',
  `channel` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閫氱煡娓犻亾: feishu, wechat, dingtalk, email',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'pending' COMMENT '鍙戦€佺姸鎬? pending, sending, success, failed',
  `config_id` bigint DEFAULT NULL COMMENT '閫氱煡閰嶇疆ID',
  `recipient_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鏀朵欢浜轰俊鎭?JSON)',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '閫氱煡鍐呭(JSON)',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '閿欒淇℃伅',
  `retry_count` int DEFAULT '0' COMMENT '閲嶈瘯娆℃暟',
  `sent_at` datetime DEFAULT NULL COMMENT '鍙戦€佹椂闂?,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '鏄惁鍒犻櫎',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_task_id` (`task_id`) USING BTREE,
  KEY `idx_task_type` (`task_type`) USING BTREE,
  KEY `idx_channel` (`channel`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_created_at` (`created_at`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='閫氱煡鏃ュ織琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_log`
--

LOCK TABLES `notification_log` WRITE;
/*!40000 ALTER TABLE `notification_log` DISABLE KEYS */;
INSERT INTO `notification_log` VALUES (1,NULL,NULL,'manual','feishu','success',1,NULL,'{\"title\":\"Test Notification\",\"content\":\"This is a test notification from TestHub\"}',NULL,0,'2026-04-30 18:43:26','2026-04-30 18:43:26','2026-04-30 18:43:26',5,5,0);
/*!40000 ALTER TABLE `notification_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operation_log`
--

DROP TABLE IF EXISTS `operation_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `operation_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `operation_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎿嶄綔绫诲瀷: create, edit, delete, execute, run, save',
  `resource_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璧勬簮绫诲瀷: project, collection, request, suite, environment, task, execution',
  `resource_id` bigint DEFAULT NULL COMMENT '璧勬簮ID',
  `resource_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璧勬簮鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鎿嶄綔鎻忚堪',
  `user_id` bigint DEFAULT NULL COMMENT '鎿嶄綔鐢ㄦ埛ID',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎿嶄綔鐢ㄦ埛鍚?,
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'IP鍦板潃',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐢ㄦ埛浠ｇ悊',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '鏄惁鍒犻櫎',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_operation_type` (`operation_type`) USING BTREE,
  KEY `idx_resource_type` (`resource_type`) USING BTREE,
  KEY `idx_resource_id` (`resource_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_created_at` (`created_at`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鎿嶄綔鏃ュ織琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operation_log`
--

LOCK TABLES `operation_log` WRITE;
/*!40000 ALTER TABLE `operation_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `operation_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prj_project`
--

DROP TABLE IF EXISTS `prj_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prj_project` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '椤圭洰鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '椤圭洰鎻忚堪',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'active' COMMENT '鐘舵€? active=杩涜涓? paused=鏆傚仠, completed=宸插畬鎴? archived=宸插綊妗?,
  `owner_id` bigint NOT NULL COMMENT '椤圭洰璐熻矗浜篒D',
  `icon` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '椤圭洰鍥炬爣',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎺掑簭',
  `include_test_cases` tinyint NOT NULL DEFAULT '1' COMMENT '鏄惁鍖呭惈娴嬭瘯鐢ㄤ緥: 0=鍚? 1=鏄?,
  `include_automated_tests` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍖呭惈鑷姩鍖栨祴璇? 0=鍚? 1=鏄?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_owner_id` (`owner_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='椤圭洰琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prj_project`
--

LOCK TABLES `prj_project` WRITE;
/*!40000 ALTER TABLE `prj_project` DISABLE KEYS */;
INSERT INTO `prj_project` VALUES (4,'鏇存柊鍚庣殑椤圭洰鍚嶇О','鏇存柊鍚庣殑椤圭洰鎻忚堪','completed',3,NULL,0,1,0,1,'2026-04-29 17:26:35','2026-04-29 21:18:14',NULL,NULL),(5,'鎴戠殑娴嬭瘯椤圭洰1777469162','杩欐槸涓€涓祴璇曢」鐩?,'active',3,NULL,0,1,0,1,'2026-04-29 21:26:02','2026-04-29 21:26:12',NULL,NULL),(6,'鎴戠殑娴嬭瘯椤圭洰1777469202','杩欐槸涓€涓祴璇曢」鐩?,'active',3,NULL,0,1,0,0,'2026-04-29 21:26:42','2026-04-29 21:26:42',NULL,NULL),(7,'TestProject001','API Testing Project','active',4,NULL,0,1,0,0,'2026-04-30 09:49:21','2026-04-30 09:49:21',4,4);
/*!40000 ALTER TABLE `prj_project` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prj_project_environment`
--

DROP TABLE IF EXISTS `prj_project_environment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prj_project_environment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐜ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐜鍚嶇О',
  `base_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '' COMMENT '鍩虹URL',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐜鎻忚堪',
  `variables` json DEFAULT NULL COMMENT '鐜鍙橀噺(JSON鏍煎紡)',
  `is_default` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁榛樿鐜: 0=鍚? 1=鏄?,
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎺掑簭',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='椤圭洰鐜琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prj_project_environment`
--

LOCK TABLES `prj_project_environment` WRITE;
/*!40000 ALTER TABLE `prj_project_environment` DISABLE KEYS */;
INSERT INTO `prj_project_environment` VALUES (1,4,'榛樿鐜','',NULL,NULL,1,0,0,'2026-04-29 17:26:35','2026-04-29 17:26:35',NULL,NULL),(2,5,'榛樿鐜','',NULL,NULL,1,0,0,'2026-04-29 21:26:02','2026-04-29 21:26:02',NULL,NULL),(3,6,'榛樿鐜','',NULL,NULL,0,0,0,'2026-04-29 21:26:42','2026-04-29 21:26:42',NULL,NULL),(4,6,'鏇存柊鐨勭幆澧冨悕绉?,'','鏇存柊鐨勭幆澧冩弿杩?,'{}',1,0,1,'2026-04-29 21:51:17','2026-04-29 21:51:32',NULL,NULL),(5,7,'榛樿鐜','',NULL,NULL,1,0,0,'2026-04-30 09:49:21','2026-04-30 09:49:21',4,4);
/*!40000 ALTER TABLE `prj_project_environment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prj_project_member`
--

DROP TABLE IF EXISTS `prj_project_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prj_project_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'tester' COMMENT '瑙掕壊: owner=璐熻矗浜? admin=绠＄悊鍛? developer=寮€鍙戣€? tester=娴嬭瘯鑰? viewer=瑙傚療鑰?,
  `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍔犲叆鏃堕棿',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_project_user` (`project_id`,`user_id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_role` (`role`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='椤圭洰鎴愬憳琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prj_project_member`
--

LOCK TABLES `prj_project_member` WRITE;
/*!40000 ALTER TABLE `prj_project_member` DISABLE KEYS */;
INSERT INTO `prj_project_member` VALUES (2,4,3,'developer','2026-04-29 17:26:35',0,'2026-04-29 17:26:35','2026-04-29 17:26:35',NULL,NULL),(3,5,3,'owner','2026-04-29 21:26:02',0,'2026-04-29 21:26:02','2026-04-29 21:26:02',NULL,NULL),(4,6,3,'owner','2026-04-29 21:26:42',0,'2026-04-29 21:26:42','2026-04-29 21:26:42',NULL,NULL),(5,6,2,'tester','2026-04-29 21:27:41',1,'2026-04-29 21:27:41','2026-04-29 21:46:35',NULL,NULL),(6,7,4,'owner','2026-04-30 09:49:21',0,'2026-04-30 09:49:21','2026-04-30 09:49:21',4,4);
/*!40000 ALTER TABLE `prj_project_member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prj_version`
--

DROP TABLE IF EXISTS `prj_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prj_version` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐗堟湰ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐗堟湰鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鐗堟湰鎻忚堪',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'planning' COMMENT '鐘舵€? planning=瑙勫垝涓? released=宸插彂甯? archived=宸插綊妗?,
  `release_date` date DEFAULT NULL COMMENT '鍙戝竷鏃ユ湡',
  `is_baseline` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍩虹嚎鐗堟湰: 0=鍚? 1=鏄?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐗堟湰琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prj_version`
--

LOCK TABLES `prj_version` WRITE;
/*!40000 ALTER TABLE `prj_version` DISABLE KEYS */;
/*!40000 ALTER TABLE `prj_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `req_analysis`
--

DROP TABLE IF EXISTS `req_analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `req_analysis` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍒嗘瀽ID',
  `document_id` bigint NOT NULL COMMENT '鏂囨。ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '鐘舵€? pending, running, completed, failed',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '瑙ｆ瀽鍚庣殑鍐呭',
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'AI鐢熸垚鐨勬憳瑕?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_document_id` (`document_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='闇€姹傚垎鏋愯褰曡〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `req_analysis`
--

LOCK TABLES `req_analysis` WRITE;
/*!40000 ALTER TABLE `req_analysis` DISABLE KEYS */;
/*!40000 ALTER TABLE `req_analysis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `req_business_requirement`
--

DROP TABLE IF EXISTS `req_business_requirement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `req_business_requirement` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '闇€姹侷D',
  `analysis_id` bigint NOT NULL COMMENT '鍒嗘瀽ID',
  `parent_id` bigint DEFAULT NULL COMMENT '鐖堕渶姹侷D(鐢ㄤ簬灞傜骇缁撴瀯)',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '闇€姹傛爣棰?,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '闇€姹傛弿杩?,
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'medium' COMMENT '浼樺厛绾? low, medium, high, critical',
  `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏉ユ簮',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_analysis_id` (`analysis_id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE,
  KEY `idx_priority` (`priority`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='涓氬姟闇€姹傝〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `req_business_requirement`
--

LOCK TABLES `req_business_requirement` WRITE;
/*!40000 ALTER TABLE `req_business_requirement` DISABLE KEYS */;
/*!40000 ALTER TABLE `req_business_requirement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `req_document`
--

DROP TABLE IF EXISTS `req_document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `req_document` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏂囨。ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏂囨。鍚嶇О',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏂囦欢璺緞',
  `file_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏂囦欢绫诲瀷: pdf, docx, txt, markdown',
  `file_size` bigint DEFAULT NULL COMMENT '鏂囦欢澶у皬',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '鐘舵€? pending=寰呰В鏋? parsing=瑙ｆ瀽涓? parsed=宸茶В鏋? failed=澶辫触',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_file_type` (`file_type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='闇€姹傛枃妗ｈ〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `req_document`
--

LOCK TABLES `req_document` WRITE;
/*!40000 ALTER TABLE `req_document` DISABLE KEYS */;
/*!40000 ALTER TABLE `req_document` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `req_generated_test_case`
--

DROP TABLE IF EXISTS `req_generated_test_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `req_generated_test_case` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐢熸垚ID',
  `requirement_id` bigint NOT NULL COMMENT '闇€姹侷D',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄤ緥鏍囬',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鐢ㄤ緥鎻忚堪',
  `precondition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鍓嶇疆鏉′欢',
  `steps` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '娴嬭瘯姝ラ',
  `expected_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '棰勬湡缁撴灉',
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'medium' COMMENT '浼樺厛绾?,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'generated' COMMENT '鐘舵€? generated=宸茬敓鎴? imported=宸插鍏ョ敤渚嬪簱, rejected=宸叉嫆缁?,
  `test_case_id` bigint DEFAULT NULL COMMENT '鍏宠仈鐨勬祴璇曠敤渚婭D(瀵煎叆鍚?',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_requirement_id` (`requirement_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_test_case_id` (`test_case_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐢熸垚鐨勬祴璇曠敤渚嬭〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `req_generated_test_case`
--

LOCK TABLES `req_generated_test_case` WRITE;
/*!40000 ALTER TABLE `req_generated_test_case` DISABLE KEYS */;
/*!40000 ALTER TABLE `req_generated_test_case` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rpt_test_report`
--

DROP TABLE IF EXISTS `rpt_test_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rpt_test_report` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鎶ュ憡ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎶ュ憡鍚嶇О',
  `report_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎶ュ憡绫诲瀷: execution=鎵ц鎶ュ憡, summary=姹囨€绘姤鍛?,
  `content` json DEFAULT NULL COMMENT '鎶ュ憡鍐呭(JSON鏍煎紡)',
  `generated_by` bigint NOT NULL COMMENT '鐢熸垚浜?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_generated_by` (`generated_by`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='娴嬭瘯鎶ュ憡琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rpt_test_report`
--

LOCK TABLES `rpt_test_report` WRITE;
/*!40000 ALTER TABLE `rpt_test_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `rpt_test_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rv_review_assignment`
--

DROP TABLE IF EXISTS `rv_review_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rv_review_assignment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `review_id` bigint NOT NULL COMMENT '璇勫ID',
  `test_case_id` bigint NOT NULL COMMENT '鐢ㄤ緥ID',
  `reviewer_id` bigint NOT NULL COMMENT '璇勫浜篒D',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '鐘舵€? pending=寰呰瘎瀹? approved=閫氳繃, rejected=鎷掔粷, needs_revision=闇€淇敼',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_review_case` (`review_id`,`test_case_id`) USING BTREE,
  KEY `idx_review_id` (`review_id`) USING BTREE,
  KEY `idx_test_case_id` (`test_case_id`) USING BTREE,
  KEY `idx_reviewer_id` (`reviewer_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璇勫鍒嗛厤琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rv_review_assignment`
--

LOCK TABLES `rv_review_assignment` WRITE;
/*!40000 ALTER TABLE `rv_review_assignment` DISABLE KEYS */;
/*!40000 ALTER TABLE `rv_review_assignment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rv_review_comment`
--

DROP TABLE IF EXISTS `rv_review_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rv_review_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璇勮ID',
  `assignment_id` bigint NOT NULL COMMENT '鍒嗛厤ID',
  `test_case_step_id` bigint DEFAULT NULL COMMENT '鐢ㄤ緥姝ラID(鍙负NULL琛ㄧず鏁翠綋鎰忚)',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璇勮鍐呭',
  `is_resolved` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁宸茶В鍐? 0=鍚? 1=鏄?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_assignment_id` (`assignment_id`) USING BTREE,
  KEY `idx_test_case_step_id` (`test_case_step_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璇勫鎰忚琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rv_review_comment`
--

LOCK TABLES `rv_review_comment` WRITE;
/*!40000 ALTER TABLE `rv_review_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `rv_review_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rv_review_template`
--

DROP TABLE IF EXISTS `rv_review_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rv_review_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '妯℃澘ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '妯℃澘鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '妯℃澘鎻忚堪',
  `checklist` json DEFAULT NULL COMMENT '妫€鏌ユ竻鍗?JSON鏍煎紡)',
  `is_default` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁榛樿妯℃澘: 0=鍚? 1=鏄?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璇勫妯℃澘琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rv_review_template`
--

LOCK TABLES `rv_review_template` WRITE;
/*!40000 ALTER TABLE `rv_review_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `rv_review_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rv_test_case_review`
--

DROP TABLE IF EXISTS `rv_test_case_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rv_test_case_review` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璇勫ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璇勫鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '璇勫鎻忚堪',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '鐘舵€? pending=寰呰瘎瀹? in_progress=璇勫涓? passed=閫氳繃, rejected=鎷掔粷, needs_revision=闇€淇敼',
  `template_id` bigint DEFAULT NULL COMMENT '璇勫妯℃澘ID',
  `assignee_id` bigint DEFAULT NULL COMMENT '璇勫浜篒D',
  `due_date` date DEFAULT NULL COMMENT '鎴鏃ユ湡',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_assignee_id` (`assignee_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='娴嬭瘯鐢ㄤ緥璇勫琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rv_test_case_review`
--

LOCK TABLES `rv_test_case_review` WRITE;
/*!40000 ALTER TABLE `rv_test_case_review` DISABLE KEYS */;
/*!40000 ALTER TABLE `rv_test_case_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_token_blacklist`
--

DROP TABLE IF EXISTS `sys_token_blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_token_blacklist` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `token_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Token JTI(鍞竴鏍囪瘑)',
  `user_id` bigint DEFAULT NULL COMMENT '鐢ㄦ埛ID',
  `expire_time` datetime NOT NULL COMMENT 'Token杩囨湡鏃堕棿',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍔犲叆榛戝悕鍗曟椂闂?,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `token_id` (`token_id`) USING BTREE,
  KEY `idx_token_id` (`token_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE,
  KEY `idx_expire_time` (`expire_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Token榛戝悕鍗曡〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_token_blacklist`
--

LOCK TABLES `sys_token_blacklist` WRITE;
/*!40000 ALTER TABLE `sys_token_blacklist` DISABLE KEYS */;
INSERT INTO `sys_token_blacklist` VALUES (1,'c35111c4-2940-4387-af27-fe016fb1c1af',2,'2026-05-06 16:32:44','2026-04-29 16:33:28',NULL),(2,'fa6630ee-1bc6-4731-9c29-aef8aaf09835',2,'2026-04-29 16:48:27','2026-04-29 16:33:37',NULL),(3,'65db83f4-b95a-4f66-a3eb-7bb0e8e09bf3',2,'2026-04-29 16:48:57','2026-04-29 16:34:05',NULL),(4,'5043a8f1-41d8-4592-8061-7f433ddb9db8',2,'2026-04-29 16:58:26','2026-04-29 16:43:35',NULL),(5,'9914a730-0a5a-422a-b394-a9db42f552a3',2,'2026-05-12 22:42:18','2026-05-05 22:53:46',NULL),(7,'b22f8ae9-1c4a-4799-9669-39e0c36e0fa5',2,'2026-05-12 22:53:52','2026-05-05 23:16:10',NULL),(8,'0e017a21-0cd4-438f-963f-0f6716dfbfa9',2,'2026-05-12 23:16:10','2026-05-05 23:30:41',NULL),(10,'69e2d2b3-f4f7-47f2-81e2-67cbefe12a0e',2,'2026-05-13 09:36:36','2026-05-06 10:16:33',NULL),(11,'94758857-ab79-4b3d-afb0-221c266e6871',2,'2026-05-13 10:16:33','2026-05-06 10:42:27',NULL),(12,'d591b43a-8f0e-4dd8-bcdf-3100cd582633',2,'2026-05-13 10:42:26','2026-05-06 10:59:11',NULL),(13,'d4d734ca-a83c-4081-80e5-8c3d10be69bd',2,'2026-05-13 10:59:11','2026-05-06 11:20:20',NULL),(14,'fe9b1221-e53c-4176-80e2-19400b1ed21d',2,'2026-05-13 11:20:19','2026-05-06 11:43:19',NULL),(15,'33079722-8e3c-4baa-ab7d-d35a0edf6272',2,'2026-05-13 11:43:19','2026-05-06 13:47:46',NULL),(16,'ffa0305b-243f-4120-bca0-cd5dd2a551ea',2,'2026-05-13 13:47:46','2026-05-06 15:25:15',NULL);
/*!40000 ALTER TABLE `sys_token_blacklist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐢ㄦ埛ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄦ埛鍚?,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閭',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀵嗙爜(BCrypt鍔犲瘑)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐪熷疄濮撳悕',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎵嬫満鍙?,
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶村儚URL',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'enabled' COMMENT '鐘舵€? enabled=鍚敤, disabled=绂佺敤',
  `last_login_time` datetime DEFAULT NULL COMMENT '鏈€鍚庣櫥褰曟椂闂?,
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏈€鍚庣櫥褰旾P',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'USER' COMMENT '瑙掕壊',
  `is_superuser` tinyint DEFAULT '0' COMMENT '鏄惁瓒呯骇绠＄悊鍛?,
  `is_staff` tinyint DEFAULT '0' COMMENT '鏄惁鍙互鐧诲綍绠＄悊鍚庡彴',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `username` (`username`) USING BTREE,
  UNIQUE KEY `email` (`email`) USING BTREE,
  KEY `idx_username` (`username`) USING BTREE,
  KEY `idx_email` (`email`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐢ㄦ埛琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (2,'testuser1777451358','updated@test.com','$2a$10$arsXJLYbH4lPKACfJVgfk.2JEmUyTol2K8OGkrcDQRSiDIXzySIIG','鏇存柊鐨勫鍚?,'13900139000',NULL,'enabled',NULL,NULL,0,'2026-04-29 16:29:20','2026-04-29 17:13:07',NULL,NULL,'USER',0,0),(3,'admin','admin@test.com','$2a$10$arsXJLYbH4lPKACfJVgfk.2JEmUyTol2K8OGkrcDQRSiDIXzySIIG','绠＄悊鍛?,'13700000000',NULL,'enabled',NULL,NULL,0,'2026-04-29 16:53:59','2026-04-29 17:13:10',NULL,NULL,'USER',1,0),(4,'testapi002','testapi002@test.com','$2a$10$YU647zaJ5lh2eEJRfMq9leDvQ4Z0uj0JFyO.1e5rgOW/R0VafYWDu',NULL,NULL,NULL,'enabled',NULL,NULL,0,'2026-04-30 09:48:41','2026-04-30 09:48:41',NULL,NULL,'USER',0,0),(5,'testuser','test@test.com','$2a$10$QUsPS4dprjiy9FhKxzXqRuYs0VdfSFTmCqfTiq8gntwzT.3E3XjHC','Test User',NULL,NULL,'enabled',NULL,NULL,0,'2026-04-30 17:24:04','2026-04-30 17:24:04',NULL,NULL,'USER',0,0);
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_profile`
--

DROP TABLE IF EXISTS `sys_user_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_profile` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `theme` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'light' COMMENT '涓婚: light=娴呰壊, dark=娣辫壊',
  `language` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'zh-hans' COMMENT '璇█: zh-hans=绠€浣撲腑鏂? en-us=鑻辨枃',
  `timezone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'Asia/Shanghai' COMMENT '鏃跺尯',
  `bio` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '涓汉绠€浠?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `user_id` (`user_id`) USING BTREE,
  KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐢ㄦ埛閰嶇疆琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_profile`
--

LOCK TABLES `sys_user_profile` WRITE;
/*!40000 ALTER TABLE `sys_user_profile` DISABLE KEYS */;
INSERT INTO `sys_user_profile` VALUES (2,2,'light','zh-hans','Asia/Shanghai',NULL,'2026-04-29 16:29:19','2026-04-29 16:29:19'),(3,3,'light','zh-hans','Asia/Shanghai',NULL,'2026-04-29 16:53:59','2026-04-29 16:53:59'),(4,4,'light','zh-hans','Asia/Shanghai',NULL,'2026-04-30 09:48:40','2026-04-30 09:48:40'),(5,5,'light','zh-hans','Asia/Shanghai',NULL,'2026-04-30 17:24:03','2026-04-30 17:24:03');
/*!40000 ALTER TABLE `sys_user_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tc_test_case`
--

DROP TABLE IF EXISTS `tc_test_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tc_test_case` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐢ㄤ緥ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄤ緥鏍囬',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鐢ㄤ緥鎻忚堪',
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'medium' COMMENT '浼樺厛绾? low=浣? medium=涓? high=楂? critical=绱ф€?,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'functional' COMMENT '绫诲瀷: functional=鍔熻兘娴嬭瘯, integration=闆嗘垚娴嬭瘯, api=API娴嬭瘯, ui=UI娴嬭瘯, performance=鎬ц兘娴嬭瘯, security=瀹夊叏娴嬭瘯',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'draft' COMMENT '鐘舵€? draft=鑽夌, active=婵€娲? deprecated=搴熷純',
  `precondition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鍓嶇疆鏉′欢',
  `expected_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '棰勬湡缁撴灉',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_priority` (`priority`) USING BTREE,
  KEY `idx_type` (`type`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_title` (`title`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='娴嬭瘯鐢ㄤ緥琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tc_test_case`
--

LOCK TABLES `tc_test_case` WRITE;
/*!40000 ALTER TABLE `tc_test_case` DISABLE KEYS */;
INSERT INTO `tc_test_case` VALUES (1,6,'鐧诲綍鍔熻兘娴嬭瘯','娴嬭瘯鐢ㄦ埛鐧诲綍鍔熻兘','high','functional','draft','鐢ㄦ埛宸叉敞鍐?,'鐧诲綍鎴愬姛',1,'2026-04-29 22:59:08','2026-04-29 23:09:32',NULL,3),(2,6,'鐧诲綍鍔熻兘娴嬭瘯','娴嬭瘯鐢ㄦ埛鐧诲綍鍔熻兘','high','functional','draft','鐢ㄦ埛宸叉敞鍐?,'鐧诲綍鎴愬姛',0,'2026-04-29 23:08:54','2026-04-29 23:08:54',3,3);
/*!40000 ALTER TABLE `tc_test_case` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tc_test_case_attachment`
--

DROP TABLE IF EXISTS `tc_test_case_attachment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tc_test_case_attachment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '闄勪欢ID',
  `test_case_id` bigint NOT NULL COMMENT '鐢ㄤ緥ID',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏂囦欢鍚?,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏂囦欢璺緞',
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏂囦欢绫诲瀷',
  `file_size` bigint DEFAULT NULL COMMENT '鏂囦欢澶у皬(瀛楄妭)',
  `uploaded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '涓婁紶鏃堕棿',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_test_case_id` (`test_case_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐢ㄤ緥闄勪欢琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tc_test_case_attachment`
--

LOCK TABLES `tc_test_case_attachment` WRITE;
/*!40000 ALTER TABLE `tc_test_case_attachment` DISABLE KEYS */;
/*!40000 ALTER TABLE `tc_test_case_attachment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tc_test_case_comment`
--

DROP TABLE IF EXISTS `tc_test_case_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tc_test_case_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璇勮ID',
  `test_case_id` bigint NOT NULL COMMENT '鐢ㄤ緥ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璇勮鍐呭',
  `parent_id` bigint DEFAULT NULL COMMENT '鐖惰瘎璁篒D(鍥炲)',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_test_case_id` (`test_case_id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐢ㄤ緥璇勮琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tc_test_case_comment`
--

LOCK TABLES `tc_test_case_comment` WRITE;
/*!40000 ALTER TABLE `tc_test_case_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `tc_test_case_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tc_test_case_label`
--

DROP TABLE IF EXISTS `tc_test_case_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tc_test_case_label` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏍囩ID',
  `test_case_id` bigint NOT NULL COMMENT '鐢ㄤ緥ID',
  `label_id` bigint NOT NULL COMMENT '鏍囩ID',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_test_case_id` (`test_case_id`) USING BTREE,
  KEY `idx_label_id` (`label_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐢ㄤ緥鏍囩鍏宠仈琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tc_test_case_label`
--

LOCK TABLES `tc_test_case_label` WRITE;
/*!40000 ALTER TABLE `tc_test_case_label` DISABLE KEYS */;
/*!40000 ALTER TABLE `tc_test_case_label` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tc_test_case_step`
--

DROP TABLE IF EXISTS `tc_test_case_step`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tc_test_case_step` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '姝ラID',
  `test_case_id` bigint NOT NULL COMMENT '鐢ㄤ緥ID',
  `step_number` int NOT NULL COMMENT '姝ラ搴忓彿',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姝ラ鎻忚堪',
  `expected_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '棰勬湡缁撴灉',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_test_case_id` (`test_case_id`) USING BTREE,
  KEY `idx_step_number` (`step_number`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐢ㄤ緥姝ラ琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tc_test_case_step`
--

LOCK TABLES `tc_test_case_step` WRITE;
/*!40000 ALTER TABLE `tc_test_case_step` DISABLE KEYS */;
INSERT INTO `tc_test_case_step` VALUES (1,1,1,'杈撳叆鐢ㄦ埛鍚?,'鐢ㄦ埛鍚嶆樉绀哄湪杈撳叆妗?,1,'2026-04-29 22:59:08','2026-04-29 23:09:32',NULL,NULL),(2,1,2,'杈撳叆瀵嗙爜','瀵嗙爜鏄剧ず涓?**',1,'2026-04-29 22:59:08','2026-04-29 23:09:32',NULL,NULL),(3,1,3,'鐐瑰嚮鐧诲綍鎸夐挳','璺宠浆鍒伴椤?,1,'2026-04-29 22:59:08','2026-04-29 23:09:32',NULL,NULL),(4,2,1,'杈撳叆鐢ㄦ埛鍚?,'鐢ㄦ埛鍚嶆樉绀哄湪杈撳叆妗?,0,'2026-04-29 23:08:54','2026-04-29 23:08:54',3,3),(5,2,2,'杈撳叆瀵嗙爜','瀵嗙爜鏄剧ず涓?**',0,'2026-04-29 23:08:54','2026-04-29 23:08:54',3,3),(6,2,3,'鐐瑰嚮鐧诲綍鎸夐挳','璺宠浆鍒伴椤?,0,'2026-04-29 23:08:54','2026-04-29 23:08:54',3,3);
/*!40000 ALTER TABLE `tc_test_case_step` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ts_test_suite`
--

DROP TABLE IF EXISTS `ts_test_suite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ts_test_suite` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '濂椾欢ID',
  `project_id` bigint NOT NULL COMMENT '椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '濂椾欢鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '濂椾欢鎻忚堪',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎺掑簭',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='娴嬭瘯濂椾欢琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ts_test_suite`
--

LOCK TABLES `ts_test_suite` WRITE;
/*!40000 ALTER TABLE `ts_test_suite` DISABLE KEYS */;
INSERT INTO `ts_test_suite` VALUES (1,6,'鐧诲綍鍔熻兘濂椾欢','鍖呭惈鎵€鏈夌櫥褰曠浉鍏崇敤渚?,0,1,'2026-04-29 23:09:46','2026-04-29 23:10:00',3,3);
/*!40000 ALTER TABLE `ts_test_suite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ts_test_suite_case`
--

DROP TABLE IF EXISTS `ts_test_suite_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ts_test_suite_case` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `suite_id` bigint NOT NULL COMMENT '濂椾欢ID',
  `test_case_id` bigint NOT NULL COMMENT '鐢ㄤ緥ID',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎺掑簭',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_suite_case` (`suite_id`,`test_case_id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_test_case_id` (`test_case_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='濂椾欢鐢ㄤ緥鍏宠仈琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ts_test_suite_case`
--

LOCK TABLES `ts_test_suite_case` WRITE;
/*!40000 ALTER TABLE `ts_test_suite_case` DISABLE KEYS */;
/*!40000 ALTER TABLE `ts_test_suite_case` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_ai_config`
--

DROP TABLE IF EXISTS `ui_ai_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_ai_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '閰嶇疆ID',
  `project_id` bigint NOT NULL COMMENT 'UI椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閰嶇疆鍚嶇О',
  `ai_model_config_id` bigint DEFAULT NULL COMMENT 'AI妯″瀷閰嶇疆ID',
  `mode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'text' COMMENT '妯″紡: text=鏂囨湰妯″紡, vision=瑙嗚妯″紡',
  `prompt_template` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鎻愮ず璇嶆ā鏉?,
  `is_enabled` tinyint NOT NULL DEFAULT '1' COMMENT '鏄惁鍚敤: 0=绂佺敤, 1=鍚敤',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_is_enabled` (`is_enabled`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI AI鏅鸿兘妯″紡閰嶇疆琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_ai_config`
--

LOCK TABLES `ui_ai_config` WRITE;
/*!40000 ALTER TABLE `ui_ai_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_ai_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_ai_execution`
--

DROP TABLE IF EXISTS `ui_ai_execution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_ai_execution` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鎵цID',
  `config_id` bigint NOT NULL COMMENT 'AI閰嶇疆ID',
  `task_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浠诲姟鎻忚堪',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '鐘舵€? pending=寰呮墽琛? running=鎵ц涓? completed=宸插畬鎴? failed=澶辫触',
  `steps` json DEFAULT NULL COMMENT '鎵ц姝ラ',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鎵ц缁撴灉',
  `executor_id` bigint NOT NULL COMMENT '鎵ц浜篒D',
  `started_at` datetime DEFAULT NULL COMMENT '寮€濮嬫椂闂?,
  `completed_at` datetime DEFAULT NULL COMMENT '瀹屾垚鏃堕棿',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_config_id` (`config_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI AI鎵ц璁板綍琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_ai_execution`
--

LOCK TABLES `ui_ai_execution` WRITE;
/*!40000 ALTER TABLE `ui_ai_execution` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_ai_execution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_element`
--

DROP TABLE IF EXISTS `ui_element`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_element` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍏冪礌ID',
  `project_id` bigint NOT NULL COMMENT 'UI椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍏冪礌鍚嶇О',
  `locator_strategy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀹氫綅绛栫暐: id, css, xpath, name, class_name, tag_name, link_text, partial_link_text',
  `locator_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀹氫綅鍣ㄥ€?,
  `element_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍏冪礌绫诲瀷: input, button, link, dropdown, checkbox, radio, text, image, container, table, form, modal',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍏冪礌鎻忚堪',
  `screenshot` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎴浘璺緞',
  `usage_count` int DEFAULT '0' COMMENT '浣跨敤娆℃暟',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_locator_strategy` (`locator_strategy`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI鍏冪礌琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_element`
--

LOCK TABLES `ui_element` WRITE;
/*!40000 ALTER TABLE `ui_element` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_element` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_element_backup`
--

DROP TABLE IF EXISTS `ui_element_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_element_backup` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `element_id` bigint NOT NULL COMMENT '鍏冪礌ID',
  `locator_strategy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '澶囩敤瀹氫綅绛栫暐',
  `locator_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '澶囩敤瀹氫綅鍣ㄥ€?,
  `priority` int NOT NULL DEFAULT '1' COMMENT '浼樺厛绾?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_element_id` (`element_id`) USING BTREE,
  KEY `idx_priority` (`priority`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI鍏冪礌澶囩敤瀹氫綅鍣ㄨ〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_element_backup`
--

LOCK TABLES `ui_element_backup` WRITE;
/*!40000 ALTER TABLE `ui_element_backup` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_element_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_element_group`
--

DROP TABLE IF EXISTS `ui_element_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_element_group` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍒嗙粍ID',
  `project_id` bigint NOT NULL COMMENT 'UI椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍒嗙粍鍚嶇О',
  `parent_id` bigint DEFAULT NULL COMMENT '鐖跺垎缁処D',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎺掑簭',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_parent_id` (`parent_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI鍏冪礌鍒嗙粍琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_element_group`
--

LOCK TABLES `ui_element_group` WRITE;
/*!40000 ALTER TABLE `ui_element_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_element_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_page_object`
--

DROP TABLE IF EXISTS `ui_page_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_page_object` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '椤甸潰瀵硅薄ID',
  `project_id` bigint NOT NULL COMMENT 'UI椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '椤甸潰瀵硅薄鍚嶇О',
  `url_pattern` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'URL妯″紡',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '椤甸潰鎻忚堪',
  `elements` json DEFAULT NULL COMMENT '椤甸潰鍏冪礌閰嶇疆',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI椤甸潰瀵硅薄琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_page_object`
--

LOCK TABLES `ui_page_object` WRITE;
/*!40000 ALTER TABLE `ui_page_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_page_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_project`
--

DROP TABLE IF EXISTS `ui_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_project` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '椤圭洰ID',
  `project_id` bigint NOT NULL COMMENT '鍏宠仈椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'UI椤圭洰鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '椤圭洰鎻忚堪',
  `engine` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'selenium' COMMENT '鑷姩鍖栧紩鎿? selenium, playwright',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI鑷姩鍖栭」鐩〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_project`
--

LOCK TABLES `ui_project` WRITE;
/*!40000 ALTER TABLE `ui_project` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_project` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_scheduled_task`
--

DROP TABLE IF EXISTS `ui_scheduled_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_scheduled_task` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '浠诲姟ID',
  `suite_id` bigint NOT NULL COMMENT '濂椾欢ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浠诲姟鍚嶇О',
  `trigger_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙﹀彂绫诲瀷: cron, interval, once',
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Cron琛ㄨ揪寮?,
  `interval_value` bigint DEFAULT NULL COMMENT '闂撮殧鍊?,
  `interval_unit` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '闂撮殧鍗曚綅',
  `once_time` datetime DEFAULT NULL COMMENT '鍗曟鎵ц鏃堕棿',
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'chromium' COMMENT '娴忚鍣?,
  `headless` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鏃犲ご妯″紡',
  `is_enabled` tinyint NOT NULL DEFAULT '1' COMMENT '鏄惁鍚敤: 0=绂佺敤, 1=鍚敤',
  `notification_config` json DEFAULT NULL COMMENT '閫氱煡閰嶇疆',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `last_run_at` datetime DEFAULT NULL COMMENT '涓婃鎵ц鏃堕棿',
  `next_run_at` datetime DEFAULT NULL COMMENT '涓嬫鎵ц鏃堕棿',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_is_enabled` (`is_enabled`) USING BTREE,
  KEY `idx_trigger_type` (`trigger_type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI瀹氭椂浠诲姟琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_scheduled_task`
--

LOCK TABLES `ui_scheduled_task` WRITE;
/*!40000 ALTER TABLE `ui_scheduled_task` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_scheduled_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_test_execution`
--

DROP TABLE IF EXISTS `ui_test_execution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_test_execution` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鎵цID',
  `suite_id` bigint NOT NULL COMMENT '濂椾欢ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT '鐘舵€? pending=寰呮墽琛? running=鎵ц涓? passed=閫氳繃, failed=澶辫触, stopped=宸插仠姝?,
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '娴忚鍣?,
  `headless` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鏃犲ご妯″紡',
  `executor_id` bigint NOT NULL COMMENT '鎵ц浜篒D',
  `started_at` datetime DEFAULT NULL COMMENT '寮€濮嬫椂闂?,
  `completed_at` datetime DEFAULT NULL COMMENT '瀹屾垚鏃堕棿',
  `total_count` int DEFAULT '0' COMMENT '鎬荤敤渚嬫暟',
  `passed_count` int DEFAULT '0' COMMENT '閫氳繃鏁?,
  `failed_count` int DEFAULT '0' COMMENT '澶辫触鏁?,
  `report_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎶ュ憡璺緞',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_executor_id` (`executor_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI娴嬭瘯鎵ц璁板綍琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_test_execution`
--

LOCK TABLES `ui_test_execution` WRITE;
/*!40000 ALTER TABLE `ui_test_execution` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_test_execution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_test_script`
--

DROP TABLE IF EXISTS `ui_test_script`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_test_script` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鑴氭湰ID',
  `project_id` bigint NOT NULL COMMENT 'UI椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鑴氭湰鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鑴氭湰鎻忚堪',
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'chromium' COMMENT '娴忚鍣? chromium, firefox, webkit, edge',
  `steps` json NOT NULL COMMENT '鎵ц姝ラ(JSON鏍煎紡)',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI娴嬭瘯鑴氭湰琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_test_script`
--

LOCK TABLES `ui_test_script` WRITE;
/*!40000 ALTER TABLE `ui_test_script` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_test_script` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_test_suite`
--

DROP TABLE IF EXISTS `ui_test_suite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_test_suite` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '濂椾欢ID',
  `project_id` bigint NOT NULL COMMENT 'UI椤圭洰ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '濂椾欢鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '濂椾欢鎻忚堪',
  `browser` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'chromium' COMMENT '娴忚鍣?,
  `headless` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鏃犲ご妯″紡: 0=鍚? 1=鏄?,
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `created_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `updated_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_project_id` (`project_id`) USING BTREE,
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI娴嬭瘯濂椾欢琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_test_suite`
--

LOCK TABLES `ui_test_suite` WRITE;
/*!40000 ALTER TABLE `ui_test_suite` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_test_suite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ui_test_suite_script`
--

DROP TABLE IF EXISTS `ui_test_suite_script`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ui_test_suite_script` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `suite_id` bigint NOT NULL COMMENT '濂椾欢ID',
  `script_id` bigint NOT NULL COMMENT '鑴氭湰ID',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '鎵ц椤哄簭',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '鏄惁鍒犻櫎: 0=鍚? 1=鏄?,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_suite_script` (`suite_id`,`script_id`) USING BTREE,
  KEY `idx_suite_id` (`suite_id`) USING BTREE,
  KEY `idx_script_id` (`script_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='UI濂椾欢鑴氭湰鍏宠仈琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ui_test_suite_script`
--

LOCK TABLES `ui_test_suite_script` WRITE;
/*!40000 ALTER TABLE `ui_test_suite_script` DISABLE KEYS */;
/*!40000 ALTER TABLE `ui_test_suite_script` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'testhub_java'
--

--
-- Dumping routines for database 'testhub_java'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-06  7:30:03
