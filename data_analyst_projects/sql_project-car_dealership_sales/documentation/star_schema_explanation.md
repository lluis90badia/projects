# Star Schema Explanation

## Project: Car Dealership Sales SQL Project

This document explains the dimensional model created from the cleaned car dealership sales dataset.

The objective of the star schema is to transform the cleaned transactional dataset into an analytical model that is easier to query, validate and use for business analysis.

The model is created after the data cleaning and data quality tracking phase. The source table for the dimensional model is:

```sql
cds_cleaned
```

---

## Data Modelling Context

Before creating the dimensional model, the project follows a layered data pipeline:

| Layer                     | Table                    | Purpose                                                        |
| ------------------------- | ------------------------ | -------------------------------------------------------------- |
| Raw layer                 | `cds_raw`                | Stores the original imported dataset without transformations   |
| Cleaning layer            | `cds_cleaning_process`   | Stores original and cleaned values during the cleaning process |
| Cleaned analytical source | `cds_cleaned`            | Stores only the final cleaned columns required for modelling   |
| Dimensional model         | `dim_*` and `fact_sales` | Stores the final star schema used for analysis                 |

The `cds_cleaned` table is created from the cleaned fields in `cds_cleaning_process`.

It contains the final analytical columns:

| Column              |
| ------------------- |
| `dealer_id`         |
| `employee_id`       |
| `employee_name`     |
| `employee_role`     |
| `hire_date`         |
| `employee_email`    |
| `employee_phone`    |
| `vin`               |
| `vehicle_brand`     |
| `vehicle_model`     |
| `vehicle_year`      |
| `vehicle_price_usd` |
| `sale_date`         |
| `customer_state`    |
| `sale_status`       |

---

## Why a Star Schema Was Created

A star schema was created to separate descriptive attributes from measurable sales facts.

This makes the model more suitable for business analysis because:

1. Dimension tables store descriptive business context.
2. The fact table stores transactional records and numeric measures.
3. Surrogate keys are used for joins between facts and dimensions.
4. Natural business keys are preserved inside dimensions for traceability.
5. Missing or unresolved dimension values are handled through `Unknown` members.
6. The final model supports cleaner aggregations by dealer, employee, vehicle, customer state, sale status and date.

---

## Star Schema Overview

The model contains one central fact table and six dimension tables.

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/star_schema.png"  height="800"></p>

---

## Fact Table

## `fact_sales`

The `fact_sales` table is the central table of the star schema.

### Grain

The grain of the fact table is:

> One row in `fact_sales` represents one vehicle sale transaction from `cds_cleaned`.

This means that each row represents one sales-related record from the cleaned dataset after replacing business keys with surrogate dimension keys.

### Fact Table Structure

| Column               | Type            | Description                                             |
| -------------------- | --------------- | ------------------------------------------------------- |
| `sale_key`           | `INT`           | Surrogate primary key of the fact table                 |
| `dealer_key`         | `INT`           | Foreign key to `dim_dealer`                             |
| `employee_key`       | `INT`           | Foreign key to `dim_employee`                           |
| `vehicle_key`        | `INT`           | Foreign key to `dim_vehicle`                            |
| `date_key`           | `INT`           | Foreign key to `dim_calendar`                           |
| `customer_state_key` | `INT`           | Foreign key to `dim_customer_state`                     |
| `sale_status_key`    | `INT`           | Foreign key to `dim_sale_status`                        |
| `sale_amount_usd`    | `DECIMAL(10,2)` | Sales amount taken from `cds_cleaned.vehicle_price_usd` |
| `sale_count`         | `INT`           | Default value of `1` for each sales record              |

### Measures

The fact table contains two main analytical measures.

| Measure           | Description                                                           |
| ----------------- | --------------------------------------------------------------------- |
| `sale_amount_usd` | Vehicle price in USD, used as the revenue-related measure             |
| `sale_count`      | Default value of `1`, used to count sales records through aggregation |

### Why `sale_count` Is Included

