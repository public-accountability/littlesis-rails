-- MySQL dump 10.13  Distrib 5.7.19, for Linux (x86_64)
--
-- Host: mysql    Database: littlesis_test
-- ------------------------------------------------------
-- Server version	5.5.57

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
-- Table structure for table `address`
--

DROP TABLE IF EXISTS `address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `address` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `street1` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street2` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street3` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `county` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state_id` int(11) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `postal` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `latitude` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `longitude` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category_id` bigint(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `last_user_id` int(11) DEFAULT NULL,
  `accuracy` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `state_name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `state_id_idx` (`state_id`),
  KEY `country_id_idx` (`country_id`),
  KEY `category_id_idx` (`category_id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  CONSTRAINT `address_ibfk_2` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `address_ibfk_4` FOREIGN KEY (`category_id`) REFERENCES `address_category` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `address_ibfk_5` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `address_category`
--

DROP TABLE IF EXISTS `address_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `address_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `address_country`
--

DROP TABLE IF EXISTS `address_country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `address_country` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `address_state`
--

DROP TABLE IF EXISTS `address_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `address_state` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `abbreviation` varchar(2) COLLATE utf8_unicode_ci NOT NULL,
  `country_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`name`),
  KEY `country_id_idx` (`country_id`),
  CONSTRAINT `address_state_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `address_country` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alias`
--

DROP TABLE IF EXISTS `alias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alias` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `name` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `context` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_primary` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`entity_id`,`name`,`context`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  KEY `name_idx` (`name`),
  CONSTRAINT `alias_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alias_ibfk_2` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_request`
--

