# Business Questions

## Project: Car Dealership Sales SQL Project

This document explains the business questions answered during the analysis phase of the project.

The analysis is based on the final star schema created from the cleaned car dealership sales dataset. The main analytical table is `fact_sales`, supported by the following dimension tables:

| Table                | Purpose                                |
| -------------------- | -------------------------------------- |
| `fact_sales`         | Stores sales records and measures      |
| `dim_dealer`         | Stores dealership information          |
| `dim_employee`       | Stores employee information            |
| `dim_vehicle`        | Stores vehicle information             |
| `dim_customer_state` | Stores US customer state information   |
| `dim_sale_status`    | Stores standardised sale status values |
| `dim_calendar`       | Stores date attributes                 |

---

## Business Rule Used in the Analysis

Only the following sale statuses are treated as completed sales:

| Sale Status | Completed Sale |
| ----------- | -------------: |
| `Sold`      |            `1` |
| `Delivered` |            `1` |

The following statuses are not treated as completed sales:

| Sale Status   | Business Interpretation                     |
| ------------- | ------------------------------------------- |
| `Cancelled`   | Sale was cancelled                          |
| `Pending`     | Sale has not yet been completed             |
| `In Progress` | Sale is still in process                    |
| `In Transit`  | Vehicle or sale process is still in transit |
| `Returned`    | Sale was completed but later returned       |
| `Unknown`     | Status is missing or unresolved             |

This distinction is important because revenue should not be considered confirmed unless the vehicle was sold or delivered.

---

# Business Question 1

## What are the total sales volume, revenue, and average sale price by year and by month?

### Objective

Understand how sales performance evolved.

This question helps identify whether the dealership network is growing, declining, or showing seasonal patterns.

### Metrics Used

| Metric                 | Definition                                                 |
| ---------------------- | ---------------------------------------------------------- |
| Completed sales volume | Number of `Sold` or `Delivered` records                    |
| Completed revenue      | Sum of `sale_amount_usd` for `Sold` or `Delivered` records |
| Average sale price     | Completed revenue divided by completed sales volume        |

### Main Dimensions Used

| Dimension         | Fields      |
| ----------------- | ----------- |
| `dim_calendar`    | Year, month |
| `dim_sale_status` | Sale status |

### Business Value

This analysis helps answer:

* Is completed revenue increasing over time?
* Are completed sales increasing or decreasing?
* Are some years or months stronger than others?
* Is the business growing because of higher volume, higher prices, or both?

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_1.png" height="450"></p>

### Insight Summary

The analysis shows a positive commercial trend over the analysed years, with completed revenue and completed sales volume increasing over time.

---

# Business Question 2

## Which brands and models generate the highest revenue, the most units sold, and the highest average sale price?

### Objective

Identify the strongest-performing vehicle brands and models from different commercial perspectives.

This question separates three different ideas:

1. Highest revenue
2. Highest sales volume
3. Highest average sale price

A model can perform well in one category but not necessarily in all of them.

---

## 2.1 Revenue by Brand and Model

### Metrics Used

| Metric            | Definition                                   |
| ----------------- | -------------------------------------------- |
| Completed revenue | Sum of `sale_amount_usd` for completed sales |

### Business Value

This analysis identifies which vehicle models contribute most to total revenue.

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_2_1.png" height="450"></p>

### Insight Summary

The Chevrolet Tahoe stood out as one of the strongest models by completed revenue.

This suggests that large SUVs may represent an important revenue driver for the dealership network.

---

## 2.2 Units Sold by Brand and Model

### Metrics Used

| Metric               | Definition                        |
| -------------------- | --------------------------------- |
| Completed units sold | Number of completed sales records |

### Business Value

This analysis identifies which models are strongest in terms of volume.

High sales volume may indicate strong demand, better affordability, stronger availability, or broader customer appeal.

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_2_2.png" height="450"></p>

### Insight Summary

Honda and Ford showed strong sales volume performance.

This suggests that these brands may play an important role in driving dealership activity and customer traffic.

---

## 2.3 Average Sale Price by Brand and Model