Although each row represents one transaction, having a `sale_count` column simplifies analytical queries.

Instead of using:

```sql
COUNT(*)
```

analysis queries can use:

```sql
SUM(sale_count)
```

This is especially useful when building business metrics such as total sales records, completed sales, cancellation rates and sales contribution percentages.

---

## Dimension Tables

---

## `dim_dealer`

The `dim_dealer` table stores dealership information.

### Purpose

This dimension allows analysis by dealership.

At this stage, the cleaned dataset only contains `dealer_id`, but creating a dealer dimension keeps the model scalable for future enrichment.

Possible future dealer attributes could include:

| Future Attribute |
| ---------------- |
| Dealer name      |
| Dealer city      |
| Dealer state     |
| Dealer region    |
| Dealer type      |
| Opening date     |

### Structure

| Column       | Type  | Description                                   |
| ------------ | ----- | --------------------------------------------- |
| `dealer_key` | `INT` | Surrogate primary key                         |
| `dealer_id`  | `INT` | Natural business identifier of the dealership |

### Key Design

| Key Type      | Column       |
| ------------- | ------------ |
| Surrogate key | `dealer_key` |
| Natural key   | `dealer_id`  |

A unique constraint is created on:

```sql
dealer_id
```

### Unknown Member

An `Unknown` member is inserted with:

```sql
dealer_key = 0
```

This prevents fact table loading failures when a dealer cannot be matched.

---

## `dim_employee`

The `dim_employee` table stores descriptive information about employees involved in sales.

### Purpose

This dimension supports employee-level analysis, such as sales performance by employee, employee role or employee tenure.

### Structure

| Column           | Type           | Description                                                      |
| ---------------- | -------------- | ---------------------------------------------------------------- |
| `employee_key`   | `INT`          | Surrogate primary key                                            |
| `employee_id`    | `INT`          | Natural employee identifier from the cleaned dataset             |
| `employee_name`  | `VARCHAR(100)` | Full employee name                                               |
| `first_name`     | `VARCHAR(50)`  | Employee first name, enriched from `ref_employee` when available |
| `last_name`      | `VARCHAR(50)`  | Employee last name, enriched from `ref_employee` when available  |
| `employee_email` | `VARCHAR(100)` | Employee email address                                           |
| `employee_role`  | `VARCHAR(50)`  | Employee job role                                                |
| `hire_date`      | `DATE`         | Employee hire date                                               |
| `employee_phone` | `VARCHAR(30)`  | Employee phone number                                            |

### Key Design

| Key Type      | Column         |
| ------------- | -------------- |
| Surrogate key | `employee_key` |
| Natural key   | `employee_id`  |

A unique constraint is created on:

```sql
employee_id
```

### Loading Logic

The dimension inserts one row per valid `employee_id`.

When multiple rows exist for the same employee in `cds_cleaned`, the dimension groups them by `employee_id` and uses aggregate logic such as:

```sql
MAX(employee_name)
MAX(employee_email)
MAX(employee_role)
MAX(hire_date)
MAX(employee_phone)
```

The employee dimension is also enriched with `first_name` and `last_name` from the `ref_employee` table when the employee email matches.

### Unknown Member

An `Unknown` member is inserted with:

```sql
employee_key = 0
```

This allows the fact table to preserve transactions even when the employee cannot be matched.

---

## `dim_vehicle`

The `dim_vehicle` table stores vehicle-level descriptive attributes.

### Purpose

This dimension supports analysis by vehicle, brand, model and vehicle year.

It is especially useful for business questions such as:

* Which vehicle brands generate the highest revenue?
* Which vehicle models have the highest completed sales?
* What is the sales distribution by vehicle year?
* Which models have higher cancellation or return rates?

### Structure

| Column          | Type          | Description                   |
| --------------- | ------------- | ----------------------------- |
| `vehicle_key`   | `INT`         | Surrogate primary key         |
| `vin`           | `VARCHAR(50)` | Vehicle Identification Number |
| `vehicle_brand` | `VARCHAR(50)` | Vehicle brand                 |
| `vehicle_model` | `VARCHAR(50)` | Vehicle model                 |
| `vehicle_year`  | `INT`         | Vehicle model year            |

