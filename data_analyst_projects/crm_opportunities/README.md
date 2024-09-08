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

### 3. Outlining questions for analysis (SQL [file](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities/crm_questions.sql)):
The following questions have been outlined to highlight key differences in performance between agents, offices, products, and sectors:
1. Which agents have the best and worst performance in terms of the percentage of won deals achieved?
   <p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities/images/question_1.PNG"  height="100"></p>
   Reed Clapper, with 65% of deals won relative to his total, may have been focusing on pursuing higher-quality opportunities, which means he has been more selective in choosing more successful opportunities compared to his colleagues. On the other hand, Lajuana Vencill (41% of deals won but with 31% more deals managed than Reed) may have been prioritising a strategy more focused on the number of deals with the goal of closing more, but with a lower conversion rate (CR%).

3. If these agents are from different offices, do those offices follow the same pattern regarding the percentage of won deals?
4. Are there significant differences between the products managed by both agents?
5. Which products have the best performance by sector?
6. What are the top 5 agents who have won the most opportunities above the overall average won per agent in the shortest average time? Therefore, we can focus on the agents with bigger proportions of won deals.
7. What are the top 3 sectors with the fewest opportunities won?
8. Identify how far the two groups are from the average per type of deal adding a rank per group.
