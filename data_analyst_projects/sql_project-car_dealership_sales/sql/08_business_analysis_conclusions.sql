/*
==================================================================================================================
******************************************** BUSINESS ANALYSIS ***************************************************
==================================================================================================================

Objective:
	- This section analyzes the cleaned and modelled car dealership sales data using the star schema.

Business focus:
	- Understand sales performance over time.
	- Identify the strongest brands, models, dealerships, states, and salespeople.
	- Separate completed sales from non-completed or uncertain sales statuses.
	- Detect commercial opportunities and analytical red flags.

Important business rule:
	- Only 'sold' and 'delivered' are considered completed sales.
	- Statuses such as 'cancelled', 'pending', 'in progress', 'in transit', 'returned', and 'unknown' are not treated as confirmed revenue.
*/

USE car_dealership_sales;

-- 1) What are the total sales volume, revenue, and average sale price by year and by month?
	SELECT
		c.year_number,
		c.month_name,
		SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS completed_sales_volume,
		SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END) AS completed_revenue,
		ROUND(
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END)
			/
			NULLIF(SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END), 0),
			2
		) AS average_sale_price
	FROM
		fact_sales f
	JOIN
		dim_calendar c USING(date_key)
	JOIN
		dim_sale_status st USING(sale_status_key)
	GROUP BY
		c.year_number,
		c.month_number,
		c.month_name
	ORDER BY
		c.year_number,
		c.month_number;
	
    -- Conclusions:
		-- In terms of completed revenue and completed sales volume, the business showed an ascending pattern during the years analysed.
		-- This suggests a positive commercial trend, either due to higher demand, better sales performance, wider dealership activity, or a stronger vehicle portfolio over time.
		-- In terms of average sale price, the peak was reached in February 2022, which may indicate the sale of higher-value vehicles during that month rather than a general increase in sales volume.
		-- Therefore, monthly revenue should always be analysed together with both sales volume and average sale price.
        
-- 2) Which brands and models generate the highest revenue, the most units sold, and the highest average sale price?
	-- 2.1) Revenue by brand and model:
		SELECT
			v.vehicle_brand,
			v.vehicle_model,
			SUM(f.sale_amount_usd) AS completed_revenue
		FROM
			fact_sales f
		JOIN
			dim_vehicle v USING(vehicle_key)
		JOIN
			dim_sale_status st USING(sale_status_key)
		WHERE
			LOWER(st.sale_status) IN ('sold', 'delivered')
			AND v.vehicle_brand <> 'Unknown'
			AND v.vehicle_model <> 'Unknown'
		GROUP BY
			v.vehicle_brand,
			v.vehicle_model
		ORDER BY
			completed_revenue DESC;
		
        -- Conclusions:
			-- In terms of vehicle model, the Chevrolet Tahoe generated the highest completed revenue, surpassing $1.1 million.
			-- In terms of vehicle brand, Chevrolet, Ford and Tesla were the main revenue-generating brands.
			-- This indicates that the dataset contains a combination of high-revenue traditional brands and higher-ticket models, especially in the SUV, pickup or electric vehicle segments.
			-- However, high revenue does not necessarily mean higher customer preference by itself; it can also be influenced by price, stock availability, dealership location and number of transactions.
            
	-- 2.2) Units sold by brand and model:
		SELECT
			v.vehicle_brand,
			v.vehicle_model,
			SUM(f.sale_count) AS completed_units_sold
		FROM
			fact_sales f
		JOIN
			dim_vehicle v USING(vehicle_key)
		JOIN
			dim_sale_status st USING(sale_status_key)
		WHERE
			LOWER(st.sale_status) IN ('sold', 'delivered')
			AND v.vehicle_brand <> 'Unknown'
			AND v.vehicle_model <> 'Unknown'
		GROUP BY
			v.vehicle_brand,
			v.vehicle_model
		ORDER BY
			completed_units_sold DESC;
		
        -- Conclusions:
			-- In terms of brand, Honda and Ford recorded the highest number of completed units sold.
			-- In terms of model, Civic LX, Fusion and Tahoe showed the strongest buying attraction from customers.
			-- This suggests that some models performed well because of higher demand and sales volume,
			-- while others may have contributed more strongly to revenue because of higher average prices.
			-- Comparing volume and revenue together helps distinguish high-demand vehicles from high-value vehicles.

	-- 2.3) Average sale price by brand and model:
		SELECT
			v.vehicle_brand,
			v.vehicle_model,
			SUM(f.sale_count) AS completed_units_sold,
			SUM(f.sale_amount_usd) AS completed_revenue,
			ROUND(SUM(f.sale_amount_usd) / NULLIF(SUM(f.sale_count), 0), 2) AS average_sale_price
		FROM
			fact_sales f
		JOIN
			dim_vehicle v USING(vehicle_key)
		JOIN
			dim_sale_status st USING(sale_status_key)
		WHERE
			LOWER(st.sale_status) IN ('sold', 'delivered')
			AND v.vehicle_brand <> 'Unknown'
			AND v.vehicle_model <> 'Unknown'
		GROUP BY
			v.vehicle_brand,
			v.vehicle_model
		ORDER BY
			average_sale_price DESC;
		
        -- Conclusions:
			-- Tesla and Chevrolet were among the brands with higher average sale prices compared with the rest of the portfolio.
			-- In terms of model, Model Y and Tahoe stood out as higher-ticket vehicles.
			-- These models may be especially relevant from a revenue perspective, even if they are not always the highest-volume models.
		
        -- Final conclusions:
			-- Chevrolet Tahoe was one of the strongest overall performers because it appeared prominently in both completed revenue and completed sales volume analysis.
			-- Ford also showed strong sales volume performance, while Tesla stood out more clearly from an average sale price perspective.
			-- The results suggest that American brands such as Chevrolet and Ford performed strongly in this dataset.

