/*
    02_analysis_queries.sql
    Project: Irish Company Survival: Registrations, Cohort Survival and Prediction
    Author:  Temuulen Bulgan

    Analysis queries, one block for each business question.
    Run after 01_create_tables.sql and notebook 2 (the tables must be loaded).
    Select one query and press F5 to run only that query.
*/

USE irish_company_survival;

/*
    Query 1.1: New companies registered each year
    Business question 1: how many companies are registered each year?
    The last year is a part year. It ends at the data date.
*/
SELECT
    d.[year],
    COUNT(*) AS registrations      -- one row in fact_company = one company
FROM fact_company AS f
JOIN dim_date AS d
    ON f.reg_date = d.[date]       -- links each company to its registration day
GROUP BY d.[year]
ORDER BY d.[year];


/*
    Query 1.2: Change in registrations from the previous year
    Business question 1: did 2016+ (Brexit) or 2020 (COVID) change the pattern?
    The first year has no previous year, so its change is NULL.
    The last year is a part year, so its change is not a full-year change.
*/
WITH yearly AS (
    SELECT
        d.[year],
        COUNT(*) AS registrations
    FROM fact_company AS f
    JOIN dim_date AS d
        ON f.reg_date = d.[date]
    GROUP BY d.[year]
)
SELECT
    [year],
    registrations,
    LAG(registrations) OVER (ORDER BY [year]) AS prev_year,
    registrations - LAG(registrations) OVER (ORDER BY [year]) AS change,
    CAST(
        (registrations - LAG(registrations) OVER (ORDER BY [year])) * 100.0
        / LAG(registrations) OVER (ORDER BY [year])
    AS DECIMAL(5, 1)) AS change_pct
FROM yearly
ORDER BY [year];

/*
    Query 1.3: New companies registered by county (all years)
    Business question 1: how many companies are registered in each county?
    LEFT JOIN keeps companies with no county. They show as one row with county NULL.
*/
SELECT
    c.county,
    COUNT(*) AS registrations
FROM fact_company AS f
LEFT JOIN dim_county AS c
    ON f.county_id = c.county_id
GROUP BY c.county
ORDER BY registrations DESC;

/*
    Query 1.4: New companies registered by sector, from 2016
    Business question 1: how many companies are registered in each sector?
    From 2016 only, because sector codes are mostly missing before 2015.
    LEFT JOIN keeps companies with no sector code. They show as one row with NULL.
*/
SELECT
    s.nace_section,
    s.section_name,
    COUNT(*) AS registrations
FROM fact_company AS f
JOIN dim_date AS d
    ON f.reg_date = d.[date]
LEFT JOIN dim_sector AS s
    ON f.sector_id = s.sector_id
WHERE d.[year] >= 2016
GROUP BY s.nace_section, s.section_name
ORDER BY registrations DESC;

/*
    Query 2.1: Share of companies still registered 1, 3 and 5 years after registration, per cohort
    Business question 2: what share of companies survive 1, 3 and 5 years?
    A cohort = all companies registered in the same year.
    Survived k years = no closing date, or closed after its k-th anniversary.
    Censoring: a company counts for k years only if its k-th anniversary is on or
    before the data date (the last date in dim_date). Younger companies are left out.
    A share is NULL when no company in the cohort is old enough yet.
*/
WITH data_date AS (
    SELECT MAX([date]) AS last_date
    FROM dim_date
),
companies AS (
    SELECT
        d.[year] AS reg_year,
        f.closed_date,
        DATEADD(YEAR, 1, f.reg_date) AS date_1y,   -- 1st anniversary
        DATEADD(YEAR, 3, f.reg_date) AS date_3y,   -- 3rd anniversary
        DATEADD(YEAR, 5, f.reg_date) AS date_5y,   -- 5th anniversary
        dd.last_date
    FROM fact_company AS f
    JOIN dim_date AS d
        ON f.reg_date = d.[date]
    CROSS JOIN data_date AS dd                     -- adds last_date to every row
),
counts AS (
    SELECT
        reg_year,
        COUNT(*) AS companies,
        -- 1 year
        SUM(CASE WHEN date_1y <= last_date
                 THEN 1 ELSE 0 END) AS eligible_1y,
        SUM(CASE WHEN date_1y <= last_date
                  AND (closed_date IS NULL OR closed_date > date_1y)
                 THEN 1 ELSE 0 END) AS survived_1y,
        -- 3 years
        SUM(CASE WHEN date_3y <= last_date
                 THEN 1 ELSE 0 END) AS eligible_3y,
        SUM(CASE WHEN date_3y <= last_date
                  AND (closed_date IS NULL OR closed_date > date_3y)
                 THEN 1 ELSE 0 END) AS survived_3y,
        -- 5 years
        SUM(CASE WHEN date_5y <= last_date
                 THEN 1 ELSE 0 END) AS eligible_5y,
        SUM(CASE WHEN date_5y <= last_date
                  AND (closed_date IS NULL OR closed_date > date_5y)
                 THEN 1 ELSE 0 END) AS survived_5y
    FROM companies
    GROUP BY reg_year
)
SELECT
    reg_year,
    companies,
    CAST(survived_1y * 100.0 / NULLIF(eligible_1y, 0) AS DECIMAL(5, 1)) AS survival_1y_pct,
    CAST(survived_3y * 100.0 / NULLIF(eligible_3y, 0) AS DECIMAL(5, 1)) AS survival_3y_pct,
    CAST(survived_5y * 100.0 / NULLIF(eligible_5y, 0) AS DECIMAL(5, 1)) AS survival_5y_pct
FROM counts
ORDER BY reg_year;

/*
    Query 2.2: Companies closed each year
    Business question 2: checks whether closures slowed down in some years,
    which would make survival look higher for the cohorts measured in those years.
    The inner JOIN on closed_date leaves out companies that are still registered.
    The last year is a part year. It ends at the data date.
*/
SELECT
    d.[year] AS closed_year,
    COUNT(*) AS closures
FROM fact_company AS f
JOIN dim_date AS d
    ON f.closed_date = d.[date]      -- joins on the closing date, not the registration date
GROUP BY d.[year]
ORDER BY d.[year];

