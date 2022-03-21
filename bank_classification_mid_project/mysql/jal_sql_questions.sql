/*
1. Create a database called credit_card_classification.
*/

drop database if exists credit_card_classification;
create database credit_card_classification;
use credit_card_classification;

/*
2. Create a table credit_card_data with the same columns as given in the csv file. Please make sure you use the correct data types for each of the columns.
*/

create table credit_card_data (
	customer_number int not null auto_increment,
	offer_accepted char(3),
	reward varchar(20),
	mailer_type varchar(10),
	income_level varchar(10),
	bank_accounts_open int,
	overdraft_protection varchar(10),
	credit_rating varchar(10),
	credit_cards_held int,
	homes_owned int,
	household_size int,
	own_your_home char(3),
	average_balance float(6,2),
	Q1_balance float(6,2),
	Q2_balance float(6,2),
	Q3_balance float(6,2),
	Q4_balance float(6,2),
	primary key(customer_number)	
) engine=innodb default charset=utf8;

alter table credit_card_data auto_increment = 1;

/*
3. (this is the CSV file we converted from the xslx file in Python):
*/

load data local infile 'bank_details.csv' into table credit_card_data fields terminated by ',' ignore 1 lines;

/*

This is the way we loaded the CSV file through the MySQL terminal ('bank_create_database.sql' contains questions 1, 2 and 3): 

mysql> source C:/Users/lluis/OneDrive/Escritorio/bank_create_database.sql;      
Query OK, 2 rows affected (0.05 sec)

Query OK, 1 row affected (0.01 sec)

Database changed
Query OK, 0 rows affected, 6 warnings (0.08 sec)

Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

Query OK, 17976 rows affected, 17976 warnings (0.42 sec)
Records: 17976  Deleted: 0  Skipped: 0  Warnings: 17976

---------------------------------------------------------------

We only have 17976 rows because we dropped before them in a Jupyter Notebook 
the NULL values (which were in 24 rows) as we agreed as a team because the proportion 
between NULL and no NULL values is too small to consider them relevant and practicaly 
don't affect the results neither in SQL, Python or Tableau.
*/

/*
4. Select all the data from table credit_card_data to check if the data was imported correctly.
*/

select * from credit_card_data;

/*
5. Use the alter table command to drop the column q4_balance from the database, as we would not use it in the analysis with SQL. Select all the data from the table to verify if the command 
worked. Limit your returned results to 10.
*/

alter table credit_card_data drop column Q4_balance;


/*
6. Use sql query to find how many rows of data you have.
*/

select count(*) as data_count 
from credit_card_data;

/*
7.1. What are the unique values in the column Offer_accepted?
*/

select distinct(offer_accepted) 
from credit_card_data;


/*
7.2. What are the unique values in the column Reward?
*/

select distinct(reward) 
from credit_card_data;


/*
7.3. What are the unique values in the column mailer_type?
*/

select distinct(mailer_type) 
from credit_card_data;


/*
7.4. What are the unique values in the column credit_cards_held?
*/

select distinct(credit_cards_held) 
from credit_card_data 
order by credit_cards_held;

/*
7.5. What are the unique values in the column household_size?
*/

select distinct(household_size) 
from credit_card_data 
order by household_size;


/*
8. Arrange the data in a decreasing order by the average_balance of the house. Return only the customer_number of the top 10 customers with the highest 
average_balances in your data.
*/

select customer_number as customer_id 
from credit_card_data 
order by average_balance desc 
limit 10;


/*
9. What is the average balance of all the customers in your data?
*/

select round(avg(average_balance), 2) as average 
from credit_card_data;


/*
10.1. What is the average balance of the customers grouped by Income Level? The returned result should have only two columns, income level and Average balance 
of the customers. Use an alias to change the name of the second column.
*/

select income_level, round(avg(average_balance), 2) as average 
from credit_card_data 
group by income_level 
order by average desc;


/*
10.2. What is the average balance of the customers grouped by number_of_bank_accounts_open? The returned result should have only two columns, number_of_bank_accounts_open and Average 
balance of the customers. Use an alias to change the name of the second column.
*/

select bank_accounts_open, round(avg(average_balance), 2) as average 
from credit_card_data 
group by bank_accounts_open 
order by average desc;


/*
10.3. What is the average number of credit cards held by customers for each of the credit card ratings? The returned result should have only two columns, rating and average number of credit 
cards held. Use an alias to change the name of the second column.
*/

select credit_rating, round(avg(credit_cards_held), 2) as num_cards 
from credit_card_data 
group by credit_rating 
order by num_cards desc;


/*
10.4. Is there any correlation between the columns credit_cards_held and number_of_bank_accounts_open? You can analyse this by grouping the data by one of the variables and then 
aggregating the results of the other column. Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
*/