### Key Design

| Key Type      | Column        |
| ------------- | ------------- |
| Surrogate key | `vehicle_key` |
| Natural key   | `vin`         |

A unique constraint is created on:

```sql
vin
```

### Loading Logic

The dimension inserts one row per valid VIN.

Rows where `vin` is `NULL` are intentionally excluded from `dim_vehicle` because they cannot reliably identify a specific vehicle.

These rows are later assigned to the `Unknown` vehicle member in the fact table.

### Unknown Member

An `Unknown` member is inserted with:

```sql
vehicle_key = 0
```

The unknown vehicle row contains:

| Column          | Value     |
| --------------- | --------- |
| `vehicle_key`   | `0`       |
| `vin`           | `NULL`    |
| `vehicle_brand` | `Unknown` |
| `vehicle_model` | `Unknown` |
| `vehicle_year`  | `NULL`    |

### Business Rationale

Using VIN as the natural key avoids incorrectly merging vehicles with the same brand, model and year. Two vehicles can share the same brand, model and year but still be different physical units.

---

## `dim_customer_state`

The `dim_customer_state` table stores US customer state information.

### Purpose

This dimension supports geographic analysis of sales activity.

It can answer questions such as:

* Which states generate the highest number of sales records?
* Which states generate the highest completed revenue?
* Are there states with more cancellations or returns?
* Are there states without sales activity?

### Structure

| Column               | Type          | Description                      |
| -------------------- | ------------- | -------------------------------- |
| `customer_state_key` | `INT`         | Surrogate primary key            |
| `state_code`         | `CHAR(2)`     | Two-letter US state abbreviation |
| `state_name`         | `VARCHAR(50)` | Full US state name               |

### Key Design

| Key Type      | Column               |
| ------------- | -------------------- |
| Surrogate key | `customer_state_key` |
| Natural key   | `state_code`         |

A unique constraint is created on:

```sql
state_code
```

### Loading Logic

Unlike some other dimensions, this table is not loaded only from states present in `cds_cleaned`.

Instead, it is loaded from the full reference table:

```sql
ref_us_states
```

### Why the Full Reference Table Is Used

US states are a stable controlled domain. Loading the full list makes it possible to analyse:

| Scenario             | Example                                                     |
| -------------------- | ----------------------------------------------------------- |
| States with sales    | States appearing in `fact_sales`                            |
| States without sales | States from `dim_customer_state` with no matching fact rows |

This is more complete than only loading states present in the cleaned dataset.

### Unknown Member

An `Unknown` member is inserted with:

```sql
customer_state_key = 0
```

This member is used when the original customer state was missing, invalid or could not be confidently standardised.

---

## `dim_sale_status`

The `dim_sale_status` table stores standardised sale status values.

### Purpose

This dimension is critical for distinguishing completed sales from non-completed sales records.

It supports analysis such as:

* Completed sales
* Completed revenue
* Pending sales
* Cancelled sales
* Returned sales
* Completed sales rate
* Cancellation rate
* Return rate

### Structure

| Column            | Type          | Description              |
| ----------------- | ------------- | ------------------------ |
| `sale_status_key` | `INT`         | Surrogate primary key    |
| `sale_status`     | `VARCHAR(50)` | Standardised sale status |

### Key Design

| Key Type      | Column            |
| ------------- | ----------------- |
| Surrogate key | `sale_status_key` |
| Natural key   | `sale_status`     |

A unique constraint is created on:

```sql
sale_status
```

### Loading Logic

The dimension inserts one row per distinct non-null `sale_status` from `cds_cleaned`.

### Unknown Member

An `Unknown` member is inserted with:

```sql
sale_status_key = 0
```

This member is used when a transaction has a missing or unmatched sale status.

### Recommended Business Classification

For business analysis, the following classification can be applied:

