USE car_dealership_sales;

-- Number and percentage of problems detected out of the total from 'data_quality_issues' table:
	SELECT
		name_column,
		COUNT(*) AS number_problems_detected,
		CONCAT(ROUND(COUNT(*) / (SELECT COUNT(*) FROM data_quality_issues) * 100, 2), ' %') AS '%_from_total_problems_detected'
	FROM
		data_quality_issues
	GROUP BY 1
	ORDER BY 2 DESC;

/*
==================================================================================================================
*************************************** CREATING THE CLEANED TABLE ***********************************************
==================================================================================================================

After completing the cleaning, standardization and validation work in 'cds_cleaning_process', a final cleaned table is created with only the columns required for analytical modelling.

This table excludes:
    - Original/raw duplicated columns.
    - Temporary cleaning columns.
    - Auxiliary validation columns.
    - Intermediate transformation fields.

Data pipeline layers used in this project:
    1) 'cds_raw'
        Stores the original imported data without transformations.

    2) 'cds_cleaning_process'
        Stores both original and cleaned values during the cleaning phase.
        This layer is useful for comparison, auditing and data quality checks.

    3) 'cds_cleaned'
        Stores the final cleaned dataset.
        This table is used as the source table for dimensional modelling.
*/
	
    DROP TABLE IF EXISTS cds_cleaned;
	CREATE TABLE cds_cleaned AS
		SELECT
			dealer_id_cleaned AS dealer_id,
			employee_id_cleaned AS employee_id,
            employee_name_cleaned AS employee_name,
            employee_role_cleaned AS employee_role,
            hire_date_cleaned AS hire_date,
            employee_email_cleaned AS employee_email,
            employee_phone_cleaned AS employee_phone,
            vin_cleaned AS vin,
            vehicle_brand_cleaned AS vehicle_brand,
            vehicle_model_cleaned AS vehicle_model,
            vehicle_year_cleaned AS vehicle_year,
            vehicle_price_usd_cleaned AS vehicle_price_usd,
            sale_date_cleaned AS sale_date,
            customer_state_cleaned AS customer_state,
            sale_status_cleaned AS sale_status
		FROM cds_cleaning_process;
        
