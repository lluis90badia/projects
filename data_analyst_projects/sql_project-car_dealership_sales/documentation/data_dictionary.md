# Data Dictionary

## Project: Car Dealership Sales SQL Project

This data dictionary documents the main fields used in the cleaned car dealership sales dataset. The dataset represents vehicle sales records from a dealership network and is used as the basis for data cleaning, dimensional modelling, fact table creation, and business analysis in MySQL.

The cleaned sample dataset contains **100 rows** and **15 columns**.

---

## Dataset Overview

| Field                 | Description                                                                                                                              |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Dataset name          | `car_dealership_sales_cleaned_sample.csv`                                                                                                |
| Business domain       | Vehicle dealership sales                                                                                                                 |
| Data stage            | Cleaned sample dataset                                                                                                                   |
| Granularity           | One row represents one vehicle sales-related record                                                                                      |
| Main business process | Vehicle sales tracking                                                                                                                   |
| Main analytical focus | Sales performance, completed sales, revenue, dealer performance, employee activity, vehicle model performance, and sale status analysis. |

---

## Column-Level Data Dictionary

| Column Name         | Recommended MySQL Data Type | Nullable | Description                                                                                                                                                                                   | Example Values                                         |
| ------------------- | --------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `dealer_id`         | `INT`                       | No       | Unique identifier of the dealership where the sale or sales-related record was registered. This field can be used to analyse performance by dealer.                                           | `1`, `3`, `5`                                          |
| `employee_id`       | `INT`                       | No       | Unique identifier of the employee associated with the sales record. This field can be used to analyse sales activity and performance by employee.                                             | `1001`, `1006`, `1012`                                 |
| `employee_name`     | `VARCHAR(100)`              | No       | Full name of the employee linked to the sales record. In a dimensional model, this attribute belongs to the employee dimension.                                                               | `John Miller`, `Jessica Moore`, `Sarah Johnson`        |
| `employee_role`     | `VARCHAR(50)`               | No       | Job role of the employee involved in the sales process. Useful for analysing sales performance by role or responsibility level.                                                               | `Sales Associate`, `Sales Consultant`, `Sales Manager` |
| `hire_date`         | `DATE`                      | Yes      | Date when the employee was hired. This can support employee tenure analysis. Some records may be unknown or unavailable.                                                                      | `2022-03-14`, `2018-09-09`, `2021-02-28`               |
| `employee_email`    | `VARCHAR(150)`              | No       | Standardised business email address of the employee. This field should be treated as an employee attribute rather than a sales transaction metric.                                            | `john.miller@sunsetautos.com`                          |
| `employee_phone`    | `VARCHAR(20)`               | Yes      | Standardised employee phone number. Stored as text because phone numbers are identifiers, not numerical values for calculation. Some records may be missing.                                  | `555-213-7788`, `555-411-8890`                         |
| `vin`               | `VARCHAR(17)`               | Yes      | Vehicle Identification Number. This identifies a specific vehicle unit. Some records may have missing VIN values after cleaning if the original value was invalid or unavailable.             | `1HGCM82633A123456`, `1FTFW1E50MFA54321`               |
| `vehicle_brand`     | `VARCHAR(50)`               | No       | Vehicle manufacturer or brand. Useful for brand-level sales and revenue analysis.                                                                                                             | `Honda`, `Toyota`, `Ford`, `Chevrolet`                 |
| `vehicle_model`     | `VARCHAR(100)`              | No       | Vehicle model sold or associated with the sales record. Useful for identifying top-performing models by revenue, volume, or completion rate.                                                  | `Civic`, `Corolla`, `F-150`, `Equinox`                 |
| `vehicle_year`      | `YEAR` or `SMALLINT`        | No       | Model year of the vehicle. Can be used to analyse sales distribution by vehicle age or production year.                                                                                       | `2021`, `2022`, `2018`                                 |
| `vehicle_price_usd` | `DECIMAL(10,2)`             | Yes      | Vehicle price in US dollars. This field is used as the main revenue-related metric in the analysis. Some records may be missing if the price was invalid or unavailable.                      | `21995.00`, `25460.00`, `38999.00`                     |
| `sale_date`         | `DATE`                      | Yes      | Date of the sale or sales-related transaction. This field enables time-based analysis, such as monthly sales trends. Some records may be missing if the original date was invalid or unknown. | `2025-01-15`, `2024-02-12`, `2025-02-10`               |
| `customer_state`    | `CHAR(2)`                   | Yes      | US state abbreviation of the customer. This field supports geographic analysis of sales activity. Some values may be missing when the state could not be confidently standardised.            | `CA`, `TX`, `NV`, `WA`                                 |
| `sale_status`       | `VARCHAR(30)`               | No       | Current status of the sale. This field is critical for distinguishing completed sales from non-completed, pending, returned, or cancelled transactions.                                       | `Sold`, `Delivered`, `Pending`, `Cancelled`            |

