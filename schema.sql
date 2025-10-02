-- Gene-Annotation-And-Database-Creation-Pipeline schema (GitHub-friendly)
-- Generated on 2025-10-02
-- Portable MySQL 8+ DDL; no server-specific variables or dump pragmas.
-- Source adapted from user's schema dump.
-- Default database name (change if you prefer)
CREATE DATABASE IF NOT EXISTS `databases_project`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE `databases_project`;

-- ENSEMBL
DROP TABLE IF EXISTS `ENSEMBL`;
CREATE TABLE `ENSEMBL` (
  `biotype`        varchar(20)  DEFAULT NULL,
  `display_name`   varchar(50)  DEFAULT NULL,
  `end`            int          DEFAULT NULL,
  `id`             varchar(50)  NOT NULL,
  `seq_region_name` varchar(10) DEFAULT NULL,
  `species`        varchar(50)  DEFAULT NULL,
  `start`          int          DEFAULT NULL,
  `strand`         tinyint      DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- NCBI
DROP TABLE IF EXISTS `NCBI`;
CREATE TABLE `NCBI` (
  `symbol`           varchar(50) NOT NULL,
  `Gene_description` text,
  PRIMARY KEY (`symbol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- UNIPROT
DROP TABLE IF EXISTS `UNIPROT`;
CREATE TABLE `UNIPROT` (
  `accession`     varchar(20)  NOT NULL,
  `gene_primary`  varchar(100) DEFAULT NULL,
  `organism_name` varchar(100) DEFAULT NULL,
  `cc_function`   text,
  `Protein_Name`  text,
  `sequence`      text,
  PRIMARY KEY (`accession`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
