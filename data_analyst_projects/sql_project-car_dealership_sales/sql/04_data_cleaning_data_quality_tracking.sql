/*
==================================================================================================================
************************************** DATA_QUALITY_ISSUES TABLE *************************************************
==================================================================================================================

This table will register problems encountered while columns will be cleaned and transformed. This table wants to highlight the importance of data quality.
Here are the steps that it will be taken:
	1) Detecting errors in 'raw_cds' table for each column
    2) Inserting errors in 'data_quality_issues' table
    3) Applying cleaning/transforming methods in 'cds_cleaned'
    4) Validating the cleaned outcome
*/
	
    USE car_dealership_sales;
    
    DROP TABLE IF EXISTS data_quality_issues;
    CREATE TABLE data_quality_issues (
		issue_id INT AUTO_INCREMENT PRIMARY KEY,
        raw_row_id INT,
        name_column VARCHAR(100),
        original_value VARCHAR(100),
        cleaned_value VARCHAR(100),
        issue_type VARCHAR(255),
        action_taken TEXT(1000)
    ) ENGINE = innodb DEFAULT CHARSET = utf8mb4;

/*
==================================================================================================================
********************************** CLEANING & TRANSFORMATION PROCESS *********************************************
==================================================================================================================
*/

-- 1) To apply cleaning and transformation steps, we create a new table containing the original data, with the addition of 'clean' columns that will be filled with the correct values from each original column. In addition, we will add a new column called 'values_to_data_quality_issues' that will help us to track incorrect values and leaving 'cds_raw' containing the original data:
	DROP TABLE IF EXISTS cds_cleaning_process;
    CREATE TABLE cds_cleaning_process AS
		SELECT * FROM cds_raw;
        
	ALTER TABLE cds_cleaning_process
		ADD COLUMN dealer_id_cleaned INT AFTER dealer_id,
        ADD COLUMN employee_id_cleaned INT AFTER employee_id,
        ADD COLUMN employee_name_cleaned VARCHAR(100) AFTER employee_name,
        ADD COLUMN employee_role_cleaned VARCHAR(70) AFTER employee_role,
        ADD COLUMN hire_date_cleaned DATE AFTER hire_date,
        ADD COLUMN employee_email_cleaned VARCHAR(100) AFTER employee_email,
        ADD COLUMN employee_phone_cleaned CHAR(12) AFTER employee_phone,
        ADD COLUMN vin_cleaned CHAR(17) AFTER vin,
        ADD COLUMN vehicle_brand_cleaned VARCHAR(50) AFTER vehicle_brand,
        ADD COLUMN vehicle_model_cleaned VARCHAR(70) AFTER vehicle_model,
        ADD COLUMN vehicle_year_cleaned SMALLINT AFTER vehicle_year,
        ADD COLUMN vehicle_price_usd_cleaned DECIMAL(10, 2) AFTER vehicle_price_usd,
        ADD COLUMN sale_date_cleaned DATE AFTER sale_date,
        ADD COLUMN customer_state_cleaned CHAR(2) AFTER customer_state,
        ADD COLUMN sale_status_cleaned VARCHAR(50) AFTER sale_status,
        ADD COLUMN values_to_data_quality_issues VARCHAR(1) DEFAULT NULL;


-- 2) We TRIM all the columns to avoid potential spaces on the edges:
	UPDATE cds_cleaning_process SET
		dealer_id = TRIM(dealer_id),
        employee_id = TRIM(employee_id),
        employee_name = TRIM(employee_name),
        employee_role = TRIM(employee_role),
        hire_date = TRIM(hire_date),
        employee_email = TRIM(employee_email),
        employee_phone = TRIM(employee_phone),
        vin = TRIM(vin),
        vehicle_brand = TRIM(vehicle_brand),
        vehicle_model = TRIM(vehicle_model),
        vehicle_year = TRIM(vehicle_year),
        vehicle_price_usd = TRIM(vehicle_price_usd),
        sale_date = TRIM(sale_date),
        customer_state = TRIM(customer_state),
        sale_status = TRIM(sale_status);

-- 3) We check if there are complete duplicate rows in the table querying all the columns:
	SELECT
		dealer_id, employee_id, employee_name, employee_role, hire_date,
        employee_email, employee_phone, vin, vehicle_brand, vehicle_model,
        vehicle_year, vehicle_price_usd, sale_date, customer_state, sale_status,
        COUNT(*) as NUM_DUPLICATE_ROWS
	FROM cds_cleaning_process
    GROUP BY
		dealer_id, employee_id, employee_name, employee_role, hire_date,
        employee_email, employee_phone, vin, vehicle_brand, vehicle_model,
        vehicle_year, vehicle_price_usd, sale_date, customer_state, sale_status
	HAVING COUNT(*) > 1;
    
    -- No complete duplicate rows found.
    
/*
==================================================================================================================
********************************************* DEALER_ID **********************************************************
==================================================================================================================

Return an explanation about the cleaning steps applied
*/

	-- 1) First of all, we check the rows with a 'dealer_id' value correct. Otherwise, we will add '1' in the 'values_to_data_quality_issues' column to the rows with incorrect 'dealer_id' value. If the value is correct, we will only keep the number:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = CASE
			WHEN UPPER(dealer_id) REGEXP '^D[0-9]{3}$' AND dealer_id <> 'D000'
				THEN NULL
			ELSE 1
		END;
    
    -- 2) Now, we populate the 'data_quality_issues' table with the rows with 'dealer_id' incorrect values:
		INSERT INTO data_quality_issues (
			raw_row_id,
            name_column,
            original_value,
            issue_type,
            action_taken
        )
        SELECT
			c.raw_row_id,
            'dealer_id' AS name_column,
            c.dealer_id as original_value,
            'Incorrect "dealer_id" value' AS issue_type,
            'Invalid dealer_id values are standardized only when the pattern is clear; otherwise they remain NULL and must be reviewed manually' AS action_taken
		FROM
			cds_cleaning_process c
		WHERE
			c.values_to_data_quality_issues = 1 AND
            NOT EXISTS (
				SELECT 1
                FROM data_quality_issues AS d
                WHERE
					d.raw_row_id = c.raw_row_id AND
                    d.name_column = 'dealer_id' AND
                    d.issue_type = 'Incorrect "dealer_id" value'
            );
            
	-- 3) After that, we extract the number from correct 'dealer_id' values and will keep the original values from the rows with incorrect 'dealer_id' values:
		UPDATE cds_cleaning_process
        SET dealer_id_cleaned = CASE
			WHEN UPPER(dealer_id) REGEXP '^D[0-9]{3}$' AND UPPER(dealer_id) <> 'D000'
				THEN CAST(SUBSTRING(dealer_id, 2) AS UNSIGNED)
            WHEN dealer_id REGEXP '^[0-9]{1,3}$'
				THEN CAST(dealer_id AS UNSIGNED)
            WHEN UPPER(dealer_id) REGEXP '^D[0-9]{1,2}$'
				THEN CAST(REPLACE(dealer_id, 'D', '') AS UNSIGNED)
            ELSE NULL
		END;
	
    -- 4) After cleaned the column, we update the 'cleaned_value' column from the 'data_quality_issues' with the cleaned value:
		UPDATE data_quality_issues d
        JOIN cds_cleaning_process c USING(raw_row_id)
        SET d.cleaned_value = c.dealer_id_cleaned
        WHERE d.name_column = 'dealer_id';
    
    -- 5) Finally, we reset the 'values_to_data_quality_issues' column to NULL:
		UPDATE cds_cleaning_process
        SET values_to_data_quality_issues = NULL;
        
/*
==================================================================================================================
********************************************** EMPLOYEE_ID *******************************************************
==================================================================================================================

	Cleaning logic:
	0) Creating 'ref_employee' table as a employee information's reference table
    1) Normalizing employee_id to the standard format E + 4 digits.
	2) Validating it against 'ref_employee'.
	3) If 'employee_id' is invalid, trying to recover the correct ID using 'employee_email' or 'employee_name'.
	4) Storing the numeric part in 'employee_id_cleaned'.
	5) Logging problematic rows in 'data_quality_issues' table.
*/

	-- 0) First of all, we create a reference table with the employee information to compare and solve inconsistencies:
		DROP TABLE IF EXISTS ref_employee;
        CREATE TABLE ref_employee (
			employee_id VARCHAR(10) PRIMARY KEY,
			first_name VARCHAR(70),
            last_name VARCHAR(70),
            employee_email VARCHAR(150)
		) ENGINE = innodb DEFAULT CHARSET = utf8mb4;
        
        INSERT INTO ref_employee VALUES
			('E1008', 'Amanda', 'Anderson', 'amanda.anderson@sunsetautos.com'),
            ('E1029', 'Anthony', 'Phillips', 'anthony.phillips@sunsetautos.com'),
            ('E1014', 'Barbara', 'Lee', 'barbara.lee@sunsetautos.com'),
            ('E1022', 'Betty', 'Green', 'betty.green@sunsetautos.com'),
            ('E1007', 'Chris', 'Taylor', 'chris.taylor@sunsetautos.com'),
			('E1011', 'Daniel', 'White', 'daniel.white@sunsetautos.com'),
            ('E1005', 'David', 'Wilson', 'david.wilson@sunsetautos.com'),
            ('E1024', 'Donna', 'Nelson', 'donna.nelson@sunsetautos.com'),
            ('E1025', 'Edward', 'Carter', 'edward.carter@sunsetautos.com'),
            ('E1004', 'Emily', 'Davis', 'emily.davis@sunsetautos.com'),
			('E1023', 'George', 'Baker', 'george.baker@sunsetautos.com'),
            ('E1021', 'Jason', 'Scott', 'jason.scott@sunsetautos.com'),
            ('E1016', 'Jennifer', 'Hall', 'jennifer.hall@sunsetautos.com'),
            ('E1006', 'Jessica', 'Moore', 'jessica.moore@sunsetautos.com'),
            ('E1001', 'John', 'Miller', 'john.miller@sunsetautos.com'),
            ('E1018', 'Karen', 'Young', 'karen.young@sunsetautos.com'), 
            ('E1013', 'Kevin', 'Martin', 'kevin.martin@sunsetautos.com'),
            ('E1010', 'Linda', 'Jackson', 'linda.jackson@sunsetautos.com'),
            ('E1028', 'Lisa', 'Carter', 'lisa.carter@sunsetautos.com'),
            ('E1027', 'Mark', 'Roberts', 'mark.roberts@sunsetautos.com'),
            ('E1030', 'Mary', 'Campbell', 'mary.campbell@sunsetautos.com'),
            ('E1003', 'Michael', 'Brown', 'michael.brown@sunsetautos.com'),
            ('E1020', 'Nancy', 'Wright', 'nancy.wright@sunsetautos.com'),
            ('E1012', 'Patricia', 'Harris', 'patricia.harris@sunsetautos.com'),
            ('E1019', 'Paul', 'King', 'paul.king@sunsetautos.com'),
            ('E1009', 'Robert', 'Thomas', 'robert.thomas@sunsetautos.com'),
            ('E1002', 'Sarah', 'Johnson', 'sarah.johnson@sunsetautos.com'),
            ('E1015', 'Steven', 'Perez', 'stephen.perez@sunsetautos.com'),
            ('E1026', 'Susan', 'Mitchell', 'susan.mitchell@sunsetautos.com'),
            ('E1017', 'Thomas', 'Allen', 'thomas.allen@sunsetautos.com');
            
	-- 1) Normalize and resolve 'employee_id' using 'ref_employee' table as source of truth:
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_resolution;
		CREATE TEMPORARY TABLE tmp_employee_resolution AS
		SELECT
			c.raw_row_id,
			c.employee_id AS employee_id_original,
			c.employee_name,
			c.employee_email,
			
			-- 1.1) standardize 'employee_id' column:
				CASE
					WHEN c.employee_id REGEXP '^[A-Za-z][0-9]{4}$'
						THEN UPPER(c.employee_id)
					WHEN c.employee_id REGEXP '^[0-9]{4}$'
						THEN CONCAT('E', c.employee_id)
					ELSE NULL
				END AS employee_id_standardized,
				
			-- 1.2) resolve 'employee_id' column based on the reference table created:
				COALESCE(r_id.employee_id, r_email.employee_id, r_name.employee_id) AS employee_id_resolved
		FROM cds_cleaning_process c
		-- join the 'employee_id' part:
			LEFT JOIN ref_employee r_id
				ON r_id.employee_id = CASE
					WHEN c.employee_id REGEXP '^[A-Za-z][0-9]{4}$'
						THEN UPPER(c.employee_id)
					WHEN c.employee_id REGEXP '^[0-9]{4}$'
						THEN CONCAT('E', c.employee_id)
					ELSE NULL
				END
                
		-- 1.3) join the 'employee_email' part:
			LEFT JOIN ref_employee r_email
				ON LOWER(c.employee_email) = LOWER(r_email.employee_email)
                
		-- 1.4) join the 'employee_name' part:
			LEFT JOIN ref_employee r_name
				ON LOWER(c.employee_name) = LOWER(CONCAT(r_name.first_name, ' ', r_name.last_name));

	-- 2) Update 'employee_id_cleaned' with the resolved value:
		UPDATE cds_cleaning_process c
		JOIN tmp_employee_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.employee_id_cleaned = CASE
			WHEN t.employee_id_resolved IS NOT NULL
				THEN CAST(SUBSTRING(t.employee_id_resolved, 2) AS UNSIGNED)
			ELSE NULL
		END;
	
    -- 3) Mark rows with 'employee_id' issues in 'cds_cleaning_process' table:
		UPDATE cds_cleaning_process c
		JOIN tmp_employee_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			WHEN t.employee_id_resolved IS NULL
				THEN 1
			WHEN t.employee_id_standardized IS NULL
				THEN 1
			WHEN t.employee_id_standardized <> t.employee_id_resolved
				THEN 1
			ELSE NULL
		END;
	
    -- 4) Insert 'employee_id issues' into 'data_quality_issues':
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'employee_id' AS name_column,
			c.employee_id AS original_value,
			CASE
				WHEN t.employee_id_resolved IS NULL
					THEN 'Unresolved "employee_id"'
				WHEN t.employee_id_standardized IS NULL
					THEN 'Invalid "employee_id" format'
				WHEN t.employee_id_standardized <> t.employee_id_resolved
					THEN '"employee_id" corrected using "ref_employee" table'
				ELSE '"employee_id" issue'
			END AS issue_type,
			CASE
				WHEN t.employee_id_resolved IS NULL
					THEN '"employee_id" could not be matched against "ref_employee" table and must be reviewed manually'
				WHEN t.employee_id_standardized IS NULL
					THEN '"employee_id" format was invalid, but it was resolved using "employee_name" or "employee_email" columns from "ref_employee" table'
				WHEN t.employee_id_standardized <> t.employee_id_resolved
					THEN '"employee_id" was replaced with the correct value from "ref_employee" table'
				ELSE '"employee_id" reviewed'
			END AS action_taken,
			c.employee_id_cleaned AS cleaned_value
		FROM cds_cleaning_process c
		JOIN tmp_employee_resolution t
			ON c.raw_row_id = t.raw_row_id
		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'employee_id'
		  );
          
	-- 5) Final manual review check:
		SELECT
			c.raw_row_id,
			c.employee_id,
			c.employee_name,
			c.employee_email,
			c.employee_id_cleaned
		FROM cds_cleaning_process c
		WHERE c.employee_id_cleaned IS NULL;

	-- 6) Reset temporary issue flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;
        
	-- 7) Drop temporary table:
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_resolution;

