# SQL database

This folder builds the SQL Server database for the project and holds the analysis queries.
The database `irish_company_survival` is a star schema: one fact table with one row per company,
and five small dimension tables for dates, company types, counties, sectors and statuses.

## Files

| File | What it does | Run order |
|---|---|---|
| `00_create_database.sql` | Creates the database `irish_company_survival` if it does not exist | 1 |
| `01_create_tables.sql` | Drops and recreates the six empty tables, with primary and foreign keys | 2 |
| `../notebooks/2_sql_database.ipynb` | Loads the tables from `data/processed/companies_clean.csv` and checks row counts in SQL | 3 |
| `02_analysis_queries.sql` | Nine queries that answer business questions 1 to 4 | 4 |


## Star schema

```mermaid
erDiagram
    dim_date ||--o{ fact_company : "registered on"
    dim_date |o--o{ fact_company : "closed on"
    dim_company_type ||--o{ fact_company : "has type"
    dim_status ||--o{ fact_company : "has status"
    dim_county |o--o{ fact_company : "located in"
    dim_sector |o--o{ fact_company : "works in"

    fact_company {
        int company_num PK
        date reg_date FK
        date closed_date FK "NULL if still registered"
        int company_type_id FK
        int status_id FK
        int county_id FK "NULL if no county"
        int sector_id FK "NULL if no sector code"
    }
    dim_date {
        date date PK
        smallint year
        tinyint quarter
        tinyint month
    }
    dim_company_type {
        int company_type_id PK
        varchar company_type
    }
    dim_county {
        int county_id PK
        varchar county
    }
    dim_sector {
        int sector_id PK
        char nace_code
        char nace_section
        varchar section_name
    }
    dim_status {
        int status_id PK
        varchar status
        bit closed
        bit closed_strict
    }
```