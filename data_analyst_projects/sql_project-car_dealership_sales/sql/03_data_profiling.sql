USE car_dealership_sales;

-- 1) Total number of rows in the raw dataset:
	SELECT
		COUNT(*) AS total_rows
	FROM
		cds_raw;
	
    -- Results: 1000 rows

-- 2) Total number of columns in the raw dataset:
	SELECT
		COUNT(*) AS total_columns
	FROM
		information_schema.columns
	WHERE
		table_schema = DATABASE() AND
        table_name = 'cds_raw';
	
    -- Results: 16 columns
    
-- 3) Column names, data types and nullability
	SELECT
		ordinal_position,
		column_name,
		data_type,
		column_type,
		is_nullable
	FROM
		information_schema.columns
	WHERE
		table_schema = DATABASE()
		AND table_name = 'cds_raw'
	ORDER BY
		ordinal_position;
	
    -- Results:
		-- 'raw_row_id' has the same data and column type (INTEGER) and cannot contain NULL values
        -- The rest of the columns are VARCHAR type and can contain NULL values
	
-- 4) NULL count by column:
	SELECT
		SUM(CASE WHEN dealer_id IS NULL THEN 1 ELSE 0 END) AS dealer_id_nulls,
		SUM(CASE WHEN employee_id IS NULL THEN 1 ELSE 0 END) AS employee_id_nulls,
		SUM(CASE WHEN employee_name IS NULL THEN 1 ELSE 0 END) AS employee_name_nulls,
		SUM(CASE WHEN employee_role IS NULL THEN 1 ELSE 0 END) AS employee_role_nulls,
		SUM(CASE WHEN hire_date IS NULL THEN 1 ELSE 0 END) AS hire_date_nulls,
		SUM(CASE WHEN employee_email IS NULL THEN 1 ELSE 0 END) AS employee_email_nulls,
		SUM(CASE WHEN employee_phone IS NULL THEN 1 ELSE 0 END) AS employee_phone_nulls,
		SUM(CASE WHEN vin IS NULL THEN 1 ELSE 0 END) AS vin_nulls,
		SUM(CASE WHEN vehicle_brand IS NULL THEN 1 ELSE 0 END) AS vehicle_brand_nulls,
		SUM(CASE WHEN vehicle_model IS NULL THEN 1 ELSE 0 END) AS vehicle_model_nulls,
		SUM(CASE WHEN vehicle_year IS NULL THEN 1 ELSE 0 END) AS vehicle_year_nulls,
		SUM(CASE WHEN vehicle_price_usd IS NULL THEN 1 ELSE 0 END) AS vehicle_price_usd_nulls,
		SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) AS sale_date_nulls,
		SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS customer_state_nulls,
		SUM(CASE WHEN sale_status IS NULL THEN 1 ELSE 0 END) AS sale_status_nulls
	FROM
		cds_raw;
	
    -- Result:
		-- No NULL values identified in any column
	
-- 5) Empty string or blank value count by selected text columns:
	SELECT
		SUM(CASE WHEN TRIM(dealer_id) = '' THEN 1 ELSE 0 END) AS dealer_id_blanks,
		SUM(CASE WHEN TRIM(employee_id) = '' THEN 1 ELSE 0 END) AS employee_id_blanks,
		SUM(CASE WHEN TRIM(employee_name) = '' THEN 1 ELSE 0 END) AS employee_name_blanks,
		SUM(CASE WHEN TRIM(employee_role) = '' THEN 1 ELSE 0 END) AS employee_role_blanks,
		SUM(CASE WHEN TRIM(employee_email) = '' THEN 1 ELSE 0 END) AS employee_email_blanks,
		SUM(CASE WHEN TRIM(employee_phone) = '' THEN 1 ELSE 0 END) AS employee_phone_blanks,
		SUM(CASE WHEN TRIM(vin) = '' THEN 1 ELSE 0 END) AS vin_blanks,
		SUM(CASE WHEN TRIM(vehicle_brand) = '' THEN 1 ELSE 0 END) AS vehicle_brand_blanks,
		SUM(CASE WHEN TRIM(vehicle_model) = '' THEN 1 ELSE 0 END) AS vehicle_model_blanks,
		SUM(CASE WHEN TRIM(customer_state) = '' THEN 1 ELSE 0 END) AS customer_state_blanks,
		SUM(CASE WHEN TRIM(sale_status) = '' THEN 1 ELSE 0 END) AS sale_status_blanks
	FROM
		cds_raw;
	
    -- Results:
		-- 14 blank values identified in 'employee_phone' column
        -- No blank values found in the rest of the columns

-- 6) Minimum and maximum sale date:
	SELECT
		MIN(sale_date) AS min_sale_date,
        MAX(sale_date) AS max_sale_date
	FROM
		cds_raw;
        
	-- Results:
		-- first sale achieved: 'blank'
        -- last sale achieved: 31/10/2024

-- 7) Count possible fully duplicated rows:
	SELECT
		COUNT(*) - COUNT(DISTINCT CONCAT_WS('|',
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
		)) AS duplicated_rows
	FROM
		cds_raw;
	
    -- Results: 0 duplicated rows identified at this moment of the project