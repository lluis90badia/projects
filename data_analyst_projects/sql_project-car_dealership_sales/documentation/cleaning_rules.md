# Cleaning Rules

## Project: Car Dealership Sales SQL Project

This document describes the data cleaning and data quality tracking rules applied to the raw car dealership sales dataset.

The objective of this cleaning process is not only to standardise values, but also to preserve traceability between the original raw data and the cleaned output. For this reason, the original columns are kept unchanged and new `_cleaned` columns are created to store the corrected or standardised values.

---

## Cleaning Strategy Overview

The cleaning process follows a structured and auditable workflow:

1. Keep the original raw dataset unchanged.
2. Create a working cleaning table named `cds_cleaning_process`.
3. Add one `_cleaned` column for each original field that needs standardisation.
4. Use reference tables, temporary resolution tables and validation rules to clean each field.
5. Store unresolved, invalid or transformed values in the `data_quality_issues` table.
6. Use `NULL` when a value cannot be corrected with high confidence.
7. Review problematic records manually instead of applying low-confidence corrections.

This approach reflects a professional data quality workflow where **data lineage**, **transparency** and **business reliability** are prioritised.

---

## Main Cleaning Tables

### `cds_raw`

Original raw data table.

This table should remain unchanged throughout the project. It represents the raw ingestion layer and is used as the original source of truth for auditing purposes.

---

### `cds_cleaning_process`

Working table used during the cleaning process.

This table is created from `cds_raw` and includes both the original columns and the cleaned columns.

Cleaned columns include:

| Cleaned Column              |
| --------------------------- |
| `dealer_id_cleaned`         |
| `employee_id_cleaned`       |
| `employee_name_cleaned`     |
| `employee_role_cleaned`     |
| `hire_date_cleaned`         |
| `employee_email_cleaned`    |
| `employee_phone_cleaned`    |
| `vin_cleaned`               |
| `vehicle_brand_cleaned`     |
| `vehicle_model_cleaned`     |
| `vehicle_year_cleaned`      |
| `vehicle_price_usd_cleaned` |
| `sale_date_cleaned`         |
| `customer_state_cleaned`    |
| `sale_status_cleaned`       |

The table also includes a temporary flag column:

| Column                          | Purpose                                                                                       |
| ------------------------------- | --------------------------------------------------------------------------------------------- |
| `values_to_data_quality_issues` | Temporary flag used to identify rows that need to be inserted into the data quality issue log |

---

### `data_quality_issues`

Audit table used to register data quality problems found during the cleaning process.

| Column           | Description                                   |
| ---------------- | --------------------------------------------- |
| `issue_id`       | Auto-increment primary key                    |
| `raw_row_id`     | Identifier of the affected raw row            |
| `name_column`    | Column where the issue was detected           |
| `original_value` | Original raw value                            |
| `cleaned_value`  | Cleaned or standardised value, when available |
| `issue_type`     | Type of issue detected                        |
| `action_taken`   | Description of the action applied             |

This table makes the cleaning process transparent and allows the user to understand what was corrected, what was standardised and what still requires manual review.

---

## General Cleaning Principles

### 1. Preserve raw data

Original values are never overwritten directly. Each cleaned value is stored in a dedicated `_cleaned` column.

Example:

| Original Column     | Cleaned Column              |
| ------------------- | --------------------------- |
| `dealer_id`         | `dealer_id_cleaned`         |
| `employee_name`     | `employee_name_cleaned`     |
| `vehicle_price_usd` | `vehicle_price_usd_cleaned` |

---

### 2. Prefer reference tables over long `CASE` statements

For categorical fields, the project uses reference or mapping tables instead of long hard-coded `CASE` expressions.

This approach is more scalable, easier to maintain and closer to professional data engineering practices.

Reference tables used include:

| Reference Table      | Purpose                                 |
| -------------------- | --------------------------------------- |
| `ref_employee`       | Official employee reference table       |
| `ref_employee_role`  | Employee role standardisation           |
| `ref_vehicle_brand`  | Vehicle brand standardisation           |
| `ref_vehicle_model`  | Vehicle model standardisation by brand  |
| `ref_us_states`      | Official US state codes and names       |
| `ref_us_state_alias` | Alternative state spellings and aliases |
| `ref_sale_status`    | Sale status standardisation             |

---

### 3. Use temporary resolution tables