-- 3) Which US states account for the highest sales volume and revenue, and how does the ranking change when analyzing units sold versus revenue?
    WITH state_performance AS (
		SELECT
			s.state_name,
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS completed_sales_volume,
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END) AS completed_revenue
		FROM
			fact_sales f
		JOIN
			dim_customer_state s USING(customer_state_key)
		JOIN
			dim_sale_status st USING(sale_status_key)
		WHERE
			s.state_name <> 'Unknown'
		GROUP BY
			s.state_name
	),

	state_rankings AS (
		SELECT
			state_name,
			completed_sales_volume,
			completed_revenue,
			DENSE_RANK() OVER(ORDER BY completed_sales_volume DESC) AS sales_volume_rank,
			DENSE_RANK() OVER(ORDER BY completed_revenue DESC) AS revenue_rank
		FROM
			state_performance
	)

	SELECT
		state_name,
		completed_sales_volume,
		completed_revenue,
		sales_volume_rank,
		revenue_rank,
		CAST(revenue_rank AS SIGNED) - CAST(sales_volume_rank AS SIGNED) AS ranking_difference
	FROM
		state_rankings
	ORDER BY
		sales_volume_rank;
		
        -- Conclusions:
			-- No major ranking change was detected among the top 10 US states when comparing completed sales volume and completed revenue.
			-- The states with the highest completed sales and revenue were also among the most populated states in the US. This is commercially reasonable because larger populations usually imply larger potential markets.
			-- States that rank high in both sales volume and revenue can be considered key geographic markets for the business.

-- 4) Which dealerships perform best in terms of revenue, units sold, average revenue per completed sale, and completed sales rate?
	WITH dealer_performance AS (
		SELECT
			d.dealer_id,
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS completed_units_sold,
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END) AS completed_revenue,
			SUM(f.sale_count) AS total_sales_records
		FROM
			fact_sales f
		JOIN
			dim_dealer d USING(dealer_key)
		JOIN
			dim_sale_status st USING(sale_status_key)
		WHERE
			d.dealer_id IS NOT NULL
		GROUP BY
			d.dealer_id
	)

	SELECT
		dealer_id,
		completed_units_sold,
		completed_revenue,
		ROUND(completed_revenue / NULLIF(completed_units_sold, 0), 2) AS average_revenue_per_completed_sale,
		CONCAT(ROUND(completed_units_sold / NULLIF(total_sales_records, 0) * 100, 2), ' %') AS completed_sales_rate,
		DENSE_RANK() OVER(ORDER BY completed_revenue DESC) AS revenue_rank,
		DENSE_RANK() OVER(ORDER BY completed_units_sold DESC) AS sales_volume_rank,
		DENSE_RANK() OVER(ORDER BY completed_revenue / NULLIF(completed_units_sold, 0) DESC) AS avg_ticket_rank
	FROM
		dealer_performance
	ORDER BY
		completed_revenue DESC;
	
    -- Conclusions:
		-- Dealership 15 was the best-performing dealership in terms of both completed revenue and completed sales volume. This indicates strong overall commercial performance, combining value generation and transaction volume.
		-- Dealership 6 achieved the highest completed sales rate, with approximately 85% of its sales records ending as sold or delivered. This suggests strong conversion efficiency, even if it was not necessarily the largest dealership by revenue or volume.
		-- Dealership 14 achieved the highest average revenue per completed sale, which may indicate a stronger focus on higher-value vehicles.
		-- The mean completed sales rate was around 75%, which provides a useful benchmark to compare dealership conversion performance.
		-- Dealerships above this benchmark may have stronger sales execution, while dealerships below it may require further investigation.