DROP TABLE IF EXISTS `api_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_request` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `api_key` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `resource` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `ip_address` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `api_key_idx` (`api_key`),
  KEY `created_at_idx` (`created_at`),
  CONSTRAINT `api_request_ibfk_1` FOREIGN KEY (`api_key`) REFERENCES `api_user` (`api_key`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_tokens`
--

DROP TABLE IF EXISTS `api_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_api_tokens_on_token` (`token`),
  UNIQUE KEY `index_api_tokens_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_user`
--

DROP TABLE IF EXISTS `api_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `api_key` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `name_first` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `name_last` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `reason` longtext COLLATE utf8_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `request_limit` int(4) NOT NULL DEFAULT '10000',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `api_key_unique_idx` (`api_key`),
  UNIQUE KEY `email_unique_idx` (`email`),
  KEY `api_key_idx` (`api_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article`
--

DROP TABLE IF EXISTS `article`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `authors` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` longtext COLLATE utf8_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `source_id` int(11) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `is_indexed` tinyint(1) NOT NULL DEFAULT '0',
  `reviewed_at` datetime DEFAULT NULL,
  `reviewed_by_user_id` bigint(20) DEFAULT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `is_hidden` tinyint(1) NOT NULL DEFAULT '0',
  `found_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `source_id_idx` (`source_id`),
  CONSTRAINT `article_ibfk_1` FOREIGN KEY (`source_id`) REFERENCES `article_source` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article_entities`
--

DROP TABLE IF EXISTS `article_entities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article_entities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_article_entities_on_entity_id_and_article_id` (`entity_id`,`article_id`),
  KEY `index_article_entities_on_is_featured` (`is_featured`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article_entity`
--

DROP TABLE IF EXISTS `article_entity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article_entity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `original_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `reviewed_by_user_id` bigint(20) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `article_id_idx` (`article_id`),
  KEY `entity_id_idx` (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article_source`
--

DROP TABLE IF EXISTS `article_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `article_source` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `abbreviation` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `articles`
--

DROP TABLE IF EXISTS `articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `snippet` varchar(255) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_by_user_id` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bootsy_image_galleries`
--

DROP TABLE IF EXISTS `bootsy_image_galleries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bootsy_image_galleries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bootsy_resource_id` int(11) DEFAULT NULL,
  `bootsy_resource_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bootsy_images`
--

DROP TABLE IF EXISTS `bootsy_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bootsy_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_file` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_gallery_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `business`
--

DROP TABLE IF EXISTS `business`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `business` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `annual_profit` bigint(20) DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  CONSTRAINT `business_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `business_industry`
--

DROP TABLE IF EXISTS `business_industry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `business_industry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `business_id` bigint(20) NOT NULL,
  `industry_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `business_id_idx` (`business_id`),
  KEY `industry_id_idx` (`industry_id`),
  CONSTRAINT `business_industry_ibfk_1` FOREIGN KEY (`industry_id`) REFERENCES `industry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `business_industry_ibfk_2` FOREIGN KEY (`business_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `business_person`
--

DROP TABLE IF EXISTS `business_person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `business_person` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sec_cik` bigint(20) DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  CONSTRAINT `business_person_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `campaigns`
--

DROP TABLE IF EXISTS `campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `tagline` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `logo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cover` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `findings` mediumtext COLLATE utf8_unicode_ci,
  `howto` mediumtext COLLATE utf8_unicode_ci,
  `custom_html` mediumtext COLLATE utf8_unicode_ci,
  `logo_credit` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_campaigns_on_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `candidate_district`
--

DROP TABLE IF EXISTS `candidate_district`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `candidate_district` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `candidate_id` bigint(20) NOT NULL,
  `district_id` bigint(20) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`candidate_id`,`district_id`),
  KEY `district_id_idx` (`district_id`),
  CONSTRAINT `candidate_district_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `political_district` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chat_user`
--

DROP TABLE IF EXISTS `chat_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `room` bigint(20) NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `room_user_id_idx` (`room`,`user_id`),
  KEY `user_id_idx` (`user_id`),
  KEY `room_updated_at_user_id_idx` (`room`,`updated_at`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `couple`
--

DROP TABLE IF EXISTS `couple`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `couple` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) NOT NULL,
  `partner1_id` int(11) DEFAULT NULL,
  `partner2_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_couple_on_entity_id` (`entity_id`),
  KEY `index_couple_on_partner1_id` (`partner1_id`),
  KEY `index_couple_on_partner2_id` (`partner2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_key`
--

DROP TABLE IF EXISTS `custom_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_key` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `value` longtext COLLATE utf8_unicode_ci,
  `description` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `object_model` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `object_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `object_name_idx` (`object_model`,`object_id`,`name`),
  UNIQUE KEY `object_name_value_idx` (`object_model`,`object_id`,`name`,`value`(100)),
  KEY `object_idx` (`object_model`,`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `degree`
--

DROP TABLE IF EXISTS `degree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `degree` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `abbreviation` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delayed_jobs`
--

DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) NOT NULL DEFAULT '0',
  `attempts` int(11) NOT NULL DEFAULT '0',
  `handler` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `last_error` mediumtext COLLATE utf8_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `queue` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `domain`
--

DROP TABLE IF EXISTS `domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `donation`
--

DROP TABLE IF EXISTS `donation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `donation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bundler_id` bigint(20) DEFAULT NULL,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `bundler_id_idx` (`bundler_id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `donation_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `donation_ibfk_2` FOREIGN KEY (`bundler_id`) REFERENCES `entity` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `education`
--

DROP TABLE IF EXISTS `education`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `education` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `degree_id` bigint(20) DEFAULT NULL,
  `field` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_dropout` tinyint(1) DEFAULT NULL,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `degree_id_idx` (`degree_id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `education_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `education_ibfk_2` FOREIGN KEY (`degree_id`) REFERENCES `degree` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `elected_representative`
--

DROP TABLE IF EXISTS `elected_representative`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `elected_representative` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bioguide_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `govtrack_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crp_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pvs_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `watchdog_id` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `crp_id_idx` (`crp_id`),
  CONSTRAINT `elected_representative_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email`
--

DROP TABLE IF EXISTS `email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `address` varchar(60) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `last_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  CONSTRAINT `email_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `email_ibfk_2` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `entity`
--

DROP TABLE IF EXISTS `entity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entity` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `blurb` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `summary` longtext COLLATE utf8_unicode_ci,
  `notes` longtext COLLATE utf8_unicode_ci,
  `website` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` bigint(20) DEFAULT NULL,
  `primary_ext` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `start_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `end_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_current` tinyint(1) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `last_user_id` int(11) DEFAULT NULL,
  `merged_id` int(11) DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `link_count` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `parent_id_idx` (`parent_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  KEY `updated_at_idx` (`updated_at`),
  KEY `name_idx` (`name`),
  KEY `blurb_idx` (`blurb`),
  KEY `website_idx` (`website`),
  KEY `search_idx` (`name`,`blurb`,`website`),
  KEY `created_at_idx` (`created_at`),
  KEY `index_entity_on_delta` (`delta`),
  CONSTRAINT `entity_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `entity` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `entity_ibfk_2` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `entity_fields`
--

DROP TABLE IF EXISTS `entity_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entity_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `value` varchar(255) NOT NULL,
  `is_admin` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_entity_fields_on_entity_id_and_field_id` (`entity_id`,`field_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `extension_definition`
--

DROP TABLE IF EXISTS `extension_definition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `extension_definition` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `display_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `has_fields` tinyint(1) NOT NULL DEFAULT '0',
  `parent_id` bigint(20) DEFAULT NULL,
  `tier` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id_idx` (`parent_id`),
  KEY `tier_idx` (`tier`),
  KEY `name_idx` (`name`),
  CONSTRAINT `extension_definition_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `extension_definition` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `extension_record`
--

DROP TABLE IF EXISTS `extension_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `extension_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `definition_id` bigint(20) NOT NULL,
  `last_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `definition_id_idx` (`definition_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  CONSTRAINT `extension_record_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `extension_record_ibfk_2` FOREIGN KEY (`definition_id`) REFERENCES `extension_definition` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `extension_record_ibfk_3` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `external_key`
--

DROP TABLE IF EXISTS `external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_key` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `external_id` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `domain_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`external_id`,`domain_id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `domain_id_idx` (`domain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `family`
--

DROP TABLE IF EXISTS `family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `family` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `is_nonbiological` tinyint(1) DEFAULT NULL,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `family_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fec_filing`
--

DROP TABLE IF EXISTS `fec_filing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fec_filing` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `relationship_id` bigint(20) DEFAULT NULL,
  `amount` bigint(20) DEFAULT NULL,
  `fec_filing_id` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crp_cycle` bigint(20) DEFAULT NULL,
  `crp_id` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `start_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `end_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_current` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `fec_filing_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fedspending_filing`
--

DROP TABLE IF EXISTS `fedspending_filing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fedspending_filing` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `relationship_id` bigint(20) DEFAULT NULL,
  `amount` bigint(20) DEFAULT NULL,
  `goods` longtext COLLATE utf8_unicode_ci,
  `district_id` bigint(20) DEFAULT NULL,
  `fedspending_id` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `end_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_current` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`),
  KEY `district_id_idx` (`district_id`),
  CONSTRAINT `fedspending_filing_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fedspending_filing_ibfk_2` FOREIGN KEY (`district_id`) REFERENCES `political_district` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fields`
--

DROP TABLE IF EXISTS `fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `display_name` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'string',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_fields_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gender`
--

DROP TABLE IF EXISTS `gender`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gender` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `generic`
--

DROP TABLE IF EXISTS `generic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generic` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `government_body`
--

DROP TABLE IF EXISTS `government_body`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `government_body` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `is_federal` tinyint(1) DEFAULT NULL,
  `state_id` bigint(20) DEFAULT NULL,
  `city` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `county` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `state_id_idx` (`state_id`),
  KEY `entity_id_idx` (`entity_id`),
  CONSTRAINT `government_body_ibfk_1` FOREIGN KEY (`state_id`) REFERENCES `address_state` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `government_body_ibfk_2` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_lists`
--

DROP TABLE IF EXISTS `group_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) DEFAULT NULL,
  `list_id` int(11) DEFAULT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_group_lists_on_group_id_and_list_id` (`group_id`,`list_id`),
  KEY `index_group_lists_on_list_id` (`list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_users`
--

DROP TABLE IF EXISTS `group_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_group_users_on_group_id_and_user_id` (`group_id`,`user_id`),
  KEY `index_group_users_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tagline` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci,
  `is_private` tinyint(1) NOT NULL DEFAULT '0',
  `slug` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_network_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `logo` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `findings` mediumtext COLLATE utf8_unicode_ci,
  `howto` mediumtext COLLATE utf8_unicode_ci,
  `featured_list_id` int(11) DEFAULT NULL,
  `cover` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `logo_credit` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_groups_on_slug` (`slug`),
  KEY `index_groups_on_delta` (`delta`),
  KEY `index_groups_on_campaign_id` (`campaign_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hierarchy`
--

DROP TABLE IF EXISTS `hierarchy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hierarchy` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image`
--

DROP TABLE IF EXISTS `image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `filename` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `caption` longtext COLLATE utf8_unicode_ci,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `is_free` tinyint(1) DEFAULT NULL,
  `url` varchar(400) COLLATE utf8_unicode_ci DEFAULT NULL,
  `width` bigint(20) DEFAULT NULL,
  `height` bigint(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `last_user_id` int(11) DEFAULT NULL,
  `has_square` tinyint(1) NOT NULL DEFAULT '0',
  `address_id` int(11) DEFAULT NULL,
  `raw_address` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `has_face` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  KEY `index_image_on_address_id` (`address_id`),
  CONSTRAINT `image_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `image_ibfk_2` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `industries`
--

DROP TABLE IF EXISTS `industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `industry_id` varchar(255) NOT NULL,
  `sector_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_industries_on_industry_id` (`industry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `industry`
--

DROP TABLE IF EXISTS `industry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `industry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `context` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `link`
--

DROP TABLE IF EXISTS `link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `link` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity1_id` bigint(20) NOT NULL,
  `entity2_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `relationship_id` bigint(20) NOT NULL,
  `is_reverse` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity1_id_idx` (`entity1_id`),
  KEY `entity2_id_idx` (`entity2_id`),
  KEY `category_id_idx` (`category_id`),
  KEY `relationship_id_idx` (`relationship_id`),
  KEY `index_link_on_entity1_id_and_category_id` (`entity1_id`,`category_id`),
  KEY `index_link_on_entity1_id_and_category_id_and_is_reverse` (`entity1_id`,`category_id`,`is_reverse`),
  CONSTRAINT `link_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`),
  CONSTRAINT `link_ibfk_2` FOREIGN KEY (`entity2_id`) REFERENCES `entity` (`id`),
  CONSTRAINT `link_ibfk_3` FOREIGN KEY (`entity1_id`) REFERENCES `entity` (`id`),
  CONSTRAINT `link_ibfk_4` FOREIGN KEY (`category_id`) REFERENCES `relationship_category` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lobby_filing`
--

DROP TABLE IF EXISTS `lobby_filing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby_filing` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `federal_filing_id` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `amount` bigint(20) DEFAULT NULL,
  `year` bigint(20) DEFAULT NULL,
  `period` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `report_type` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `end_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_current` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lobby_filing_lobby_issue`
--

DROP TABLE IF EXISTS `lobby_filing_lobby_issue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby_filing_lobby_issue` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `issue_id` bigint(20) NOT NULL,
  `lobby_filing_id` bigint(20) NOT NULL,
  `specific_issue` longtext COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `issue_id_idx` (`issue_id`),
  KEY `lobby_filing_id_idx` (`lobby_filing_id`),
  CONSTRAINT `lobby_filing_lobby_issue_ibfk_1` FOREIGN KEY (`lobby_filing_id`) REFERENCES `lobby_filing` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `lobby_filing_lobby_issue_ibfk_2` FOREIGN KEY (`issue_id`) REFERENCES `lobby_issue` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lobby_filing_lobbyist`
--

DROP TABLE IF EXISTS `lobby_filing_lobbyist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby_filing_lobbyist` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lobbyist_id` bigint(20) NOT NULL,
  `lobby_filing_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `lobbyist_id_idx` (`lobbyist_id`),
  KEY `lobby_filing_id_idx` (`lobby_filing_id`),
  CONSTRAINT `lobby_filing_lobbyist_ibfk_1` FOREIGN KEY (`lobbyist_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `lobby_filing_lobbyist_ibfk_2` FOREIGN KEY (`lobby_filing_id`) REFERENCES `lobby_filing` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lobby_filing_relationship`
--

DROP TABLE IF EXISTS `lobby_filing_relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby_filing_relationship` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `relationship_id` bigint(20) NOT NULL,
  `lobby_filing_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`),
  KEY `lobby_filing_id_idx` (`lobby_filing_id`),
  CONSTRAINT `lobby_filing_relationship_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`),
  CONSTRAINT `lobby_filing_relationship_ibfk_2` FOREIGN KEY (`lobby_filing_id`) REFERENCES `lobby_filing` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lobby_issue`
--

DROP TABLE IF EXISTS `lobby_issue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby_issue` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lobbying`
--

DROP TABLE IF EXISTS `lobbying`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobbying` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `lobbying_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lobbyist`
--

DROP TABLE IF EXISTS `lobbyist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobbyist` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lda_registrant_id` bigint(20) DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  CONSTRAINT `lobbyist_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ls_list`
--

DROP TABLE IF EXISTS `ls_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ls_list` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `description` longtext COLLATE utf8_unicode_ci,
  `is_ranked` tinyint(1) NOT NULL DEFAULT '0',
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `is_network` tinyint(1) NOT NULL DEFAULT '0',
  `display_name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `featured_list_id` bigint(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_user_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `custom_field_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `is_private` tinyint(1) DEFAULT '0',
  `creator_user_id` int(11) DEFAULT NULL,
  `short_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `last_user_id_idx` (`last_user_id`),
  KEY `featured_list_id` (`featured_list_id`),
  KEY `index_ls_list_on_delta` (`delta`),
  KEY `index_ls_list_on_name` (`name`),
  CONSTRAINT `ls_list_ibfk_1` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `ls_list_ibfk_2` FOREIGN KEY (`featured_list_id`) REFERENCES `ls_list` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ls_list_entity`
--

DROP TABLE IF EXISTS `ls_list_entity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ls_list_entity` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `list_id` bigint(20) NOT NULL,
  `entity_id` bigint(20) NOT NULL,
  `rank` bigint(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_user_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `custom_field` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `list_id_idx` (`list_id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  KEY `created_at_idx` (`created_at`),
  KEY `entity_deleted_list_idx` (`entity_id`,`is_deleted`,`list_id`),
  KEY `list_deleted_entity_idx` (`list_id`,`is_deleted`,`entity_id`),
  CONSTRAINT `ls_list_entity_ibfk_1` FOREIGN KEY (`list_id`) REFERENCES `ls_list` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ls_list_entity_ibfk_2` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ls_list_entity_ibfk_3` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `map_annotations`
--

DROP TABLE IF EXISTS `map_annotations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `map_annotations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `map_id` int(11) NOT NULL,
  `order` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text,
  `highlighted_entity_ids` varchar(255) DEFAULT NULL,
  `highlighted_rel_ids` varchar(255) DEFAULT NULL,
  `highlighted_text_ids` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_map_annotations_on_map_id` (`map_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `membership`
--

DROP TABLE IF EXISTS `membership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `membership` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dues` bigint(20) DEFAULT NULL,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `membership_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `modification`
--

DROP TABLE IF EXISTS `modification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `modification` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `object_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) NOT NULL DEFAULT '1',
  `is_create` tinyint(1) NOT NULL DEFAULT '0',
  `is_delete` tinyint(1) NOT NULL DEFAULT '0',
  `is_merge` tinyint(1) NOT NULL DEFAULT '0',
  `merge_object_id` bigint(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `object_model` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `object_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `object_idx` (`object_model`,`object_id`),
  KEY `user_id_idx` (`user_id`),
  KEY `is_create_idx` (`is_create`),
  KEY `is_delete_idx` (`is_delete`),
  KEY `object_model_idx` (`object_model`),
  KEY `object_id_idx` (`object_id`),
  KEY `points_summary_idx` (`user_id`,`is_create`,`object_model`),
  CONSTRAINT `modification_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `modification_field`
--

DROP TABLE IF EXISTS `modification_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `modification_field` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `modification_id` bigint(20) NOT NULL,
  `field_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `old_value` longtext COLLATE utf8_unicode_ci,
  `new_value` longtext COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `modification_id_idx` (`modification_id`),
  CONSTRAINT `modification_field_ibfk_1` FOREIGN KEY (`modification_id`) REFERENCES `modification` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `network_map`
--

DROP TABLE IF EXISTS `network_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `network_map` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `data` longtext COLLATE utf8_unicode_ci NOT NULL,
  `entity_ids` varchar(5000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rel_ids` varchar(5000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `title` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` longtext COLLATE utf8_unicode_ci,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `zoom` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '1',
  `is_private` tinyint(1) NOT NULL DEFAULT '0',
  `thumbnail` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `index_data` longtext COLLATE utf8_unicode_ci,
  `secret` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `graph_data` mediumtext COLLATE utf8_unicode_ci,
  `annotations_data` text COLLATE utf8_unicode_ci,
  `annotations_count` int(11) NOT NULL DEFAULT '0',
  `list_sources` tinyint(1) NOT NULL DEFAULT '0',
  `is_cloneable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `user_id_idx` (`user_id`),
  KEY `index_network_map_on_delta` (`delta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `note`
--

DROP TABLE IF EXISTS `note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci NOT NULL,
  `body_raw` text COLLATE utf8_unicode_ci NOT NULL,
  `alerted_user_names` varchar(500) COLLATE utf8_unicode_ci DEFAULT NULL,
  `alerted_user_ids` varchar(500) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entity_ids` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `relationship_ids` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lslist_ids` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sfguardgroup_ids` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `network_ids` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_private` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_legacy` tinyint(1) NOT NULL DEFAULT '0',
  `sf_guard_user_id` int(11) DEFAULT NULL,
  `new_user_id` int(11) DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `user_id_idx` (`user_id`),
  KEY `updated_at_idx` (`updated_at`),
  KEY `is_private_idx` (`is_private`),
  KEY `alerted_user_ids_idx` (`alerted_user_ids`(255)),
  KEY `entity_ids_idx` (`entity_ids`),
  KEY `relationship_ids_idx` (`relationship_ids`),
  KEY `lslist_ids_idx` (`lslist_ids`),
  KEY `index_note_on_delta` (`delta`),
  KEY `index_note_on_new_user_id` (`new_user_id`),
  KEY `index_note_on_sf_guard_user_id` (`sf_guard_user_id`),
  CONSTRAINT `note_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sf_guard_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `note_entities`
--

DROP TABLE IF EXISTS `note_entities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note_entities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_note_entities_on_note_id_and_entity_id` (`note_id`,`entity_id`),
  KEY `index_note_entities_on_entity_id` (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `note_groups`
--

DROP TABLE IF EXISTS `note_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_note_groups_on_note_id_and_group_id` (`note_id`,`group_id`),
  KEY `index_note_groups_on_group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `note_lists`
--

DROP TABLE IF EXISTS `note_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) DEFAULT NULL,
  `list_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_note_lists_on_note_id_and_list_id` (`note_id`,`list_id`),
  KEY `index_note_lists_on_list_id` (`list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `note_networks`
--

DROP TABLE IF EXISTS `note_networks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note_networks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) DEFAULT NULL,
  `network_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_note_networks_on_note_id_and_network_id` (`note_id`,`network_id`),
  KEY `index_note_networks_on_network_id` (`network_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `note_relationships`
--

DROP TABLE IF EXISTS `note_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note_relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) DEFAULT NULL,
  `relationship_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_note_relationships_on_note_id_and_relationship_id` (`note_id`,`relationship_id`),
  KEY `index_note_relationships_on_relationship_id` (`relationship_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `note_users`
--

DROP TABLE IF EXISTS `note_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_note_users_on_note_id_and_user_id` (`note_id`,`user_id`),
  KEY `index_note_users_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ny_disclosures`
--

DROP TABLE IF EXISTS `ny_disclosures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ny_disclosures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filer_id` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `report_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_code` varchar(1) COLLATE utf8_unicode_ci NOT NULL,
  `e_year` varchar(4) COLLATE utf8_unicode_ci NOT NULL,
  `transaction_id` bigint(20) NOT NULL,
  `schedule_transaction_date` date DEFAULT NULL,
  `original_date` date DEFAULT NULL,
  `contrib_code` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contrib_type_code` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `corp_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mid_init` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL,
  `check_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `check_date` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount1` float DEFAULT NULL,
  `amount2` float DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `other_recpt_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `purpose_code1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `purpose_code2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `explanation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_type` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bank_loan_check_box` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crerec_uid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crerec_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_ny_disclosures_on_filer_id` (`filer_id`),
  KEY `index_ny_disclosures_on_e_year` (`e_year`),
  KEY `index_ny_disclosures_on_contrib_code` (`contrib_code`),
  KEY `index_ny_disclosures_on_original_date` (`original_date`),
  KEY `index_ny_disclosures_on_delta` (`delta`),
  KEY `index_filer_report_trans_date_e_year` (`filer_id`,`report_id`,`transaction_id`,`schedule_transaction_date`,`e_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ny_disclosures_staging`
--

DROP TABLE IF EXISTS `ny_disclosures_staging`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ny_disclosures_staging` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filer_id` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `report_id` varchar(1) COLLATE utf8_unicode_ci NOT NULL,
  `transaction_code` varchar(1) COLLATE utf8_unicode_ci NOT NULL,
  `e_year` varchar(4) COLLATE utf8_unicode_ci NOT NULL,
  `transaction_id` bigint(20) NOT NULL,
  `schedule_transaction_date` date NOT NULL,
  `original_date` date DEFAULT NULL,
  `contrib_code` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contrib_type_code` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `corp_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mid_init` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL,
  `check_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `check_date` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount1` float DEFAULT NULL,
  `amount2` float DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `other_recpt_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `purpose_code1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `purpose_code2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `explanation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transfer_type` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bank_loan_check_box` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crerec_uid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crerec_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ny_filer_entities`
--

DROP TABLE IF EXISTS `ny_filer_entities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ny_filer_entities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ny_filer_id` int(11) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `is_committee` tinyint(1) DEFAULT NULL,
  `cmte_entity_id` int(11) DEFAULT NULL,
  `e_year` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filer_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `office` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ny_filer_entities_on_ny_filer_id` (`ny_filer_id`),
  KEY `index_ny_filer_entities_on_entity_id` (`entity_id`),
  KEY `index_ny_filer_entities_on_is_committee` (`is_committee`),
  KEY `index_ny_filer_entities_on_cmte_entity_id` (`cmte_entity_id`),
  KEY `index_ny_filer_entities_on_filer_id` (`filer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ny_filers`
--

DROP TABLE IF EXISTS `ny_filers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ny_filers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filer_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filer_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `committee_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `office` int(11) DEFAULT NULL,
  `district` int(11) DEFAULT NULL,
  `treas_first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `treas_last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_ny_filers_on_filer_id` (`filer_id`),
  KEY `index_ny_filers_on_filer_type` (`filer_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ny_matches`
--

DROP TABLE IF EXISTS `ny_matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ny_matches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ny_disclosure_id` int(11) DEFAULT NULL,
  `donor_id` int(11) DEFAULT NULL,
  `recip_id` int(11) DEFAULT NULL,
  `relationship_id` int(11) DEFAULT NULL,
  `matched_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_ny_matches_on_ny_disclosure_id` (`ny_disclosure_id`),
  KEY `index_ny_matches_on_donor_id` (`donor_id`),
  KEY `index_ny_matches_on_recip_id` (`recip_id`),
  KEY `index_ny_matches_on_relationship_id` (`relationship_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `object_tag`
--

DROP TABLE IF EXISTS `object_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_tag` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tag_id` bigint(20) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `object_model` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `object_id` bigint(20) NOT NULL,
  `last_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`object_model`,`object_id`,`tag_id`),
  KEY `object_idx` (`object_model`,`object_id`),
  KEY `tag_id_idx` (`tag_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  CONSTRAINT `object_tag_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `object_tag_ibfk_2` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `org`
--

DROP TABLE IF EXISTS `org`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `org` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `name_nick` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `employees` bigint(20) DEFAULT NULL,
  `revenue` bigint(20) DEFAULT NULL,
  `fedspending_id` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lda_registrant_id` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  CONSTRAINT `org_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `os_candidates`
--

DROP TABLE IF EXISTS `os_candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os_candidates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cycle` varchar(255) NOT NULL,
  `feccandid` varchar(255) NOT NULL,
  `crp_id` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `party` varchar(1) DEFAULT NULL,
  `distid_runfor` varchar(255) DEFAULT NULL,
  `distid_current` varchar(255) DEFAULT NULL,
  `currcand` tinyint(1) DEFAULT NULL,
  `cyclecand` tinyint(1) DEFAULT NULL,
  `crpico` varchar(1) DEFAULT NULL,
  `recipcode` varchar(2) DEFAULT NULL,
  `nopacs` varchar(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_os_candidates_on_crp_id` (`crp_id`),
  KEY `index_os_candidates_on_feccandid` (`feccandid`),
  KEY `index_os_candidates_on_cycle_and_crp_id` (`cycle`,`crp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `os_category`
--

DROP TABLE IF EXISTS `os_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `category_id` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `category_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `industry_id` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `industry_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `sector_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_id_idx` (`category_id`),
  UNIQUE KEY `unique_name_idx` (`category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `os_committees`
--

DROP TABLE IF EXISTS `os_committees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os_committees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cycle` varchar(4) NOT NULL,
  `cmte_id` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `affiliate` varchar(255) DEFAULT NULL,
  `ultorg` varchar(255) DEFAULT NULL,
  `recipid` varchar(255) DEFAULT NULL,
  `recipcode` varchar(2) DEFAULT NULL,
  `feccandid` varchar(255) DEFAULT NULL,
  `party` varchar(1) DEFAULT NULL,
  `primcode` varchar(5) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `sensitive` tinyint(1) DEFAULT NULL,
  `foreign` tinyint(1) DEFAULT NULL,
  `active_in_cycle` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_os_committees_on_cmte_id` (`cmte_id`),
  KEY `index_os_committees_on_recipid` (`recipid`),
  KEY `index_os_committees_on_cmte_id_and_cycle` (`cmte_id`,`cycle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `os_donations`
--

DROP TABLE IF EXISTS `os_donations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os_donations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cycle` varchar(4) NOT NULL,
  `fectransid` varchar(19) NOT NULL,
  `contribid` varchar(12) DEFAULT NULL,
  `contrib` varchar(255) DEFAULT NULL,
  `recipid` varchar(9) DEFAULT NULL,
  `orgname` varchar(255) DEFAULT NULL,
  `ultorg` varchar(255) DEFAULT NULL,
  `realcode` varchar(5) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(2) DEFAULT NULL,
  `zip` varchar(5) DEFAULT NULL,
  `recipcode` varchar(2) DEFAULT NULL,
  `transactiontype` varchar(3) DEFAULT NULL,
  `cmteid` varchar(9) DEFAULT NULL,
  `otherid` varchar(9) DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `microfilm` varchar(30) DEFAULT NULL,
  `occupation` varchar(255) DEFAULT NULL,
  `employer` varchar(255) DEFAULT NULL,
  `source` varchar(5) DEFAULT NULL,
  `fec_cycle_id` varchar(24) NOT NULL,
  `name_last` varchar(255) DEFAULT NULL,
  `name_first` varchar(255) DEFAULT NULL,
  `name_middle` varchar(255) DEFAULT NULL,
  `name_suffix` varchar(255) DEFAULT NULL,
  `name_prefix` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_os_donations_on_fec_cycle_id` (`fec_cycle_id`),
  KEY `index_os_donations_on_fectransid` (`fectransid`),
  KEY `index_os_donations_on_cycle` (`cycle`),
  KEY `index_os_donations_on_microfilm` (`microfilm`),
  KEY `index_os_donations_on_date` (`date`),
  KEY `index_os_donations_on_contribid` (`contribid`),
  KEY `index_os_donations_on_fectransid_and_cycle` (`fectransid`,`cycle`),
  KEY `index_os_donations_on_name_last_and_name_first` (`name_last`,`name_first`),
  KEY `index_os_donations_on_realcode` (`realcode`),
  KEY `index_os_donations_on_amount` (`amount`),
  KEY `index_os_donations_on_realcode_and_amount` (`realcode`,`amount`),
  KEY `index_os_donations_on_state` (`state`),
  KEY `index_os_donations_on_recipid` (`recipid`),
  KEY `index_os_donations_on_recipid_and_amount` (`recipid`,`amount`),
  KEY `index_os_donations_on_zip` (`zip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `os_entity_category`
--

DROP TABLE IF EXISTS `os_entity_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os_entity_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `category_id` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `source` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`entity_id`,`category_id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `category_id_idx` (`category_id`),
  CONSTRAINT `os_entity_category_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `os_entity_donor`
--

DROP TABLE IF EXISTS `os_entity_donor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os_entity_donor` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `donor_id` varchar(12) CHARACTER SET utf8 DEFAULT NULL,
  `match_code` bigint(20) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `reviewed_by_user_id` bigint(20) DEFAULT NULL,
  `is_processed` tinyint(1) NOT NULL DEFAULT '0',
  `is_synced` tinyint(1) NOT NULL DEFAULT '1',
  `reviewed_at` datetime DEFAULT NULL,
  `locked_by_user_id` bigint(20) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `entity_donor_idx` (`entity_id`,`donor_id`),
  KEY `reviewed_at_idx` (`reviewed_at`),
  KEY `locked_at_idx` (`locked_at`),
  KEY `is_synced_idx` (`is_synced`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `os_entity_preprocess`
--

DROP TABLE IF EXISTS `os_entity_preprocess`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os_entity_preprocess` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `cycle` varchar(4) COLLATE utf8_unicode_ci NOT NULL,
  `processed_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `entity_cycle_idx` (`entity_id`,`cycle`),
  KEY `entity_id_idx` (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `os_entity_transaction`
--

DROP TABLE IF EXISTS `os_entity_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os_entity_transaction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) NOT NULL,
  `cycle` varchar(4) NOT NULL,
  `transaction_id` varchar(30) NOT NULL,
  `match_code` bigint(20) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `is_processed` tinyint(1) NOT NULL DEFAULT '0',
  `is_synced` tinyint(1) NOT NULL DEFAULT '1',
  `reviewed_by_user_id` bigint(20) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `locked_by_user_id` bigint(20) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `entity_cycle_transaction_idx` (`entity_id`,`cycle`,`transaction_id`),
  KEY `is_synced_idx` (`is_synced`),
  KEY `reviewed_at_idx` (`reviewed_at`),
  KEY `locked_at_idx` (`locked_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `os_matches`
--

DROP TABLE IF EXISTS `os_matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `os_matches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `os_donation_id` int(11) NOT NULL,
  `donation_id` int(11) DEFAULT NULL,
  `donor_id` int(11) NOT NULL,
  `recip_id` int(11) DEFAULT NULL,
  `relationship_id` int(11) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `matched_by` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `cmte_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_os_matches_on_os_donation_id` (`os_donation_id`),
  KEY `index_os_matches_on_donor_id` (`donor_id`),
  KEY `index_os_matches_on_recip_id` (`recip_id`),
  KEY `index_os_matches_on_cmte_id` (`cmte_id`),
  KEY `index_os_matches_on_relationship_id` (`relationship_id`),
  KEY `index_os_matches_on_reference_id` (`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ownership`
--

DROP TABLE IF EXISTS `ownership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ownership` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `percent_stake` bigint(20) DEFAULT NULL,
  `shares` bigint(20) DEFAULT NULL,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `ownership_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `markdown` mediumtext COLLATE utf8_unicode_ci,
  `last_user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_pages_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name_last` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `name_first` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `name_middle` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name_prefix` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name_suffix` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name_nick` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `birthplace` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gender_id` bigint(20) DEFAULT NULL,
  `party_id` bigint(20) DEFAULT NULL,
  `is_independent` tinyint(1) DEFAULT NULL,
  `net_worth` bigint(20) DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  `name_maiden` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `gender_id_idx` (`gender_id`),
  KEY `party_id_idx` (`party_id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `name_idx` (`name_last`,`name_first`,`name_middle`),
  CONSTRAINT `person_ibfk_1` FOREIGN KEY (`party_id`) REFERENCES `entity` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `person_ibfk_2` FOREIGN KEY (`gender_id`) REFERENCES `gender` (`id`),
  CONSTRAINT `person_ibfk_3` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `phone`
--

DROP TABLE IF EXISTS `phone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phone` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity_id` bigint(20) NOT NULL,
  `number` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `last_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  CONSTRAINT `phone_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `phone_ibfk_2` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `political_candidate`
--

DROP TABLE IF EXISTS `political_candidate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `political_candidate` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `is_federal` tinyint(1) DEFAULT NULL,
  `is_state` tinyint(1) DEFAULT NULL,
  `is_local` tinyint(1) DEFAULT NULL,
  `pres_fec_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `senate_fec_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `house_fec_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crp_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `pres_fec_id_idx` (`pres_fec_id`),
  KEY `senate_fec_id_idx` (`senate_fec_id`),
  KEY `house_fec_id_idx` (`house_fec_id`),
  KEY `crp_id_idx` (`crp_id`),
  CONSTRAINT `political_candidate_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `political_district`
--

DROP TABLE IF EXISTS `political_district`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `political_district` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `state_id` bigint(20) DEFAULT NULL,
  `federal_district` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state_district` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `local_district` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `state_id_idx` (`state_id`),
  CONSTRAINT `political_district_ibfk_1` FOREIGN KEY (`state_id`) REFERENCES `address_state` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `political_fundraising`
--

DROP TABLE IF EXISTS `political_fundraising`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `political_fundraising` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `fec_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type_id` bigint(20) DEFAULT NULL,
  `state_id` bigint(20) DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `state_id_idx` (`state_id`),
  KEY `type_id_idx` (`type_id`),
  KEY `entity_id_idx` (`entity_id`),
  KEY `fec_id_idx` (`fec_id`),
  CONSTRAINT `political_fundraising_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `political_fundraising_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `political_fundraising_ibfk_2` FOREIGN KEY (`state_id`) REFERENCES `address_state` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `political_fundraising_ibfk_3` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `political_fundraising_type`
--

DROP TABLE IF EXISTS `political_fundraising_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `political_fundraising_type` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `position`
--

DROP TABLE IF EXISTS `position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `position` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `is_board` tinyint(1) DEFAULT NULL,
  `is_executive` tinyint(1) DEFAULT NULL,
  `is_employee` tinyint(1) DEFAULT NULL,
  `compensation` bigint(20) DEFAULT NULL,
  `boss_id` bigint(20) DEFAULT NULL,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `boss_id_idx` (`boss_id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `position_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `position_ibfk_2` FOREIGN KEY (`boss_id`) REFERENCES `entity` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `professional`
--

DROP TABLE IF EXISTS `professional`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `professional` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `professional_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `public_company`
--

DROP TABLE IF EXISTS `public_company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `public_company` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ticker` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sec_cik` bigint(20) DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  CONSTRAINT `public_company_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `queue_entities`
--

DROP TABLE IF EXISTS `queue_entities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `queue_entities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `is_skipped` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_queue_entities_on_queue_and_entity_id` (`queue`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reference`
--

DROP TABLE IF EXISTS `reference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reference` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `fields` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source` varchar(1000) COLLATE utf8_unicode_ci NOT NULL,
  `source_detail` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `publication_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `object_model` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `object_id` bigint(20) NOT NULL,
  `last_user_id` int(11) DEFAULT NULL,
  `ref_type` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `last_user_id_idx` (`last_user_id`),
  KEY `source_idx` (`source`(255)),
  KEY `name_idx` (`name`),
  KEY `updated_at_idx` (`updated_at`),
  KEY `object_idx` (`object_model`,`object_id`,`updated_at`),
  KEY `index_reference_on_object_model_and_object_id_and_ref_type` (`object_model`,`object_id`,`ref_type`),
  CONSTRAINT `reference_ibfk_1` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reference_excerpt`
--

DROP TABLE IF EXISTS `reference_excerpt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reference_excerpt` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `reference_id` bigint(20) NOT NULL,
  `body` longtext COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reference_id_idx` (`reference_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  CONSTRAINT `reference_excerpt_ibfk_1` FOREIGN KEY (`reference_id`) REFERENCES `reference` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reference_excerpt_ibfk_2` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `relationship`
--

DROP TABLE IF EXISTS `relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relationship` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entity1_id` bigint(20) NOT NULL,
  `entity2_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `description1` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description2` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount` bigint(20) DEFAULT NULL,
  `goods` longtext COLLATE utf8_unicode_ci,
  `filings` bigint(20) DEFAULT NULL,
  `notes` longtext COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `start_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `end_date` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_current` tinyint(1) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `last_user_id` int(11) DEFAULT NULL,
  `amount2` bigint(20) DEFAULT NULL,
  `is_gte` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `entity1_id_idx` (`entity1_id`),
  KEY `entity2_id_idx` (`entity2_id`),
  KEY `category_id_idx` (`category_id`),
  KEY `last_user_id_idx` (`last_user_id`),
  KEY `entity_idx` (`entity1_id`,`entity2_id`),
  KEY `entity1_category_idx` (`entity1_id`,`category_id`),
  KEY `index_relationship_is_d_e2_cat_amount` (`is_deleted`,`entity2_id`,`category_id`,`amount`),
  CONSTRAINT `relationship_ibfk_1` FOREIGN KEY (`entity2_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `relationship_ibfk_2` FOREIGN KEY (`entity1_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `relationship_ibfk_3` FOREIGN KEY (`category_id`) REFERENCES `relationship_category` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `relationship_ibfk_4` FOREIGN KEY (`last_user_id`) REFERENCES `sf_guard_user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `relationship_category`
--

DROP TABLE IF EXISTS `relationship_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relationship_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `display_name` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `default_description` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entity1_requirements` text COLLATE utf8_unicode_ci,
  `entity2_requirements` text COLLATE utf8_unicode_ci,
  `has_fields` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `representative`
--

DROP TABLE IF EXISTS `representative`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `representative` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bioguide_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  CONSTRAINT `representative_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `representative_district`
--

DROP TABLE IF EXISTS `representative_district`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `representative_district` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `representative_id` bigint(20) NOT NULL,
  `district_id` bigint(20) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`representative_id`,`district_id`),
  KEY `district_id_idx` (`district_id`),
  KEY `representative_id_idx` (`representative_id`),
  CONSTRAINT `representative_district_ibfk_3` FOREIGN KEY (`representative_id`) REFERENCES `elected_representative` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `representative_district_ibfk_4` FOREIGN KEY (`district_id`) REFERENCES `political_district` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scheduled_email`
--

DROP TABLE IF EXISTS `scheduled_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_email` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `from_email` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `from_name` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `to_email` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `to_name` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subject` text COLLATE utf8_unicode_ci,
  `body_text` longtext COLLATE utf8_unicode_ci,
  `body_html` longtext COLLATE utf8_unicode_ci,
  `is_sent` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `school`
--

DROP TABLE IF EXISTS `school`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `school` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `endowment` bigint(20) DEFAULT NULL,
  `students` bigint(20) DEFAULT NULL,
  `faculty` bigint(20) DEFAULT NULL,
  `tuition` bigint(20) DEFAULT NULL,
  `is_private` tinyint(1) DEFAULT NULL,
  `entity_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entity_id_idx` (`entity_id`),
  CONSTRAINT `school_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `entity` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scraper_meta`
--

DROP TABLE IF EXISTS `scraper_meta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scraper_meta` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `scraper` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `namespace` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `predicate` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`scraper`,`namespace`,`predicate`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `data` longtext COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sf_guard_group`
--

DROP TABLE IF EXISTS `sf_guard_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `blurb` varchar(255) DEFAULT NULL,
  `description` text,
  `contest` text,
  `is_working` tinyint(1) NOT NULL DEFAULT '0',
  `is_private` tinyint(1) NOT NULL DEFAULT '0',
  `display_name` varchar(255) NOT NULL,
  `home_network_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `index_sf_guard_group_on_display_name` (`display_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sf_guard_group_list`
--

DROP TABLE IF EXISTS `sf_guard_group_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_group_list` (
  `group_id` int(11) NOT NULL DEFAULT '0',
  `list_id` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`group_id`,`list_id`),
  KEY `list_id` (`list_id`),
  CONSTRAINT `sf_guard_group_list_ibfk_1` FOREIGN KEY (`list_id`) REFERENCES `ls_list` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sf_guard_group_list_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `sf_guard_group` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sf_guard_group_permission`
--

DROP TABLE IF EXISTS `sf_guard_group_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_group_permission` (
  `group_id` int(11) NOT NULL DEFAULT '0',
  `permission_id` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`group_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `sf_guard_group_permission_ibfk_1` FOREIGN KEY (`permission_id`) REFERENCES `sf_guard_permission` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sf_guard_group_permission_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `sf_guard_group` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sf_guard_permission`
--

DROP TABLE IF EXISTS `sf_guard_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sf_guard_remember_key`
--

DROP TABLE IF EXISTS `sf_guard_remember_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_remember_key` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `remember_key` varchar(32) DEFAULT NULL,
  `ip_address` varchar(50) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`,`ip_address`),
  KEY `user_id_idx` (`user_id`),
  KEY `remember_key_idx` (`remember_key`),
  CONSTRAINT `sf_guard_remember_key_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sf_guard_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sf_guard_user`
--

DROP TABLE IF EXISTS `sf_guard_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(128) NOT NULL,
  `algorithm` varchar(128) NOT NULL DEFAULT 'sha1',
  `salt` varchar(128) DEFAULT NULL,
  `password` varchar(128) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_super_admin` tinyint(1) DEFAULT '0',
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `is_active_idx_idx` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sf_guard_user_group`
--

DROP TABLE IF EXISTS `sf_guard_user_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_user_group` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `group_id` int(11) NOT NULL DEFAULT '0',
  `is_owner` tinyint(1) DEFAULT NULL,
  `score` bigint(20) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`,`group_id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `sf_guard_user_group_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sf_guard_user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sf_guard_user_group_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `sf_guard_group` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sf_guard_user_permission`
--

DROP TABLE IF EXISTS `sf_guard_user_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_user_permission` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `permission_id` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `sf_guard_user_permission_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sf_guard_user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sf_guard_user_permission_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `sf_guard_permission` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sf_guard_user_profile`
--

DROP TABLE IF EXISTS `sf_guard_user_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sf_guard_user_profile` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `name_first` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `name_last` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `reason` longtext COLLATE utf8_unicode_ci,
  `analyst_reason` longtext COLLATE utf8_unicode_ci,
  `is_visible` tinyint(1) NOT NULL DEFAULT '1',
  `invitation_code` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `enable_announcements` tinyint(1) NOT NULL DEFAULT '1',
  `enable_html_editor` tinyint(1) NOT NULL DEFAULT '1',
  `enable_recent_views` tinyint(1) NOT NULL DEFAULT '1',
  `enable_favorites` tinyint(1) NOT NULL DEFAULT '1',
  `enable_pointers` tinyint(1) NOT NULL DEFAULT '1',
  `public_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `bio` longtext COLLATE utf8_unicode_ci,
  `is_confirmed` tinyint(1) NOT NULL DEFAULT '0',
  `confirmation_code` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ranking_opt_out` tinyint(1) NOT NULL DEFAULT '0',
  `watching_opt_out` tinyint(1) NOT NULL DEFAULT '0',
  `enable_notes_list` tinyint(1) NOT NULL DEFAULT '1',
  `enable_notes_notifications` tinyint(1) NOT NULL DEFAULT '1',
  `score` bigint(20) DEFAULT NULL,
  `show_full_name` tinyint(1) NOT NULL DEFAULT '0',
  `unread_notes` int(11) DEFAULT '0',
  `home_network_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_idx` (`user_id`),
  UNIQUE KEY `unique_email_idx` (`email`),
  UNIQUE KEY `unique_public_name_idx` (`public_name`),
  KEY `user_id_public_name_idx` (`user_id`,`public_name`),
  CONSTRAINT `sf_guard_user_profile_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sf_guard_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `social`
--

DROP TABLE IF EXISTS `social`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `social_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sphinx_index`
--

DROP TABLE IF EXISTS `sphinx_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sphinx_index` (
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_visible` tinyint(1) NOT NULL DEFAULT '1',
  `triple_namespace` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `triple_predicate` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `triple_value` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `taggings`
--

DROP TABLE IF EXISTS `taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) NOT NULL,
  `tagable_class` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `tagable_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_tagable_class` (`tagable_class`),
  KEY `index_taggings_on_tagable_id` (`tagable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `task_meta`
--

DROP TABLE IF EXISTS `task_meta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_meta` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `task` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `namespace` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `predicate` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueness_idx` (`task`,`namespace`,`predicate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `theyrule_gender_queue`
--

DROP TABLE IF EXISTS `theyrule_gender_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `theyrule_gender_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) NOT NULL,
  `is_done` tinyint(1) NOT NULL DEFAULT '0',
  `locked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `toolkit_pages`
--

DROP TABLE IF EXISTS `toolkit_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `toolkit_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `markdown` mediumtext COLLATE utf8_unicode_ci,
  `last_user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_toolkit_pages_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_industries`
--

DROP TABLE IF EXISTS `topic_industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic_industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `topic_id` int(11) DEFAULT NULL,
  `industry_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_topic_industries_on_topic_id_and_industry_id` (`topic_id`,`industry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_lists`
--

DROP TABLE IF EXISTS `topic_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `topic_id` int(11) DEFAULT NULL,
  `list_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_topic_lists_on_topic_id_and_list_id` (`topic_id`,`list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_maps`
--

DROP TABLE IF EXISTS `topic_maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic_maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `topic_id` int(11) DEFAULT NULL,
  `map_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_topic_maps_on_topic_id_and_map_id` (`topic_id`,`map_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topics`
--

DROP TABLE IF EXISTS `topics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `default_list_id` int(11) DEFAULT NULL,
  `shortcuts` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_topics_on_name` (`name`),
  UNIQUE KEY `index_topics_on_slug` (`slug`),
  KEY `index_topics_on_default_list_id` (`default_list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction`
--

DROP TABLE IF EXISTS `transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `contact1_id` bigint(20) DEFAULT NULL,
  `contact2_id` bigint(20) DEFAULT NULL,
  `district_id` bigint(20) DEFAULT NULL,
  `is_lobbying` tinyint(1) DEFAULT NULL,
  `relationship_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `contact1_id_idx` (`contact1_id`),
  KEY `contact2_id_idx` (`contact2_id`),
  KEY `relationship_id_idx` (`relationship_id`),
  CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`relationship_id`) REFERENCES `relationship` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`contact2_id`) REFERENCES `entity` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `transaction_ibfk_3` FOREIGN KEY (`contact1_id`) REFERENCES `entity` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `default_network_id` int(11) DEFAULT NULL,
  `sf_guard_user_id` int(11) NOT NULL,
  `username` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `remember_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmation_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `newsletter` tinyint(1) DEFAULT NULL,
  `chatid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_restricted` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_sf_guard_user_id` (`sf_guard_user_id`),
  UNIQUE KEY `index_users_on_username` (`username`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `versions`
--

DROP TABLE IF EXISTS `versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(255) NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) NOT NULL,
  `whodunnit` varchar(255) DEFAULT NULL,
  `object` text,
  `created_at` datetime DEFAULT NULL,
  `object_changes` longtext,
  `entity1_id` int(11) DEFAULT NULL,
  `entity2_id` int(11) DEFAULT NULL,
  `association_data` longtext,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`),
  KEY `index_versions_on_entity1_id` (`entity1_id`),
  KEY `index_versions_on_entity2_id` (`entity2_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-08-02 12:55:30
INSERT INTO schema_migrations (version) VALUES ('20131031182415');

INSERT INTO schema_migrations (version) VALUES ('20131031182500');

INSERT INTO schema_migrations (version) VALUES ('20131031193556');

INSERT INTO schema_migrations (version) VALUES ('20131031193758');

INSERT INTO schema_migrations (version) VALUES ('20131031203057');

INSERT INTO schema_migrations (version) VALUES ('20131031203445');

INSERT INTO schema_migrations (version) VALUES ('20131031204510');

INSERT INTO schema_migrations (version) VALUES ('20131031205616');

INSERT INTO schema_migrations (version) VALUES ('20131101162116');

INSERT INTO schema_migrations (version) VALUES ('20131103163139');

INSERT INTO schema_migrations (version) VALUES ('20131103171959');

INSERT INTO schema_migrations (version) VALUES ('20131103172251');

INSERT INTO schema_migrations (version) VALUES ('20131104173751');

INSERT INTO schema_migrations (version) VALUES ('20131105202708');

INSERT INTO schema_migrations (version) VALUES ('20131105230558');

INSERT INTO schema_migrations (version) VALUES ('20131105230559');

INSERT INTO schema_migrations (version) VALUES ('20131107004713');

INSERT INTO schema_migrations (version) VALUES ('20131111201415');

INSERT INTO schema_migrations (version) VALUES ('20131112003439');

INSERT INTO schema_migrations (version) VALUES ('20131112155046');

INSERT INTO schema_migrations (version) VALUES ('20131112162504');

INSERT INTO schema_migrations (version) VALUES ('20131112170621');

INSERT INTO schema_migrations (version) VALUES ('20131113230739');

INSERT INTO schema_migrations (version) VALUES ('20131115201434');

INSERT INTO schema_migrations (version) VALUES ('20131116204113');

INSERT INTO schema_migrations (version) VALUES ('20131116213612');

INSERT INTO schema_migrations (version) VALUES ('20131118204508');

INSERT INTO schema_migrations (version) VALUES ('20131119165617');

INSERT INTO schema_migrations (version) VALUES ('20131119165745');

INSERT INTO schema_migrations (version) VALUES ('20131120153555');

INSERT INTO schema_migrations (version) VALUES ('20131121223826');

INSERT INTO schema_migrations (version) VALUES ('20131122004427');

INSERT INTO schema_migrations (version) VALUES ('20131123204352');

INSERT INTO schema_migrations (version) VALUES ('20131126184236');

INSERT INTO schema_migrations (version) VALUES ('20131210165138');

INSERT INTO schema_migrations (version) VALUES ('20140109181536');

INSERT INTO schema_migrations (version) VALUES ('20140114214219');

INSERT INTO schema_migrations (version) VALUES ('20140114220845');

INSERT INTO schema_migrations (version) VALUES ('20140120183345');

INSERT INTO schema_migrations (version) VALUES ('20140121183412');

INSERT INTO schema_migrations (version) VALUES ('20140606172356');

INSERT INTO schema_migrations (version) VALUES ('20140701010220');

INSERT INTO schema_migrations (version) VALUES ('20140701010523');

INSERT INTO schema_migrations (version) VALUES ('20140701011639');

INSERT INTO schema_migrations (version) VALUES ('20140702190320');

INSERT INTO schema_migrations (version) VALUES ('20140729180230');

INSERT INTO schema_migrations (version) VALUES ('20141006212617');

INSERT INTO schema_migrations (version) VALUES ('20150203051704');

INSERT INTO schema_migrations (version) VALUES ('20150203171448');

INSERT INTO schema_migrations (version) VALUES ('20150209174251');

INSERT INTO schema_migrations (version) VALUES ('20150209190253');

INSERT INTO schema_migrations (version) VALUES ('20150224181318');

INSERT INTO schema_migrations (version) VALUES ('20150224183355');

INSERT INTO schema_migrations (version) VALUES ('20150304212842');

INSERT INTO schema_migrations (version) VALUES ('20150307210703');

INSERT INTO schema_migrations (version) VALUES ('20150318234636');

INSERT INTO schema_migrations (version) VALUES ('20150325183612');

INSERT INTO schema_migrations (version) VALUES ('20150406160627');

INSERT INTO schema_migrations (version) VALUES ('20150429230431');

INSERT INTO schema_migrations (version) VALUES ('20150505164306');

INSERT INTO schema_migrations (version) VALUES ('20150505223711');

INSERT INTO schema_migrations (version) VALUES ('20150506185713');

INSERT INTO schema_migrations (version) VALUES ('20150506195141');

INSERT INTO schema_migrations (version) VALUES ('20150520172037');

INSERT INTO schema_migrations (version) VALUES ('20150527164245');

INSERT INTO schema_migrations (version) VALUES ('20150618205223');

INSERT INTO schema_migrations (version) VALUES ('20150826164457');

INSERT INTO schema_migrations (version) VALUES ('20151009211944');

INSERT INTO schema_migrations (version) VALUES ('20151118171301');

INSERT INTO schema_migrations (version) VALUES ('20151121152809');

INSERT INTO schema_migrations (version) VALUES ('20151224175054');

INSERT INTO schema_migrations (version) VALUES ('20160202003823');

INSERT INTO schema_migrations (version) VALUES ('20160712173138');

INSERT INTO schema_migrations (version) VALUES ('20160722151948');

INSERT INTO schema_migrations (version) VALUES ('20160726175346');

INSERT INTO schema_migrations (version) VALUES ('20160801140142');

INSERT INTO schema_migrations (version) VALUES ('20160802001356');

INSERT INTO schema_migrations (version) VALUES ('20160805195708');

INSERT INTO schema_migrations (version) VALUES ('20160809191319');

INSERT INTO schema_migrations (version) VALUES ('20160811135725');

INSERT INTO schema_migrations (version) VALUES ('20161004185636');

INSERT INTO schema_migrations (version) VALUES ('20161005180511');

INSERT INTO schema_migrations (version) VALUES ('20161010133616');

INSERT INTO schema_migrations (version) VALUES ('20161010150852');

INSERT INTO schema_migrations (version) VALUES ('20161020222913');

INSERT INTO schema_migrations (version) VALUES ('20161027171001');

INSERT INTO schema_migrations (version) VALUES ('20161027190336');

INSERT INTO schema_migrations (version) VALUES ('20161107142712');

INSERT INTO schema_migrations (version) VALUES ('20161121184436');

INSERT INTO schema_migrations (version) VALUES ('20161222185023');

INSERT INTO schema_migrations (version) VALUES ('20170109160535');

INSERT INTO schema_migrations (version) VALUES ('20170123193334');

INSERT INTO schema_migrations (version) VALUES ('20170227163755');

INSERT INTO schema_migrations (version) VALUES ('20170227190903');

INSERT INTO schema_migrations (version) VALUES ('20170315175216');

INSERT INTO schema_migrations (version) VALUES ('20170412144422');

INSERT INTO schema_migrations (version) VALUES ('20170413200356');

INSERT INTO schema_migrations (version) VALUES ('20170418215509');

INSERT INTO schema_migrations (version) VALUES ('20170427180140');

INSERT INTO schema_migrations (version) VALUES ('20170508151516');

INSERT INTO schema_migrations (version) VALUES ('20170612163321');

INSERT INTO schema_migrations (version) VALUES ('20170612172624');

INSERT INTO schema_migrations (version) VALUES ('20170626212039');

INSERT INTO schema_migrations (version) VALUES ('20170706142752');

INSERT INTO schema_migrations (version) VALUES ('20170719172615');

INSERT INTO schema_migrations (version) VALUES ('20170802165123');