/*
Before creating the dimensional model, final sanity checks are performed on 'cds_cleaned'.

The goal of this step is to confirm that the cleaned table is stable enough to be used as the source for dimensions and the fact table.

These checks do not replace the previous data quality process.
They are final profiling checks before modelling.
*/

	-- 1) Check the total number of rows in the cleaned table (expected result: 1000 rows):
		SELECT COUNT(*) AS total_rows
		FROM cds_cleaned;		-- There are 1000 rows
        
        -- 1.1) Check whether there are fully duplicated rows in 'cds_cleaned' table (if 'duplicated_rows' = 0, no exact duplicate records were found):
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
				cds_cleaned;			-- 1 fully duplicated row detected
		
        -- 1.2) Identify the fully duplicated rows:
			SELECT
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
				sale_status,
				COUNT(*) AS duplicate_count
			FROM
				cds_cleaned
			GROUP BY
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
			HAVING
				COUNT(*) > 1;
	
		/*
			1.3) Delete fully duplicated rows using a temporary column
				- Because 'cds_cleaned' table does not currently have a unique row identifier, a temporary technical column is added to safely identify and delete only one row from each duplicated group.
                - After this process:
					- One row from each duplicated group is preserved
					- Extra duplicated rows are removed
        */
			
            -- 1.3.1) Add a temporary technical identifier to each row:
				ALTER TABLE cds_cleaned
				ADD COLUMN temp_row_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
			
            -- 1.3.2) Identify which row it would be dropped before deleted:
				WITH duplicated_rows AS (
					SELECT
						temp_row_id,
						ROW_NUMBER() OVER (
							PARTITION BY
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
							ORDER BY
								temp_row_id
						) AS row_number_within_duplicate_group
					FROM
						cds_cleaned
				)
				SELECT
					c.*
				FROM
					cds_cleaned c
				JOIN
					duplicated_rows d
						ON c.temp_row_id = d.temp_row_id
				WHERE
					d.row_number_within_duplicate_group > 1;		-- 1 row identified
			
            -- 1.3.3) Delete only the duplicated row:
				WITH duplicated_rows AS (
					SELECT
						temp_row_id,
						ROW_NUMBER() OVER (
							PARTITION BY
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
							ORDER BY
								temp_row_id
						) AS row_number_within_duplicate_group
					FROM
						cds_cleaned
				)
				DELETE c
				FROM
					cds_cleaned c
				JOIN
					duplicated_rows d
						ON c.temp_row_id = d.temp_row_id
				WHERE
					d.row_number_within_duplicate_group > 1;		-- 1 row affected
			
            -- 1.3.4) Validate there are no fully duplicated rows:
				SELECT
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
					sale_status,
					COUNT(*) AS duplicate_count
				FROM
					cds_cleaned
				GROUP BY
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
				HAVING
					COUNT(*) > 1;					-- 0 rows returned (no fully duplicated rows identified)
			
            -- 1.3.5) Check again the total number of rows in the cleaned table (expected result: 999 rows):
				SELECT COUNT(*) AS total_rows_after_duplicate_rows_deleted
				FROM cds_cleaned;					-- There are 999 rows
			
            -- 1.3.6) Remove the temporary technical column because it is no longer needed:
				ALTER TABLE cds_cleaned
                DROP COLUMN temp_row_id;
    
    -- 2) Check the number of sales per 'dealer_id':
		SELECT
			dealer_id,
            COUNT(*) AS rows_per_dealer_id
		FROM cds_cleaned
        GROUP BY 1
        ORDER BY 1;
	
    -- Check the number of sales per 'employee_name':
		SELECT
			employee_name,
			COUNT(*) AS rows_per_employee
		FROM cds_cleaned
        GROUP BY 1
        ORDER BY 2 DESC;
	
    -- Check the number of sales per 'vehicle_brand':
		SELECT
			vehicle_brand,
			COUNT(*) AS rows_per_brand
		FROM cds_cleaned
        GROUP BY 1
        ORDER BY 2 DESC;
	
    -- Return the MIN and MAX hire_date to check if the hire dates are realistic:
		SELECT
			MIN(hire_date) AS 'oldest_employee',
            MAX(hire_date) AS 'newest employee'
		FROM cds_cleaned;
	
    -- Return the MIN and MAX sale_date to check if those dates are among the period 2022-2025:
		SELECT
			MIN(sale_date) AS 'first_sale_made',
            MAX(sale_date) AS 'latest_sale_made'
		FROM cds_cleaned;
	
    -- Check the number of sales per 'customer_state':
		SELECT
			customer_state,
			COUNT(*) AS rows_per_customer_state
		FROM cds_cleaned
        GROUP BY 1
        ORDER BY 2 DESC;
	
    -- Check the number of sales per 'sale_status':
		SELECT
			sale_status,
			COUNT(*) AS rows_per_sale_status
		FROM cds_cleaned
        GROUP BY 1
        ORDER BY 2 DESC;
	
/*
==================================================================================================================
******************************* CREATE STAR SCHEMA FROM 'cds_cleaned' table **************************************
==================================================================================================================

This section creates a dimensional model from the cleaned sales dataset.

Modelling approach:
    - Dimensions store descriptive business attributes.
    - The fact table stores sales transactions and measurable values.
    - Surrogate keys are used to connect the fact table with dimensions.
    - Natural/business keys are preserved inside dimensions for traceability.

Fact table grain:
    One row in 'fact_sales' represents one vehicle sale transaction from 'cds_cleaned'.

Important distinction:
    - Reference tables such as 'ref_*' were used during the cleaning and standardization phase.
    - Dimension tables such as 'dim_*' are created for analytical modelling and reporting.
*/

	DROP TABLE IF EXISTS fact_sales;

	DROP TABLE IF EXISTS dim_employee;
	DROP TABLE IF EXISTS dim_vehicle;
	DROP TABLE IF EXISTS dim_dealer;
	DROP TABLE IF EXISTS dim_customer_state;
	DROP TABLE IF EXISTS dim_sale_status;
	DROP TABLE IF EXISTS dim_calendar;