-- 5) Which employees generate the highest revenue and sales volume, and how do they compare within their own dealership?
	WITH employee_performance AS (
		SELECT
			e.employee_name,
			d.dealer_id,
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END) AS employee_completed_revenue,
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS employee_completed_sales_volume
		FROM
			fact_sales f
		JOIN
			dim_employee e USING(employee_key)
		JOIN
			dim_dealer d USING(dealer_key)
		JOIN
			dim_sale_status st USING(sale_status_key)
		GROUP BY
			e.employee_name,
			d.dealer_id
	)

	SELECT
		employee_name,
		dealer_id,
		employee_completed_revenue,
		employee_completed_sales_volume,
		CONCAT(
			ROUND(
				employee_completed_revenue / 
                NULLIF(SUM(employee_completed_revenue) OVER(PARTITION BY dealer_id), 0) * 100,
				2
			),
			' %'
		) AS dealer_revenue_share,
		CONCAT(
			ROUND(
				employee_completed_sales_volume
				/ NULLIF(SUM(employee_completed_sales_volume) OVER(PARTITION BY dealer_id), 0) * 100,
				2
			),
			' %'
		) AS dealer_sales_volume_share,
		DENSE_RANK() OVER(
			PARTITION BY dealer_id
			ORDER BY employee_completed_revenue DESC
		) AS employee_revenue_rank_within_dealer
	FROM
		employee_performance
	ORDER BY
		employee_completed_revenue DESC,
		employee_completed_sales_volume DESC;
	
    -- Conclusions:
		-- Mary Campbell from dealership 15 was the top-performing employee in absolute terms, generating approximately $1.2 million in completed revenue and 53 completed sales. This is consistent with dealership 15 being the strongest dealership overall.
		-- Karen Young from dealership 9 achieved the highest dealer revenue share, accounting for approximately 73% of that dealership's revenue, while Thomas Allen accounted for around 27%. This shows that dealership 9 had the largest internal revenue concentration among employees.
		-- In terms of completed sales volume share, dealership 11 showed the largest internal difference: Betty Green accounted for 71% of the dealership's completed sales volume, while Jason Scott accounted for 29%. These differences may indicate top-performer impact, uneven lead distribution, different experience levels, or potential dependency risk on specific employees.
        
        