For more complex cleaning rules, temporary tables are created to separate detection, transformation and validation logic.

Examples:

| Temporary Table                 | Purpose                                                   |
| ------------------------------- | --------------------------------------------------------- |
| `tmp_employee_name_resolution`  | Resolves employee names using ID, email and name matching |
| `tmp_employee_email_resolution` | Resolves official employee emails                         |
| `tmp_employee_phone_resolution` | Standardises phone numbers                                |
| `tmp_hire_date_resolution`      | Parses and validates hire dates                           |
| `tmp_vin_resolution`            | Validates and standardises VINs                           |
| `tmp_vehicle_year_resolution`   | Validates vehicle year values                             |
| `tmp_vehicle_price_resolution`  | Converts and validates vehicle prices                     |
| `tmp_sale_date_resolution`      | Parses and validates sale dates                           |
| `tmp_sale_status_resolution`    | Resolves sale status values                               |

Temporary tables make the SQL easier to read, debug and validate.

---

### 4. Use `NULL` for unresolved values

When a value cannot be corrected with high confidence, it is set to `NULL` in the cleaned column and logged in `data_quality_issues`.

This prevents low-confidence assumptions from contaminating the cleaned dataset.

---

### 5. Track issues before final modelling

Rows with incorrect, suspicious, ambiguous or unresolved values are registered before the final cleaned table and dimensional model are created.

This ensures that the final analytical layer is based on documented and validated data.

---

# Column-Level Cleaning Rules

---

## `dealer_id`

### Objective

Standardise dealership identifiers into numeric values while preserving the original dealer ID in the source column.

### Expected Format

The expected original format is:

```sql
D + 3 digits
```

Example:

| Original Value | Cleaned Value |
| -------------- | ------------: |
| `D001`         |           `1` |
| `D005`         |           `5` |
| `D012`         |          `12` |

### Cleaning Rules

| Rule                                           | Action                      |
| ---------------------------------------------- | --------------------------- |
| Value matches `D` + 3 digits and is not `D000` | Extract numeric part        |
| Value is already numeric with 1 to 3 digits    | Convert to integer          |
| Value matches `D` + 1 or 2 digits              | Extract numeric part        |
| Value is invalid or cannot be standardised     | Set cleaned value to `NULL` |

### Data Quality Tracking

Invalid dealer identifiers are inserted into `data_quality_issues`.

The issue is logged as:

```text
Incorrect "dealer_id" value
```

### Business Rationale

Dealer IDs are important for dealership performance analysis. Standardising them as integers simplifies joins, aggregations and dimensional modelling.

---

## `employee_id`

### Objective

Resolve and standardise employee identifiers using the official employee reference table.

### Reference Table

`ref_employee`

This table contains official employee information:

| Field            |
| ---------------- |
| `employee_id`    |
| `first_name`     |
| `last_name`      |
| `employee_email` |

### Expected Format

The expected employee ID format is:

```sql
E + 4 digits
```

Example:

| Original Value | Standard Format | Cleaned Numeric Value |
| -------------- | --------------- | --------------------: |
| `E1001`        | `E1001`         |                `1001` |
| `e1001`        | `E1001`         |                `1001` |
| `1001`         | `E1001`         |                `1001` |

### Cleaning Rules

| Rule                                                    | Action                                   |
| ------------------------------------------------------- | ---------------------------------------- |
| Employee ID matches an official value in `ref_employee` | Keep and convert to numeric part         |
| Employee ID has minor format differences                | Standardise and validate                 |
| Employee ID is invalid but email matches `ref_employee` | Recover official employee ID using email |
| Employee ID is invalid but name matches `ref_employee`  | Recover official employee ID using name  |
| Employee cannot be resolved                             | Set `employee_id_cleaned` to `NULL`      |

### Data Quality Tracking

Problematic employee IDs are inserted into `data_quality_issues`.

### Business Rationale

Employee IDs are key for employee-level performance analysis. Because employee names and emails can also identify employees, the cleaning logic attempts to recover invalid IDs using trusted employee reference data before setting them to `NULL`.

---

## `employee_name`

### Objective

Resolve employee names using the official employee reference table.

### Reference Table

`ref_employee`

### Matching Logic

The employee name is resolved using the following order:

1. `employee_id_cleaned`
2. `employee_email`
3. Normalised `employee_name`

### Cleaning Rules