/*
==================================================================================================================
************************************************ DIM_EMPLOYEE ****************************************************
==================================================================================================================

This dimension stores descriptive information about employees involved in vehicle sales.

Key fields:
    - employee_key:
        Surrogate key generated for the dimensional model.
        This is the key used by 'fact_sales'.

    - employee_id:
        Natural/business key from the cleaned dataset.
        It is kept for traceability with the original business entity.

Unknown member:
    - A default row with 'employee_key' = 0 is inserted.
    - This prevents fact table loading failures when an employee cannot be matched, while still preserving the sales transaction for analysis.

Source:
    - Employee data comes from 'cds_cleaned' and is enriched with 'first_name' and 'last_name' from 'ref_employee' table when available.
*/
	
	CREATE TABLE dim_employee (
		employee_key INT NOT NULL PRIMARY KEY,
		employee_id INT NULL,
		employee_name VARCHAR(100) NULL,
		first_name VARCHAR(50) NULL,
		last_name VARCHAR(50) NULL,
		employee_email VARCHAR(100) NULL,
		employee_role VARCHAR(50) NULL,
		hire_date DATE NULL,
		employee_phone VARCHAR(30) NULL,

		UNIQUE KEY uq_dim_employee_id (employee_id)
	) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

	-- Unknown member:
		INSERT INTO dim_employee (
			employee_key,
			employee_id,
			employee_name,
			first_name,
			last_name,
			employee_email,
			employee_role,
			hire_date,
			employee_phone
		)
		VALUES (
			0,
			NULL,
			'Unknown',
			NULL,
			NULL,
			NULL,
			'Unknown',
			NULL,
			NULL
		);

	-- Insert one dimension row per valid 'employee_id':
		INSERT INTO dim_employee (
			employee_key,
			employee_id,
			employee_name,
			first_name,
			last_name,
			employee_email,
			employee_role,
			hire_date,
			employee_phone
		)
		SELECT
			ROW_NUMBER() OVER (ORDER BY employee_id) AS employee_key,
			employee_id,
			MAX(employee_name) AS employee_name,
			MAX(first_name) AS first_name,
			MAX(last_name) AS last_name,
			MAX(employee_email) AS employee_email,
			MAX(employee_role) AS employee_role,
			MAX(hire_date) AS hire_date,
			MAX(employee_phone) AS employee_phone
		FROM (
			SELECT
				c.employee_id,
				c.employee_name,
				r.first_name,
				r.last_name,
				c.employee_email,
				c.employee_role,
				c.hire_date,
				c.employee_phone
			FROM
				cds_cleaned c
			LEFT JOIN
				ref_employee r
					USING(employee_email)
			WHERE
				c.employee_id IS NOT NULL
		) e
		GROUP BY
			employee_id;