-- 6) What is the rate of completed, cancelled, or pending sales by dealership, state, brand, and salesperson?
	SELECT
		d.dealer_id,
		cs.state_name,
		v.vehicle_brand,
		e.employee_name,
		SUM(f.sale_count) AS total_sales_records,

		SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS completed_sales,
		CONCAT(
			ROUND(
				SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END)
				/ NULLIF(SUM(f.sale_count), 0)
				* 100,
				2
			),
			' %'
		) AS completed_sales_rate,

		SUM(CASE WHEN LOWER(st.sale_status) = 'cancelled' THEN f.sale_count ELSE 0 END) AS cancelled_sales,
		CONCAT(
			ROUND(
				SUM(CASE WHEN LOWER(st.sale_status) = 'cancelled' THEN f.sale_count ELSE 0 END)
				/ NULLIF(SUM(f.sale_count), 0)
				* 100,
				2
			),
			' %'
		) AS cancelled_sales_rate,

		SUM(CASE WHEN LOWER(st.sale_status) = 'pending' THEN f.sale_count ELSE 0 END) AS pending_sales,
		CONCAT(
			ROUND(
				SUM(CASE WHEN LOWER(st.sale_status) = 'pending' THEN f.sale_count ELSE 0 END)
				/ NULLIF(SUM(f.sale_count), 0)
				* 100,
				2
			),
			' %'
		) AS pending_sales_rate

	FROM
		fact_sales f
	JOIN
		dim_dealer d USING(dealer_key)
	JOIN
		dim_customer_state cs USING(customer_state_key)
	JOIN
		dim_vehicle v USING(vehicle_key)
	JOIN
		dim_employee e USING(employee_key)
	JOIN
		dim_sale_status st USING(sale_status_key)
	WHERE
		cs.state_name <> 'Unknown'
		AND v.vehicle_brand <> 'Unknown'
	GROUP BY
		d.dealer_id,
		cs.state_name,
		v.vehicle_brand,
		e.employee_name
	HAVING
		total_sales_records > 0
	ORDER BY
		completed_sales_rate DESC,
		total_sales_records DESC;
    
    -- Conclusions:
		-- John Miller from dealership 1 in California achieved the highest completed sales rate, with 75% of his Nissan-related sales records ending as sold or delivered. This suggests strong conversion performance for that specific dealership, state, brand and salesperson combination.
		-- However, this result should be interpreted together with the total number of records in that group.
		-- Status mix analysis is useful to identify strong conversion areas, but also to detect groups with high cancellation, pending or uncertain sales rates.

-- 7) Are there any relevant time-based sales patterns, such as months with higher demand, seasonality, or unusual drops?
	WITH monthly_sales AS (
		SELECT
			c.year_number,
			c.month_number,
			c.month_name,
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS completed_sales_volume,
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END) AS completed_revenue
		FROM
			fact_sales f
		JOIN
			dim_calendar c USING(date_key)
		JOIN
			dim_sale_status st USING(sale_status_key)
		GROUP BY
			c.year_number,
			c.month_number,
			c.month_name
	),

	monthly_trends AS (
		SELECT
			year_number,
			month_number,
			month_name,
			completed_sales_volume,
			completed_revenue,
			LAG(completed_sales_volume) OVER(ORDER BY year_number, month_number) AS previous_month_sales_volume,
			LAG(completed_revenue) OVER(ORDER BY year_number, month_number) AS previous_month_revenue
		FROM
			monthly_sales
	)

	SELECT
		year_number,
		month_name,
		completed_sales_volume,
		completed_revenue,
		previous_month_sales_volume,
		completed_sales_volume - previous_month_sales_volume AS sales_volume_change,
		CONCAT(
			ROUND(
				(completed_sales_volume - previous_month_sales_volume)
				/ NULLIF(previous_month_sales_volume, 0)
				* 100,
				2
			),
			' %'
		) AS sales_volume_mom_change,
		previous_month_revenue,
		completed_revenue - previous_month_revenue AS revenue_change,
		CONCAT(
			ROUND(
				(completed_revenue - previous_month_revenue)
				/ NULLIF(previous_month_revenue, 0)
				* 100,
				2
			),
			' %'
		) AS revenue_mom_change
	FROM
		monthly_trends
	ORDER BY
		year_number,
		month_number;
	
    -- Conclusions:
		-- The analysis suggests that spring and fall periods had stronger sales performance. 
        -- On the other hand, winter appeared to be the period with the lowest sales rate.
		-- This may indicate a seasonal sales pattern, which is common in vehicle sales due to consumer behaviour, weather conditions, promotional campaigns, tax periods or dealership stock cycles.
		-- Revenue and sales volume should also be analysed together because a month can generate high revenue either through more sales or through fewer but higher-value transactions.