| Sale Status   | Completed Sale |
| ------------- | -------------: |
| `Sold`        |            `1` |
| `Delivered`   |            `1` |
| `Pending`     |            `0` |
| `In Progress` |            `0` |
| `In Transit`  |            `0` |
| `Cancelled`   |            `0` |
| `Returned`    |            `0` |
| `Unknown`     |            `0` |

This classification can be implemented either in analytical SQL queries or as an additional attribute in `dim_sale_status`, for example:

```sql
is_completed_sale
```

Adding this derived attribute would make analysis queries easier and more consistent.

---

## `dim_calendar`

The `dim_calendar` table stores date attributes for time-based analysis.

### Purpose

This dimension enables analysis by year, quarter, month, week and day.

It supports questions such as:

* How do completed sales evolve over time?
* What are the monthly revenue trends?
* Are there seasonal sales patterns?
* Which quarters perform better?
* Are cancellations or returns concentrated in specific periods?

### Structure

| Column           | Type          | Description                                      |
| ---------------- | ------------- | ------------------------------------------------ |
| `date_key`       | `INT`         | Integer date key in `YYYYMMDD` format            |
| `full_date`      | `DATE`        | Actual calendar date                             |
| `year_number`    | `INT`         | Calendar year                                    |
| `quarter_number` | `INT`         | Calendar quarter                                 |
| `month_number`   | `INT`         | Month number                                     |
| `month_name`     | `VARCHAR(20)` | Month name                                       |
| `day_of_month`   | `INT`         | Day of the month                                 |
| `day_name`       | `VARCHAR(20)` | Day name                                         |
| `week_of_year`   | `INT`         | ISO-style week number using `WEEK(full_date, 3)` |

### Key Design

| Key Type           | Column      |
| ------------------ | ----------- |
| Surrogate/date key | `date_key`  |
| Natural date       | `full_date` |

A unique constraint is created on:

```sql
full_date
```

### Loading Logic

The calendar dimension is generated dynamically using a recursive CTE.

It creates one row for every date between:

```sql
MIN(cds_cleaned.sale_date)
```

and:

```sql
MAX(cds_cleaned.sale_date)
```

The `date_key` is generated in `YYYYMMDD` format.

Example:

| Date         |   Date Key |
| ------------ | ---------: |
| `2025-01-15` | `20250115` |
| `2024-02-12` | `20240212` |

### Missing Sale Dates

The model does not create an artificial `Unknown` row in `dim_calendar`.

Instead:

```sql
fact_sales.date_key
```

is allowed to be `NULL`.

This is a deliberate modelling decision because an unknown date is not a real calendar date. Rows without a valid sale date are preserved in the fact table but cannot be used in time-based analysis unless handled separately.

---

## Relationship Between Fact and Dimensions

The fact table joins to the dimensions through surrogate keys.

| Fact Table Column    | Dimension Table      | Dimension Key        |
| -------------------- | -------------------- | -------------------- |
| `dealer_key`         | `dim_dealer`         | `dealer_key`         |
| `employee_key`       | `dim_employee`       | `employee_key`       |
| `vehicle_key`        | `dim_vehicle`        | `vehicle_key`        |
| `date_key`           | `dim_calendar`       | `date_key`           |
| `customer_state_key` | `dim_customer_state` | `customer_state_key` |
| `sale_status_key`    | `dim_sale_status`    | `sale_status_key`    |

The model enforces referential integrity through foreign key constraints.

Indexes are also created on each foreign key column in `fact_sales` to support join performance.

---

## Fact Table Loading Logic

The `fact_sales` table is loaded from `cds_cleaned`.

During the loading process, the natural keys from `cds_cleaned` are replaced with surrogate keys from the dimension tables.

### Mapping Logic