---

## Categorical Values

### `employee_role`

The cleaned dataset includes the following employee roles:

| Value              |
| ------------------ |
| `Sales Associate`  |
| `Sales Consultant` |
| `Sales Manager`    |
| `Internet Sales`   |
| `Sales Advisor`    |
| `General Manager`  |

---

### `sale_status`

The cleaned dataset includes the following sale statuses:

| Value         | Business Interpretation                     |
| ------------- | ------------------------------------------- |
| `Sold`        | Completed sale                              |
| `Delivered`   | Completed sale                              |
| `Pending`     | Sale not yet completed                      |
| `In Progress` | Sale process is active but not completed    |
| `In Transit`  | Vehicle or sale process is still in transit |
| `Returned`    | Sale was completed but later returned       |
| `Cancelled`   | Sale was cancelled                          |

For business analysis, `Sold` and `Delivered` can be treated as **completed sales**, while the rest should generally be treated as **non-completed or unresolved sales statuses** unless stated otherwise.

---

## Key Business Metrics Derived from the Dataset

Although not all of the following fields exist directly in the cleaned CSV, they can be derived from the available columns during the analysis phase.

| Metric               | Definition                                                              |
| -------------------- | ----------------------------------------------------------------------- |
| Completed sales      | Count of records where `sale_status` is `Sold` or `Delivered`           |
| Completed revenue    | Sum of `vehicle_price_usd` where `sale_status` is `Sold` or `Delivered` |
| Total sales records  | Total number of sales-related records, regardless of status             |
| Completed sales rate | Completed sales divided by total sales records                          |
| Average ticket size  | Completed revenue divided by completed sales                            |
| Cancellation rate    | Cancelled sales divided by total sales records                          |
| Return rate          | Returned sales divided by total sales records                           |

---

## Suggested Dimensional Model Mapping

The cleaned dataset can be transformed into a star schema for analytical purposes.

### Fact Table

#### `fact_sales`

Recommended fields:

| Field                | Source Column           | Description                               |
| -------------------- | ----------------------- | ----------------------------------------- |
| `sale_key`           | Generated surrogate key | Unique identifier for each fact row       |
| `dealer_key`         | From `dealer_id`        | Foreign key to `dim_dealer`               |
| `employee_key`       | From `employee_id`      | Foreign key to `dim_employee`             |
| `vehicle_key`        | From vehicle attributes | Foreign key to `dim_vehicle`              |
| `sale_status_key`    | From `sale_status`      | Foreign key to `dim_sale_status`          |
| `customer_state_key` | From `customer_state`   | Foreign key to `dim_customer_state`       |
| `sale_date`          | `sale_date`             | Date of the sales record                  |
| `sale_amount_usd`    | `vehicle_price_usd`     | Sales amount or vehicle price             |
| `sale_count`         | Derived value           | Usually `1` per row, used for aggregation |

---

### Dimension Tables

#### `dim_dealer`

| Field        | Source Column           | Description                                   |
| ------------ | ----------------------- | --------------------------------------------- |
| `dealer_key` | Generated surrogate key | Primary key of the dealer dimension           |
| `dealer_id`  | `dealer_id`             | Natural business identifier of the dealership |

---

#### `dim_employee`

