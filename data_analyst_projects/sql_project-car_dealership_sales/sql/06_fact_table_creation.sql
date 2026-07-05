/*
==================================================================================================================
************************************************ FACT_SALES ******************************************************
==================================================================================================================

This fact table stores vehicle sale transactions.

Fact table grain:
    One row in 'fact_sales' represents one vehicle sale transaction from 'cds_cleaned' table.

The fact table contains:
    - Surrogate foreign keys to dimensions.
    - Numeric measures used for analysis.

Measures:
    - sale_amount_usd:
        - Sales amount taken from 'cds_cleaned.vehicle_price_usd'.
        - It is stored in the fact table because price is analysed as a transactional measure.

    - sale_count:
        - Default value of 1 for each row.
        - This makes it easier to calculate number of sales using SUM(sale_count).

Handling missing dimension matches:
    During the INSERT process, COALESCE(dimension_key, 0) assigns unmatched records to the corresponding 'Unknown' member in each dimension.
*/

	CREATE TABLE fact_sales (
		sale_key INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		dealer_key INT NOT NULL,
		employee_key INT NOT NULL,
		vehicle_key INT NOT NULL,
		date_key INT NULL,
		customer_state_key INT NOT NULL,
		sale_status_key INT NOT NULL,
		sale_amount_usd DECIMAL(10,2) NULL,
		sale_count INT NOT NULL DEFAULT 1,

		KEY idx_fact_sales_dealer_key (dealer_key),
		KEY idx_fact_sales_employee_key (employee_key),
		KEY idx_fact_sales_vehicle_key (vehicle_key),
		KEY idx_fact_sales_date_key (date_key),
		KEY idx_fact_sales_customer_state_key (customer_state_key),
		KEY idx_fact_sales_sale_status_key (sale_status_key),

		CONSTRAINT fk_fact_sales_dealer
			FOREIGN KEY (dealer_key)
			REFERENCES dim_dealer (dealer_key),

		CONSTRAINT fk_fact_sales_employee
			FOREIGN KEY (employee_key)
			REFERENCES dim_employee (employee_key),

		CONSTRAINT fk_fact_sales_vehicle
			FOREIGN KEY (vehicle_key)
			REFERENCES dim_vehicle (vehicle_key),

		CONSTRAINT fk_fact_sales_date
			FOREIGN KEY (date_key)
			REFERENCES dim_calendar (date_key),

		CONSTRAINT fk_fact_sales_customer_state
			FOREIGN KEY (customer_state_key)
			REFERENCES dim_customer_state (customer_state_key),

		CONSTRAINT fk_fact_sales_sale_status
			FOREIGN KEY (sale_status_key)
			REFERENCES dim_sale_status (sale_status_key)
	) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
    
    -- Load the fact table from 'cds_cleaned' by replacing business keys with surrogate dimension keys.
    -- If a dimension value cannot be matched, it is assigned to the corresponding 'Unknown' member with key = 0.
		INSERT INTO fact_sales (
		dealer_key,
		employee_key,
		vehicle_key,
		date_key,
		customer_state_key,
		sale_status_key,
		sale_amount_usd,
		sale_count
	)
	SELECT
		COALESCE(dd.dealer_key, 0) AS dealer_key,
		COALESCE(de.employee_key, 0) AS employee_key,
		COALESCE(dv.vehicle_key, 0) AS vehicle_key,
		dc.date_key AS date_key,
		COALESCE(dcs.customer_state_key, 0) AS customer_state_key,
		COALESCE(dss.sale_status_key, 0) AS sale_status_key,
		c.vehicle_price_usd AS sale_amount_usd,
		1 AS sale_count
	FROM
		cds_cleaned c
	LEFT JOIN
		dim_dealer dd
			ON c.dealer_id = dd.dealer_id
	LEFT JOIN
		dim_employee de
			ON c.employee_id = de.employee_id
	LEFT JOIN
		dim_vehicle dv
			ON c.vin = dv.vin
	LEFT JOIN
		dim_calendar dc
			ON c.sale_date = dc.full_date
	LEFT JOIN
		dim_customer_state dcs
			ON c.customer_state = dcs.state_code
	LEFT JOIN
		dim_sale_status dss
			ON c.sale_status = dss.sale_status;

