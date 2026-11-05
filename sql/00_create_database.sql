/*
    00_create_database.sql
    Project: Irish Company Survival: Registrations, Cohort Survival and Prediction
    Author:  Temuulen Bulgan

    Creates the empty database for the project.
    Run this file first, then 01_create_tables.sql.
*/

/* Switch to the master database, where new databases are created */
USE master;
GO

/* Create the database only if it does not exist yet */
IF DB_ID('irish_company_survival') IS NULL
    CREATE DATABASE irish_company_survival;
GO