-- 8) Which combination of brand, model, vehicle year, and US state generates the highest revenue or the best business opportunities (top 10)?
	SELECT
		v.vehicle_brand,
		v.vehicle_model,
		v.vehicle_year,
		cs.state_name,
		SUM(f.sale_count) AS completed_units_sold,
		SUM(f.sale_amount_usd) AS completed_revenue,
		ROUND(SUM(f.sale_amount_usd) / NULLIF(SUM(f.sale_count), 0), 2) AS average_sale_price
	FROM
		fact_sales f
	JOIN
		dim_vehicle v USING(vehicle_key)
	JOIN
		dim_customer_state cs USING(customer_state_key)
	JOIN
		dim_sale_status st USING(sale_status_key)
	WHERE
		LOWER(st.sale_status) IN ('sold', 'delivered')
		AND v.vehicle_brand <> 'Unknown'
		AND v.vehicle_model <> 'Unknown'
		AND cs.state_name <> 'Unknown'
		AND v.vehicle_year IS NOT NULL
	GROUP BY
		v.vehicle_brand,
		v.vehicle_model,
		v.vehicle_year,
		cs.state_name
	ORDER BY
		completed_revenue DESC
	LIMIT 10;
    
    -- Conclusions:
		-- The 2020 Tesla Model Y and the 2020 Ford F-150 were the vehicle combinations that generated the highest completed sales revenue.
		-- These combinations can be considered strong business opportunities within the dataset.
		-- The Tesla Model Y likely represents a higher-ticket electric vehicle opportunity, while the Ford F-150 may reflect strong demand for pickup trucks in the US market.
		-- These results can support inventory planning, local marketing campaigns and dealership stock allocation.
		-- However, before making business decisions, revenue should be compared with margin, stock availability, cancellation rates, return rates and local demand.

-- 9) Are there significant differences between newer and older vehicles in terms of sales volume, revenue generated, and average price?
	SELECT
		CASE
			WHEN v.vehicle_year BETWEEN 2013 AND 2018 THEN 'older_vehicles'
			WHEN v.vehicle_year BETWEEN 2019 AND 2022 THEN 'newer_vehicles'
			ELSE 'Unknown'
		END AS vehicle_category,

		SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS completed_sales_volume,

		CONCAT(
			ROUND(
				SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END)
				/
				NULLIF(
					SUM(SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END)) OVER(),
					0
				)
				* 100,
				2
			),
			' %'
		) AS completed_sales_rate,

		SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END) AS completed_revenue,

		CONCAT(
			ROUND(
				SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END)
				/
				NULLIF(
					SUM(SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END)) OVER(),
					0
				)
				* 100,
				2
			),
			' %'
		) AS completed_revenue_rate,

		ROUND(
			SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END)
			/
			NULLIF(SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END), 0),
			2
		) AS average_sale_price

	FROM
		fact_sales f
	JOIN
		dim_vehicle v USING(vehicle_key)
	JOIN
		dim_sale_status st USING(sale_status_key)
	GROUP BY
		vehicle_category
	ORDER BY
		completed_revenue DESC;
	
	-- Conclusions:
		-- Older vehicles represented slightly more completed sales volume, with around 49% of sales, compared with approximately 47% for newer vehicles.
		-- However, newer vehicles generated significantly more completed revenue, accounting for around 56%, compared with approximately 40% for older vehicles.
		-- This indicates that older vehicles may drive more volume because they are usually more affordable, while newer vehicles generate more revenue because of their higher average sale price.
		-- Around 4% of sales volume and 4% of revenue came from vehicles classified as Unknown.
		-- 'Unknown' category should be monitored because it limits the reliability of vehicle age analysis.