/*
==================================================================================================================
********************************************* EMPLOYEE_NAME ******************************************************
==================================================================================================================

	Professional cleaning logic:
		0) We will use 'ref_employee' as the source of truth.
		1) We will try to resolve the correct 'employee_name' using:
		   - 'employee_id_cleaned'
		   - 'employee_email'
		   - normalized 'employee_name'
		2) If the original 'employee_name' column is incorrect but can be matched to 'ref_employee' table, we will replace it with the correct name.
		3) If it cannot be matched, 'employee_name_cleaned' will be NULL and the row must be reviewed manually.
*/

	-- 1) Create a temporary table to resolve the correct employee name using 'ref_employee' table:
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_name_resolution;
		CREATE TEMPORARY TABLE tmp_employee_name_resolution AS
		SELECT
			c.raw_row_id,
			c.employee_id,
			c.employee_id_cleaned,
			c.employee_name AS employee_name_original,
			c.employee_email,

			-- Standardize the original name only for comparison purposes:
			REGEXP_REPLACE(c.employee_name, '[[:space:]]+', ' ') AS employee_name_normalized,

			-- Correct full name from 'ref_employee' table:
			COALESCE(
				CONCAT(r_id.first_name, ' ', r_id.last_name),		-- First matching option from the JOIN section using 'ref_employee'
				CONCAT(r_email.first_name, ' ', r_email.last_name),	-- Second matching option from the JOIN section using 'ref_employee'
				CONCAT(r_name.first_name, ' ', r_name.last_name)	-- Third matching option from the JOIN section using 'ref_employee'
			) AS employee_name_resolved,

			-- This column explains how the correct employee name was found:
			CASE
				WHEN r_id.employee_id IS NOT NULL THEN 'Matched by "employee_id"'
				WHEN r_email.employee_id IS NOT NULL THEN 'Matched by "employee_email"'
				WHEN r_name.employee_id IS NOT NULL THEN 'Matched by "employee_name"'
				ELSE 'Not matched'
			END AS match_method

		FROM cds_cleaning_process c

		-- First matching option (for example: if 'employee_id_cleaned' = 1001, we compare it with 'ref_employee.employee_id' = 'E1001'):
		LEFT JOIN ref_employee r_id
			ON r_id.employee_id = CONCAT('E', LPAD(c.employee_id_cleaned, 4, '0'))

		-- Second matching option (if the email is correct, we can use it to find the correct employee name):
		LEFT JOIN ref_employee r_email
			ON LOWER(c.employee_email) = LOWER(r_email.employee_email)

		-- Third matching option (if the name is already correct or only has minor spacing/capitalization issues, we compare it with the official full name from 'ref_employee' table):
		LEFT JOIN ref_employee r_name
			ON LOWER(REGEXP_REPLACE(c.employee_name, '[[:space:]]+', ' ')) = LOWER(CONCAT(r_name.first_name, ' ', r_name.last_name));

	-- 2) Update 'employee_name_cleaned' with the correct full name from 'ref_employee' table:
		UPDATE cds_cleaning_process c
		JOIN tmp_employee_name_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.employee_name_cleaned = t.employee_name_resolved;

	-- 3) Mark rows that have 'employee_name' quality issues:
		UPDATE cds_cleaning_process c
		JOIN tmp_employee_name_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			-- If there is no match in 'ref_employee' table, the name cannot be trusted.
			WHEN t.employee_name_resolved IS NULL THEN 1

			-- If the original name does not follow the expected format, we log it.
			WHEN t.employee_name_original NOT REGEXP '^[A-Z][a-z]+[ ][A-Z][a-z]+$' THEN 1

			-- If the original normalized name is different from the resolved official name, we log it.
			WHEN t.employee_name_normalized <> t.employee_name_resolved THEN 1

			ELSE NULL
		END;

	-- 4) Insert 'employee_name' issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'employee_name' AS name_column,
			c.employee_name AS original_value,
			
            -- 'issue_type' column:
			CASE
				WHEN t.employee_name_resolved IS NULL
					THEN 'Unresolved "employee_name"'

				WHEN t.employee_name_original NOT REGEXP '^[A-Z][a-z]+[ ][A-Z][a-z]+$'
					THEN 'Incorrect "employee_name" format'

				WHEN t.employee_name_normalized <> t.employee_name_resolved
					THEN '"employee_name" corrected using "ref_employee" table'

				ELSE '"employee_name" issue'
			END AS issue_type,
			
            -- 'action_taken' column:
			CASE
				WHEN t.employee_name_resolved IS NULL
					THEN '"employee_name" could not be matched against "ref_employee" table and must be reviewed manually'

				WHEN t.employee_name_original NOT REGEXP '^[A-Z][a-z]+[ ][A-Z][a-z]+$'
					THEN CONCAT('"employee_name" format was incorrect, but it was resolved using "ref_employee" table. Match method: ', t.match_method)

				WHEN t.employee_name_normalized <> t.employee_name_resolved
					THEN CONCAT('"employee_name" was replaced with the official full name from "ref_employee" table. Match method: ', t.match_method)

				ELSE '"employee_name" reviewed'
			END AS action_taken,

			c.employee_name_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_employee_name_resolution t
			ON c.raw_row_id = t.raw_row_id
		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'employee_name'
		  );

	-- 5) Check rows that still could not be cleaned (these rows need manual review because they could not be matched with 'ref_employee' table):
		SELECT
			c.raw_row_id,
			c.employee_id,
			c.employee_id_cleaned,
			c.employee_name,
			c.employee_email,
			c.employee_name_cleaned
		FROM cds_cleaning_process c
		WHERE c.employee_name_cleaned IS NULL;

	-- 6) Reset the temporary flag used to insert rows into 'data_quality_issues' table:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 7) Drop the temporary table:
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_name_resolution;
		

/*
==================================================================================================================
******************************************** EMPLOYEE_EMAIL ******************************************************
==================================================================================================================

	Cleaning logic:
		1) We will use 'ref_employee' table as the source of truth, like we did with the previous two columns.
		2) We will not generate the email manually from 'employee_name', because 'ref_employee' already contains the official email.
		3) We will try to resolve the correct 'employee_email' using:
		   - 'employee_id_cleaned'
		   - 'employee_name_cleaned'
		   - normalized 'employee_email'
		4) If the original email is incorrect but can be matched to 'ref_employee', we will replace it with the official email.
		5) If it cannot be matched, 'employee_email_cleaned' will be NULL and the row must be reviewed manually.
		6) We will also check if the cleaned email creates duplicates in the transactional table.
*/

	-- 1) Create a temporary table to resolve the correct employee email using 'ref_employee' table:
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_email_resolution;
		CREATE TEMPORARY TABLE tmp_employee_email_resolution AS
		SELECT
			c.raw_row_id,
			c.employee_id,
			c.employee_id_cleaned,
			c.employee_name,
			c.employee_name_cleaned,
			c.employee_email AS employee_email_original,
			LOWER(c.employee_email) AS employee_email_normalized,

			-- Official email found in "ref_employee":
			COALESCE(
				r_id.employee_email,
				r_name.employee_email,
				r_email.employee_email
			) AS employee_email_resolved,

			-- This column explains how the correct email was found:
			CASE
				WHEN r_id.employee_id IS NOT NULL THEN 'Matched by "employee_id"'
				WHEN r_name.employee_id IS NOT NULL THEN 'Matched by "employee_name"'
				WHEN r_email.employee_id IS NOT NULL THEN 'Matched by "employee_email"'
				ELSE 'Not matched'
			END AS match_method
		FROM cds_cleaning_process c
        
		-- First matching option (if 'employee_id_cleaned' = 1001, we compare it with 'ref_employee.employee_id' = 'E1001'):
		LEFT JOIN ref_employee r_id
			ON r_id.employee_id = CONCAT('E', LPAD(c.employee_id_cleaned, 4, '0'))
            
		-- Second matching option (if 'employee_name_cleaned' = 'John Miller', we compare it with the official full name from 'ref_employee' table):
		LEFT JOIN ref_employee r_name
			ON LOWER(c.employee_name_cleaned) = LOWER(CONCAT(r_name.first_name, ' ', r_name.last_name))
            
		-- Third matching option (if the email is already correct or only has uppercase/spaces, we match it directly):
		LEFT JOIN ref_employee r_email
			ON LOWER(c.employee_email) = LOWER(r_email.employee_email);

	-- 2) Update 'employee_email_cleaned' with the official email from 'ref_employee' table:
		UPDATE cds_cleaning_process c
		JOIN tmp_employee_email_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.employee_email_cleaned = t.employee_email_resolved;

	-- 3) Mark rows that have 'employee_email' quality issues:
		UPDATE cds_cleaning_process c
		JOIN tmp_employee_email_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
        
			-- If there is no match in 'ref_employee', the email cannot be trusted:
			WHEN t.employee_email_resolved IS NULL THEN 1
            
			-- If the original email has an invalid basic email format, we log it:
			WHEN t.employee_email_original NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' THEN 1
            
			-- If the email domain is not the expected company domain, we log it:
			WHEN LOWER(t.employee_email_original) NOT LIKE '%@sunsetautos.com' THEN 1
            
			-- If the normalized original email is different from the official email, we log it:
			WHEN t.employee_email_normalized <> LOWER(t.employee_email_resolved) THEN 1
			ELSE NULL
		END;

	-- 4) Insert 'employee_email' issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'employee_email' AS name_column,
			c.employee_email AS original_value,
            
			CASE
				WHEN t.employee_email_resolved IS NULL
					THEN 'Unresolved "employee_email"'
				WHEN t.employee_email_original NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
					THEN 'Invalid "employee_email" format'
				WHEN LOWER(t.employee_email_original) NOT LIKE '%@sunsetautos.com'
					THEN 'Invalid "employee_email" domain'
				WHEN t.employee_email_normalized <> LOWER(t.employee_email_resolved)
					THEN '"employee_email" corrected using "ref_employee" table'
				ELSE '"employee_email" issue'
			END AS issue_type,

			CASE
				WHEN t.employee_email_resolved IS NULL
					THEN '"employee_email" could not be matched against "ref_employee" table and must be reviewed manually'
				WHEN t.employee_email_original NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
					THEN CONCAT('"employee_email" had an invalid format, but it was resolved using "ref_employee" table. Match method: ', t.match_method)
				WHEN LOWER(t.employee_email_original) NOT LIKE '%@sunsetautos.com'
					THEN CONCAT('"employee_email" had an invalid domain, but it was resolved using "ref_employee" table. Match method: ', t.match_method)
				WHEN t.employee_email_normalized <> LOWER(t.employee_email_resolved)
					THEN CONCAT('"employee_email" was replaced with the official email from "ref_employee" table. Match method: ', t.match_method)
				ELSE '"employee_email" reviewed'
			END AS action_taken,

			c.employee_email_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_employee_email_resolution t
			ON c.raw_row_id = t.raw_row_id
		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'employee_email'
		  );

	-- 5) Check possible duplicate cleaned emails:
		-- In a sales table, the same employee can appear many times, so repeated emails are not automatically wrong. However, the same cleaned email linked to different employee_id_cleaned values would be a problem
			DROP TEMPORARY TABLE IF EXISTS tmp_employee_email_duplicates;
			CREATE TEMPORARY TABLE tmp_employee_email_duplicates AS
				SELECT
					employee_email_cleaned,
					COUNT(DISTINCT employee_id_cleaned) AS different_employee_ids
				FROM cds_cleaning_process
				WHERE employee_email_cleaned IS NOT NULL
				GROUP BY employee_email_cleaned
				HAVING COUNT(DISTINCT employee_id_cleaned) > 1;

	-- 6) Insert duplicate email issues if the same email is linked to different employees:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'employee_email' AS name_column,
			c.employee_email AS original_value,
			'Duplicated "employee_email" linked to different employees' AS issue_type,
			'The same cleaned "employee_email" is linked to more than one "employee_id_cleaned". This must be reviewed manually' AS action_taken,
			c.employee_email_cleaned AS cleaned_value
		FROM cds_cleaning_process c
		JOIN tmp_employee_email_duplicates d
			ON c.employee_email_cleaned = d.employee_email_cleaned
		WHERE NOT EXISTS (
			SELECT 1
			FROM data_quality_issues q
			WHERE q.raw_row_id = c.raw_row_id
			  AND q.name_column = 'employee_email'
			  AND q.issue_type = 'Duplicated "employee_email" linked to different employees'
		);

	-- 7) Check rows that still could not be cleaned (these rows need manual review because they could not be matched with 'ref_employee' table):
		SELECT
			c.raw_row_id,
			c.employee_id,
			c.employee_id_cleaned,
			c.employee_name,
			c.employee_name_cleaned,
			c.employee_email,
			c.employee_email_cleaned
		FROM cds_cleaning_process c
		WHERE c.employee_email_cleaned IS NULL;

	-- 8) Reset the temporary flag used to insert rows into 'data_quality_issues' table:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 9) Drop temporary tables explicitly:
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_email_resolution;
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_email_duplicates;