### Metrics Used

| Metric             | Definition                                        |
| ------------------ | ------------------------------------------------- |
| Average sale price | Completed revenue divided by completed units sold |

### Business Value

This analysis identifies higher-ticket brands and models.

A high average sale price does not always mean a model is the highest contributor to total revenue, but it can indicate stronger premium positioning.

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_2_3.png" height="450"></p>

### Insight Summary

Tesla and Chevrolet stood out in terms of higher average sale price.

This suggests that some models may contribute more through price premium, while others contribute more through volume.

---

## Combined Product Insight

The analysis shows that different brands and models contribute to performance in different ways:

| Performance Area   | Stronger Examples          |
| ------------------ | -------------------------- |
| Revenue            | Chevrolet Tahoe            |
| Sales volume       | Honda and Ford models      |
| Average sale price | Tesla and Chevrolet models |

This demonstrates why product performance should be evaluated using several KPIs together instead of only ranking by revenue.

---

# Business Question 3

## Which US states account for the highest sales volume and revenue, and how does the ranking change when analysing units sold versus revenue?

### Objective

Understand geographic sales performance across US states.

This question helps identify where the dealership network generates the most activity and revenue.

### Metrics Used

| Metric               | Definition                                   |
| -------------------- | -------------------------------------------- |
| Completed units sold | Number of completed sales records            |
| Completed revenue    | Sum of completed sale amounts                |
| Average sale price   | Completed revenue divided by completed sales |

### Main Dimensions Used

| Dimension            | Fields                 |
| -------------------- | ---------------------- |
| `dim_customer_state` | State code, state name |
| `dim_sale_status`    | Sale status            |

### Business Value

This analysis helps answer:

* Which states generate the most completed sales?
* Which states generate the most completed revenue?
* Do high-volume states also generate high revenue?
* Are some states stronger because of higher average sale prices?

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_3.png" height="450"></p>

### Insight Summary

The top-performing states were also among the most populated US states, which is consistent with larger market potential.

However, population should not be treated as the only explanation. Dealership coverage, inventory availability, local demand, customer purchasing power and marketing activity can also influence performance.

---

# Business Question 4

## Which dealerships perform best in terms of revenue, units sold, average revenue per completed sale, and completed sales rate?

### Objective

Evaluate dealership performance using several KPIs instead of relying on a single ranking.

### Metrics Used

| Metric                             | Definition                                      |
| ---------------------------------- | ----------------------------------------------- |
| Completed sales                    | Number of `Sold` or `Delivered` records         |
| Completed revenue                  | Sum of completed sales amount                   |
| Average revenue per completed sale | Completed revenue divided by completed sales    |
| Total sales records                | All sales-related records, regardless of status |
| Completed sales rate               | Completed sales divided by total sales records  |

### Main Dimensions Used

| Dimension         | Fields      |
| ----------------- | ----------- |
| `dim_dealer`      | Dealer ID   |
| `dim_sale_status` | Sale status |

### Business Value

This analysis helps distinguish between:

* Dealerships with high total revenue
* Dealerships with high sales volume
* Dealerships with high average ticket size
* Dealerships with better conversion from total records to completed sales

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_4.png" height="450"></p>

### Insight Summary

Dealership 15 was the strongest overall performer in completed revenue and completed sales volume.

Dealership 6 showed the strongest completed sales rate, while dealership 14 achieved the highest average revenue per completed sale.

This demonstrates why dealership performance should be evaluated using several KPIs together.

A dealership with the highest revenue is not always the dealership with the best conversion rate or the highest average transaction value.

---

# Business Question 5

## Which employees generate the highest revenue and sales volume, and how do they compare within their own dealership?

### Objective

Analyse employee sales performance both overall and within each dealership.

This helps identify top performers and possible concentration risks.

### Metrics Used

| Metric                               | Definition                                                         |
| ------------------------------------ | ------------------------------------------------------------------ |
| Completed sales                      | Number of completed sales records                                  |
| Completed revenue                    | Sum of completed sale amounts                                      |
| Employee revenue share within dealer | Employee completed revenue divided by dealership completed revenue |
| Employee sales share within dealer   | Employee completed sales divided by dealership completed sales     |

