LOAD DATA LOCAL INFILE 'D:/ESTUDI/SQL/sql_project-car_dealership_sales/data/raw/raw_car_dealership_sales_22_25.csv'
INTO TABLE cds_raw
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(
	dealer_id,
    employee_id,
    employee_name,
    employee_role,
    hire_date,
    employee_email,
    employee_phone,
    vin,
    vehicle_brand,
    vehicle_model,
    vehicle_year,
    vehicle_price_usd,
    sale_date,
    customer_state,
    sale_status
);