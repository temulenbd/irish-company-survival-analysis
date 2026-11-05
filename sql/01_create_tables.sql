/*
    01_create_tables.sql
    Project: Irish Company Survival: Registrations, Cohort Survival and Prediction
    Author:  Temuulen Bulgan

    Creates the star schema: five dimension tables and one fact table
    with one row per company. The tables are empty; notebook 2 loads them.
    Run after 00_create_database.sql. Running it again drops and recreates the tables.
*/

USE irish_company_survival;
GO

/* Drop old tables first. The fact table goes first because it points to the dimensions */
DROP TABLE IF EXISTS fact_company;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_company_type;
DROP TABLE IF EXISTS dim_county;
DROP TABLE IF EXISTS dim_sector;
DROP TABLE IF EXISTS dim_status;
GO

/* Calendar: one row per day from the first registration date to the data date */
CREATE TABLE dim_date (
    [date]     DATE     NOT NULL PRIMARY KEY,
    [year]     SMALLINT NOT NULL,
    [quarter]  TINYINT  NOT NULL,
    [month]    TINYINT  NOT NULL
);

/* Company types: the 7 main types from notebook 1 */
CREATE TABLE dim_company_type (
    company_type_id  INT         NOT NULL PRIMARY KEY,
    company_type     VARCHAR(50) NOT NULL UNIQUE
);

/* Counties: the counties found in the address */
CREATE TABLE dim_county (
    county_id  INT         NOT NULL PRIMARY KEY,
    county     VARCHAR(20) NOT NULL UNIQUE
);

/* Sectors: one row per 4-digit NACE code, with its NACE Rev 2 section letter.
   nace_section is NULL for codes that do not exist in NACE Rev 2 */
CREATE TABLE dim_sector (
    sector_id     INT     NOT NULL PRIMARY KEY,
    nace_code     CHAR(4) NOT NULL UNIQUE,
    nace_section  CHAR(1) NULL
);

/* CRO statuses: closed = left the register;
   closed_strict also counts Strike Off Listed and Liquidation as closed */
CREATE TABLE dim_status (
    status_id      INT         NOT NULL PRIMARY KEY,
    status         VARCHAR(50) NOT NULL UNIQUE,
    closed         BIT         NOT NULL,
    closed_strict  BIT         NOT NULL
);

/* Fact table: one row per company registered from 2000.
   county_id and sector_id are NULL when notebook 1 found no county or no sector code */
CREATE TABLE fact_company (
    company_num      INT  NOT NULL PRIMARY KEY,
    reg_date         DATE NOT NULL REFERENCES dim_date([date]),
    closed_date      DATE NULL     REFERENCES dim_date([date]),
    company_type_id  INT  NOT NULL REFERENCES dim_company_type(company_type_id),
    status_id        INT  NOT NULL REFERENCES dim_status(status_id),
    county_id        INT  NULL     REFERENCES dim_county(county_id),
    sector_id        INT  NULL     REFERENCES dim_sector(sector_id)
);
GO