| Rule                                            | Action                                |
| ----------------------------------------------- | ------------------------------------- |
| Employee ID matches `ref_employee`              | Use official first name and last name |
| Employee email matches `ref_employee`           | Use official first name and last name |
| Normalised employee name matches `ref_employee` | Use official first name and last name |
| Employee cannot be matched                      | Set `employee_name_cleaned` to `NULL` |

### Standardisation Applied

The process normalises spacing for comparison purposes.

Example:

| Original Value  | Cleaned Value |
| --------------- | ------------- |
| `john   miller` | `John Miller` |
| `JOHN MILLER`   | `John Miller` |

### Data Quality Tracking

Rows where the employee name is corrected or cannot be resolved are inserted into `data_quality_issues`.

### Business Rationale

Employee names are descriptive attributes and should be consistent in the employee dimension. The official reference table is used as the source of truth instead of manually rebuilding names from inconsistent raw values.

---

## `employee_email`

### Objective

Resolve employee emails using the official employee reference table.

### Reference Table

`ref_employee`

### Matching Logic

The employee email is resolved using:

1. `employee_id_cleaned`
2. `employee_name_cleaned`
3. Normalised `employee_email`

### Cleaning Rules

| Rule                                             | Action                                 |
| ------------------------------------------------ | -------------------------------------- |
| Employee ID matches `ref_employee`               | Use official email                     |
| Employee name matches `ref_employee`             | Use official email                     |
| Email matches `ref_employee` after normalisation | Use official email                     |
| Email cannot be matched                          | Set `employee_email_cleaned` to `NULL` |

### Important Design Decision

Emails are **not generated manually** from employee names.

Instead, the project uses the official email stored in `ref_employee`.

This avoids incorrect assumptions such as:

```text
john.miller@sunsetautos.com
```

being generated for the wrong employee or wrong company domain.

### Data Quality Tracking

Incorrect, corrected or unresolved emails are inserted into `data_quality_issues`.

### Business Rationale

Email addresses are employee attributes and should be accurate. Using a reference table prevents artificial values from being created during cleaning.

---

## `employee_role`

### Objective

Standardise employee roles into a consistent set of business roles.

### Reference Table

`ref_employee_role`

### Accepted Cleaned Values

| Cleaned Role       |
| ------------------ |
| `Sales Associate`  |
| `Sales Consultant` |
| `Sales Manager`    |
| `Internet Sales`   |
| `Sales Advisor`    |
| `General Manager`  |

### Cleaning Rules

| Rule                                           | Action                                |
| ---------------------------------------------- | ------------------------------------- |
| Raw role exists in `ref_employee_role`         | Replace with official cleaned role    |
| Raw role has known misspelling or abbreviation | Map to official cleaned role          |
| Raw role cannot be matched                     | Set `employee_role_cleaned` to `NULL` |

### Example Mappings

| Raw Value          | Cleaned Value      |
| ------------------ | ------------------ |
| `sales assoc`      | `Sales Associate`  |
| `sales asoc`       | `Sales Associate`  |
| `sale associate`   | `Sales Associate`  |
| `sales consultant` | `Sales Consultant` |
| `sales manager`    | `Sales Manager`    |

### Data Quality Tracking

Unmatched roles are inserted into `data_quality_issues`.

### Business Rationale

Standardised employee roles allow analysis by role type, such as comparing sales managers, sales consultants and internet sales employees.

---

## `employee_phone`

### Objective

Standardise employee phone numbers into a consistent US phone format.

### Expected Format

```text
XXX-XXX-XXXX
```

Example:

```text
555-213-7788
```

### Cleaning Rules

| Rule                                                      | Action                                          |
| --------------------------------------------------------- | ----------------------------------------------- |
| Value has 10 digits after removing non-numeric characters | Format as `XXX-XXX-XXXX`                        |
| Value has 11 digits and starts with `1`                   | Remove leading `1` and format as `XXX-XXX-XXXX` |
| Value has invalid digit length                            | Set `employee_phone_cleaned` to `NULL`          |

### Standardisation Applied

All non-numeric characters are removed before formatting.

Examples of characters removed:

| Character Type       |
| -------------------- |
| Spaces               |
| Parentheses          |
| Dashes               |
| Dots                 |
| Country code symbols |

### Data Quality Tracking

Invalid phone numbers are inserted into `data_quality_issues`.

Duplicate phone numbers are reviewed carefully but rows are not deleted automatically.