### Main Dimensions Used

| Dimension         | Fields              |
| ----------------- | ------------------- |
| `dim_employee`    | Employee name       |
| `dim_dealer`      | Dealer ID           |
| `dim_sale_status` | Sale status         |

### Business Value

This analysis helps answer:

* Who are the top-performing salespeople?
* Is sales performance concentrated in a small number of employees?
* Are some dealerships too dependent on one employee?

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_5.png" height="450"></p>

### Insight Summary

Mary Campbell was the strongest salesperson in absolute completed revenue and sales volume.

However, employee analysis also revealed concentration patterns within some dealerships, where one employee generated a much larger share of revenue or sales than another.

This can indicate top-performer impact, but also a potential dependency risk.

Employee performance should be interpreted carefully. Factors such as seniority, assigned leads, working hours, product specialisation, customer traffic and sales opportunities should be considered before drawing operational conclusions.

---

# Business Question 6

## What is the rate of completed, cancelled, or pending sales by dealership, state, brand, and salesperson?

### Objective

Analyse the distribution of sale statuses across different business dimensions.

This helps identify areas with strong conversion performance and areas with higher cancellation, pending, returned or unresolved rates.

### Metrics Used

| Metric                       | Definition                                                   |
| ---------------------------- | ------------------------------------------------------------ |
| Total records                | All sales-related records                                    |
| Completed records            | Records with `Sold` or `Delivered` status                    |
| Cancelled records            | Records with `Cancelled` status                              |
| Pending / in-process records | Records with `Pending`, `In Progress` or `In Transit` status |
| Returned records             | Records with `Returned` status                               |
| Completed sales rate         | Completed records divided by total records                   |

### Main Dimensions Used

| Dimension            | Fields      |
| -------------------- | ----------- |
| `dim_dealer`         | Dealer ID   |
| `dim_customer_state` | State       |
| `dim_vehicle`        | Brand       |
| `dim_employee`       | Salesperson |
| `dim_sale_status`    | Sale status |

### Business Value

This analysis helps answer:

* Which groups convert more sales successfully?
* Are some dealerships or states more affected by cancellations?
* Are some brands more likely to remain pending or in transit?
* Are some salespeople associated with stronger completion rates?

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_6.png" height="450"></p>

### Insight Summary

The analysis identified specific combinations of dealership, state, brand and salesperson with strong completed sales rates.

For example, one dealership-state-brand-salesperson combination achieved a high completed sales rate, suggesting strong conversion performance for that specific segment.

However, these results should always be interpreted together with the total number of records in the group. A high percentage based on a small number of records may not be enough to support a strong business conclusion.

---

# Business Question 7

## Are there any relevant time-based sales patterns, such as months with higher demand, seasonality, or unusual drops?

### Objective

Identify monthly performance trends and possible seasonality.

### Metrics Used

| Metric                               | Definition                                              |
| ------------------------------------ | ------------------------------------------------------- |
| Completed sales volume               | Number of completed sales                               |
| Completed revenue                    | Sum of completed sales amount                           |
| Previous month sales volume          | Sales volume from the previous month                    |
| Sales volume month-over-month change | Current month sales volume compared with previous month |
| Previous month revenue               | Revenue from the previous month                         |
| Revenue month-over-month change      | Current month revenue compared with previous month      |

### Main Dimensions Used

| Dimension         | Fields      |
| ----------------- | ----------- |
| `dim_calendar`    | Year, month |
| `dim_sale_status` | Sale status |

### SQL Concepts Used

| Concept          | Purpose                                               |
| ---------------- | ----------------------------------------------------- |
| `LAG()`          | Compare current month performance with previous month |
| Window functions | Calculate month-over-month changes                    |
| `NULLIF()`       | Avoid division by zero                                |

### Business Value

This analysis helps answer:

* Which months perform better?
* Are there signs of seasonality?
* Are there unusual drops in revenue or volume?
* Are stronger months caused by higher volume or higher average sale prices?

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_7.png" height="450"></p>