/*
==================================================================================================================
************************************************ DIM_VEHICLE *****************************************************
==================================================================================================================

This dimension stores descriptive information about vehicles.

Key fields:
    - vehicle_key:
        - Surrogate key generated for the dimensional model.
        - This is the key used by 'fact_sales'.

    - vin:
        - Natural/business key of the vehicle.
        - VIN is used to identify unique vehicles when available.

Handling missing VIN values:
    - Rows with NULL VIN are not inserted as individual vehicles because they cannot be reliably identified.
    - Instead, these sales will be assigned to the default Unknown vehicle member with 'vehicle_key' = 0 when loading the fact table.

Source:
    - Vehicle attributes are loaded from 'cds_cleaned'.
*/

	CREATE TABLE dim_vehicle (
		vehicle_key INT NOT NULL PRIMARY KEY,
		vin VARCHAR(50) NULL,
		vehicle_brand VARCHAR(50) NULL,
		vehicle_model VARCHAR(50) NULL,
		vehicle_year INT NULL,

		UNIQUE KEY uq_dim_vehicle_vin (vin)
	) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

	-- Unknown member:
		INSERT INTO dim_vehicle (
			vehicle_key,
			vin,
			vehicle_brand,
			vehicle_model,
			vehicle_year
		)
		VALUES (
			0,
			NULL,
			'Unknown',
			'Unknown',
			NULL
		);

	-- Insert one dimension row per valid VIN
    -- Vehicles without VIN are intentionally excluded and mapped to vehicle_key = 0 in 'fact_sales' table:
		INSERT INTO dim_vehicle (
			vehicle_key,
			vin,
			vehicle_brand,
			vehicle_model,
			vehicle_year
		)
		SELECT
			ROW_NUMBER() OVER (ORDER BY vin) AS vehicle_key,
			vin,
			MAX(vehicle_brand) AS vehicle_brand,
			MAX(vehicle_model) AS vehicle_model,
			MAX(vehicle_year) AS vehicle_year
		FROM
			cds_cleaned
		WHERE
			vin IS NOT NULL
		GROUP BY
			vin;
    
/*
==================================================================================================================
************************************************* DIM_DEALER *****************************************************
==================================================================================================================

This dimension stores dealer information.

At this stage, only 'dealer_id' is available in the cleaned dataset.
Even with limited attributes, creating a dealer dimension keeps the model consistent and allows future enrichment with dealer name, city, state, region or other attributes.

Key fields:
    - dealer_key:
        Surrogate key used by 'fact_sales' table.

    - dealer_id:
        Natural/business key from the cleaned dataset.

Unknown member:
    'dealer_key' = 0 is inserted to handle missing or unmatched dealer records during fact loading.
*/

	CREATE TABLE dim_dealer (
		dealer_key INT NOT NULL PRIMARY KEY,
		dealer_id INT NULL,

		UNIQUE KEY uq_dim_dealer_id (dealer_id)
	) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

	-- Unknown member:
		INSERT INTO dim_dealer (
			dealer_key,
			dealer_id
		)
		VALUES (
			0,
			NULL
		);

	-- Insert one dimension row per valid 'dealer_id':
		INSERT INTO dim_dealer (
			dealer_key,
			dealer_id
		)
		SELECT
			ROW_NUMBER() OVER (ORDER BY dealer_id) AS dealer_key,
			dealer_id
		FROM (
			SELECT DISTINCT
				dealer_id
			FROM
				cds_cleaned
			WHERE
				dealer_id IS NOT NULL
		) d;
    
/*
==================================================================================================================
********************************************* DIM_CUSTOMER_STATE *************************************************
==================================================================================================================

This dimension stores the complete list of US states / customer locations.

Unlike dimensions such as employee, vehicle or dealer, this dimension is loaded from the reference table 'ref_us_states' instead of only using states present in 'cds_cleaned' table.

Reason:
    - US states are a stable and controlled domain.
    - Loading the full reference list allows the model to analyse both:
        - States with sales.
        - States without sales.

Key fields:
    - customer_state_key:
        Surrogate key used by 'fact_sales' table.

    - state_code:
        Natural key, for example CA, TX, NY.

Unknown member:
    'customer_state_key' = 0 is used when a sale has a missing or invalid 'customer_state' value.
*/

	CREATE TABLE dim_customer_state (
		customer_state_key INT NOT NULL PRIMARY KEY,
		state_code CHAR(2) NULL,
		state_name VARCHAR(50) NULL,

		UNIQUE KEY uq_dim_customer_state_code (state_code)
	) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

	-- Unknown member:
		INSERT INTO dim_customer_state (
			customer_state_key,
			state_code,
			state_name
		)
		VALUES (
			0,
			NULL,
			'Unknown'
		);

	-- Insert the complete list of US states from the reference table:
		INSERT INTO dim_customer_state (
			customer_state_key,
			state_code,
			state_name
		)
		SELECT
			ROW_NUMBER() OVER (ORDER BY us_state_code) AS customer_state_key,
			us_state_code AS state_code,
			us_state_name AS state_name
		FROM
			ref_us_states;