### Business Rationale

Phone numbers are identifiers, not numeric measures. They are stored as text and standardised for consistency. Repeated employee phone numbers are not necessarily an error because the same employee can appear in multiple sales records.

---

## `hire_date`

### Objective

Convert employee hire dates into a reliable `YYYY-MM-DD` format.

### Target Format

```text
YYYY-MM-DD
```

### Accepted Input Formats

| Input Format |
| ------------ |
| `YYYY-MM-DD` |
| `YYYY/MM/DD` |
| `DD-MM-YYYY` |
| `DD/MM/YYYY` |
| `MM-DD-YYYY` |
| `MM/DD/YYYY` |

### Cleaning Rules

| Rule                                                                  | Action                            |
| --------------------------------------------------------------------- | --------------------------------- |
| Date is already in `YYYY-MM-DD` or `YYYY/MM/DD` format                | Convert to `DATE`                 |
| Date is clearly `DD-MM-YYYY` because first number is greater than 12  | Convert to `DATE`                 |
| Date is clearly `MM-DD-YYYY` because second number is greater than 12 | Convert to `DATE`                 |
| Date has impossible day or month                                      | Set to `NULL`                     |
| Date is ambiguous, such as `05-06-2020`                               | Set to `NULL` and flag for review |
| Date cannot be parsed                                                 | Set to `NULL`                     |

### Ambiguous Date Handling

Ambiguous dates are not guessed automatically.

Example:

```text
05-06-2020
```

This could mean:

| Interpretation | Meaning     |
| -------------- | ----------- |
| `DD-MM-YYYY`   | 5 June 2020 |
| `MM-DD-YYYY`   | 6 May 2020  |

Without a clear business rule, the safest option is to flag the value for manual review.

### Data Quality Tracking

Invalid, impossible and ambiguous hire dates are inserted into `data_quality_issues`.

### Business Rationale

Hire date can support employee tenure analysis. Incorrect date parsing could distort tenure calculations, so ambiguous values are handled conservatively.

---

## `vin`

### Objective

Validate and standardise Vehicle Identification Numbers.

### Expected Format

A valid VIN must:

| Requirement                              |
| ---------------------------------------- |
| Have exactly 17 characters               |
| Contain only numbers and capital letters |
| Exclude the letters `I`, `O` and `Q`     |

### Cleaning Rules

| Rule                                         | Action                        |
| -------------------------------------------- | ----------------------------- |
| VIN has 17 valid characters                  | Convert to uppercase and keep |
| VIN contains invalid letters `I`, `O` or `Q` | Set `vin_cleaned` to `NULL`   |
| VIN has fewer or more than 17 characters     | Set `vin_cleaned` to `NULL`   |
| VIN has invalid symbols                      | Set `vin_cleaned` to `NULL`   |

### Valid VIN Pattern

```sql
^[A-HJ-NPR-Z0-9]{17}$
```

### Data Quality Tracking

Invalid VINs are inserted into `data_quality_issues`.

Duplicate VINs are also logged, but rows are not deleted automatically.

### Business Rationale

VINs identify individual vehicles. However, duplicate VINs in a sales-related table may require business review rather than automatic deletion, because the same vehicle could appear in multiple transaction states depending on the source system.

---

## `vehicle_brand`

### Objective

Standardise vehicle brand names using a brand reference table.

### Reference Table

`ref_vehicle_brand`

### Cleaning Rules

| Rule                                    | Action                                |
| --------------------------------------- | ------------------------------------- |
| Raw brand exists in `ref_vehicle_brand` | Map to official brand                 |
| Raw brand is a known misspelling        | Map to official brand                 |
| Raw brand cannot be matched             | Set `vehicle_brand_cleaned` to `NULL` |

### Example Mappings

| Raw Value | Cleaned Value |
| --------- | ------------- |
| `forrd`   | `Ford`        |
| `frod`    | `Ford`        |
| `toyta`   | `Toyota`      |
| `jep`     | `Jeep`        |
| `chevy`   | `Chevrolet`   |

### Data Quality Tracking

Unresolved brands are inserted into `data_quality_issues`.

### Business Rationale

Brand-level analysis is one of the core use cases of this project. Misspelled brands would fragment sales and revenue metrics, so they must be standardised before analysis.

---

## `vehicle_model`

### Objective