### Insight Summary

Spring and fall appeared to be stronger sales periods, while winter showed weaker performance.

This may indicate a seasonal sales pattern, which is common in vehicle sales due to consumer behaviour, weather conditions, promotional campaigns, tax periods or dealership stock cycles.

A longer historical dataset would be needed to confirm whether this is a stable seasonal pattern.

---

# Business Question 8

## Which combination of brand, model, vehicle year, and US state generates the highest revenue or the best business opportunities?

### Objective

Identify the most valuable product-geography combinations.

This question looks beyond individual brands or states and combines several dimensions to identify specific commercial opportunities.

### Metrics Used

| Metric               | Definition                                        |
| -------------------- | ------------------------------------------------- |
| Completed units sold | Number of completed sales                         |
| Completed revenue    | Sum of completed sale amounts                     |
| Average sale price   | Completed revenue divided by completed units sold |

### Main Dimensions Used

| Dimension            | Fields                     |
| -------------------- | -------------------------- |
| `dim_vehicle`        | Brand, model, vehicle year |
| `dim_customer_state` | State                      |
| `dim_sale_status`    | Sale status                |

### Business Value

This analysis helps support:

* Inventory planning
* Local marketing campaigns
* Dealership stock allocation
* Product mix decisions
* Regional sales strategy

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_8.png" height="450"></p>

### Insight Summary

The 2020 Tesla Model Y and the 2020 Ford F-150 were among the combinations that generated the highest completed sales revenue.

These combinations can be considered strong business opportunities within the dataset.

The Tesla Model Y likely represents a higher-ticket electric vehicle opportunity, while the Ford F-150 may reflect strong demand for pickup trucks in the US market.

Before making business decisions, revenue should also be compared with margin, stock availability, cancellation rates, return rates and local demand.

---

# Business Question 9

## Are there significant differences between newer and older vehicles in terms of sales volume, revenue generated, and average price?

### Objective

Compare vehicle age categories to understand how older and newer vehicles contribute differently to the business.

### Vehicle Categories Used

| Category       | Vehicle Years                      |
| -------------- | ---------------------------------- |
| Older vehicles | 2013 to 2018                       |
| Newer vehicles | 2019 to 2022                       |
| Unknown        | Missing or unresolved vehicle year |

### Metrics Used

| Metric                  | Definition                                          |
| ----------------------- | --------------------------------------------------- |
| Completed sales volume  | Number of completed sales                           |
| Completed sales share   | Category sales divided by total completed sales     |
| Completed revenue       | Sum of completed sale amounts                       |
| Completed revenue share | Category revenue divided by total completed revenue |
| Average sale price      | Completed revenue divided by completed sales        |

### Main Dimensions Used

| Dimension         | Fields       |
| ----------------- | ------------ |
| `dim_vehicle`     | Vehicle year |
| `dim_sale_status` | Sale status  |

### Business Value

This analysis helps answer:

* Do older vehicles generate more unit sales?
* Do newer vehicles generate more revenue?
* How much does vehicle age affect average sale price?
* Should inventory strategy prioritise affordability, revenue, or a balanced mix?

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_9.png" height="450"></p>

### Insight Summary

Older vehicles represented slightly more completed sales volume, with around 49% of sales, compared with approximately 47% for newer vehicles.

However, newer vehicles generated significantly more completed revenue, accounting for around 56%, compared with approximately 40% for older vehicles.

This indicates that older vehicles may drive more volume because they are usually more affordable, while newer vehicles generate more revenue because of their higher average sale price.

The `Unknown` category should be monitored because it limits the reliability of vehicle age analysis.

---

# Business Question 10

## Which records, dimensions, or combinations show potential analytical red flags?

### Objective

Identify areas that require further business or data quality investigation.

This section is not only about finding “bad performance”. It is about detecting signals that deserve deeper analysis.

The script analyses four types of red flags:

1. Employees with low sales share within their dealership
2. Low-performing dealerships
3. US states with few transactions
4. Sale price outliers

---