| Source Column in `cds_cleaned` | Dimension Join                  | Fact Column          |
| ------------------------------ | ------------------------------- | -------------------- |
| `dealer_id`                    | `dim_dealer.dealer_id`          | `dealer_key`         |
| `employee_id`                  | `dim_employee.employee_id`      | `employee_key`       |
| `vin`                          | `dim_vehicle.vin`               | `vehicle_key`        |
| `sale_date`                    | `dim_calendar.full_date`        | `date_key`           |
| `customer_state`               | `dim_customer_state.state_code` | `customer_state_key` |
| `sale_status`                  | `dim_sale_status.sale_status`   | `sale_status_key`    |
| `vehicle_price_usd`            | Direct measure                  | `sale_amount_usd`    |
| Derived constant               | Direct measure                  | `sale_count = 1`     |

### Unknown Member Handling

The fact loading process uses:

```sql
COALESCE(dimension_key, 0)
```

for most dimensions.

This means that if a dimension value cannot be matched, the transaction is still inserted into `fact_sales`, but it is assigned to the corresponding `Unknown` dimension member.

This approach avoids losing transactions during modelling.

### Exception: Calendar Dimension

The calendar dimension is handled differently.

If `sale_date` cannot be matched to `dim_calendar`, then:

```sql
date_key = NULL
```

This is because there is no artificial `Unknown` date row in `dim_calendar`.

---

## Unknown Members

The model uses `Unknown` members to preserve facts with missing or unresolved dimensional values.

| Dimension            | Unknown Key | Reason                           |
| -------------------- | ----------: | -------------------------------- |
| `dim_dealer`         |         `0` | Missing or unmatched dealer      |
| `dim_employee`       |         `0` | Missing or unmatched employee    |
| `dim_vehicle`        |         `0` | Missing or unmatched VIN         |
| `dim_customer_state` |         `0` | Missing or unmatched state       |
| `dim_sale_status`    |         `0` | Missing or unmatched sale status |

The calendar dimension is the exception because unknown dates are stored as `NULL` in `fact_sales.date_key`.

---

## Validation Checks After Modelling

After creating the star schema, several validation checks are performed.

### 1. Row Count Validation

The number of rows in `fact_sales` is compared with the number of rows in `cds_cleaned`.

Expected result:

```text
cds_cleaned rows = fact_sales rows
```

Current result documented in the SQL script:

| Table         |  Rows |
| ------------- | ----: |
| `cds_cleaned` | `999` |
| `fact_sales`  | `999` |

This confirms that no records were lost or duplicated during fact table loading.

---

### 2. Unknown Dimension Member Validation

The fact table is checked to identify how many rows were assigned to unknown dimension members.

Current result documented in the SQL script:

| Unknown Dimension           | Rows |
| --------------------------- | ---: |
| Unknown vehicle rows        | `43` |
| Unknown customer state rows | `27` |
| Other unknown dimensions    |  `0` |

This means some records still have unresolved vehicle or customer state values, but those records remain available in the fact table.

---

### 3. Missing Date Validation

Rows without a valid `date_key` are counted.

Current result documented in the SQL script:

| Check                   | Rows |
| ----------------------- | ---: |
| Rows without `date_key` | `50` |

These rows are preserved in `fact_sales`, but they cannot be included in date-based analysis unless handled separately.

---

### 4. Unknown Vehicle Review

Rows with:

```sql
vehicle_key = 0
```

are reviewed separately.

In this model, this mainly represents source records where `vin` is `NULL` or could not be matched to `dim_vehicle`.

Current result documented in the SQL script:

| Check                      | Rows |
| -------------------------- | ---: |
| Sales with unknown vehicle | `43` |

---

### 5. Orphan Foreign Key Validation

The model checks for orphan foreign keys, such as fact rows with a `vehicle_key` that does not exist in `dim_vehicle`.

Current result documented in the SQL script:

| Check               | Rows |
| ------------------- | ---: |
| Orphan vehicle keys |  `0` |

This confirms that referential integrity is preserved.

---

### 6. Measure Validation

The total sales amount in `fact_sales` is compared with the total `vehicle_price_usd` amount in `cds_cleaned`.

Expected result:

