# Car Dealership Sales SQL Project

By [Lluis Badia Planes](https://github.com/lluis90badia/projects)

---

## Content

- [Project Home page](https://github.com/lluis90badia/projects/tree/main/data_analyst_projects/sql_project-car_dealership_sales)
- [Documentation](https://github.com/lluis90badia/projects/tree/main/data_analyst_projects/sql_project-car_dealership_sales/documentation)
- [SQL files](https://github.com/lluis90badia/projects/tree/main/data_analyst_projects/sql_project-car_dealership_sales/sql)

---

## Overview

This project demonstrates an end-to-end SQL workflow in **MySQL** using a fictional US car dealership sales dataset.

The project covers the full data lifecycle:

1. Raw CSV import
2. Data cleaning and standardisation
3. Data quality issue tracking
4. Creation of a cleaned analytical table
5. Dimensional modelling with a star schema
6. Fact table creation
7. Business analysis and conclusions

The goal is to transform a raw and inconsistent dataset into a reliable analytical model that can support dealership sales analysis.

---

## Business Context

The dataset represents vehicle sales records from a dealership network.

The analysis focuses on answering business questions such as:

* Which brands and models generate the highest completed revenue?
* Which dealerships perform best by revenue, volume and completion rate?
* Which employees generate the most completed sales?
* Which US states generate the highest sales activity?
* Are there relevant seasonal sales patterns?
* Are newer vehicles more profitable than older vehicles?
* Which records or segments show potential analytical red flags?

For business analysis, only the following sale statuses are treated as completed sales:

| Sale Status | Business Meaning |
| ----------- | ---------------- |
| `Sold`      | Completed sale   |
| `Delivered` | Completed sale   |

Other statuses such as `Cancelled`, `Pending`, `In Progress`, `In Transit`, `Returned` and `Unknown` are not treated as confirmed revenue.

---

## Tools Used

* **MySQL**
* SQL data cleaning
* SQL data modelling
* Star schema design
* Window functions
* Common Table Expressions
* Data quality validation
* Business analysis with SQL

---

## Project Structure

```text
car-dealership-sales-sql-project/
│
├── data/
│   ├── raw/
│   │   └── raw_car_dealership_sales_22_25.csv
│   └── cleaned/
│       └── car_dealership_sales_cleaned_sample.csv
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_data_import.sql
│   ├── 03_data_profiling.sql
│   ├── 04_data_cleaning_data_quality_tracking.sql
│   ├── 05_dimensional_modelling.sql
│   ├── 06_fact_table_creation.sql
│   └── 07_business_analysis_conclusions.sql
│
├── documentation/
│   ├── data_dictionary.md
│   ├── cleaning_rules.md
│   ├── star_schema_explanation.md
│   └── business_questions.md
│
├── images/
│   └── star_schema_diagram.png
│
└── README.md
```

---

## Data Pipeline

```text
Raw CSV
   ↓
cds_raw
   ↓
cds_cleaning_process
   ↓
data_quality_issues
   ↓
cds_cleaned
   ↓
Dimension Tables
   ↓
fact_sales
   ↓
Business Analysis
```

---

## 1. Raw Data Import

The raw CSV is imported into the `cds_raw` table.

All columns are initially loaded as `VARCHAR` to preserve the original data exactly as received.

A `raw_row_id` column is added to uniquely identify each imported row and maintain traceability throughout the cleaning process.

---

## 2. Data Cleaning and Data Quality Tracking

The cleaning process is performed in `cds_cleaning_process`.

Instead of overwriting raw values, the project creates separate `_cleaned` columns.

Examples:

| Original Column     | Cleaned Column              |
| ------------------- | --------------------------- |
| `dealer_id`         | `dealer_id_cleaned`         |
| `employee_email`    | `employee_email_cleaned`    |
| `vehicle_price_usd` | `vehicle_price_usd_cleaned` |
| `sale_status`       | `sale_status_cleaned`       |

The cleaning process includes:

* Trimming unnecessary spaces
* Standardising dealer and employee IDs
* Resolving employee names and emails using reference tables
* Standardising employee roles
* Cleaning phone numbers
* Validating VINs
* Standardising vehicle brands and models
* Validating vehicle years and prices
* Parsing and validating dates
* Standardising US customer states
* Standardising sale statuses
* Logging problematic values in `data_quality_issues`

Values that cannot be corrected with high confidence are set to `NULL` and flagged for review.

---

## 3. Cleaned Analytical Table

After cleaning, the final `cds_cleaned` table is created.

This table contains only the final cleaned columns required for modelling and analysis.

It removes raw duplicated columns, temporary transformation fields and auxiliary validation columns.

---

## 4. Dimensional Modelling

The cleaned dataset is transformed into a star schema.

The model contains one central fact table and several dimensions:

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/star_schema.PNG"  height="400"></p>

### Dimension Tables

| Table                | Purpose                                        |
| -------------------- | ---------------------------------------------- |
| `dim_dealer`         | Stores dealership identifiers                  |
| `dim_employee`       | Stores employee attributes                     |
| `dim_vehicle`        | Stores vehicle information                     |
| `dim_customer_state` | Stores US customer state information           |
| `dim_sale_status`    | Stores standardised sale statuses              |
| `dim_calendar`       | Stores date attributes for time-based analysis |

### Fact Table

| Table        | Purpose                                         |
| ------------ | ----------------------------------------------- |
| `fact_sales` | Stores sales records, foreign keys and measures |

The grain of `fact_sales` is:

> One row represents one cleaned vehicle sales-related record.

The main measures are:

| Measure           | Description                           |
| ----------------- | ------------------------------------- |
| `sale_amount_usd` | Vehicle sale amount                   |
| `sale_count`      | Default value of `1` per sales record |

---

## 5. Validation

Several validation checks are performed after modelling:

* Row count comparison between `cds_cleaned` and `fact_sales`
* Unknown dimension member checks
* Missing date checks
* Orphan foreign key checks
* Sales amount reconciliation between cleaned and fact tables

These checks help confirm that the dimensional model preserves the cleaned data correctly.

---

## 6. Business Analysis

The final analysis answers key dealership performance questions using the star schema.

Main analysis areas include:

| Area                   | Focus                                               |
| ---------------------- | --------------------------------------------------- |
| Sales trend            | Revenue, volume and average sale price over time    |
| Product performance    | Best-performing brands and models                   |
| Geography              | Sales performance by US state                       |
| Dealership performance | Revenue, completed sales and completion rate        |
| Employee performance   | Salesperson revenue, volume and dealer contribution |
| Sale status            | Completed, cancelled, pending and returned sales    |
| Seasonality            | Monthly sales patterns                              |
| Vehicle age            | Older vs newer vehicle performance                  |
| Red flags              | Low-performing segments and potential outliers      |

---

## Key Insights

Some of the main findings from the analysis include:

* The business showed a positive sales trend over the analysed years.
* Chevrolet Tahoe was one of the strongest models by completed revenue.
* Chevrolet, Ford and Tesla were among the main revenue-generating brands.
* Honda and Ford showed strong sales volume performance.
* Tesla and Chevrolet stood out in terms of higher average sale price.
* Dealership 15 was the strongest overall performer by completed revenue and sales volume.
* Dealership 6 achieved the strongest completed sales rate.
* Mary Campbell was the strongest salesperson by completed revenue and sales volume.
* Spring and fall appeared to be stronger sales periods than winter.
* Newer vehicles generated more revenue, while older vehicles contributed strongly to sales volume.

These insights should be interpreted together with business context such as inventory availability, dealership size, local demand, vehicle mix and data quality limitations.

---

## Data Quality Considerations

This project intentionally avoids applying low-confidence corrections.

Examples of conservative data quality decisions include:

* Ambiguous dates are not guessed automatically.
* Invalid VINs are set to `NULL`.
* Unmatched customer states are set to `NULL`.
* Unknown dimension members are used to preserve fact table records.
* Duplicate VINs or phone numbers are reviewed instead of being automatically deleted.

This approach prioritises analytical reliability and traceability.

---

## Documentation

Additional documentation is available in the `documentation/` folder:

| File                         | Description                                               |
| ---------------------------- | --------------------------------------------------------- |
| `data_dictionary.md`         | Explains dataset columns, data types and business meaning |
| `cleaning_rules.md`          | Documents cleaning and standardisation rules              |
| `star_schema_explanation.md` | Explains the dimensional model and design decisions       |
| `business_questions.md`      | Describes the business questions, metrics and insights    |

---

## How to Run the Project

1. Create the MySQL database.
2. Import the raw CSV into `cds_raw`.
3. Run the cleaning and data quality tracking script.
4. Create the cleaned table.
5. Create the dimension tables.
6. Create and populate the fact table.
7. Run the validation checks.
8. Run the business analysis queries.

Recommended execution order:

```text
01_database_setup.sql
02_data_import.sql
03_data_profiling.sql
04_data_cleaning_data_quality_tracking.sql
05_dimensional_modelling.sql
06_fact_table_creation.sql
07_business_analysis_conclusions.sql
```

---

## Project Outcome

The final result is a complete SQL portfolio project that demonstrates how raw dealership sales data can be transformed into a clean, modelled and analysis-ready dataset.

The project shows practical skills in:

* SQL cleaning
* Data quality tracking
* Reference table design
* Dimensional modelling
* Fact table creation
* Analytical SQL
* Business-oriented data analysis
