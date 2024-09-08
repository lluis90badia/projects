# CRM Sales Opportunities (Source: [Maven Analytics](https://app.mavenanalytics.io/))

By [Lluis Badia Planes](https://github.com/lluis90badia/projects)

<p align="center"><img src="https://ewm.swiss/application/files/9316/1243/4780/CRM_Systems_EWM_Digital_Agency_Geneva.png" height="400"></p>

- [Situation]()
- [Objectives]()
- [Actions Taken]()
- [Conclusions]()

## Situation

B2B sales pipeline data from a fictitious company that sells computer hardware, including information on accounts, products, sales teams, and sales opportunities.

## Objectives

- Create a database and tables in MySQL Workbench to import the CSV files from Maven Analytics using LOAD DATA LOCAL INFILE syntax.
- Outline several questions to analyse the results using queries with Advanced SQL syntax (CTEs, subqueries, window functions, CASE, etc.).

## Actions Taken

### 1. Database and tables creation:
- [Database and tables](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities/create_crm_db_tables.sql) created in MySQL Workbench. The following image shows the EER Diagram consisting of 4 tables structured as a Star Schema:
<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities/images/crm_eer_diagram.PNG"  height="450"></p>

### 2. CSV files import:
- Files imported using LOAD DATA LOCAL INFILE syntax.

### 3. Outlining questions for analysis:
The following questions have been outlined to highlight key differences in performance between agents, offices, products, and sectors:
1. Which agents have the best and worst performance in terms of the percentage of won deals achieved?
2. If these agents are from different offices, do those offices follow the same pattern regarding the percentage of won deals?