```text
SUM(cds_cleaned.vehicle_price_usd) = SUM(fact_sales.sale_amount_usd)
```

This check confirms that the revenue-related measure was transferred correctly from the cleaned table to the fact table.

---

## Business Analysis Enabled by the Model

The star schema supports dealership sales analysis across multiple business perspectives.

### Dealer Performance

Using:

```sql
fact_sales
dim_dealer
```

Possible questions:

* Which dealers generate the highest completed revenue?
* Which dealers have the highest completed sales rate?
* Which dealers have a higher proportion of cancelled or returned sales?

---

### Employee Performance

Using:

```sql
fact_sales
dim_employee
```

Possible questions:

* Which employees generate the most completed sales?
* Which employees generate the highest completed revenue?
* Does performance vary by employee role?
* Is there any relationship between employee tenure and sales performance?

---

### Vehicle Performance

Using:

```sql
fact_sales
dim_vehicle
```

Possible questions:

* Which brands generate the highest completed revenue?
* Which vehicle models have the highest sales volume?
* Which vehicle years are most commonly sold?
* Are some models more associated with returns or cancellations?

---

### Geographic Analysis

Using:

```sql
fact_sales
dim_customer_state
```

Possible questions:

* Which customer states generate the most sales activity?
* Which states generate the highest completed revenue?
* Are some states more associated with cancellations, returns or pending sales?

---

### Sales Status Analysis

Using:

```sql
fact_sales
dim_sale_status
```

Possible questions:

* What percentage of sales records are completed?
* What percentage are cancelled?
* What percentage are returned?
* How much revenue comes only from `Sold` and `Delivered` records?

---

### Time-Based Analysis

Using:

```sql
fact_sales
dim_calendar
```

Possible questions:

* What are the monthly completed sales trends?
* What are the quarterly revenue trends?
* Are there seasonal patterns in completed sales?
* Do cancellation or return rates vary over time?

---

## Recommended Query Pattern

A typical analytical query should start from `fact_sales` and join only the dimensions required for the analysis.

Example:

```sql
SELECT
    dv.vehicle_brand,
    dv.vehicle_model,
    SUM(fs.sale_count) AS total_sales_records,
    SUM(fs.sale_amount_usd) AS total_sales_amount
FROM
    fact_sales fs
JOIN
    dim_vehicle dv
        ON fs.vehicle_key = dv.vehicle_key
GROUP BY
    dv.vehicle_brand,
    dv.vehicle_model
ORDER BY
    total_sales_amount DESC;
```

For completed sales analysis, `dim_sale_status` should be included:

```sql
SELECT
    dv.vehicle_brand,
    dv.vehicle_model,
    SUM(fs.sale_count) AS completed_sales,
    SUM(fs.sale_amount_usd) AS completed_revenue
FROM
    fact_sales fs
JOIN
    dim_vehicle dv
        ON fs.vehicle_key = dv.vehicle_key
JOIN
    dim_sale_status dss
        ON fs.sale_status_key = dss.sale_status_key
WHERE
    dss.sale_status IN ('Sold', 'Delivered')
GROUP BY
    dv.vehicle_brand,
    dv.vehicle_model
ORDER BY
    completed_revenue DESC;
```

---

## Design Decisions

### 1. Surrogate Keys Are Used

Each dimension uses a surrogate key such as:

| Dimension            | Surrogate Key        |
| -------------------- | -------------------- |
| `dim_dealer`         | `dealer_key`         |
| `dim_employee`       | `employee_key`       |
| `dim_vehicle`        | `vehicle_key`        |
| `dim_customer_state` | `customer_state_key` |
| `dim_sale_status`    | `sale_status_key`    |
| `dim_calendar`       | `date_key`           |

This makes the fact table simpler and more stable than joining directly on raw business values.

---

### 2. Natural Keys Are Preserved

Natural keys are still stored inside the dimension tables.

Examples:

