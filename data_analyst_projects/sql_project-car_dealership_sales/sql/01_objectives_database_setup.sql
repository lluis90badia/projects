/*
PROJECT OBJECTIVE:
    This project demonstrates a professional SQL-based data cleaning workflow in MySQL using a fictional US car dealership sales dataset.

The main objective is to transform a raw CSV import into a reliable, analysis-ready staging table while preserving full traceability from every cleaned value back to the original raw record.

The business goal is to prepare trustworthy data for dealership sales analysis, including:
    - Sales performance by dealer, employee, vehicle brand/model, state, and sales status;
    - Detection and documentation of data quality issues that may distort KPIs;
    - Standardization of operational fields such as employee IDs, employee names, roles, emails, phones, VINs, vehicle attributes, prices, dates, customer states, and sale statuses;
    - Creation of reusable reference/mapping tables for categorical fields;
    - Preparation of a clean dataset that can later be converted into a dimensional/star schema for reporting and dashboarding.

The main conclusions and data-quality principles applied are:
    - Raw data must be preserved unchanged. Cleaning is performed in a separate staging/cleaning table.
    - Every row represents a vehicle sales transaction, so duplicate checks must respect the transaction-level grain.
    - Cleaned columns are kept separate from original columns to support auditing and explainability.
    - Invalid or low-confidence values should not be overwritten silently; they should be set to NULL when appropriate and logged in 'data_quality_issues' table.
    - Reference and mapping tables are more scalable than long CASE statements for low-cardinality categorical fields such as employee_role, vehicle_brand, customer_state, and sale_status.
    - Date fields require special care because strings such as 05-06-2021 can be ambiguous across DD-MM-YYYY and MM-DD-YYYY formats. Ambiguous dates are flagged for manual review instead of being guessed automatically.
    - Data types and constraints should be applied after cleaning, not before, because raw CSV data often contains inconsistent formats.
    - Business validation is as important as technical validation: prices, dates, states, statuses, and IDs can all affect business KPIs if cleaned incorrectly.
    - The final cleaned dataset can be used as the foundation for a later dimensional model with fact and dimension tables.
*/

SET GLOBAL local_infile = ON;
SET SQL_SAFE_UPDATES = 0;

DROP DATABASE IF EXISTS car_dealership_sales;
CREATE DATABASE car_dealership_sales;
USE car_dealership_sales;

/*
First of all, we will import the dataset (CSV) into a 'raw' table to preserve the original data without modifications. That is why, all the columns will have VARCHAR type. In addition, a new column called 'raw_row_id' will be added to uniquely identify each imported raw record, preserve traceability back to the original CSV row, and support auditing, or cleaning errors without relying on potentially duplicate columns.
*/

CREATE TABLE cds_raw (								-- cds = CAR DEALERSHIP SALES
	raw_row_id INT AUTO_INCREMENT PRIMARY KEY,		
    dealer_id VARCHAR(100),
    employee_id VARCHAR(100),
    employee_name VARCHAR(100),
    employee_role VARCHAR(100),
    hire_date VARCHAR(100),
    employee_email VARCHAR(100),
    employee_phone VARCHAR(100),
    vin VARCHAR(100),
    vehicle_brand VARCHAR(100),
    vehicle_model VARCHAR(100),
    vehicle_year VARCHAR(100),
    vehicle_price_usd VARCHAR(100),
    sale_date VARCHAR(100),
    customer_state VARCHAR(100),
    sale_status VARCHAR(100)
) ENGINE = innodb DEFAULT CHARSET = utf8mb4;