-- 10) Which records, dimensions, or combinations show potential analytical red flags, such as salespeople with low sales percentage, low-performing dealerships, states with few transactions, or price outliers?
	-- 10.1) Employees with low sales share within their dealership:
		WITH employee_dealer_sales AS (
			SELECT
				e.employee_name,
				d.dealer_id,
				SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS employee_completed_sales
			FROM
				fact_sales f
			JOIN
				dim_employee e USING(employee_key)
			JOIN
				dim_dealer d USING(dealer_key)
			JOIN
				dim_sale_status st USING(sale_status_key)
			GROUP BY
				e.employee_name,
				d.dealer_id
		)

		SELECT
			employee_name,
			dealer_id,
			employee_completed_sales,
			CONCAT(
				ROUND(
					employee_completed_sales
					/ NULLIF(SUM(employee_completed_sales) OVER(PARTITION BY dealer_id), 0)
					* 100,
					2
				),
				' %'
			) AS employee_sales_share_within_dealer
		FROM
			employee_dealer_sales
		WHERE
			employee_completed_sales > 0
		ORDER BY
			dealer_id,
			employee_completed_sales;
        
        -- Conclusions:
			-- In terms of completed sales volume share, dealership 11 had the largest difference between employees.
			-- Betty Green accounted for 71% of that dealership's completed sales volume, while Jason Scott accounted for only 29%.
			-- This may indicate a relevant performance gap, but it should not be interpreted as an employee issue without additional context.
			-- Factors such as seniority, assigned leads, working hours, product specialisation, customer traffic and sales opportunities should be reviewed before drawing operational conclusions.
	
    -- 10.2) Low-performing dealerships:
		WITH dealer_performance AS (
			SELECT
				d.dealer_id,
				SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS completed_sales,
				SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_amount_usd ELSE 0 END) AS completed_revenue,
				SUM(f.sale_count) AS total_sales_records
			FROM
				fact_sales f
			JOIN
				dim_dealer d USING(dealer_key)
			JOIN
				dim_sale_status st USING(sale_status_key)
			GROUP BY
				d.dealer_id
		),

		dealer_rates AS (
			SELECT
				dealer_id,
				completed_sales,
				completed_revenue,
				total_sales_records,
				completed_sales / NULLIF(total_sales_records, 0) AS completed_sales_rate,
				completed_sales / NULLIF(SUM(completed_sales) OVER(), 0) AS completed_sales_market_share
			FROM
				dealer_performance
		)

		SELECT
			dealer_id,
			completed_sales,
			completed_revenue,
			total_sales_records,
			CONCAT(ROUND(completed_sales_rate * 100, 2), ' %') AS completed_sales_rate,
			CONCAT(ROUND(completed_sales_market_share * 100, 2), ' %') AS completed_sales_market_share
		FROM
			dealer_rates
		WHERE
			completed_sales_rate < 0.5
			OR completed_sales_market_share < 0.05
		ORDER BY
			completed_sales;
		
        -- Conclusions:
			-- Dealerships 3, 11, 13 and 7, representing 4 out of 15 dealerships, had less than 5% of the total completed sales performance.
			-- These dealerships can be flagged for further analysis because their contribution to total sales volume was relatively low.
			-- However, low market share does not automatically mean poor performance.
			-- It may also be explained by smaller market size, fewer employees, lower inventory, weaker local demand, or limited dealership coverage.
			-- To assess true performance, sales share should be compared with completed sales rate, revenue, average ticket size, dealership capacity and local market potential.
		
	-- 10.3) US states with few transactions:
        WITH state_sales AS (
			SELECT
				cs.customer_state_key,
				cs.state_name,
				SUM(CASE WHEN LOWER(st.sale_status) IN ('sold', 'delivered') THEN f.sale_count ELSE 0 END) AS completed_sales
			FROM
				fact_sales f
			JOIN
				dim_customer_state cs USING(customer_state_key)
			JOIN
				dim_sale_status st USING(sale_status_key)
			WHERE
				cs.state_name <> 'Unknown'
			GROUP BY
				cs.customer_state_key,
				cs.state_name
		),

		ranked_states AS (
			SELECT
				customer_state_key,
				state_name,
				completed_sales,
				ROW_NUMBER() OVER(ORDER BY completed_sales ASC) AS rn
			FROM
				state_sales
		)

		SELECT
			state_name,
			completed_sales,
			CONCAT(
				ROUND(
					completed_sales / NULLIF(SUM(completed_sales) OVER(), 0) * 100,
					2
				),
				' %'
			) AS completed_sales_share
		FROM
			ranked_states
		WHERE
			rn <= 3
		ORDER BY
			completed_sales ASC;
                    
		-- Conclusions:
			-- Utah, Alabama and South Carolina were the states with the fewest completed sales according to the analysis.
			-- Utah recorded approximately 31.6%, while Alabama and South Carolina recorded approximately 34.21%.
			-- These values should be reviewed carefully because percentages for "fewest sales" may be affected by the denominator used in the calculation.
			-- From a business perspective, states with fewer transactions may represent underdeveloped markets, limited dealership presence, lower inventory availability or weaker local demand.
			-- Additional market context would be needed before deciding whether these states represent a commercial risk or an expansion opportunity.
	
    -- 10.4) Sale Price outliers:
		WITH completed_sales AS (
			SELECT
				v.vehicle_brand,
				v.vehicle_model,
				f.sale_amount_usd
			FROM
				fact_sales f
			JOIN
				dim_vehicle v USING(vehicle_key)
			JOIN
				dim_sale_status st USING(sale_status_key)
			WHERE
				LOWER(st.sale_status) IN ('sold', 'delivered')
				AND v.vehicle_brand <> 'Unknown'
				AND v.vehicle_model <> 'Unknown'
		),

		model_avg AS (
			SELECT
				vehicle_brand,
				vehicle_model,
				AVG(sale_amount_usd) AS avg_model_price,
				STDDEV(sale_amount_usd) AS stddev_model_price
			FROM
				completed_sales
			GROUP BY
				vehicle_brand,
				vehicle_model
		)

		SELECT
			cs.vehicle_brand,
			cs.vehicle_model,
			cs.sale_amount_usd,
			ROUND(ma.avg_model_price, 2) AS avg_model_price,
			ROUND(ma.stddev_model_price, 2) AS stddev_model_price
		FROM
			completed_sales cs
		JOIN
			model_avg ma
			ON cs.vehicle_brand = ma.vehicle_brand
			AND cs.vehicle_model = ma.vehicle_model
		WHERE
			ma.stddev_model_price IS NOT NULL
			AND ABS(cs.sale_amount_usd - ma.avg_model_price) > 2 * ma.stddev_model_price
		ORDER BY
			ABS(cs.sale_amount_usd - ma.avg_model_price) DESC;
        
	-- Conclusions:
		-- Hyundai Elantra was the model with the highest standard deviation in sale price, with a stddev_model_price of 3974.56. This indicates greater price variability for that model compared with the rest of the portfolio.
		-- Chrysler 200 was the model with the lowest standard deviation in sale price, with a stddev_model_price of 1362.69. This suggests that Chrysler 200 sales prices were more consistent within the dataset.
		-- High price variability may be caused by differences in vehicle year, trim, mileage, condition, discounts, financing conditions or possible data quality issues.
		-- Price outliers should not be removed automatically because they may represent valid business cases, such as premium configurations or exceptional discounts.
	