## 10.1 Employees with Low Sales Share Within Their Dealership

### Objective

Detect uneven sales distribution between employees within the same dealership.

### Metrics Used

| Metric                             | Definition                                                                  |
| ---------------------------------- | --------------------------------------------------------------------------- |
| Employee completed sales           | Completed sales generated by each employee                                  |
| Employee sales share within dealer | Employee completed sales divided by total completed sales of the dealership |

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_10_1.png" height="450"></p>

### Insight Summary

Dealership 11 had the largest difference between employees.

Betty Green accounted for 71% of that dealership's completed sales volume, while Jason Scott accounted for 29%.

This may indicate a relevant performance gap, but it should not be interpreted as an employee issue without additional context.

Possible explanations include:

* Seniority
* Assigned leads
* Working hours
* Product specialisation
* Customer traffic
* Sales opportunities
* Dealership staffing structure

---

## 10.2 Low-Performing Dealerships

### Objective

Identify dealerships with low contribution to total completed sales or low completed sales rate.

### Metrics Used

| Metric                       | Definition                                                  |
| ---------------------------- | ----------------------------------------------------------- |
| Completed sales              | Number of completed sales                                   |
| Completed revenue            | Sum of completed sale amounts                               |
| Total sales records          | All sales-related records                                   |
| Completed sales rate         | Completed sales divided by total records                    |
| Completed sales market share | Dealership completed sales divided by total completed sales |

### Thresholds Used

Dealerships are flagged when:

| Condition                                |
| ---------------------------------------- |
| Completed sales rate is below 50%        |
| Completed sales market share is below 5% |

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_10_2.png" height="450"></p>

### Insight Summary

Dealerships 3, 11, 13 and 7 had less than 5% of the total completed sales performance.

These dealerships can be flagged for further analysis because their contribution to total sales volume was relatively low.

However, low market share does not automatically mean poor performance. It may also be explained by:

* Smaller market size
* Fewer employees
* Lower inventory
* Weaker local demand
* Limited dealership coverage
* Different dealership capacity

To assess true performance, sales share should be compared with completed sales rate, revenue, average ticket size, dealership capacity and local market potential.

---

## 10.3 US States with Few Transactions

### Objective

Identify states with low completed sales activity.

### Metrics Used

| Metric                | Definition                                             |
| --------------------- | ------------------------------------------------------ |
| Completed sales       | Number of completed sales by state                     |
| Completed sales share | State completed sales divided by total completed sales |

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_10_3.png" height="450"></p>

### Insight Summary

Utah, Alabama and South Carolina were the states with the fewest completed sales according to the analysis.

States with few transactions may represent:

* Low market penetration
* Limited dealership presence
* Lower local demand
* Limited inventory coverage
* Data availability issues

These states should be reviewed before deciding whether they represent poor commercial performance or simply limited market exposure.

---

## 10.4 Sale Price Outliers

### Objective

Identify vehicle sale prices that are unusually far from the average price for the same brand and model.

### Metrics Used

| Metric                      | Definition                                                               |
| --------------------------- | ------------------------------------------------------------------------ |
| Average model price         | Average completed sale price for each brand-model combination            |
| Standard deviation by model | Price variability for each brand-model combination                       |
| Price outlier               | Sale price more than two standard deviations away from the model average |

### SQL Concepts Used

| Concept        | Purpose                           |
| -------------- | --------------------------------- |
| `AVG()`        | Calculate average model price     |
| `STDDEV()`     | Calculate price variability       |
| `ABS()`        | Measure distance from the average |
| `2 * STDDEV()` | Define outlier threshold          |

### Result (screenshot)

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/sql_project-car_dealership_sales/images/business_questions_screenshots/question_10_4.png" height="450"></p>

### Insight Summary

Hyundai Elantra was the model with the highest standard deviation in sale price, indicating greater price variability compared with the rest of the portfolio.

Chrysler 200 was the model with the lowest standard deviation in sale price, suggesting more consistent sales prices within the dataset.

High price variability may be caused by:

* Vehicle year
* Trim level
* Mileage
* Vehicle condition
* Discounts
* Financing conditions
* Data quality issues

