-- MySQL dump 10.13  Distrib 5.5.47, for debian-linux-gnu (x86_64)
--
-- Host: mysql.engines.internal    Database: prosody
-- ------------------------------------------------------
-- Server version       5.5.47-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `prosody`
--

DROP TABLE IF EXISTS `prosody`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prosody` (
  `host` text,
  `user` text,
  `store` text,
  `key` text,
  `type` text,
  `value` mediumtext,
  KEY `prosody_index` (`host`(20),`user`(20),`store`(20),`key`(20))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prosody`
--

LOCK TABLES `prosody` WRITE;
/*!40000 ALTER TABLE `prosody` DISABLE KEYS */;
INSERT INTO `prosody` VALUES ('test.com','test','accounts','password','string','pass');
INSERT INTO `prosody` VALUES ('test.com','test3','accounts','password','string','pass3');
/*!40000 ALTER TABLE `prosody` ENABLE KEYS */;-----------
UNLOCK TABLES;ion       5.5.47-0ubuntu0.14.04.1
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;=@@CHARACTER_SET_RESULTS */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;ON */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;0 */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;REIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
-- Dump completed on 2016-05-06 18:08:48 SQL_NOTES=0 */;