/*
==================================================================================================================
************************************************* VALIDATIONS ****************************************************
==================================================================================================================

Final validation checks after creating the star schema.

The goal of this section is to confirm that:
    1) The fact table preserves the same number of rows as the cleaned source table.
    2) All unmatched or missing dimension values have been correctly assigned to Unknown members.
    3) Missing sale dates are clearly identified.
    4) Known data quality limitations, such as missing VIN values, remain traceable after modelling.

These checks are important because dimensional modelling should not hide data quality issues.
Instead, it should preserve the transactions and make unresolved issues visible for analysis.
*/

	-- 1) Compare the number of rows between the cleaned source table and the fact table:
		-- Expected result: both counts should match
        -- If they do not match, some transactions may have been duplicated or lost during the fact loading process
			SELECT
				(SELECT COUNT(*) FROM cds_cleaned) AS cleaned_rows,
				(SELECT COUNT(*) FROM fact_sales) AS fact_rows;
			
            -- Current result after loading the available dataset:
				-- cleaned_rows = 999
                -- fact_rows = 999
	
    -- 2) Check how many fact rows were assigned to 'Unknown' dimension members.
		-- These rows usually come from NULL values, invalid values, or unmatched business keys in the cleaned source table
        -- A high number of 'Unknown' rows should be reveiwed as part of the data quality analysis
			SELECT
				SUM(CASE WHEN dealer_key = 0 THEN 1 ELSE 0 END) AS unknown_dealer_rows,
				SUM(CASE WHEN employee_key = 0 THEN 1 ELSE 0 END) AS unknown_employee_rows,
				SUM(CASE WHEN vehicle_key = 0 THEN 1 ELSE 0 END) AS unknown_vehicle_rows,
				SUM(CASE WHEN customer_state_key = 0 THEN 1 ELSE 0 END) AS unknown_state_rows,
				SUM(CASE WHEN sale_status_key = 0 THEN 1 ELSE 0 END) AS unknown_status_rows
			FROM
				fact_sales;
			
            -- Current result after loading the available dataset:
				-- unknown_vehicle_rows = 43
                -- unknown_state_rows = 27
                -- Other columns = 0
	
    -- 3) Check fact rows without a valid sale date:
		-- 'date_key' is allowed to be NULL because no artificial 'Unknown' date row was created in 'dim_calendar' table
        -- These records should be reviewed separately because they cannot be used in time-based analysis
			SELECT
				COUNT(*) AS rows_without_date_key
			FROM
				fact_sales
			WHERE
				date_key IS NULL;
		
        -- Current result after loading the available dataset:
				-- rows_without_date_key = 50
	
    -- 4) Check sales assigned to the 'Unknown' vehicle member:
		-- In this model, 'vehicle_key' = 0 mainly represents sales where VIN was NULL or could not be matched
			SELECT
				COUNT(*) AS sales_with_unknown_vehicle
			FROM
				fact_sales
			WHERE
				vehicle_key = 0;
			
			-- Current result after loading the available dataset:
					-- sales_with_unknown_vehicle = 43
		
        -- Review the source rows that caused the 'Unknown' vehicle assigment:
			-- These records have NULL VIN and therefore cannot be linked to a specific vehicle in 'dim_vehicle' table
				SELECT *
				FROM cds_cleaned
				WHERE vin IS NULL;
		
	-- 5) Confirm that there are no orphan foreign keys in the fact table:
		-- Foreign key constraints should already prevent this, but this query documents the integrity check
			SELECT
				COUNT(*) AS orphan_vehicle_keys
			FROM
				fact_sales fs
			LEFT JOIN
				dim_vehicle dv
					ON fs.vehicle_key = dv.vehicle_key
			WHERE
				dv.vehicle_key IS NULL;
			
            -- Current result after loading the available dataset:
					-- orphan_vehicle_keys = 0
	
    -- 6) Compare the total sales amount between the cleaned source table and the fact table:
		-- Expected result: both totals should match
        -- If they do not match, the measure may have been transformed incorrectly during the loading process
			SELECT
				(SELECT SUM(vehicle_price_usd) FROM cds_cleaned) AS cleaned_total_sales_amount,
				(SELECT SUM(sale_amount_usd) FROM fact_sales) AS fact_total_sales_amount,
                (SELECT SUM(sale_amount_usd) FROM fact_sales) - (SELECT SUM(vehicle_price_usd) FROM cds_cleaned) as difference_between_fact_cleaned_tables;