/*
==================================================================================================================
********************************************* EMPLOYEE_ROLE ******************************************************
==================================================================================================================

	Cleaning logic:
		1) 'employee_role' will be cleaned using a specific reference table: 'ref_employee_role'.
		2) We will create a mapping table with possible incorrect values and their official cleaned value.
		3) We will update 'employee_role_cleaned' using that reference table.
		4) If a role cannot be matched, it will be inserted into 'data_quality_issues' table for manual review.

	Important:
		'ref_employee' table is useful to validate 'employee_id', 'employee_name' and 'employee_email'. However, it was not provided in the 'ref_employee' table.
*/

	-- 1) Check the current distinct 'employee_role' values (it is useful before creating or updating the reference table):
		SELECT
			employee_role,
			COUNT(*) AS role_count
		FROM cds_cleaning_process
		GROUP BY employee_role
		ORDER BY role_count DESC;

	-- 2) Create a reference table for employee roles:
		DROP TABLE IF EXISTS ref_employee_role;
		CREATE TABLE ref_employee_role (
			raw_role_value VARCHAR(100) PRIMARY KEY,
			clean_role_value VARCHAR(100) NOT NULL
		) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

	-- 3) Populate the reference table:
		INSERT INTO ref_employee_role (
			raw_role_value,
			clean_role_value
		)
		VALUES
			-- Sales Associate
			('sales associate', 'Sales Associate'),
			('sales assoc', 'Sales Associate'),
			('sales asoc', 'Sales Associate'),
			('sale associate', 'Sales Associate'),
			('sales ass', 'Sales Associate'),
            ('sale asociate', 'Sales Associate'),
            ('Sales Asociate', 'Sales Associate'),

			-- Sales Consultant
			('sales consultant', 'Sales Consultant'),
			('sale consultan', 'Sales Consultant'),
			('sales comsultant', 'Sales Consultant'),
            ('sale Consultant', 'Sales Consultant'),

			-- Sales Advisor
			('sales advisor', 'Sales Advisor'),
			('sales avisor', 'Sales Advisor'),
			('sale advisor', 'Sales Advisor'),

			-- Sales Manager
			('sales manager', 'Sales Manager'),
			('sale manager', 'Sales Manager'),
			('sales manger', 'Sales Manager'),
			('sales managr', 'Sales Manager'),
			('sales mgr', 'Sales Manager'),
            ('Sales Mnager', 'Sales Manager'),

			-- Other possible dealership roles
			('internet sales', 'Internet Sales'),
			('internet sale', 'Internet Sales'),
			('general manager', 'General Manager'),
			('general manger', 'General Manager');

	-- 4) Create a temporary table to resolve 'employee_role':
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_role_resolution;
		CREATE TEMPORARY TABLE tmp_employee_role_resolution AS
		SELECT
			c.raw_row_id,
			c.employee_role AS employee_role_original,
			LOWER(c.employee_role) AS employee_role_normalized,
			r.clean_role_value AS employee_role_resolved
		FROM cds_cleaning_process c
		LEFT JOIN ref_employee_role r
			ON LOWER(c.employee_role) = LOWER(r.raw_role_value);

	-- 5) Update 'employee_role_cleaned' column:
		-- If the role exists in 'ref_employee_role', we use the official clean value.
		-- If it does not exist, 'employee_role_cleaned' will be NULL.
			UPDATE cds_cleaning_process c
			JOIN tmp_employee_role_resolution t
				ON c.raw_row_id = t.raw_row_id
			SET c.employee_role_cleaned = t.employee_role_resolved;

	-- 6) Mark rows with 'employee_role' quality issues:
		-- A row has a role issue when:
			-- The role could not be matched with 'ref_employee_role'.
			-- The original value is different from the official cleaned value.
				UPDATE cds_cleaning_process c
				JOIN tmp_employee_role_resolution t
					ON c.raw_row_id = t.raw_row_id
				SET c.values_to_data_quality_issues = CASE
					WHEN t.employee_role_resolved IS NULL THEN 1
					WHEN c.employee_role <> t.employee_role_resolved THEN 1
					ELSE NULL
				END;

	-- 7) Insert 'employee_role issues' into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'employee_role' AS name_column,
			c.employee_role AS original_value,

			CASE
				WHEN t.employee_role_resolved IS NULL
					THEN 'Unresolved "employee_role"'
				WHEN TRIM(c.employee_role) <> t.employee_role_resolved
					THEN '"employee_role" standardized using "ref_employee_role" table'
				ELSE '"employee_role" issue'
			END AS issue_type,

			CASE
				WHEN t.employee_role_resolved IS NULL
					THEN '"employee_role" could not be matched against "ref_employee_role" table and must be reviewed manually'
				WHEN TRIM(c.employee_role) <> t.employee_role_resolved
					THEN '"employee_role" was replaced with the official role value from "ref_employee_role" table'
				ELSE '"employee_role" reviewed'
			END AS action_taken,

			c.employee_role_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_employee_role_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'employee_role'
		  );

	-- 8) Check roles that still need manual review:
		SELECT
			c.employee_role,
			COUNT(*) AS role_count
		FROM cds_cleaning_process c
		WHERE c.employee_role_cleaned IS NULL
		GROUP BY c.employee_role
		ORDER BY role_count DESC;

	-- 9) Reset the temporary flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 10) Drop the temporary table:
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_role_resolution;

/*
==================================================================================================================
********************************************* EMPLOYEE_PHONE *****************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original 'employee_phone' unchanged.
		2) We will create/use 'employee_phone_cleaned' to store the standardized phone number.
		3) The expected phone format is: XXX-XXX-XXXX.
		4) To clean the value, we will:
		   - Remove all non-numeric characters.
		   - If the result has 10 digits, format it as XXX-XXX-XXXX.
		   - If the result has 11 digits and starts with 1, remove the leading 1 and format the remaining 10 digits.
		   - If the result does not have a valid number of digits, set 'employee_phone_cleaned' to NULL.
		5) We will register problematic rows in 'data_quality_issues' table.
		6) We will check duplicate phones carefully, but we will not delete rows automatically.
		   In a sales table, the same employee can appear many times, so repeated phone numbers are not always wrong.
*/

	-- 1) Create a temporary table to clean the phone number (REGEXP_REPLACE(employee_phone, '[^0-9]', '') removes everything that is not a number):
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_phone_resolution;
		CREATE TEMPORARY TABLE tmp_employee_phone_resolution AS
			SELECT
				c.raw_row_id,
				c.employee_phone AS employee_phone_original,
				REGEXP_REPLACE(TRIM(c.employee_phone), '[^0-9]', '') AS phone_digits,
				
				CASE
					-- Case 1: standard 10-digit US phone number:
					WHEN LENGTH(REGEXP_REPLACE(c.employee_phone, '[^0-9]', '')) = 10
						THEN CONCAT(
							SUBSTRING(REGEXP_REPLACE(c.employee_phone, '[^0-9]', ''), 1, 3),
							'-',
							SUBSTRING(REGEXP_REPLACE(c.employee_phone, '[^0-9]', ''), 4, 3),
							'-',
							SUBSTRING(REGEXP_REPLACE(c.employee_phone, '[^0-9]', ''), 7, 4)
					)
					
					-- Case 2: 11 digits starting with country code 1 (example: 15551234567 -> 555-123-4567):
					WHEN LENGTH(REGEXP_REPLACE(c.employee_phone, '[^0-9]', '')) = 11
						 AND LEFT(REGEXP_REPLACE(c.employee_phone, '[^0-9]', ''), 1) = '1'
							THEN CONCAT(
								SUBSTRING(REGEXP_REPLACE(c.employee_phone, '[^0-9]', ''), 2, 3),
								'-',
								SUBSTRING(REGEXP_REPLACE(c.employee_phone, '[^0-9]', ''), 5, 3),
								'-',
								SUBSTRING(REGEXP_REPLACE(c.employee_phone, '[^0-9]', ''), 8, 4)
							)

					-- Any other case is not reliable enough:
					ELSE NULL
				END AS employee_phone_resolved

			FROM cds_cleaning_process c;

	-- 2) Update 'employee_phone_cleaned' column:
		UPDATE cds_cleaning_process c
		JOIN tmp_employee_phone_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.employee_phone_cleaned = t.employee_phone_resolved;

	-- 3) Mark rows with 'employee_phone' quality issues:
		UPDATE cds_cleaning_process c
		JOIN tmp_employee_phone_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			WHEN t.employee_phone_resolved IS NULL THEN 1
			WHEN TRIM(c.employee_phone) <> t.employee_phone_resolved THEN 1
			ELSE NULL
		END;

	-- 4) Insert 'employee_phone' issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'employee_phone' AS name_column,
			c.employee_phone AS original_value,

			CASE
				WHEN t.employee_phone_resolved IS NULL
					THEN 'Invalid "employee_phone"'
				WHEN TRIM(c.employee_phone) <> t.employee_phone_resolved
					THEN '"employee_phone" standardized'
				ELSE '"employee_phone" issue'
			END AS issue_type,

			CASE
				WHEN t.employee_phone_resolved IS NULL
					THEN '"employee_phone" could not be converted to the expected format XXX-XXX-XXXX and must be reviewed manually'
				WHEN TRIM(c.employee_phone) <> t.employee_phone_resolved
					THEN '"employee_phone" was cleaned by removing non-numeric characters and formatting it as XXX-XXX-XXXX'
				ELSE '"employee_phone" reviewed'
			END AS action_taken,

			c.employee_phone_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_employee_phone_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'employee_phone'
		  );

	-- 5) Check duplicate cleaned phone numbers (in a transactional sales table, the same employee may appear in many rows. Therefore, repeated 'employee_phone_cleaned' values are not automatically wrong):
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_phone_duplicates;
		CREATE TEMPORARY TABLE tmp_employee_phone_duplicates AS
		SELECT
			employee_phone_cleaned,
			COUNT(DISTINCT employee_id_cleaned) AS different_employee_ids,
			COUNT(DISTINCT employee_name_cleaned) AS different_employee_names
		FROM cds_cleaning_process
		WHERE employee_phone_cleaned IS NOT NULL
		GROUP BY employee_phone_cleaned
		HAVING COUNT(DISTINCT employee_id_cleaned) > 1
			OR COUNT(DISTINCT employee_name_cleaned) > 1;

	-- 6) Insert duplicate phone issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'employee_phone' AS name_column,
			c.employee_phone AS original_value,
			'Duplicated "employee_phone" linked to different employees' AS issue_type,
			'The same cleaned "employee_phone" is linked to more than one employee. This must be reviewed manually before deleting or modifying rows' AS action_taken,
			c.employee_phone_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_employee_phone_duplicates d
			ON c.employee_phone_cleaned = d.employee_phone_cleaned

		WHERE NOT EXISTS (
			SELECT 1
			FROM data_quality_issues q
			WHERE q.raw_row_id = c.raw_row_id
			  AND q.name_column = 'employee_phone'
			  AND q.issue_type = 'Duplicated "employee_phone" linked to different employees'
		);

	-- 7) Check rows that still need manual review:
		SELECT
			c.raw_row_id,
			c.employee_id,
			c.employee_id_cleaned,
			c.employee_name,
			c.employee_name_cleaned,
			c.employee_phone,
			c.employee_phone_cleaned
		FROM cds_cleaning_process c
		WHERE c.employee_phone_cleaned IS NULL;
        
        -- 7.1) Identified one case that employee ID '1004' has NULL value instead of its correct phone number:
			UPDATE cds_cleaning_process
			SET employee_phone_cleaned = '555-999-1122'
			WHERE employee_id_cleaned = 1004;

	-- 8) Check suspicious duplicated phones (this helps us inspect duplicated cleaned phones before deciding any further action):
		SELECT
			c.employee_phone_cleaned,
			c.employee_id_cleaned,
			c.employee_name_cleaned,
			COUNT(*) AS row_count_phones
		FROM cds_cleaning_process c
		WHERE c.employee_phone_cleaned IN (
			SELECT employee_phone_cleaned
			FROM tmp_employee_phone_duplicates
		)
		GROUP BY
			c.employee_phone_cleaned,
			c.employee_id_cleaned,
			c.employee_name_cleaned
		ORDER BY
			c.employee_phone_cleaned,
			c.employee_id_cleaned;

	-- 9) Reset the temporary flag
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 10) Drop temporary tables:
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_phone_resolution;
		DROP TEMPORARY TABLE IF EXISTS tmp_employee_phone_duplicates;

