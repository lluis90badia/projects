/*
==================================================================================================================
******************************************** FINAL VALIDATIONS ***************************************************
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