select bank_accounts_open as num_accounts, ceil(avg(credit_cards_held)) as mode_num_card 
from credit_card_data 
group by num_accounts 
order by mode_num_card desc;

select credit_cards_held as num_cards, floor(avg(bank_accounts_open)) as num_accounts 
from credit_card_data 
group by num_cards 
order by num_accounts desc;

/*
There is NO correlation between these two columns. According to the correlation matrix from the numerical 
values in this dataset, the correlation value tends towards 0; therefore, there are no similar patterns between 
them. That means, the majority of the customers held two credit cards and only one bank account.
*/


/*
11.1. For the rest of the things, they are not too concerned. Write a simple query to find what are the options available for them?
*/

select * from credit_card_data 
where credit_rating in ('Medium', 'High') and credit_cards_held < 3 and own_your_home = 'Yes' and household_size > 2;


/*
11.2. Can you filter the customers who accepted the offers here?
*/

select customer_number
from credit_card_data
where credit_rating in ('Medium', 'High') and credit_cards_held < 3 and own_your_home = 'Yes' and household_size > 2 and offer_accepted = 'Yes';


/*
12. Your managers want to find out the list of customers whose average balance is less than the average balance of all the customers in the database. Write a query to show 
them the list of such customers. You might need to use a subquery for this problem.
*/

select customer_number, average_balance 
from credit_card_data 
where average_balance < (select avg(average_balance) from credit_card_data);


/*
13. Since this is something that the senior management is regularly interested in, create a view of the same query.
*/

create or replace view customer_avg_balance as 
	select customer_number, average_balance 
	from credit_card_data 
    where average_balance < 
    (
		select avg(average_balance) 
        from credit_card_data
	);

select*from customer_avg_balance;


/*
14. What is the number of people who accepted the offer vs number of people who did not?
*/

select offer_accepted, count(offer_accepted) as count 
from credit_card_data 
group by offer_accepted;


/*
15. Your managers are more interested in customers with a credit rating of high or medium. What is the difference in average balances of the customers with high credit 
card rating and low credit card rating?
*/

select round((select avg(average_balance) 
from credit_card_data 
where credit_rating = 'High') - (select avg(average_balance) from credit_card_data where credit_rating = 'Low'), 2) as difference_avg_high_low;

# Same query as the above one but with different output:
select credit_rating, round(avg(average_balance), 2) as average 
from credit_card_data 
where credit_rating != 'Medium' 
group by credit_rating;


/*
16. In the database, which all types of communication (mailer_type) were used and with how many customers?
*/

select mailer_type, count(mailer_type) as count 
from credit_card_data 
group by mailer_type;


/*
17. Provide the details of the customer that is the 11th least Q1_balance in your database.
*/

select*from credit_card_data 
order by Q1_balance 
limit 10, 1;


# --------------------------------------------------------------------------------------------------------------------------------------------

# This is the query we used to extract the information and exported to CSV (data_profile.csv) through Python to develop our profile analysis in Python and Tableau:

select offer_accepted, mailer_type, average_balance, household_size, credit_cards_held, bank_accounts_open, own_your_home, homes_owned, income_level, credit_rating, 
	case
		when average_balance >= 1600 and credit_rating = 'High'and income_level = 'High' then 'Highest Target'
		when credit_rating = 'High' and income_level = 'High' or average_balance >= 1600 and credit_rating = 'High' 
			or income_level = 'High' and average_balance >= 1600 then 'High Target'
		when credit_rating = 'Medium' and income_level = 'Medium' and average_balance >= 1600 or credit_rating = 'High' 
			and income_level = 'Medium' and average_balance between 500 and 1599 or credit_rating = 'Medium' and income_level = 'High' 
            and average_balance between 500 and 1599 then 'Medium High Target'
		when credit_rating = 'Medium' and income_level = 'Medium' and average_balance  between 500 and 1599 then 'Medium Target'
		when credit_rating = 'Medium' and income_level = 'Medium' and average_balance  < 500 or credit_rating = 'Low' and income_level = 'Medium' 
			and average_balance between 500 and 1599 or credit_rating = 'Medium' and income_level = 'Low' and average_balance between 500 
            and 1599 then 'Medium Low Target'
		when credit_rating = 'Low' and income_level = 'Low' or average_balance < 500 and credit_rating = 'Low' or income_level = 'Low' 
			and average_balance  < 500 then 'Low Target'
		when average_balance < 500 and credit_rating = 'Low' and income_level = 'Low' then 'Lowest Target'
		else 'Non classifiable'
	end as profiles 
 from credit_card_data 
 where household_size < 7 
 order by profiles desc;