/*
==================================================================================================================
************************************************ HIRE_DATE *******************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original 'hire_date' unchanged for traceability.
		2) We will store the cleaned date in 'hire_date_cleaned'.
		3) The final expected format is YYYY-MM-DD.
		4) We will try to convert different common date formats:
		   - YYYY-MM-DD
		   - YYYY/MM/DD
		   - DD-MM-YYYY
		   - DD/MM/YYYY
		   - MM-DD-YYYY
		   - MM/DD/YYYY
		5) Dates with impossible months or days will be set to NULL.
		6) Ambiguous dates such as 05-06-2020 will also be treated carefully.
		   This could mean:
		   - 5 June 2020
		   - 6 May 2020
		   Therefore, unless there is a clear business rule, it is safer to flag them for manual review.
		7) Problematic rows will be inserted into 'data_quality_issues' table.
*/

	-- 1) Create a temporary table to normalize and parse 'hire_date':
		DROP TEMPORARY TABLE IF EXISTS tmp_hire_date_resolution;
		CREATE TEMPORARY TABLE tmp_hire_date_resolution AS
		SELECT
			c.raw_row_id,
			c.hire_date AS hire_date_original,
			REPLACE(c.hire_date, '/', '-') AS hire_date_normalized,

			/*
				This column identifies the date format:
					- We separate the cases before converting the date because STR_TO_DATE() may return unexpected results if the format is wrong or ambiguous.
			*/
			CASE
				-- Format: YYYY-MM-DD
				WHEN REPLACE(c.hire_date, '/', '-') REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
					THEN 'YYYY-MM-DD'

				-- Format: DD-MM-YYYY
				-- If the first number is greater than 12, it cannot be a month.
				-- Therefore, it must be the day.
				WHEN REPLACE(c.hire_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 1, 2) AS UNSIGNED) > 12
					THEN 'DD-MM-YYYY'

				-- Format: MM-DD-YYYY
				-- If the first number is 12 or lower and the second number is greater than 12,
				-- then the first number is probably the month.
				WHEN REPLACE(c.hire_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 1, 2) AS UNSIGNED) <= 12
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 4, 2) AS UNSIGNED) > 12
					THEN 'MM-DD-YYYY'

				-- Ambiguous format:
				-- Example: 05-06-2020
				-- It could be 5 June or 6 May.
				WHEN REPLACE(c.hire_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 1, 2) AS UNSIGNED) BETWEEN 1 AND 12
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 4, 2) AS UNSIGNED) BETWEEN 1 AND 12
					THEN 'AMBIGUOUS'

				ELSE 'INVALID_FORMAT'
			END AS date_format_detected,

			/*
				This column attempts to convert the original value into a real DATE.
				The conversion is only applied when the format is clear.
				Ambiguous or invalid values are set to NULL.
			*/
			CASE
				/*
					Case 1: YYYY-MM-DD
					Example:
					2020-06-15 -> 2020-06-15
				*/
				WHEN REPLACE(c.hire_date, '/', '-') REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 6, 2) AS UNSIGNED) BETWEEN 1 AND 12
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 9, 2) AS UNSIGNED) BETWEEN 1 AND
						 DAY(LAST_DAY(CONCAT(
							 SUBSTRING(REPLACE(c.hire_date, '/', '-'), 1, 4),
							 '-',
							 SUBSTRING(REPLACE(c.hire_date, '/', '-'), 6, 2),
							 '-01'
						 )))
				THEN STR_TO_DATE(REPLACE(c.hire_date, '/', '-'), '%Y-%m-%d')
				/*
					Case 2: DD-MM-YYYY
					Example:
					25-06-2020 -> 2020-06-25
					This is considered high confidence only when the first number is greater than 12.
				*/
				WHEN REPLACE(c.hire_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 1, 2) AS UNSIGNED) > 12
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 4, 2) AS UNSIGNED) BETWEEN 1 AND 12
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 1, 2) AS UNSIGNED) BETWEEN 1 AND
						 DAY(LAST_DAY(CONCAT(
							 SUBSTRING(REPLACE(c.hire_date, '/', '-'), 7, 4),
							 '-',
							 SUBSTRING(REPLACE(c.hire_date, '/', '-'), 4, 2),
							 '-01'
						 )))
				THEN STR_TO_DATE(REPLACE(c.hire_date, '/', '-'), '%d-%m-%Y')
				/*
					Case 3: MM-DD-YYYY
					Example:
					06-25-2020 -> 2020-06-25
					This is considered high confidence only when the second number is greater than 12.
				*/
				WHEN REPLACE(c.hire_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 1, 2) AS UNSIGNED) BETWEEN 1 AND 12
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 4, 2) AS UNSIGNED) > 12
					 AND CAST(SUBSTRING(REPLACE(c.hire_date, '/', '-'), 4, 2) AS UNSIGNED) BETWEEN 1 AND
						 DAY(LAST_DAY(CONCAT(
							 SUBSTRING(REPLACE(c.hire_date, '/', '-'), 7, 4),
							 '-',
							 SUBSTRING(REPLACE(c.hire_date, '/', '-'), 1, 2),
							 '-01'
						 )))
				THEN STR_TO_DATE(REPLACE(c.hire_date, '/', '-'), '%m-%d-%Y')

				-- Invalid or ambiguous dates are not cleaned automatically:
				ELSE NULL
			END AS hire_date_resolved

		FROM cds_cleaning_process c;
        
	-- 2) Update 'hire_date_cleaned':
		UPDATE cds_cleaning_process c
		JOIN tmp_hire_date_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.hire_date_cleaned = t.hire_date_resolved;
        
	/*
	-- 3) Mark rows with 'hire_date' quality issues:
		A row has a quality issue when:
			- The date could not be converted.
			- The date format was ambiguous.
			- The original value is different from the cleaned date.
	*/
		UPDATE cds_cleaning_process c
		JOIN tmp_hire_date_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			-- Ambiguous dates should not be guessed:
			WHEN t.date_format_detected = 'AMBIGUOUS' THEN 1

			-- Invalid format or impossible date:
			WHEN t.hire_date_resolved IS NULL THEN 1

			-- The value was valid but required standardization:
			WHEN t.hire_date_normalized <> DATE_FORMAT(t.hire_date_resolved, '%Y-%m-%d') THEN 1

			ELSE NULL
		END;

	-- 4) Insert hire_date issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'hire_date' AS name_column,
			c.hire_date AS original_value,

			CASE
				WHEN t.date_format_detected = 'AMBIGUOUS'
					THEN 'Ambiguous "hire_date" format'
				WHEN t.date_format_detected = 'INVALID_FORMAT'
					THEN 'Invalid "hire_date" format'
				WHEN t.hire_date_resolved IS NULL
					THEN 'Invalid "hire_date" value'
				WHEN t.hire_date_normalized <> DATE_FORMAT(t.hire_date_resolved, '%Y-%m-%d')
					THEN '"hire_date" standardized'
				ELSE 'hire_date issue'
			END AS issue_type,

			CASE
				WHEN t.date_format_detected = 'AMBIGUOUS'
					THEN '"hire_date" could match DD-MM-YYYY or MM-DD-YYYY. It was not converted automatically and must be reviewed manually'
				WHEN t.date_format_detected = 'INVALID_FORMAT'
					THEN '"hire_date" does not match any accepted format and must be reviewed manually'
				WHEN t.hire_date_resolved IS NULL
					THEN '"hire_date" contains an impossible date, such as month 00, day 00, month greater than 12, or an invalid day for the month'
				WHEN t.hire_date_normalized <> DATE_FORMAT(t.hire_date_resolved, '%Y-%m-%d')
					THEN CONCAT('"hire_date" was converted from ', t.date_format_detected, ' to YYYY-MM-DD')
				ELSE '"hire_date" reviewed'
			END AS action_taken,

			-- cleaned_value is probably VARCHAR/TEXT in 'data_quality_issues' table, so DATE_FORMAT is used to store the cleaned date as readable text:
				DATE_FORMAT(c.hire_date_cleaned, '%Y-%m-%d') AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_hire_date_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'hire_date'
		  );

	-- 5) Check rows that still need manual review:
		SELECT
			c.raw_row_id,
			c.employee_id,
			c.employee_name,
			c.hire_date,
			c.hire_date_cleaned
		FROM cds_cleaning_process c
		WHERE c.hire_date_cleaned IS NULL;

	-- 6) Business validation (a hire date should normally not be in the future. If there are future dates, they should be reviewed manually):
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'hire_date' AS name_column,
			c.hire_date AS original_value,
			'Future "hire_date"' AS issue_type,
			'"hire_date_cleaned" is later than the current date and must be reviewed manually' AS action_taken,
			DATE_FORMAT(c.hire_date_cleaned, '%Y-%m-%d') AS cleaned_value
		FROM cds_cleaning_process c
		WHERE c.hire_date_cleaned > CURDATE()
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'hire_date'
				  AND d.issue_type = 'Future "hire_date"'
		  );

	-- 7) Reset the temporary flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 8) Drop the temporary table
		DROP TEMPORARY TABLE IF EXISTS tmp_hire_date_resolution;
        
/*
==================================================================================================================
**************************************************** VIN *********************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original VIN unchanged.
		2) We will store the cleaned value in 'vin_cleaned'.
		3) A valid VIN must:
		   - Have exactly 17 characters.
		   - Contain only numbers and capital letters.
		   - Not contain the letters I, O or Q, because they are not valid in VINs.
		4) We will convert lowercase letters to uppercase.
		5) Invalid VINs will be set to NULL in 'vin_cleaned'.
		6) Duplicate VINs will be logged in 'data_quality_issues' table, but rows will not be deleted automatically.
*/

	-- 1) Create a temporary table to validate and clean VIN:
		DROP TEMPORARY TABLE IF EXISTS tmp_vin_resolution;
		CREATE TEMPORARY TABLE tmp_vin_resolution AS
		SELECT
			c.raw_row_id,
			c.vin AS vin_original,
			UPPER(c.vin) AS vin_normalized,
			-- Cleaned VIN:
			-- If the VIN has 17 valid characters and does not contain I, O or Q, we keep it.
			-- Otherwise, we set it to NULL.
			CASE
				WHEN LENGTH(c.vin) = 17
					 AND UPPER(c.vin) REGEXP '^[A-HJ-NPR-Z0-9]{17}$'
				THEN UPPER(c.vin)
				ELSE NULL
			END AS vin_resolved
		FROM cds_cleaning_process c;

	-- 2) Update 'vin_cleaned':
		UPDATE cds_cleaning_process c
		JOIN tmp_vin_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.vin_cleaned = t.vin_resolved;

	-- 3) Mark rows with VIN quality issues:
		UPDATE cds_cleaning_process c
		JOIN tmp_vin_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			WHEN t.vin_resolved IS NULL THEN 1
			WHEN c.vin <> t.vin_resolved THEN 1
			ELSE NULL
		END;
        
	-- 4) Insert VIN issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'vin' AS name_column,
			c.vin AS original_value,

			CASE
				WHEN t.vin_resolved IS NULL AND LENGTH(c.vin) <> 17
					THEN 'Invalid VIN length'
				WHEN t.vin_resolved IS NULL
					THEN 'Invalid VIN characters'
				WHEN c.vin <> t.vin_resolved
					THEN 'VIN standardized'
				ELSE 'VIN issue'
			END AS issue_type,

			CASE
				WHEN t.vin_resolved IS NULL AND LENGTH(c.vin) <> 17
					THEN 'VIN must contain exactly 17 characters and must be reviewed manually'
				WHEN t.vin_resolved IS NULL
					THEN 'VIN contains invalid characters. VINs can include numbers and letters except I, O and Q'
				WHEN c.vin <> t.vin_resolved
					THEN 'VIN was converted to uppercase'
				ELSE 'VIN reviewed'
			END AS action_taken,

			c.vin_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_vin_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'vin'
		  );

	/*
	5) Check duplicated VINs:
		If VIN should uniquely identify one vehicle, duplicated VINs are suspicious.
		However, we do not delete rows automatically because a duplicate can have business explanations, for example a returned vehicle, a duplicated transaction, or a data-entry error.
	*/
		DROP TEMPORARY TABLE IF EXISTS tmp_vin_duplicates;
		CREATE TEMPORARY TABLE tmp_vin_duplicates AS
		SELECT
			vin_cleaned,
			COUNT(*) AS vin_count
		FROM cds_cleaning_process
		WHERE vin_cleaned IS NOT NULL
		GROUP BY vin_cleaned
		HAVING COUNT(*) > 1;

	-- 6) Insert duplicated VIN issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'vin' AS name_column,
			c.vin AS original_value,
			'Duplicated VIN' AS issue_type,
			'The same cleaned VIN appears more than once. Review manually before deleting or modifying rows' AS action_taken,
			c.vin_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_vin_duplicates d
			ON c.vin_cleaned = d.vin_cleaned

		WHERE NOT EXISTS (
			SELECT 1
			FROM data_quality_issues q
			WHERE q.raw_row_id = c.raw_row_id
			  AND q.name_column = 'vin'
			  AND q.issue_type = 'Duplicated VIN'
		);
        
	-- 7) Check VIN rows that need manual review:
		SELECT
			c.raw_row_id,
			c.vin,
			c.vin_cleaned
		FROM cds_cleaning_process c
		WHERE c.vin_cleaned IS NULL;

	-- 8) Reset temporary issue flag for VIN:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 9) Drop VIN temporary tables:
		DROP TEMPORARY TABLE IF EXISTS tmp_vin_resolution;
		DROP TEMPORARY TABLE IF EXISTS tmp_vin_duplicates;

