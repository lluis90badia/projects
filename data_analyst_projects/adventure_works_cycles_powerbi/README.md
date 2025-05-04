# AdventureWorks Cycles Sales Report (Power BI)

By [Lluis Badia Planes](https://github.com/lluis90badia/projects)

<p align="center"><img src="https://images.squarespace-cdn.com/content/v1/5767b637ebbd1a42a8a9574e/1723021928553-838PX1LMG9CJAR9UTDOU/Madone8.jpeg?format=1500w" height="400"></p>

## Content

- [Brief description](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/README.md#brief-description)
- [Objectives](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/README.md#objectives)
- [Workflow](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/README.md#workflow)
- [Insights & Conclusions](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/README.md#insights--conclusions)

## Brief description

AdventureWorks Cycles is a fictional international company that manufactures bicycles and related products. This project only used sales data from the United States at the regional and state levels between 2017 and 2020.
The dataset can be downloaded from [Kaggle](https://www.kaggle.com/datasets/algorismus/adventure-works-in-excel-tables).

## Objectives

- Deliver an executive overview of business performance through key metrics: revenue, orders, and profit.
- Analyse month-over-month (MoM) revenue and order volume variability between July 2017 and May 2020 from two perspectives: Region/State and Category/Subcategory.
- Identify the worst-performing products during the analysed period that would help to explore potential solutions.

## Workflow

### 1. ETL Process:

The project began with an ETL process involving multiple CSV files before loading the data into Power BI Desktop. This included:
- Extracting the relevant raw data.
- Transforming it through column reduction, type conversion, and the creation of new calculated columns aligned with the project’s objectives.
- Loading the cleaned tables into an import data model.

### 2. Data Modelling

Once the tables were loaded, relationships through key columns were built using 1:N cardinality<br>, resulting in a snowflake schema<br> for better normalisation (“data_model” image).
<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/images/data_model.png" height="450"></p>

With the model in place, the use of [DAX](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/measures_dax.txt) was employed for:
- Creating a date table using CALENDAR(), with additional columns and hierarchies for multi-level time-based analysis.
- Defining measures for sales, revenue, cost, and profit.
- Implementing time intelligence logic, focusing on MoM and year-over-year (YoY) comparisons due to the absence of complete yearly data.
- Ranking and visualising the Top 5 Worst Products using RANKX, integrated into tooltips within the executive time-series visual for deeper insight.
- Adding bookmarked buttons to reset filters and improve user navigation across dimensions and metrics.

### 3. Visualization & Analysis

To explore the data in depth and from various angles, the following visual types were implemented:
- Bar and donut charts: to display revenue and sales by category and geography.
- Heatmap: to illustrate monthly variability by region.
- Cards and KPIs: to present performance indicators dynamically based on user filters.
- Scatter plots: to reveal relationships between metrics and behaviours across subcategories.
- In addition, slicers by year and region were created, along with buttons with bookmarks to easily switch between the metrics.

## Insights & Conclusions

The analysis highlights key changes between May and June 2018.

- Revenue: A significant drop was observed across most regions (approx. -50% MoM, especially in the South). Although sharp, this decline fits within a broader pattern of seasonal variability during 2018. Mountain Bikes experienced the steepest drop, with losses exceeding $100K (-72% MoM).
<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/images/rev_jun18.png" height="450"></p>
<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/images/rev_cat_jun18.png" height="450"></p>
- Orders: A decline in sales was also evident, though less severe than revenue (-25% MoM). The reduction was not limited to bikes–apparel sales also fell notably during that period.
<br/>
<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/images/ord_jun18.png" height="450"></p>
- Profit: The sharper fall in revenue compared to sales volume led to a dramatic profit collapse of -570% MoM. In May 2018, bicycles accounted for 81% of total profit, but by June, profits turned negative, with Mountain Bikes alone dropping between -700% and -900% MoM.
<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/adventure_works_cycles_powerbi/images/prof_jun18.png" height="450"></p>

Overall, the analysis of sales, revenue, and profit across time confirms that summer months exhibited the greatest variability. June consistently performs the worst in terms of revenue and profit, while August sees spikes in both, driving strong profitability.