| Dimension            | Natural Key   |
| -------------------- | ------------- |
| `dim_dealer`         | `dealer_id`   |
| `dim_employee`       | `employee_id` |
| `dim_vehicle`        | `vin`         |
| `dim_customer_state` | `state_code`  |
| `dim_sale_status`    | `sale_status` |
| `dim_calendar`       | `full_date`   |

This preserves traceability between the star schema and the cleaned dataset.

---

### 3. Unknown Members Preserve Transactions

Rows with missing or unresolved dimensional values are not dropped.

Instead, they are assigned to `Unknown` dimension members where appropriate.

This is important because dropping rows could understate sales volume, revenue or operational activity.

---

### 4. Missing Dates Are Kept as `NULL`

The model does not create an artificial unknown calendar date.

This avoids mixing real dates with artificial date records. Transactions without a valid sale date remain in the fact table, but they are excluded from time-based joins unless handled intentionally.

---

### 5. `dim_customer_state` Uses a Full Reference Domain

The customer state dimension is loaded from the complete US state reference table, not only from states present in the cleaned dataset.

This makes the model more complete and suitable for geographic coverage analysis.

---

### 6. `dim_vehicle` Uses VIN as the Main Natural Key

VIN is used as the natural key because it identifies a specific vehicle unit.

Rows without VIN are mapped to the unknown vehicle member rather than being grouped only by brand, model and year.

This prevents different physical vehicles from being incorrectly merged.

---

## Suggested Future Improvements

The current model is already suitable for SQL portfolio analysis, but it could be improved further with the following enhancements.

### 1. Add Classification Columns to `dim_sale_status`

Recommended fields:

| Field               | Description                                                                |
| ------------------- | -------------------------------------------------------------------------- |
| `is_completed_sale` | `1` for `Sold` and `Delivered`, otherwise `0`                              |
| `status_group`      | Groups statuses into completed, cancelled, returned, pending or in process |

This would simplify business analysis queries.

---

### 2. Enrich `dim_dealer`

Recommended future fields:

| Field           |
| --------------- |
| `dealer_name`   |
| `dealer_city`   |
| `dealer_state`  |
| `dealer_region` |
| `dealer_type`   |

This would make dealer performance analysis more realistic.

---

### 3. Add Vehicle Segmentation

Recommended future fields:

| Field             |
| ----------------- |
| `vehicle_segment` |
| `body_type`       |
| `fuel_type`       |
| `new_or_used`     |

This would enable more advanced analysis by SUV, sedan, truck, electric vehicle or used vehicle category.

---

### 4. Add a Dedicated Date Key for Employee Hire Date

Currently, `dim_calendar` is connected to `fact_sales.sale_date`.

If employee tenure analysis becomes more important, `hire_date` could also be connected to a date dimension or used to derive tenure attributes inside `dim_employee`.

---

### 5. Consider Slowly Changing Dimensions

If the project evolves into a more advanced dimensional modelling exercise, employee role changes, dealer changes or vehicle attribute updates could be handled using Slowly Changing Dimension logic.

For this project, a simple Type 1 dimension approach is sufficient.

---

## Summary

The star schema converts the cleaned dealership sales dataset into a structured analytical model.

The model contains:

| Table                | Type       | Purpose                                       |
| -------------------- | ---------- | --------------------------------------------- |
| `fact_sales`         | Fact table | Stores vehicle sale transactions and measures |
| `dim_dealer`         | Dimension  | Stores dealership identifiers                 |
| `dim_employee`       | Dimension  | Stores employee attributes                    |
| `dim_vehicle`        | Dimension  | Stores vehicle attributes                     |
| `dim_customer_state` | Dimension  | Stores US customer state information          |
| `dim_sale_status`    | Dimension  | Stores standardised sale statuses             |
| `dim_calendar`       | Dimension  | Stores date attributes for time analysis      |

This structure supports reliable business analysis by separating sales measures from descriptive attributes while preserving data quality traceability through unknown members and validation checks.

The final model is appropriate for analysing completed sales, revenue, dealer performance, employee performance, vehicle model performance, customer geography, sale status distribution and time-based trends.