/*
==================================================================================================================
******************************************** VEHICLE_BRAND *******************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original 'vehicle_brand' unchanged.
		2) We will store the cleaned brand in 'vehicle_brand_cleaned'.
		3) Instead of using a long CASE statement, we will create a reference/mapping table.
		4) The reference table allows us to map incorrect values such as:
		   - "Forrd" -> "Ford"
		   - "Toyta" -> "Toyota"
		   - "Jep" -> "Jeep"
		5) Values that cannot be matched will be set to NULL in 'vehicle_brand_cleaned'.
		6) Unresolved brands will be inserted into 'data_quality_issues' table for manual review.
*/

	-- 1) Check current distinct vehicle brand values:
		SELECT
			vehicle_brand,
			COUNT(*) AS brand_count
		FROM cds_cleaning_process
		GROUP BY vehicle_brand
        ORDER BY brand_count DESC;
        
	-- 2) Create a reference table for vehicle brands:
		DROP TABLE IF EXISTS ref_vehicle_brand;
		CREATE TABLE ref_vehicle_brand (
			raw_brand_value VARCHAR(100) PRIMARY KEY,
			clean_brand_value VARCHAR(100) NOT NULL
		) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

		/*
		Important:
		raw_brand_value is stored in lowercase to avoid duplicates such as: 'Ford' and 'ford'.
		Later, when we join this table with cds_cleaning_process, we will compare it using LOWER(vehicle_brand).
		*/

		INSERT INTO ref_vehicle_brand (
			raw_brand_value,
			clean_brand_value
		)
		VALUES
			-- Ford
			('ford', 'Ford'),
			('for', 'Ford'),
			('forrd', 'Ford'),
			('frod', 'Ford'),
			('foord', 'Ford'),
			-- Nissan
			('nissan', 'Nissan'),
			('nisan', 'Nissan'),
			('nisssan', 'Nissan'),
			-- Honda
			('honda', 'Honda'),
			('hnda', 'Honda'),
			('hond', 'Honda'),
			-- Chevrolet
			('chevrolet', 'Chevrolet'),
			('cheverolet', 'Chevrolet'),
			('chevy', 'Chevrolet'),
			('chev', 'Chevrolet'),
			('chevrole', 'Chevrolet'),
			-- Toyota
			('toyota', 'Toyota'),
			('toyta', 'Toyota'),
			('t0yota', 'Toyota'),
			-- Chrysler
			('chrysler', 'Chrysler'),
			('crysler', 'Chrysler'),
			('chrystler', 'Chrysler'),
			('chrysle', 'Chrysler'),
			-- Hyundai
			('hyundai', 'Hyundai'),
			('hyndai', 'Hyundai'),
			('hundai', 'Hyundai'),
			('hyunday', 'Hyundai'),
			('hyundia', 'Hyundai'),
			-- Jeep
			('jeep', 'Jeep'),
			('jep', 'Jeep'),
			('jepp', 'Jeep'),
			-- Kia
			('kia', 'Kia'),
			('kai', 'Kia'),
			-- Ram
			('ram', 'Ram'),
			('ran', 'Ram'),
			-- Tesla
			('tesla', 'Tesla'),
			('telsa', 'Tesla'),
			('lesta', 'Tesla'),
            -- BMW
            ('bmw', 'BMW'),
            ('bmv', 'BMW'),
            ('bnw', 'BMW'),
            ('vmw', 'BMW'),
            ('vmv', 'BMW'),
            -- Acura
            ('acura', 'Acura'),
            ('cura', 'Acura'),
            ('acra', 'Acura'),
            ('acur', 'Acura');

/*
	-- 4) Create a temporary table to resolve 'vehicle_brand':
		The first join looks for exact matches in 'ref_vehicle_brand' table.
		The CASE block is only used as a secondary fallback for pattern-based corrections.

		This keeps the process flexible:
			- Exact known errors are handled by 'ref_vehicle_brand'.
			- Common patterns can still be corrected when confidence is high.
*/

		DROP TEMPORARY TABLE IF EXISTS tmp_vehicle_brand_resolution;
		CREATE TEMPORARY TABLE tmp_vehicle_brand_resolution AS
		SELECT
			c.raw_row_id,
			c.vehicle_brand AS vehicle_brand_original,

			-- Brand resolved from the reference table or from high-confidence fallback rules.
			-- COALESCE returns the first non-NULL value.
			-- First, it tries to use 'ref_vehicle_brand'.
			-- If there is no match in 'ref_vehicle_brand', it applies fallback pattern rules.
			COALESCE(
				r.clean_brand_value,

				CASE
					WHEN LOWER(c.vehicle_brand) LIKE 'for%' OR LOWER(c.vehicle_brand) LIKE '%ord' THEN 'Ford'
					WHEN LOWER(c.vehicle_brand) LIKE 'nis%' OR LOWER(c.vehicle_brand) LIKE '%san' THEN 'Nissan'
					WHEN LOWER(c.vehicle_brand) LIKE 'hon%' OR LOWER(c.vehicle_brand) LIKE '%nda' THEN 'Honda'
					WHEN LOWER(c.vehicle_brand) LIKE 'che%' OR LOWER(c.vehicle_brand) LIKE '%olet' THEN 'Chevrolet'
					WHEN LOWER(c.vehicle_brand) LIKE 'to%'  OR LOWER(c.vehicle_brand) LIKE '%ota' THEN 'Toyota'
					WHEN LOWER(c.vehicle_brand) LIKE 'chr%' OR LOWER(c.vehicle_brand) LIKE '%sler' THEN 'Chrysler'
					WHEN LOWER(c.vehicle_brand) LIKE '%yun%'
						OR LOWER(c.vehicle_brand) LIKE '%iun%'
						OR LOWER(c.vehicle_brand) LIKE '%ium%'
						OR LOWER(c.vehicle_brand) LIKE '%dai'
						OR LOWER(c.vehicle_brand) LIKE '%day' 
					THEN 'Hyundai'
					WHEN LOWER(c.vehicle_brand) = 'jep' OR LOWER(c.vehicle_brand) LIKE '%eep' THEN 'Jeep'
					WHEN LOWER(c.vehicle_brand) = 'kai' THEN 'Kia'
					WHEN LOWER(c.vehicle_brand) = 'ran' THEN 'Ram'
					WHEN LOWER(c.vehicle_brand) = 'telsa' OR LOWER(c.vehicle_brand) = 'lesta' THEN 'Tesla'
					WHEN LOWER(c.vehicle_brand) IN ('bmv', 'bnw', 'vmw', 'vmv') THEN 'BMW'
					WHEN LOWER(c.vehicle_brand) IN ('cura', 'acra', 'acur') THEN 'Acura'
					ELSE NULL
				END
			) AS vehicle_brand_resolved,

			-- This column explains how the brand was matched.
			CASE
				WHEN r.clean_brand_value IS NOT NULL THEN 'Matched by ref_vehicle_brand'
				WHEN
					LOWER(c.vehicle_brand) LIKE 'for%' OR LOWER(c.vehicle_brand) LIKE '%ord'
					OR LOWER(c.vehicle_brand) LIKE 'nis%' 
					OR LOWER(c.vehicle_brand) LIKE '%san'
					OR LOWER(c.vehicle_brand) LIKE 'hon%' 
					OR LOWER(c.vehicle_brand) LIKE '%nda'
					OR LOWER(c.vehicle_brand) LIKE 'che%' 
					OR LOWER(c.vehicle_brand) LIKE '%olet'
					OR LOWER(c.vehicle_brand) LIKE 'to%'  
					OR LOWER(c.vehicle_brand) LIKE '%ota'
					OR LOWER(c.vehicle_brand) LIKE 'chr%' 
					OR LOWER(c.vehicle_brand) LIKE '%sler'
					OR LOWER(c.vehicle_brand) LIKE '%yun%'
					OR LOWER(c.vehicle_brand) LIKE '%iun%'
					OR LOWER(c.vehicle_brand) LIKE '%ium%'
					OR LOWER(c.vehicle_brand) LIKE '%dai'
					OR LOWER(c.vehicle_brand) LIKE '%day'
					OR LOWER(c.vehicle_brand) = 'jep'
					OR LOWER(c.vehicle_brand) LIKE '%eep'
					OR LOWER(c.vehicle_brand) = 'kai'
					OR LOWER(c.vehicle_brand) = 'ran'
					OR LOWER(c.vehicle_brand) IN ('telsa', 'lesta')
					OR LOWER(c.vehicle_brand) IN ('bmv', 'bnw', 'vmw', 'vmv')
					OR LOWER(c.vehicle_brand) IN ('cura', 'acra', 'acur')
				THEN 'Matched by fallback pattern'
				ELSE 'Not matched'
			END AS match_method

		FROM cds_cleaning_process c

		LEFT JOIN ref_vehicle_brand r
			ON LOWER(c.vehicle_brand) = r.raw_brand_value;

	-- 5) Update 'vehicle_brand_cleaned':
		UPDATE cds_cleaning_process c
		JOIN tmp_vehicle_brand_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.vehicle_brand_cleaned = t.vehicle_brand_resolved;

	-- 6) Mark rows with 'vehicle_brand' quality issues:
		UPDATE cds_cleaning_process c
		JOIN tmp_vehicle_brand_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			WHEN t.vehicle_brand_resolved IS NULL THEN 1
			WHEN c.vehicle_brand <> t.vehicle_brand_resolved THEN 1
			ELSE NULL
		END;

	-- 7) Insert vehicle_brand issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'vehicle_brand' AS name_column,
			c.vehicle_brand AS original_value,

			CASE
				WHEN t.vehicle_brand_resolved IS NULL
					THEN 'Unresolved "vehicle_brand"'
				WHEN c.vehicle_brand <> t.vehicle_brand_resolved
					THEN '"vehicle_brand" standardized'
				ELSE '"vehicle_brand" issue'
			END AS issue_type,

			CASE
				WHEN t.vehicle_brand_resolved IS NULL
					THEN '"vehicle_brand" could not be matched against "ref_vehicle_brand" table and must be reviewed manually'
				WHEN c.vehicle_brand <> t.vehicle_brand_resolved
					THEN CONCAT('"vehicle_brand" was standardized to the official brand name. Match method: ', t.match_method)
				ELSE '"vehicle_brand" reviewed'
			END AS action_taken,

			c.vehicle_brand_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_vehicle_brand_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'vehicle_brand'
		  );

	-- 8) Check vehicle brands that still need manual review:
		SELECT
			c.vehicle_brand,
			COUNT(*) AS brand_count
		FROM cds_cleaning_process c
		WHERE c.vehicle_brand_cleaned IS NULL
		GROUP BY c.vehicle_brand
		ORDER BY brand_count DESC;

	-- 9) Reset temporary issue flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 10) Drop temporary table:
		DROP TEMPORARY TABLE IF EXISTS tmp_vehicle_brand_resolution;