/*
==================================================================================================================
********************************************* FINAL CONCLUSIONS **************************************************
==================================================================================================================

1) The analysis shows that the dealership business had a positive commercial trend over the analysed years, with completed revenue and completed sales volume increasing over time.

2) From a product perspective:
	- The dataset shows that different brands and models contribute to performance in different ways.
	- Chevrolet Tahoe stood out as one of the strongest overall models because it performed well in both revenue and sales volume.
	- Honda and Ford showed strong sales volume, while Tesla and Chevrolet stood out in terms of higher average sale price.

3) From a geographic perspective:
	- The top-performing states were also among the most populated US states, which is consistent with larger market potential.
    - However, population should not be treated as the only explanation, because dealership coverage, inventory, local demand and customer purchasing power can also influence results.

4) From a dealership perspective:
	- Dealership 15 was the strongest overall performer in completed revenue and completed sales volume.
	- Dealership 6 showed the strongest completed sales rate, while dealership 14 achieved the highest average revenue per completed sale.
	- This demonstrates why dealership performance should be evaluated using several KPIs together instead of relying on a single ranking.

5) From an employee perspective:
	- Mary Campbell was the strongest salesperson in absolute completed revenue and sales volume.
	- However, employee analysis also revealed concentration patterns within some dealerships, where one employee generated a much larger share of revenue or sales than another. This can indicate top-performer impact, but also potential dependency risk.

6) From a time-based perspective:
	- Spring and fall appeared to be stronger sales periods, while winter showed weaker performance.
	- This suggests possible seasonality, although a longer historical dataset would be needed to confirm a stable seasonal pattern.

7) From a vehicle age perspective:
	- Older vehicles generated slightly more sales volume, while newer vehicles generated significantly more revenue.
    - This suggests that older vehicles may support affordability and volume, whereas newer vehicles are more important for revenue generation and higher average ticket size.

8) Finally, the red flag analysis identified areas that require further investigation:
	- Low-contribution dealerships
    - Uneven employee sales distribution
    - States with fewer transactions
    - 'Unknown' vehicle values and models with high price variability.

These findings show how SQL can be used not only to calculate metrics, but also to support business decision-making around inventory, dealership performance, sales conversion, geographic strategy, employee productivity and data quality.
*/