/*
==================================================================================================================
*********************************************** DIM_SALE_STATUS **************************************************
==================================================================================================================

This dimension stores the standardized sale status values used for sales analysis.

Examples may include:
    - Completed
    - Pending
    - Cancelled
    - Refunded

Key fields:
    - sale_status_key:
        Surrogate key used by 'fact_sales'.

    - sale_status:
        Clean standardized status value from 'cds_cleaned' table.

Unknown member:
    'sale_status_key' = 0 is used when a sale has a missing or unmatched status.
*/

	CREATE TABLE dim_sale_status (
		sale_status_key INT NOT NULL PRIMARY KEY,
		sale_status VARCHAR(50) NULL,
        
		UNIQUE KEY uq_dim_sale_status (sale_status)
	) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

	-- Unknown member:
		INSERT INTO dim_sale_status (
			sale_status_key,
			sale_status
		)
		VALUES (
			0,
			'Unknown'
		);

	-- Insert oen dimension row per standardized sale status:
		INSERT INTO dim_sale_status (
			sale_status_key,
			sale_status
		)
		SELECT
			ROW_NUMBER() OVER (ORDER BY sale_status) AS sale_status_key,
			sale_status
		FROM (
			SELECT DISTINCT
				sale_status
			FROM
				cds_cleaned
			WHERE
				sale_status IS NOT NULL
		) s;

/*
==================================================================================================================
************************************************* DIM_CALENDAR ***************************************************
==================================================================================================================

This dimension stores calendar attributes for date-based analysis.

The calendar is generated dynamically using the minimum and maximum sale dates found in 'cds_cleaned'.

Key fields:
    - date_key:
        Integer key in YYYYMMDD format.
        Example: 20260629 = 29 June 2026.

    - full_date:
        Actual calendar date used to join with 'cds_cleaned.sale_date'.

This dimension enables time-based analysis by year, quarter, month, week and day.
*/

	CREATE TABLE dim_calendar (
		date_key INT NOT NULL PRIMARY KEY,
		full_date DATE NOT NULL,
		year_number INT NOT NULL,
		quarter_number INT NOT NULL,
		month_number INT NOT NULL,
		month_name VARCHAR(20) NOT NULL,
		day_of_month INT NOT NULL,
		day_name VARCHAR(20) NOT NULL,
		week_of_year INT NOT NULL,

		UNIQUE KEY uq_dim_calendar_full_date (full_date)
	) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
	
    -- Increase the recursive CTE limit to support calendar generation over multi-year periods:
		SET SESSION cte_max_recursion_depth = 10000;
	
    -- Generate one calendar row for each date between the first and latest sale date:
		INSERT INTO dim_calendar (
			date_key,
			full_date,
			year_number,
			quarter_number,
			month_number,
			month_name,
			day_of_month,
			day_name,
			week_of_year
		)
		WITH RECURSIVE calendar_dates AS (
			SELECT
				MIN(sale_date) AS full_date
			FROM
				cds_cleaned
			WHERE
				sale_date IS NOT NULL

			UNION ALL

			SELECT
				DATE_ADD(full_date, INTERVAL 1 DAY)
			FROM
				calendar_dates
			WHERE
				full_date < (
					SELECT MAX(sale_date)
					FROM cds_cleaned
					WHERE sale_date IS NOT NULL
				)
		)
		SELECT
			CAST(DATE_FORMAT(full_date, '%Y%m%d') AS UNSIGNED) AS date_key,
			full_date,
			YEAR(full_date) AS year_number,
			QUARTER(full_date) AS quarter_number,
			MONTH(full_date) AS month_number,
			MONTHNAME(full_date) AS month_name,
			DAY(full_date) AS day_of_month,
			DAYNAME(full_date) AS day_name,
			WEEK(full_date, 3) AS week_of_year
		FROM
			calendar_dates;