/*
==================================================================================================================
********************************************** VEHICLE_MODEL *****************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original 'vehicle_model' unchanged.
		2) We will store the cleaned model in 'vehicle_model_cleaned'.
		3) vehicle_model should be validated together with 'vehicle_brand_cleaned' when possible.
		   Example:
		   - Toyota Corolla is valid.
		   - Ford Corolla would be suspicious.
		4) We will create a reference table with known model misspellings.
		5) If the model cannot be resolved, 'vehicle_model_cleaned' will be NULL and the row will be sent to 'data_quality_issues' table.
*/

	-- 1) Check current distinct 'vehicle_model' values:
		SELECT
			vehicle_brand_cleaned,
			vehicle_model,
			COUNT(*) AS model_count
		FROM cds_cleaning_process
		GROUP BY
			vehicle_brand_cleaned,
			vehicle_model
		ORDER BY
			vehicle_brand_cleaned,
			vehicle_model;

	-- 2) Create a reference table for vehicle models:
		DROP TABLE IF EXISTS ref_vehicle_model;
		CREATE TABLE ref_vehicle_model (
			clean_brand_value VARCHAR(100) NOT NULL,
			raw_model_value VARCHAR(100) NOT NULL,
			clean_model_value VARCHAR(100) NOT NULL,
			PRIMARY KEY (clean_brand_value, raw_model_value)
		) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

	-- 3) Populate the reference table ('raw_model_value' is stored in lowercase because the JOIN will use LOWER(vehicle_model).This avoids duplicate issues such as 'Corolla' and 'corolla'):
		INSERT INTO ref_vehicle_model (
			clean_brand_value,
			raw_model_value,
			clean_model_value
		)
		VALUES
			('Ford', 'f-150', 'F-150'),
			('Ford', 'f150', 'F-150'),
			('Ford', 'f 150', 'F-150'),
			('Ford', 'f1500', 'F-150'),
            ('Ford', 'escape', 'Escape'),
            ('Ford', 'explorer', 'Explorer'),
            ('Ford', 'fusion', 'Fusion'),
            ('Ford', 'fuson', 'Fusion'),
            ('Ford', 'mustang', 'Mustang'),
            ('Ford', 'mustan', 'Mustang'),
			('Toyota', 'corolla', 'Corolla'),
			('Toyota', 'corola', 'Corolla'),
			('Toyota', 'coro', 'Corolla'),
            ('Toyota', 'camry', 'Camry'),
            ('Toyota', 'canry', 'Camry'),
            ('Toyota', 'rav4', 'RAV4'),
            ('Toyota', 'tacoma', 'Tacoma'),
			('Honda', 'civic', 'Civic'),
            ('Honda', 'civic lx', 'Civic LX'),
            ('Honda', 'lx', 'Civic LX'),
            ('Honda', 'cr-v', 'CR-V'),
            ('Honda', 'crv', 'CR-V'),
            ('Honda', 'accord', 'Accord'),
            ('Honda', 'acord', 'Accord'),
			('Nissan', 'altima', 'Altima'),
            ('Nissan', 'leaf', 'Leaf'),
            ('Nissan', 'rogue sport', 'Rogue Sport'),
            ('Nissan', 'sentra', 'Sentra'),
			('Chevrolet', 'silverado', 'Silverado'),
            ('Chevrolet', 'equinox', 'Equinox'),
            ('Chevrolet', 'malibu', 'Malibu'),
            ('Chevrolet', 'tahoe', 'Tahoe'),
			('Chrysler', 'pacifica', 'Pacifica'),
            ('Chrysler', '200', '200'),
            ('Chrysler', '300', '300'),
			('Hyundai', 'elantra', 'Elantra'),
            ('Hyundai', 'kona', 'Kona'),
            ('Hyundai', 'sonata', 'Sonata'),
            ('Hyundai', 'tucson', 'Tucson'),
			('Jeep', 'wrangler', 'Wrangler'),
            ('Jeep', 'cherokee', 'Cherokee'),
            ('Jeep', 'cheroke', 'Cherokee'),
            ('Jeep', 'grand cherokee', 'Grand Cherokee'),
            ('Jeep', 'grand cheroke', 'Grand Cherokee'),
			('Kia', 'sportage', 'Sportage'),
            ('Kia', 'optima', 'Optima'),
            ('Kia', 'sorento', 'Sorento'),
			('Ram', '1500', '1500'),
			('Tesla', 'model 3', 'Model 3'),
            ('Tesla', 'model y', 'Model Y'),
            ('Acura', 'ilx', 'ILX'),
            ('Acura', 'mdx', 'MDX'),
            ('BMW', '328i', '328i'),
            ('BMW', 'x3', 'X3');

	-- 4) Create a temporary table to resolve 'vehicle_model':
		-- We use 'vehicle_brand_cleaned' + 'vehicle_model' to find the correct model.
		-- This is safer than cleaning the model without considering the brand.
			DROP TEMPORARY TABLE IF EXISTS tmp_vehicle_model_resolution;
			CREATE TEMPORARY TABLE tmp_vehicle_model_resolution AS
			SELECT
				c.raw_row_id,
				c.vehicle_brand,
				c.vehicle_brand_cleaned,
				c.vehicle_model AS vehicle_model_original,
				LOWER(c.vehicle_model) AS vehicle_model_normalized,
				r.clean_model_value AS vehicle_model_resolved,
                
				-- This explains whether the model was found or not:
				CASE
					WHEN r.clean_model_value IS NOT NULL THEN 'Matched by ref_vehicle_model'
					ELSE 'Not matched'
				END AS match_method

			FROM cds_cleaning_process c
			LEFT JOIN ref_vehicle_model r
				ON c.vehicle_brand_cleaned = r.clean_brand_value
				AND LOWER(c.vehicle_model) = r.raw_model_value;

	-- 5) Update 'vehicle_model_cleaned':
		UPDATE cds_cleaning_process c
		JOIN tmp_vehicle_model_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.vehicle_model_cleaned = t.vehicle_model_resolved;

	-- 6) Mark rows with 'vehicle_model' quality issues:
		UPDATE cds_cleaning_process c
		JOIN tmp_vehicle_model_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			WHEN t.vehicle_model_resolved IS NULL THEN 1
			WHEN c.vehicle_model <> t.vehicle_model_resolved THEN 1
			ELSE NULL
		END;

	-- 7) Insert 'vehicle_model' issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'vehicle_model' AS name_column,
			c.vehicle_model AS original_value,

			CASE
				WHEN t.vehicle_model_resolved IS NULL
					THEN 'Unresolved "vehicle_model"'
				WHEN c.vehicle_model <> t.vehicle_model_resolved
					THEN '"vehicle_model" standardized'
				ELSE '"vehicle_model" issue'
			END AS issue_type,

			CASE
				WHEN t.vehicle_model_resolved IS NULL
					THEN '"vehicle_model" could not be matched against "ref_vehicle_model" table and must be reviewed manually'
				WHEN c.vehicle_model <> t.vehicle_model_resolved
					THEN CONCAT('"vehicle_model" was standardized using "ref_vehicle_model" table. Match method: ', t.match_method)
				ELSE '"vehicle_model" reviewed'
			END AS action_taken,

			c.vehicle_model_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_vehicle_model_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
			AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				AND d.name_column = 'vehicle_model'
			);

	-- 8) Check vehicle models that still need manual review:
		SELECT
			c.vehicle_brand_cleaned,
			c.vehicle_model,
			COUNT(*) AS model_count
		FROM cds_cleaning_process c
		WHERE c.vehicle_model_cleaned IS NULL
		GROUP BY
			c.vehicle_brand_cleaned,
			c.vehicle_model
		ORDER BY
			c.vehicle_brand_cleaned,
			model_count DESC;

	-- 9) Reset temporary issue flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 10) Drop temporary table:
		DROP TEMPORARY TABLE IF EXISTS tmp_vehicle_model_resolution;

/*
==================================================================================================================
*********************************************** VEHICLE_YEAR *****************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original 'vehicle_year' unchanged.
		2) We will store the cleaned year in 'vehicle_year_cleaned'.
		3) A valid vehicle year should:
		   - Have 4 digits.
		   - Be a realistic vehicle year.
		   - Not be in the future.
		4) In this dataset, the expected range seems to be 2013 to 2022.
		5) However, for a more flexible professional rule, we can allow values between 1980 and the current year.
		6) If this specific project only accepts cars between 2013 and 2022, use that stricter rule instead.
*/

	-- 1) Check current distinct 'vehicle_year' values:
		SELECT
			vehicle_year,
			COUNT(*) AS year_count
		FROM cds_cleaning_process
		GROUP BY 1
		ORDER BY 1;

	-- 2) Create a temporary table to validate 'vehicle_year':
		DROP TEMPORARY TABLE IF EXISTS tmp_vehicle_year_resolution;
		CREATE TEMPORARY TABLE tmp_vehicle_year_resolution AS
			SELECT
				c.raw_row_id,
				c.vehicle_year AS vehicle_year_original,
				
				-- Numeric version of the year, only when the value has 4 digits:
				CASE
					WHEN c.vehicle_year REGEXP '^[0-9]{4}$'
					THEN CAST(c.vehicle_year AS UNSIGNED)
					ELSE NULL
				END AS vehicle_year_numeric,

				-- Cleaned year using a flexible professional range:
				CASE
					WHEN c.vehicle_year REGEXP '^[0-9]{4}$'
						 AND CAST(c.vehicle_year AS UNSIGNED) BETWEEN 1980 AND YEAR(CURDATE())
					THEN CAST(c.vehicle_year AS UNSIGNED)
					ELSE NULL
				END AS vehicle_year_resolved,

				-- Optional stricter validation for this specific dataset:
				CASE
					WHEN c.vehicle_year REGEXP '^[0-9]{4}$'
						 AND CAST(c.vehicle_year AS UNSIGNED) BETWEEN 2013 AND 2022
					THEN 1

					ELSE 0
				END AS is_valid_project_range

			FROM cds_cleaning_process c;

	-- 3) Update 'vehicle_year_cleaned':
		UPDATE cds_cleaning_process c
		JOIN tmp_vehicle_year_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.vehicle_year_cleaned = t.vehicle_year_resolved;


/*
	4) Mark rows with 'vehicle_year' quality issues:
		A row has an issue when:
			- The year is not 4 digits.
			- The year is outside a realistic range.
			- The year is outside the expected project range of 2013 to 2022.
*/
		UPDATE cds_cleaning_process c
		JOIN tmp_vehicle_year_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			WHEN t.vehicle_year_resolved IS NULL THEN 1
			WHEN t.is_valid_project_range = 0 THEN 1
			ELSE NULL
		END;

	-- 5) Insert 'vehicle_year' issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'vehicle_year' AS name_column,
			c.vehicle_year AS original_value,

			CASE
				WHEN c.vehicle_year NOT REGEXP '^[0-9]{4}$'
					THEN 'Invalid "vehicle_year" format'
				WHEN t.vehicle_year_resolved IS NULL
					THEN 'Unrealistic "vehicle_year"'
				WHEN t.is_valid_project_range = 0
					THEN '"vehicle_year" outside expected project range'
				ELSE '"vehicle_year" issue'
			END AS issue_type,

			CASE
				WHEN c.vehicle_year NOT REGEXP '^[0-9]{4}$'
					THEN '"vehicle_year" must contain exactly 4 digits and must be reviewed manually'
				WHEN t.vehicle_year_resolved IS NULL
					THEN '"vehicle_year" is outside the realistic accepted range and must be reviewed manually'
				WHEN t.is_valid_project_range = 0
					THEN '"vehicle_year" is valid but outside the expected project range 2013-2022. Review whether it should be accepted'
				ELSE '"vehicle_year" reviewed'
			END AS action_taken,

			c.vehicle_year_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_vehicle_year_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
					AND d.name_column = 'vehicle_year'
		  );

	-- 6) Check vehicle years that still need manual review:
		SELECT
			c.vehicle_year,
			c.vehicle_year_cleaned,
			COUNT(*) AS year_count
		FROM cds_cleaning_process c
		WHERE c.vehicle_year_cleaned IS NULL
		   OR c.vehicle_year_cleaned NOT BETWEEN 2013 AND 2022
		GROUP BY
			c.vehicle_year,
			c.vehicle_year_cleaned
		ORDER BY
			c.vehicle_year;

	-- 7) Reset temporary issue flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 8) Drop temporary table
		DROP TEMPORARY TABLE IF EXISTS tmp_vehicle_year_resolution;

/*
==================================================================================================================
******************************************** VEHICLE_PRICE_USD ***************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original 'vehicle_price_usd' unchanged.
		2) We will store the cleaned value in 'vehicle_price_usd_cleaned'.
		3) Prices must be numeric and cannot be negative.
		4) Because the vehicles are from 2013-2022, we will use 8,000 USD as a minimum business threshold.
		5) We will remove common non-numeric characters such as '$' and ','.
		6) If the price cannot be converted to a valid number, it will be set to NULL.
		7) Problematic rows will be inserted into 'data_quality_issues' table.
*/

	-- 1) Create a temporary table to clean 'vehicle_price_usd':
		DROP TEMPORARY TABLE IF EXISTS tmp_vehicle_price_resolution;
		CREATE TEMPORARY TABLE tmp_vehicle_price_resolution AS
		SELECT
			c.raw_row_id,
			c.vehicle_price_usd AS vehicle_price_original,
			REGEXP_REPLACE(c.vehicle_price_usd, '[^0-9.-]', '') AS vehicle_price_numeric_text,
			-- Convert to DECIMAL only if the cleaned text has a valid numeric structure:
			CASE
				WHEN REGEXP_REPLACE(c.vehicle_price_usd, '[^0-9.-]', '') REGEXP '^-?[0-9]+(\\.[0-9]{1,2})?$'
				THEN CAST(REGEXP_REPLACE(c.vehicle_price_usd, '[^0-9.-]', '') AS DECIMAL(10,2))
				ELSE NULL
			END AS vehicle_price_numeric,
			-- Final cleaned price after applying business rules:
			CASE
				WHEN REGEXP_REPLACE(c.vehicle_price_usd, '[^0-9.-]', '') REGEXP '^-?[0-9]+(\\.[0-9]{1,2})?$'
					 AND CAST(REGEXP_REPLACE(c.vehicle_price_usd, '[^0-9.-]', '') AS DECIMAL(10,2)) >= 8000
				THEN CAST(REGEXP_REPLACE(c.vehicle_price_usd, '[^0-9.-]', '') AS DECIMAL(10,2))
				ELSE NULL
			END AS vehicle_price_resolved
		FROM cds_cleaning_process c;
        
	-- 2) Update 'vehicle_price_usd_cleaned':
		UPDATE cds_cleaning_process c
		JOIN tmp_vehicle_price_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.vehicle_price_usd_cleaned = t.vehicle_price_resolved;

/*
	3) Mark rows with 'vehicle_price_usd' quality issues:
    
		A row has an issue when:
			- The price cannot be converted to a number.
			- The price is negative.
			- The price is below the accepted business threshold.
			- The original value contained symbols and needed standardization.
*/
		UPDATE cds_cleaning_process c
		JOIN tmp_vehicle_price_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			-- Not a valid number:
			WHEN t.vehicle_price_numeric IS NULL THEN 1
			-- Negative price:
			WHEN t.vehicle_price_numeric < 0 THEN 1
			-- Unrealistically low price for this project:
			WHEN t.vehicle_price_numeric < 8000 THEN 1
			-- Valid price but original value had symbols such as $ or ,
			WHEN c.vehicle_price_usd <> CAST(t.vehicle_price_resolved AS CHAR) THEN 1
			ELSE NULL
		END;

	-- 4) Insert 'vehicle_price_usd' issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'vehicle_price_usd' AS name_column,
			c.vehicle_price_usd AS original_value,

			CASE
				WHEN t.vehicle_price_numeric IS NULL
					THEN 'Invalid "vehicle_price_usd" format'
				WHEN t.vehicle_price_numeric < 0
					THEN 'Negative "vehicle_price_usd"'
				WHEN t.vehicle_price_numeric < 8000
					THEN '"vehicle_price_usd" below minimum threshold'
				WHEN c.vehicle_price_usd <> CAST(t.vehicle_price_resolved AS CHAR)
					THEN '"vehicle_price_usd" standardized'
				ELSE '"vehicle_price_usd" issue'
			END AS issue_type,

			CASE
				WHEN t.vehicle_price_numeric IS NULL
					THEN '"vehicle_price_usd" could not be converted to a numeric value and must be reviewed manually'
				WHEN t.vehicle_price_numeric < 0
					THEN '"vehicle_price_usd" cannot be negative. It was replaced by NULL and must be reviewed manually'
				WHEN t.vehicle_price_numeric < 8000
					THEN '"vehicle_price_usd" is below the accepted minimum threshold of 8000 USD and must be reviewed manually'
				WHEN c.vehicle_price_usd <> CAST(t.vehicle_price_resolved AS CHAR)
					THEN '"vehicle_price_usd" was cleaned by removing non-numeric characters such as currency symbols or commas'
				ELSE '"vehicle_price_usd" reviewed'
			END AS action_taken,

			c.vehicle_price_usd_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_vehicle_price_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'vehicle_price_usd'
		  );

	-- 5) Check rows that still need manual review:
		SELECT
			c.raw_row_id,
			c.vehicle_brand_cleaned,
			c.vehicle_model_cleaned,
			c.vehicle_year_cleaned,
			c.vehicle_price_usd,
			c.vehicle_price_usd_cleaned
		FROM cds_cleaning_process c
		WHERE c.vehicle_price_usd_cleaned IS NULL;

