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