Standardise vehicle models and validate them together with the cleaned vehicle brand.

### Reference Table

`ref_vehicle_model`

### Cleaning Rules

| Rule                                                      | Action                                |
| --------------------------------------------------------- | ------------------------------------- |
| Brand and model combination exists in `ref_vehicle_model` | Map to official model                 |
| Model is a known misspelling for that brand               | Map to official model                 |
| Model does not match the cleaned brand                    | Set `vehicle_model_cleaned` to `NULL` |
| Model cannot be resolved                                  | Set `vehicle_model_cleaned` to `NULL` |

### Brand-Model Validation

Vehicle model should be validated in combination with vehicle brand.

Example:

| Combination       | Interpretation |
| ----------------- | -------------- |
| `Toyota Corolla`  | Valid          |
| `Ford Corolla`    | Suspicious     |
| `Chevrolet Tahoe` | Valid          |
| `Toyota Tahoe`    | Suspicious     |

### Data Quality Tracking

Unresolved or suspicious model values are inserted into `data_quality_issues`.

### Business Rationale

Vehicle model analysis is highly relevant in dealership sales. If models are not validated against the correct brand, revenue by model can become misleading.

---

## `vehicle_year`

### Objective

Validate vehicle model years.

### Cleaning Rules

| Rule                                      | Action                               |
| ----------------------------------------- | ------------------------------------ |
| Value has exactly 4 digits                | Convert to integer                   |
| Year is between 1980 and the current year | Keep value                           |
| Year is not numeric                       | Set `vehicle_year_cleaned` to `NULL` |
| Year is in the future                     | Set `vehicle_year_cleaned` to `NULL` |
| Year is unrealistically old               | Set `vehicle_year_cleaned` to `NULL` |

### Project-Specific Note

The dataset mainly appears to contain vehicles from around 2013 to 2022.

However, the cleaning script applies a more flexible professional range:

```text
1980 to current year
```

A stricter business rule could be applied if the project scope only allows vehicles from 2013 to 2022.

### Data Quality Tracking

Invalid vehicle years are inserted into `data_quality_issues`.

### Business Rationale

Vehicle year is important for analysing price, vehicle age, stock profile and sales performance. Future years or unrealistic values could distort business conclusions.

---

## `vehicle_price_usd`

### Objective

Clean and validate vehicle prices in US dollars.

### Target Type

```sql
DECIMAL(10,2)
```

### Cleaning Rules

| Rule                                                 | Action                                    |
| ---------------------------------------------------- | ----------------------------------------- |
| Value contains currency symbols or commas            | Remove non-numeric characters             |
| Value is numeric and greater than or equal to `8000` | Convert to decimal                        |
| Value is negative                                    | Set `vehicle_price_usd_cleaned` to `NULL` |
| Value is below `8000`                                | Set `vehicle_price_usd_cleaned` to `NULL` |
| Value cannot be converted to a number                | Set `vehicle_price_usd_cleaned` to `NULL` |

### Example Transformations

| Original Value | Cleaned Value |
| -------------- | ------------: |
| `$25,000`      |    `25000.00` |
| `27000`        |    `27000.00` |
| `-15000`       |        `NULL` |
| `abc`          |        `NULL` |

### Data Quality Tracking

Invalid, negative, below-threshold or non-numeric prices are inserted into `data_quality_issues`.

### Business Rationale

Vehicle price is used as the main revenue-related metric. Invalid prices could significantly distort revenue, average ticket size and vehicle model performance analysis.

---

## `sale_date`

### Objective

Convert sale dates into a reliable `YYYY-MM-DD` format.

### Target Format

```text
YYYY-MM-DD
```

### Accepted Input Formats

| Input Format | Accepted When                             |
| ------------ | ----------------------------------------- |
| `YYYY-MM-DD` | Always, if valid                          |
| `YYYY/MM/DD` | Always, if valid                          |
| `DD-MM-YYYY` | When the first number is greater than 12  |
| `DD/MM/YYYY` | When the first number is greater than 12  |
| `MM-DD-YYYY` | When the second number is greater than 12 |
| `MM/DD/YYYY` | When the second number is greater than 12 |

### Cleaning Rules

| Rule                                    | Action                            |
| --------------------------------------- | --------------------------------- |
| Date is valid and unambiguous           | Convert to `DATE`                 |
| Date has impossible day or month        | Set to `NULL`                     |
| Date is ambiguous, such as `05-06-2021` | Set to `NULL` and flag for review |
| Date cannot be parsed                   | Set to `NULL`                     |