| Field            | Source Column           | Description                           |
| ---------------- | ----------------------- | ------------------------------------- |
| `employee_key`   | Generated surrogate key | Primary key of the employee dimension |
| `employee_id`    | `employee_id`           | Natural employee identifier           |
| `employee_name`  | `employee_name`         | Full employee name                    |
| `employee_role`  | `employee_role`         | Employee job role                     |
| `hire_date`      | `hire_date`             | Employee hiring date                  |
| `employee_email` | `employee_email`        | Employee email address                |
| `employee_phone` | `employee_phone`        | Employee phone number                 |

---

#### `dim_vehicle`

| Field           | Source Column           | Description                          |
| --------------- | ----------------------- | ------------------------------------ |
| `vehicle_key`   | Generated surrogate key | Primary key of the vehicle dimension |
| `vin`           | `vin`                   | Vehicle Identification Number        |
| `vehicle_brand` | `vehicle_brand`         | Vehicle manufacturer                 |
| `vehicle_model` | `vehicle_model`         | Vehicle model                        |
| `vehicle_year`  | `vehicle_year`          | Vehicle model year                   |

---

#### `dim_sale_status`

| Field               | Source Column           | Description                                              |
| ------------------- | ----------------------- | -------------------------------------------------------- |
| `sale_status_key`   | Generated surrogate key | Primary key of the sale status dimension                 |
| `sale_status`       | `sale_status`           | Standardised sale status                                 |
| `is_completed_sale` | Derived field           | Indicates whether the status represents a completed sale |

Recommended logic:

| `sale_status` | `is_completed_sale` |
| ------------- | ------------------- |
| `Sold`        | `1`                 |
| `Delivered`   | `1`                 |
| `Pending`     | `0`                 |
| `In Progress` | `0`                 |
| `In Transit`  | `0`                 |
| `Returned`    | `0`                 |
| `Cancelled`   | `0`                 |

---

#### `dim_customer_state`

| Field                | Source Column           | Description                                   |
| -------------------- | ----------------------- | --------------------------------------------- |
| `customer_state_key` | Generated surrogate key | Primary key of the customer state dimension   |
| `customer_state`     | `customer_state`        | Standardised two-letter US state abbreviation |

---

## Data Quality Notes

The cleaned sample dataset still contains some nullable fields. This is expected in a realistic cleaning process when certain values cannot be corrected with high confidence.

| Column              | Data Quality Note                                                                        |
| ------------------- | ---------------------------------------------------------------------------------------- |
| `hire_date`         | May be missing when the employee hire date was unavailable or invalid in the source data |
| `employee_phone`    | May be missing when the original phone number could not be standardised                  |
| `vin`               | May be missing when the original VIN was invalid, incomplete, or unavailable             |
| `vehicle_price_usd` | May be missing when the price was invalid or not reliable                                |
| `sale_date`         | May be missing when the sale date was invalid or unavailable                             |
| `customer_state`    | May be missing when the state could not be confidently standardised                      |

In this project, missing values should not automatically be treated as errors. In some cases, replacing uncertain values with `NULL` is preferable to applying low-confidence corrections that could distort business analysis.

---

## Business Context

This dataset supports a dealership sales analysis workflow. The most relevant business questions include:

* Which vehicle brands and models generate the highest completed revenue?
* Which dealerships have the strongest completed sales performance?
* Which employees contribute most to completed sales?
* What percentage of sales records are completed, cancelled, returned, or still pending?
* Which customer states generate the most sales activity?
* What is the average ticket size for completed sales?
* Are there patterns in sale status by vehicle brand, dealer, or employee role?

The purpose of the cleaned dataset and dimensional model is to make these analyses more reliable, consistent, and easier to reproduce.

---

## Summary

This data dictionary provides the documentation layer for the cleaned car dealership sales dataset. It defines each column, explains its business meaning, identifies nullable fields, and connects the cleaned dataset with the future star schema model used for sales analysis.

The dataset is suitable for demonstrating an end-to-end SQL workflow including:

1. Data profiling
2. Data cleaning and standardisation
3. Data quality tracking
4. Dimensional modelling
5. Fact table creation
6. Business analysis
7. Business insight generation