/*
	6) Optional business validation:
		This helps you review very high prices.
		They may be valid, but they are worth checking.
		Adjust the threshold depending on your dataset.
*/
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'vehicle_price_usd' AS name_column,
			c.vehicle_price_usd AS original_value,
			'Potentially high "vehicle_price_usd"' AS issue_type,
			'"vehicle_price_usd_cleaned" is unusually high and should be reviewed as a potential outlier' AS action_taken,
			c.vehicle_price_usd_cleaned AS cleaned_value
		FROM cds_cleaning_process c
		WHERE c.vehicle_price_usd_cleaned > 150000
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
					AND d.name_column = 'vehicle_price_usd'
					AND d.issue_type = 'Potentially high "vehicle_price_usd"'
		  );

	-- 7) Reset temporary issue flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 8) Drop temporary table:
		DROP TEMPORARY TABLE IF EXISTS tmp_vehicle_price_resolution;

/*
==================================================================================================================
************************************************ SALE_DATE *******************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original 'sale_date' unchanged.
		2) We will store the cleaned date in 'sale_date_cleaned'.
		3) The final expected format is YYYY-MM-DD.
		4) We will accept and convert high-confidence formats:
		   - YYYY-MM-DD
		   - YYYY/MM/DD
		   - DD-MM-YYYY when the first number is greater than 12
		   - DD/MM/YYYY when the first number is greater than 12
		   - MM-DD-YYYY when the second number is greater than 12
		   - MM/DD/YYYY when the second number is greater than 12
		5) Ambiguous dates such as 05-06-2021 will not be guessed automatically.
		6) Invalid dates, impossible dates and ambiguous dates will be inserted into 'data_quality_issues' table.
*/

/*
	1) Create a temporary table to normalize and parse 'sale_date':
		REPLACE(sale_date, '/', '-') changes all separators to '-'.
		This makes the following logic easier because we only need to check one separator.
*/
		DROP TEMPORARY TABLE IF EXISTS tmp_sale_date_resolution;
		CREATE TEMPORARY TABLE tmp_sale_date_resolution AS
		SELECT
			c.raw_row_id,
			c.sale_date AS sale_date_original,
			REPLACE(c.sale_date, '/', '-') AS sale_date_normalized,
			/*
				Detect the date format before converting it.
				This is important because 05-06-2021 is ambiguous:
					- DD-MM-YYYY: 5 June 2021
					- MM-DD-YYYY: 6 May 2021
			*/
			CASE
				-- Format: YYYY-MM-DD
				WHEN REPLACE(c.sale_date, '/', '-') REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
					THEN 'YYYY-MM-DD'
                    
				-- Format: DD-MM-YYYY (First number greater than 12 means it cannot be a month):
				WHEN REPLACE(c.sale_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 1, 2) AS UNSIGNED) > 12
					THEN 'DD-MM-YYYY'

				-- Format: MM-DD-YYYY (Second number greater than 12 means it cannot be a month):
				WHEN REPLACE(c.sale_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 1, 2) AS UNSIGNED) BETWEEN 1 AND 12
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 4, 2) AS UNSIGNED) > 12
					THEN 'MM-DD-YYYY'

				-- Ambiguous date (Example: 05-06-2021):
				WHEN REPLACE(c.sale_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 1, 2) AS UNSIGNED) BETWEEN 1 AND 12
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 4, 2) AS UNSIGNED) BETWEEN 1 AND 12
					THEN 'AMBIGUOUS'

				ELSE 'INVALID_FORMAT'
			END AS date_format_detected,
            
			-- Convert 'sale_date' to a real DATE only when the format is reliable (Ambiguous and invalid dates are set to NULL):
			CASE
				-- Case 1: YYYY-MM-DD (2021-08-15 -> 2021-08-15):
				WHEN REPLACE(c.sale_date, '/', '-') REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 6, 2) AS UNSIGNED) BETWEEN 1 AND 12
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 9, 2) AS UNSIGNED) BETWEEN 1 AND
						 DAY(LAST_DAY(CONCAT(
							 SUBSTRING(REPLACE(c.sale_date, '/', '-'), 1, 4),
							 '-',
							 SUBSTRING(REPLACE(c.sale_date, '/', '-'), 6, 2),
							 '-01'
						 )))
				THEN STR_TO_DATE(REPLACE(c.sale_date, '/', '-'), '%Y-%m-%d')
                
				-- Case 2: DD-MM-YYYY (25-08-2021 -> 2021-08-25):
				WHEN REPLACE(c.sale_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 1, 2) AS UNSIGNED) > 12
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 4, 2) AS UNSIGNED) BETWEEN 1 AND 12
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 1, 2) AS UNSIGNED) BETWEEN 1 AND
						 DAY(LAST_DAY(CONCAT(
							 SUBSTRING(REPLACE(c.sale_date, '/', '-'), 7, 4),
							 '-',
							 SUBSTRING(REPLACE(c.sale_date, '/', '-'), 4, 2),
							 '-01'
						 )))
				THEN STR_TO_DATE(REPLACE(c.sale_date, '/', '-'), '%d-%m-%Y')

				-- Case 3: MM-DD-YYYY (08-25-2021 -> 2021-08-25; high confidence because second number is greater than 12):
				WHEN REPLACE(c.sale_date, '/', '-') REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 1, 2) AS UNSIGNED) BETWEEN 1 AND 12
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 4, 2) AS UNSIGNED) > 12
					 AND CAST(SUBSTRING(REPLACE(c.sale_date, '/', '-'), 4, 2) AS UNSIGNED) BETWEEN 1 AND
						 DAY(LAST_DAY(CONCAT(
							 SUBSTRING(REPLACE(c.sale_date, '/', '-'), 7, 4),
							 '-',
							 SUBSTRING(REPLACE(c.sale_date, '/', '-'), 1, 2),
							 '-01'
						 )))
				THEN STR_TO_DATE(REPLACE(c.sale_date, '/', '-'), '%m-%d-%Y')

				ELSE NULL
			END AS sale_date_resolved

		FROM cds_cleaning_process c;

	-- 2) Update 'sale_date_cleaned':
		UPDATE cds_cleaning_process c
		JOIN tmp_sale_date_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.sale_date_cleaned = t.sale_date_resolved;

/*
	3) Mark rows with 'sale_date' quality issues:
		A row has an issue when:
			- The date is ambiguous.
			- The date format is invalid.
			- The date value is impossible.
			- The value was valid but required standardization.
*/
		UPDATE cds_cleaning_process c
		JOIN tmp_sale_date_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			WHEN t.date_format_detected = 'AMBIGUOUS' THEN 1
			WHEN t.sale_date_resolved IS NULL THEN 1
			WHEN t.sale_date_normalized <> DATE_FORMAT(t.sale_date_resolved, '%Y-%m-%d') THEN 1
			ELSE NULL
		END;

	-- 4) Insert 'sale_date' column issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'sale_date' AS name_column,
			c.sale_date AS original_value,

			CASE
				WHEN t.date_format_detected = 'AMBIGUOUS'
					THEN 'Ambiguous "sale_date" format'
				WHEN t.date_format_detected = 'INVALID_FORMAT'
					THEN 'Invalid "sale_date" format'
				WHEN t.sale_date_resolved IS NULL
					THEN 'Invalid "sale_date" value'
				WHEN t.sale_date_normalized <> DATE_FORMAT(t.sale_date_resolved, '%Y-%m-%d')
					THEN '"sale_date" standardized'
				ELSE '"sale_date" issue'
			END AS issue_type,

			CASE
				WHEN t.date_format_detected = 'AMBIGUOUS'
					THEN '"sale_date" could match DD-MM-YYYY or MM-DD-YYYY. It was not converted automatically and must be reviewed manually'
				WHEN t.date_format_detected = 'INVALID_FORMAT'
					THEN '"sale_date" does not match any accepted format and must be reviewed manually'
				WHEN t.sale_date_resolved IS NULL
					THEN '"sale_date" contains an impossible date, such as month 00, day 00, month greater than 12, or an invalid day for the month'
				WHEN t.sale_date_normalized <> DATE_FORMAT(t.sale_date_resolved, '%Y-%m-%d')
					THEN CONCAT('"sale_date" was converted from ', t.date_format_detected, ' to YYYY-MM-DD')
				ELSE '"sale_date" reviewed'
			END AS action_taken,

			DATE_FORMAT(c.sale_date_cleaned, '%Y-%m-%d') AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_sale_date_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'sale_date'
		  );

	-- 5) Business validation: 'sale_date' cannot be in the future (A sale date after today is suspicious):
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'sale_date' AS name_column,
			c.sale_date AS original_value,
			'Future "sale_date"' AS issue_type,
			'"sale_date_cleaned" is later than the current date and must be reviewed manually' AS action_taken,
			DATE_FORMAT(c.sale_date_cleaned, '%Y-%m-%d') AS cleaned_value
		FROM cds_cleaning_process c
		WHERE c.sale_date_cleaned > CURDATE()
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'sale_date'
				  AND d.issue_type = 'Future "sale_date"'
		  );

/*
	6) Business validation: 'sale_date' should not be earlier than vehicle_year
		- If 'vehicle_year_cleaned' = 2020, the sale_date should normally not be before 2020-01-01.
        - This is a business rule, not only a date-format rule.
*/
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'sale_date' AS name_column,
			c.sale_date AS original_value,
			'"sale_date" earlier than "vehicle_year"' AS issue_type,
			'"sale_date_cleaned" is earlier than the vehicle year and must be reviewed manually' AS action_taken,
			DATE_FORMAT(c.sale_date_cleaned, '%Y-%m-%d') AS cleaned_value
		FROM cds_cleaning_process c
		WHERE c.sale_date_cleaned IS NOT NULL
		  AND c.vehicle_year_cleaned IS NOT NULL
		  AND YEAR(c.sale_date_cleaned) < c.vehicle_year_cleaned
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
					AND d.name_column = 'sale_date'
					AND d.issue_type = '"sale_date" earlier than "vehicle_year"'
		  );

	-- 8) Check rows that still need manual review:
		SELECT
			c.raw_row_id,
			c.vehicle_year,
			c.vehicle_year_cleaned,
			c.sale_date,
			c.sale_date_cleaned
		FROM cds_cleaning_process c
		WHERE c.sale_date_cleaned IS NULL;

	-- 9) Reset temporary issue flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 10) Drop temporary table:
		DROP TEMPORARY TABLE IF EXISTS tmp_sale_date_resolution;

/*
==================================================================================================================
************************************************ CUSTOMER_STATE **************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original 'customer_state' unchanged.
		2) We will store the cleaned state code in 'customer_state_cleaned'.
		3) The correct cleaned value is the US postal abbreviation, for example:
		   - California -> CA
		   - CA         -> CA
		4) We will use a reference table instead of a long CASE statement.
		5) Values that cannot be matched will be set to NULL and inserted into data_quality_issues.
		6) We avoid very broad patterns such as '%ska' because they can match more than one state:
		   - Alaska   -> AK
		   - Nebraska -> NE
*/

	-- 1) Create the official US states reference table:
		-- Drop the child alias table first, because it has a foreign key that references ref_us_states.
		DROP TABLE IF EXISTS ref_us_state_alias;
		DROP TABLE IF EXISTS ref_us_states;
		CREATE TABLE ref_us_states (
			us_state_code CHAR(2) PRIMARY KEY,
			us_state_name VARCHAR(50) NOT NULL
		) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

		INSERT INTO ref_us_states (us_state_code, us_state_name)
		VALUES
			('AL', 'Alabama'), ('AK', 'Alaska'), ('AZ', 'Arizona'), ('AR', 'Arkansas'),
			('CA', 'California'), ('CO', 'Colorado'), ('CT', 'Connecticut'), ('DE', 'Delaware'),
			('FL', 'Florida'), ('GA', 'Georgia'), ('HI', 'Hawaii'), ('ID', 'Idaho'),
			('IL', 'Illinois'), ('IN', 'Indiana'), ('IA', 'Iowa'), ('KS', 'Kansas'),
			('KY', 'Kentucky'), ('LA', 'Louisiana'), ('ME', 'Maine'), ('MD', 'Maryland'),
			('MA', 'Massachusetts'), ('MI', 'Michigan'), ('MN', 'Minnesota'), ('MS', 'Mississippi'),
			('MO', 'Missouri'), ('MT', 'Montana'), ('NE', 'Nebraska'), ('NV', 'Nevada'),
			('NH', 'New Hampshire'), ('NJ', 'New Jersey'), ('NM', 'New Mexico'), ('NY', 'New York'),
			('NC', 'North Carolina'), ('ND', 'North Dakota'), ('OH', 'Ohio'), ('OK', 'Oklahoma'),
			('OR', 'Oregon'), ('PA', 'Pennsylvania'), ('RI', 'Rhode Island'), ('SC', 'South Carolina'),
			('SD', 'South Dakota'), ('TN', 'Tennessee'), ('TX', 'Texas'), ('UT', 'Utah'),
			('VT', 'Vermont'), ('VA', 'Virginia'), ('WA', 'Washington'), ('WV', 'West Virginia'),
			('WI', 'Wisconsin'), ('WY', 'Wyoming'), ('DC', 'District of Columbia');

	-- 2) Create a state alias/mapping table:
		DROP TABLE IF EXISTS ref_us_state_alias;
		CREATE TABLE ref_us_state_alias (
			state_raw_value VARCHAR(100) PRIMARY KEY,
			state_clean_code CHAR(2) NOT NULL,

			CONSTRAINT fk_ref_us_state_alias_code
				FOREIGN KEY (state_clean_code)
				REFERENCES ref_us_states(us_state_code)
		) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