### Ambiguous Date Handling

Ambiguous sale dates are not guessed automatically.

Example:

```text
05-06-2021
```

This could mean either:

| Interpretation | Meaning     |
| -------------- | ----------- |
| `DD-MM-YYYY`   | 5 June 2021 |
| `MM-DD-YYYY`   | 6 May 2021  |

### Data Quality Tracking

Invalid, impossible and ambiguous sale dates are inserted into `data_quality_issues`.

### Business Rationale

Sale date is essential for trend analysis. Incorrect date parsing could distort monthly sales, seasonality and time-based performance conclusions.

---

## `customer_state`

### Objective

Standardise customer state values into official two-letter US postal abbreviations.

### Reference Tables

| Table                | Purpose                                           |
| -------------------- | ------------------------------------------------- |
| `ref_us_states`      | Official US state codes and names                 |
| `ref_us_state_alias` | Accepted aliases, names and alternative spellings |

### Target Format

```text
Two-letter US state abbreviation
```

Examples:

| Original Value | Cleaned Value |
| -------------- | ------------- |
| `California`   | `CA`          |
| `CA`           | `CA`          |
| `Texas`        | `TX`          |

### Cleaning Rules

| Rule                                              | Action                                 |
| ------------------------------------------------- | -------------------------------------- |
| Value is already a valid two-letter US state code | Keep code                              |
| Value matches official state name                 | Convert to state code                  |
| Value matches a known alias                       | Convert to state code                  |
| Value cannot be matched confidently               | Set `customer_state_cleaned` to `NULL` |

### Important Design Decision

The cleaning process avoids broad patterns such as:

```sql
LIKE '%ska'
```

because they may match more than one state.

Example:

| Pattern | Could Match |
| ------- | ----------- |
| `%ska`  | `Alaska`    |
| `%ska`  | `Nebraska`  |

### Data Quality Tracking

Unresolved state values are inserted into `data_quality_issues`.

### Business Rationale

Customer state supports geographic sales analysis. Low-confidence corrections could assign sales to the wrong state, so unresolved values are set to `NULL` instead of being guessed.

---

## `sale_status`

### Objective

Standardise sale status values into a controlled set of sales cycle statuses.

### Reference Table

`ref_sale_status`

### Accepted Cleaned Values

| Cleaned Status | Business Meaning                      |
| -------------- | ------------------------------------- |
| `Pending`      | Sale not yet completed                |
| `In Progress`  | Sale process is active                |
| `In Transit`   | Vehicle or sale process is in transit |
| `Sold`         | Completed sale                        |
| `Delivered`    | Completed sale                        |
| `Cancelled`    | Cancelled sale                        |
| `Returned`     | Returned sale                         |

### Cleaning Rules

| Rule                                       | Action                              |
| ------------------------------------------ | ----------------------------------- |
| Raw status exists in `ref_sale_status`     | Map to official sale status         |
| Raw status matches a safe fallback pattern | Map to official sale status         |
| Raw status cannot be matched               | Set `sale_status_cleaned` to `NULL` |

### Example Mappings

| Raw Value    | Cleaned Value |
| ------------ | ------------- |
| `pend`       | `Pending`     |
| `panding`    | `Pending`     |
| `in progres` | `In Progress` |
| `in trans`   | `In Transit`  |
| `sol`        | `Sold`        |
| `sould`      | `Sold`        |
| `deliverd`   | `Delivered`   |
| `delivery`   | `Delivered`   |
| `canceled`   | `Cancelled`   |
| `retu`       | `Returned`    |

### Fallback Pattern Logic

If a value is not found in the reference table, fallback patterns are used only when they are sufficiently clear.

Examples:

| Pattern          | Cleaned Status |
| ---------------- | -------------- |
| Contains `pend`  | `Pending`      |
| Contains `prog`  | `In Progress`  |
| Contains `trans` | `In Transit`   |
| Contains `can`   | `Cancelled`    |
| Contains `sol`   | `Sold`         |
| Contains `deli`  | `Delivered`    |
| Contains `retu`  | `Returned`     |

### Important Design Decision

The cleaning stage does not use an `ENUM` type for `sale_status`.

Instead, the script first cleans the values and leaves stronger constraints for the final cleaned table or dimension table.

