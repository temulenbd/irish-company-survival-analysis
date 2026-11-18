# Data dictionary

Columns of the processed CSV files in `data/processed/`. The raw file `data/raw/companies.csv.zip` is the CRO "Company Records" download (see the main [README](../README.md#data-sources)).

### `companies_clean.csv` (512,008 rows, one per company registered from 2000)

| Column | Type | Description |
|---|---|---|
| `company_num` | integer | CRO company number (unique) |
| `reg_date` | date | Registration date |
| `company_type` | text | Private limited (LTD), Guarantee (CLG), DAC, Unlimited, Public (PLC), Other, Unknown |
| `status` | text | Status on the register, e.g. Normal, Dissolved, Strike Off Listed, Liquidation |
| `closed` | true/false | True when the company has a closing date (left the register) |
| `closed_date` | date | Date the company left the register; empty if still registered |
| `nace_code` | text | 4-digit NACE Rev 2 sector code chosen by the company, stored as text to keep leading zeros (e.g. `0150`); empty for most companies registered before 2015 |
| `county` | text | County taken from the registered address (uppercase); empty for 1,822 companies |

### `cohort_survival.csv` (72 rows, one per cohort and age)

| Column | Description |
|---|---|
| `reg_year` | Registration year (cohort) |
| `years_after` | Age: 1, 3 or 5 years after registration |
| `eligible` | Companies old enough to be counted at that age by the data date |
| `survived` | Of those, companies still registered at that age |
| `survival_pct` | `survived` / `eligible` × 100 |

### `sector_survival.csv` (19 rows, one per sector with at least 100 companies, 2016 to 2020 cohorts)

| Column | Description |
|---|---|
| `section_name` | NACE section (first 2 digits of `nace_code`) |
| `eligible_5y` | Companies old enough for the 5-year rate |
| `survived_5y` | Of those, companies still registered after 5 years |
| `survival_5y_pct` | `survived_5y` / `eligible_5y` × 100 |
| `ci_low_pct`, `ci_high_pct` | 95% Wilson confidence interval |

### `area_survival.csv` (44 rows, one per cohort and area)

| Column | Description |
|---|---|
| `reg_year` | Registration year (cohort) |
| `area` | Dublin or Other counties |
| `eligible_5y`, `survived_5y`, `survival_5y_pct` | As in `sector_survival.csv` |

### `model_results.csv` (6 rows, one per model and set)

| Column | Description |
|---|---|
| `set` | validation (2018 cohort) or test (2019 and 2020 cohorts) |
| `model` | Baseline (sector average), Logistic regression or Decision tree |
| `auc` | Area under the ROC curve (0.5 = guessing, 1.0 = perfect) |
| `brier` | Brier score (lower is better) |
| `mean_predicted_pct` | Average predicted survival |
| `actual_pct` | Share of companies that survived |
| `auc_gain` | AUC minus the baseline AUC in the same set |
| `chosen` | True for the model chosen on the validation cohort |
