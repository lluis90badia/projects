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