### Data Quality Tracking

Unmatched or standardised sale statuses are inserted into `data_quality_issues`.

### Business Rationale

Sale status is critical for business analysis because only `Sold` and `Delivered` are treated as completed sales. Incorrect status values would distort completed sales, completed revenue, cancellation rates and return rates.

---

# Data Quality Issue Types

The project logs different types of issues depending on the column and rule applied.

Common issue categories include:

| Issue Type         | Meaning                                                  |
| ------------------ | -------------------------------------------------------- |
| Incorrect value    | The original value does not follow the expected format   |
| Unresolved value   | The value cannot be matched to a reference table         |
| Standardised value | The value was corrected or mapped to an official value   |
| Invalid format     | The value has an invalid structure                       |
| Ambiguous value    | The value could have more than one valid interpretation  |
| Duplicate value    | The value appears more than expected and requires review |

---

# Duplicate Handling

The cleaning process does not automatically delete records only because some attributes are duplicated.

Examples:

| Field            | Duplicate Handling                                                                      |
| ---------------- | --------------------------------------------------------------------------------------- |
| `employee_phone` | Repeated values may be valid because the same employee can appear in many sales records |
| `vin`            | Duplicate VINs are logged for review, but not automatically deleted                     |
| Full rows        | Fully duplicated rows should be reviewed separately before deletion                     |

This is important because the dataset represents sales-related records. A repeated employee, phone number, vehicle or dealer can be normal depending on the business process.

---

# Business Rules Applied

The main business rules applied during cleaning are:

| Area     | Rule                                                                               |
| -------- | ---------------------------------------------------------------------------------- |
| Dealer   | Dealer IDs are standardised into numeric identifiers                               |
| Employee | Employee data is resolved against the official employee reference table            |
| Phone    | US phone numbers are standardised as `XXX-XXX-XXXX`                                |
| VIN      | VINs must have 17 valid alphanumeric characters and cannot contain `I`, `O` or `Q` |
| Brand    | Vehicle brands are standardised using a mapping table                              |
| Model    | Vehicle models are validated together with vehicle brand                           |
| Year     | Vehicle years must be realistic and not in the future                              |
| Price    | Vehicle prices must be numeric and at least `8000` USD                             |
| Date     | Ambiguous dates are not guessed automatically                                      |
| State    | Customer states are standardised to official US postal abbreviations               |
| Status   | Sale statuses are standardised into the official sales cycle values                |

---

# Completed Sales Logic

For later business analysis, the following sale statuses are treated as completed sales:

| Sale Status   | Completed Sale |
| ------------- | -------------: |
| `Sold`        |            `1` |
| `Delivered`   |            `1` |
| `Pending`     |            `0` |
| `In Progress` |            `0` |
| `In Transit`  |            `0` |
| `Cancelled`   |            `0` |
| `Returned`    |            `0` |

This logic is especially important for metrics such as:

| Metric               |
| -------------------- |
| Completed sales      |
| Completed revenue    |
| Completed sales rate |
| Average ticket size  |
| Cancellation rate    |
| Return rate          |

---

# Why This Cleaning Approach Is Professional

This cleaning process follows several professional data quality principles:

1. **Raw data is preserved**
   The original dataset remains unchanged.

2. **Cleaned values are separated from raw values**
   Each cleaned field has its own `_cleaned` column.

3. **Reference tables are used where possible**
   This improves maintainability and avoids long, hard-coded transformation logic.

4. **Uncertain values are not guessed**
   Ambiguous or unresolved values are set to `NULL` and flagged for review.

5. **Data quality issues are logged**
   The `data_quality_issues` table provides traceability and auditability.

6. **Business context is considered**
   Cleaning decisions are aligned with dealership sales analysis, revenue reporting and dimensional modelling.

---

# Summary

The cleaning process transforms a raw and inconsistent car dealership sales dataset into a more reliable analytical dataset.

The main improvements include:

* Standardised dealer IDs
* Resolved employee IDs, names and emails
* Standardised employee roles
* Cleaned phone numbers
* Validated hire dates
* Validated VINs
* Standardised vehicle brands and models
* Validated vehicle years and prices
* Cleaned sale dates
* Standardised US customer states
* Standardised sale statuses
* Logged data quality issues for traceability

The final cleaned dataset is suitable for dimensional modelling, fact table creation and business analysis in MySQL.