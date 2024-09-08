# CRM Sales Opportunities (Source: [Maven Analytics](https://app.mavenanalytics.io/))

By [Lluis Badia Planes](https://github.com/lluis90badia/projects)

<p align="center"><img src="https://ewm.swiss/application/files/9316/1243/4780/CRM_Systems_EWM_Digital_Agency_Geneva.png" height="400"></p>

- [Situation](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/README.md#situation)
- [Objectives](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/README.md#objectives)
- [Actions Taken](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/README.md#actions-taken)

## Situation

B2B sales pipeline data from a fictitious company that sells computer hardware, including information on accounts, products, sales teams, and sales opportunities.

## Objectives

- Create a database and tables in MySQL Workbench to import the CSV files from Maven Analytics using LOAD DATA LOCAL INFILE syntax.
- Outline several questions to analyse the results using queries with Advanced SQL syntax (CTEs, subqueries, window functions, CASE, etc.).

## Actions Taken

### 1. Database and tables creation:
- [Database and tables](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/create_crm_db_tables.sql) created in MySQL Workbench. The following image shows the EER Diagram consisting of 4 tables structured as a Star Schema:
<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/images/crm_eer_diagram.PNG"  height="450"></p>

### 2. CSV files import:
- Files imported using LOAD DATA LOCAL INFILE syntax.

### 3. Outlining questions for analysis (SQL [file](https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/crm_questions.sql)):
The following questions have been outlined to highlight key differences in performance between agents, offices, products, and sectors:
1. Which agents have the best and worst performance in terms of the percentage of won deals achieved?
   <p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/images/question_1.PNG"  height="100"></p>
   Reed Clapper, with 65% of deals won relative to his total, may have been focusing on pursuing higher-quality opportunities, which means he has been more selective in choosing more successful opportunities compared to his colleagues. On the other hand, Lajuana Vencill (41% of deals won but with 31% more deals managed than Reed) may have been prioritising a strategy more focused on the number of deals to close more, but with a lower conversion rate (CR%).

2. If these agents are from different offices, do those offices follow the same pattern regarding the percentage of won deals?
   <p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/images/question_2_1.PNG"  height="100"></p>
   <p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/images/question_2_2.PNG"  height="100"></p>
   First, and thanks to the first query, it is confirmed that these two agents are from different offices. Secondly, the same trend is followed (51% in the East versus 46% at the central office) as with the agents themselves; however, the revenue generated has followed an opposite pattern. From a sales strategy perspective, it seems that the central office may have been adopting more uniform patterns compared to the other offices, as it is the only one that includes deals that are still in the expectation stage. However, its CR% has been the lowest, which could have caused a negative perception among the upper levels of the company, and it is likely that changes were implemented to facilitate a higher number of deals won.

3. Are there significant differences between the products managed by both agents?
   <p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/images/question_3.PNG"  height="200"></p>
   There are significant differences between the two agents. Primarily, two products show major variations between them. One of these, the “GTX Pro,” has been the most managed by agent Reed Clapper (27%), whereas in the case of Lajuana Vencill, she hasn’t managed any. The other noticeable product is the “GTX Basic,” which has been the most managed by Lajuana (41%), far more than in Reed’s case (16%). In summary, Reed shows a much more balanced distribution, indicating greater diversification and adaptation to different products to mitigate the risks of focusing on fewer products. On the other hand, Lajuana has adopted a pattern of high dependency on a few products, which could lead to market vulnerability if those products do not perform well.

4. Which products have the best performance by sector?
   <p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/images/question_4.PNG"  height="250"></p>
   It can be observed that the product ‘GTX Basic’ dominates among the products with the best performance by sector, with the Retail sector standing out as having the highest number of deals managed (288) and the highest percentage of won deals (64%) compared to the rest.
   
5. What are the top 5 agents who have won the most opportunities above the overall average won per agent in the shortest average time? Therefore, we can focus on the agents with bigger proportions of won deals.
   <p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/images/question_5.PNG"  height="150"></p>
   Based on the fact that the average number of deals managed per agent is 141, it can be identified that Zane Levy has been the fastest in closing a winning deal on average (47 days); however, the fact that she has only obtained 3.8% of the total won deals indicates that, although she closes some deals quickly, her capacity to generate a significant volume of winning closures has been limited, especially when compared, for example, with Darcel Schlecht and his 8.2% in an average of 49 days.
   
6. What are the top 3 sectors with fewer opportunities won? Compare with the top 3 sectors with more opportunities won how far those sectors are from the average per type of deal and adding a rank:
   <p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/data_analyst_projects/crm_opportunities_mysql/images/question_6.PNG"  height="200"></p>
   The top 3 with a fewer number of opportunities won are Employment, Services and Entertainment. Comparing them with those that have generated more winning deals (Retail, Technology, and Medical), all types of agreements are below the average, unlike those that have generated more (which are above the average). In general, the group with more won deals is farther from the average than the other group, especially in prospecting deals (121% vs between -50% and -70%). Additionally, the Retail sector has achieved significantly higher performance than the other two in the group, which is not the case in the other group (where percentages are more uniform between them).