/*
	3) Populate the state alias table:
		We insert:
			- the 2-character code in lowercase
			- the full state name in lowercase
*/

		INSERT INTO ref_us_state_alias (state_raw_value, state_clean_code)
			VALUES
				('al', 'AL'), ('alabama', 'AL'),
				('ak', 'AK'), ('alaska', 'AK'),
				('az', 'AZ'), ('arizona', 'AZ'), ('airzona', 'AZ'),
				('ar', 'AR'), ('arkansas', 'AR'),
				('ca', 'CA'), ('california', 'CA'), ('alifornia', 'CA'),
				('co', 'CO'), ('colorado', 'CO'),
				('ct', 'CT'), ('connecticut', 'CT'),
				('de', 'DE'), ('delaware', 'DE'),
				('fl', 'FL'), ('florida', 'FL'), ('florid', 'FL'),
				('ga', 'GA'), ('georgia', 'GA'),
				('hi', 'HI'), ('hawaii', 'HI'),
				('id', 'ID'), ('idaho', 'ID'),
				('il', 'IL'), ('illinois', 'IL'),
				('in', 'IN'), ('indiana', 'IN'),
				('ia', 'IA'), ('iowa', 'IA'),
				('ks', 'KS'), ('kansas', 'KS'),
				('ky', 'KY'), ('kentucky', 'KY'),
				('la', 'LA'), ('louisiana', 'LA'),
				('me', 'ME'), ('maine', 'ME'),
				('md', 'MD'), ('maryland', 'MD'),
				('ma', 'MA'), ('massachusetts', 'MA'),
				('mi', 'MI'), ('michigan', 'MI'),
				('mn', 'MN'), ('minnesota', 'MN'),
				('ms', 'MS'), ('mississippi', 'MS'),
				('mo', 'MO'), ('missouri', 'MO'),
				('mt', 'MT'), ('montana', 'MT'),
				('ne', 'NE'), ('nebraska', 'NE'),
				('nv', 'NV'), ('nevada', 'NV'), ('neavda', 'NV'),
				('nh', 'NH'), ('new hampshire', 'NH'),
				('nj', 'NJ'), ('new jersey', 'NJ'),
				('nm', 'NM'), ('new mexico', 'NM'),
				('ny', 'NY'), ('new york', 'NY'), ('newyork', 'NY'),
				('nc', 'NC'), ('north carolina', 'NC'),
				('nd', 'ND'), ('north dakota', 'ND'),
				('oh', 'OH'), ('ohio', 'OH'),
				('ok', 'OK'), ('oklahoma', 'OK'),
				('or', 'OR'), ('oregon', 'OR'),
				('pa', 'PA'), ('pennsylvania', 'PA'),
				('ri', 'RI'), ('rhode island', 'RI'),
				('sc', 'SC'), ('south carolina', 'SC'),
				('sd', 'SD'), ('south dakota', 'SD'),
				('tn', 'TN'), ('tennessee', 'TN'),
				('tx', 'TX'), ('texas', 'TX'),
				('ut', 'UT'), ('utah', 'UT'),
				('vt', 'VT'), ('vermont', 'VT'),
				('va', 'VA'), ('virginia', 'VA'),
				('wa', 'WA'), ('washington', 'WA'),
				('wv', 'WV'), ('west virginia', 'WV'),
				('wi', 'WI'), ('wisconsin', 'WI'),
				('wy', 'WY'), ('wyoming', 'WY'),
				('dc', 'DC'), ('district of columbia', 'DC');

	-- 4) Check current distinct 'customer_state' values:
		SELECT
			customer_state,
			COUNT(*) AS state_count
		FROM cds_cleaning_process
		GROUP BY customer_state
		ORDER BY state_count DESC;

	-- 5) Create a temporary table to resolve 'customer_state':
		DROP TEMPORARY TABLE IF EXISTS tmp_customer_state_resolution;
		CREATE TEMPORARY TABLE tmp_customer_state_resolution AS
		SELECT
			c.raw_row_id,
			c.customer_state AS customer_state_original,
			LOWER(c.customer_state) AS customer_state_normalized,
			-- Cleaned 2-character state code:
			r.state_clean_code AS customer_state_resolved,
			-- Explains whether the value was found or not:
			CASE
				WHEN r.state_clean_code IS NOT NULL THEN 'Matched by "ref_us_state_alias" table'
				ELSE 'Not matched'
			END AS match_method
		FROM cds_cleaning_process c
		LEFT JOIN ref_us_state_alias r
			ON LOWER(c.customer_state) = r.state_raw_value;

	-- 6) Update 'customer_state_cleaned':
		UPDATE cds_cleaning_process c
		JOIN tmp_customer_state_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.customer_state_cleaned = t.customer_state_resolved;

	-- 7) Mark rows with 'customer_state' quality issues:
		UPDATE cds_cleaning_process c
		JOIN tmp_customer_state_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			WHEN t.customer_state_resolved IS NULL THEN 1
			WHEN UPPER(c.customer_state) <> t.customer_state_resolved THEN 1
			ELSE NULL
		END;

	-- 8) Insert 'customer_state' column issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'customer_state' AS name_column,
			c.customer_state AS original_value,

			CASE
				WHEN t.customer_state_resolved IS NULL
					THEN 'Unresolved "customer_state"'
				WHEN UPPER(c.customer_state) <> t.customer_state_resolved
					THEN '"customer_state" standardized'
				ELSE '"customer_state" issue'
			END AS issue_type,

			CASE
				WHEN t.customer_state_resolved IS NULL
					THEN '"customer_state" could not be matched against "ref_us_state_alias" table and must be reviewed manually'
				WHEN UPPER(c.customer_state) <> t.customer_state_resolved
					THEN CONCAT('"customer_state" was standardized to the official US postal abbreviation. Match method: ', t.match_method)
				ELSE '"customer_state" reviewed'
			END AS action_taken,

			c.customer_state_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_customer_state_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'customer_state'
		  );

	-- 9) Check 'customer_state' values that still need manual review:
		SELECT
			c.customer_state,
			COUNT(*) AS state_count
		FROM cds_cleaning_process c
		WHERE c.customer_state_cleaned IS NULL
		GROUP BY c.customer_state
		ORDER BY state_count DESC;

	-- 10) Reset temporary issue flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 11) Drop temporary table:
		DROP TEMPORARY TABLE IF EXISTS tmp_customer_state_resolution;

/*
==================================================================================================================
************************************************** SALE_STATUS ***************************************************
==================================================================================================================

	Cleaning logic:
		1) We will keep the original 'sale_status' unchanged.
		2) We will store the cleaned value in 'sale_status_cleaned'.
		3) The accepted sale statuses are:
		   - Pending
		   - In Progress
		   - In Transit
		   - Sold
		   - Delivered
		   - Cancelled
		   - Returned
		4) We will use a reference table instead of a long CASE statement.
		5) Values that cannot be matched will be set to NULL and inserted into 'data_quality_issues' table.
		6) We will not use ENUM at this stage of cleaning.
		   It is better to apply constraints later in the final clean table or dimension table.
*/

	-- 1) Create a sale status reference table:
		DROP TABLE IF EXISTS ref_sale_status;
		CREATE TABLE ref_sale_status (
			raw_status_value VARCHAR(100) PRIMARY KEY,
			clean_status_value VARCHAR(50) NOT NULL
		) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

	-- 2) Populate the sale status reference table:
		INSERT INTO ref_sale_status (
			raw_status_value,
			clean_status_value
		)
		VALUES
			-- Pending
			('pending', 'Pending'),
			('pend', 'Pending'),
			('panding', 'Pending'),
			-- In Progress
			('in progress', 'In Progress'),
			('progress', 'In Progress'),
			('in-progress', 'In Progress'),
			('in progres', 'In Progress'),
			-- In Transit
			('in transit', 'In Transit'),
			('transit', 'In Transit'),
			('in-transit', 'In Transit'),
			('in trans', 'In Transit'),
			-- Sold
			('sold', 'Sold'),
			('sol', 'Sold'),
			('sould', 'Sold'),
			-- Delivered
			('delivered', 'Delivered'),
			('deliverd', 'Delivered'),
			('delivery', 'Delivered'),
			('deli', 'Delivered'),
			-- Cancelled
			('cancelled', 'Cancelled'),
			('canceled', 'Cancelled'),
			('cancel', 'Cancelled'),
			('cancelled sale', 'Cancelled'),
			-- Returned
			('returned', 'Returned'),
			('return', 'Returned'),
			('retu', 'Returned');

	-- 3) Check current distinct 'sale_status' values:
		SELECT
			sale_status,
			COUNT(*) AS status_count
		FROM cds_cleaning_process
		GROUP BY sale_status
		ORDER BY status_count DESC;

	-- 4) Create a temporary table to resolve 'sale_status':
		DROP TEMPORARY TABLE IF EXISTS tmp_sale_status_resolution;
		CREATE TEMPORARY TABLE tmp_sale_status_resolution AS
		SELECT
			c.raw_row_id,
			c.sale_status AS sale_status_original,
			LOWER(c.sale_status) AS sale_status_normalized,
			COALESCE(
				r.clean_status_value,
				CASE
					WHEN LOWER(c.sale_status) LIKE '%pend%' THEN 'Pending'
					WHEN LOWER(c.sale_status) LIKE '%prog%' THEN 'In Progress'
					WHEN LOWER(c.sale_status) LIKE '%trans%' THEN 'In Transit'
					WHEN LOWER(c.sale_status) LIKE '%can%' THEN 'Cancelled'
					WHEN LOWER(c.sale_status) LIKE '%sol%' THEN 'Sold'
					WHEN LOWER(c.sale_status) LIKE '%deli%' THEN 'Delivered'
					WHEN LOWER(c.sale_status) LIKE '%retu%' THEN 'Returned'
					ELSE NULL
				END
			) AS sale_status_resolved,
			-- Explains how the match was made:
			CASE
				WHEN r.clean_status_value IS NOT NULL THEN 'Matched by ref_sale_status'
				WHEN LOWER(c.sale_status) LIKE '%pend%'
					OR LOWER(c.sale_status) LIKE '%prog%'
					OR LOWER(c.sale_status) LIKE '%trans%'
					OR LOWER(c.sale_status) LIKE '%can%'
					OR LOWER(c.sale_status) LIKE '%sol%'
					OR LOWER(c.sale_status) LIKE '%deli%'
					OR LOWER(c.sale_status) LIKE '%retu%'
				THEN 'Matched by fallback pattern'

				ELSE 'Not matched'
			END AS match_method

		FROM cds_cleaning_process c

		LEFT JOIN ref_sale_status r
			ON LOWER(c.sale_status) = r.raw_status_value;

	-- 5) Update 'sale_status_cleaned':
		UPDATE cds_cleaning_process c
		JOIN tmp_sale_status_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.sale_status_cleaned = t.sale_status_resolved;

/*
	6) Mark rows with 'sale_status' quality issues:
		A row has an issue when:
			- The status could not be matched.
			- The original value is different from the cleaned value.
*/
		UPDATE cds_cleaning_process c
		JOIN tmp_sale_status_resolution t
			ON c.raw_row_id = t.raw_row_id
		SET c.values_to_data_quality_issues = CASE
			WHEN t.sale_status_resolved IS NULL THEN 1
			WHEN c.sale_status <> t.sale_status_resolved THEN 1
			ELSE NULL
		END;

	-- 7) Insert 'sale_status' issues into 'data_quality_issues' table:
		INSERT INTO data_quality_issues (
			raw_row_id,
			name_column,
			original_value,
			issue_type,
			action_taken,
			cleaned_value
		)
		SELECT
			c.raw_row_id,
			'sale_status' AS name_column,
			c.sale_status AS original_value,

			CASE
				WHEN t.sale_status_resolved IS NULL
					THEN 'Unresolved "sale_status"'
				WHEN c.sale_status <> t.sale_status_resolved
					THEN '"sale_status" standardized'
				ELSE '"sale_status" issue'
			END AS issue_type,

			CASE
				WHEN t.sale_status_resolved IS NULL
					THEN '"sale_status" could not be matched against "ref_sale_status" table and must be reviewed manually'
				WHEN c.sale_status <> t.sale_status_resolved
					THEN CONCAT('"sale_status" was standardized to an official sales cycle status. Match method: ', t.match_method)
				ELSE '"sale_status" reviewed'
			END AS action_taken,

			c.sale_status_cleaned AS cleaned_value

		FROM cds_cleaning_process c
		JOIN tmp_sale_status_resolution t
			ON c.raw_row_id = t.raw_row_id

		WHERE c.values_to_data_quality_issues = 1
		  AND NOT EXISTS (
				SELECT 1
				FROM data_quality_issues d
				WHERE d.raw_row_id = c.raw_row_id
				  AND d.name_column = 'sale_status'
		  );

	-- 8) Business validation: review final status order/count:
		SELECT
			sale_status_cleaned,
			COUNT(*) AS status_count
		FROM cds_cleaning_process
		GROUP BY sale_status_cleaned
		ORDER BY status_count DESC;

	-- 9) Check 'sale_status' values that still need manual review:
		SELECT
			c.sale_status,
			COUNT(*) AS status_count
		FROM cds_cleaning_process c
		WHERE c.sale_status_cleaned IS NULL
		GROUP BY c.sale_status
		ORDER BY status_count DESC;

	-- 10) Reset temporary issue flag:
		UPDATE cds_cleaning_process
		SET values_to_data_quality_issues = NULL;

	-- 11) Drop temporary table:
		DROP TEMPORARY TABLE IF EXISTS tmp_sale_status_resolution;