Price outliers should not be removed automatically because they may represent valid business cases, such as premium configurations or exceptional discounts.

---

# Final Business Conclusions

## 1. Overall Sales Trend

The dealership business showed a positive commercial trend over the analysed years, with completed revenue and completed sales volume increasing over time.

This suggests that the dealership network performed better commercially in later periods of the dataset.

---

## 2. Product Performance

Different brands and models contribute to performance in different ways.

Chevrolet Tahoe stood out as one of the strongest overall models because it performed well in both revenue and sales volume.

Honda and Ford showed strong sales volume, while Tesla and Chevrolet stood out in terms of higher average sale price.

This means that product strategy should not be based on one metric only. Some models are important for volume, while others are important for revenue or premium positioning.

---

## 3. Geographic Performance

The top-performing states were also among the most populated US states, which is consistent with larger market potential.

However, population alone should not be treated as the only explanation.

Other relevant factors include:

* Dealership coverage
* Inventory availability
* Local demand
* Customer purchasing power
* Regional marketing activity
* Competition

---

## 4. Dealership Performance

Dealership 15 was the strongest overall performer in completed revenue and completed sales volume.

Dealership 6 showed the strongest completed sales rate, while dealership 14 achieved the highest average revenue per completed sale.

This demonstrates that dealership performance should be evaluated using several KPIs together instead of relying on a single ranking.

---

## 5. Employee Performance

Mary Campbell was the strongest salesperson in absolute completed revenue and sales volume.

However, the analysis also revealed concentration patterns within some dealerships, where one employee generated a much larger share of revenue or sales than another.

This may indicate top-performer impact, but also potential dependency risk.

---

## 6. Time-Based Patterns

Spring and fall appeared to be stronger sales periods, while winter showed weaker performance.

This suggests possible seasonality, although a longer historical dataset would be needed to confirm a stable seasonal pattern.

---

## 7. Vehicle Age

Older vehicles generated slightly more sales volume, while newer vehicles generated significantly more revenue.

This suggests that older vehicles may support affordability and volume, whereas newer vehicles are more important for revenue generation and higher average ticket size.

---

## 8. Red Flags and Further Investigation

The analysis identified several areas that require further investigation:

| Red Flag Area                      | Reason                                                                      |
| ---------------------------------- | --------------------------------------------------------------------------- |
| Low-contribution dealerships       | May indicate lower performance, smaller capacity or limited market coverage |
| Uneven employee sales distribution | May indicate top-performer dependency or unequal opportunity distribution   |
| States with fewer transactions     | May indicate low market penetration or limited dealership presence          |
| Unknown vehicle values             | Limit reliability of vehicle-level analysis                                 |
| Models with high price variability | May indicate valid pricing differences or possible data quality issues      |

---

# Business Value of the Analysis

This analysis shows how SQL can be used not only to calculate metrics, but also to support business decision-making.

The project provides insights into:

| Area                   | Business Use                                               |
| ---------------------- | ---------------------------------------------------------- |
| Sales performance      | Understand revenue and volume trends                       |
| Product strategy       | Identify high-performing brands and models                 |
| Inventory planning     | Align stock with demand and revenue opportunities          |
| Dealership performance | Compare locations using multiple KPIs                      |
| Employee productivity  | Detect top performers and concentration risk               |
| Geographic strategy    | Identify strong and weak states                            |
| Sales conversion       | Separate completed and non-completed sales                 |
| Data quality           | Detect unknown values, outliers and analytical limitations |

---

# Summary

The business analysis phase answers ten key business questions using the final star schema.

The analysis focuses on:

1. Sales trends over time
2. Brand and model performance
3. Geographic performance by US state
4. Dealership performance
5. Employee performance
6. Sale status and conversion rates
7. Seasonality and time-based patterns
8. Product-geography opportunities
9. Vehicle age performance
10. Analytical red flags and data quality limitations

Together, these questions demonstrate how a cleaned and modelled SQL dataset can be transformed into practical business insights for a vehicle dealership network.
