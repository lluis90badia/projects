drop database if exists crm;
create database crm;
use crm;

create table sales_teams (
	sales_agent varchar(100),
    manager varchar(100),
    regional_office varchar(10),
    primary key (sales_agent)
) engine=innoDB default charset=utf8mb4;

load data local infile 'D:/Programes/MySQL/MySQL Server 8.0/bin/sql/crm/sales_teams.csv' into table sales_teams fields terminated by ',' ignore 1 lines;

create table products (
	product_name varchar(50),
    series varchar(3),
    sales_price int,
    primary key (product_name)
) engine=innoDB default charset=utf8mb4;

load data local infile 'D:/Programes/MySQL/MySQL Server 8.0/bin/sql/crm/products.csv' into table products fields terminated by ',' ignore 1 lines;

create table accounts (
	account_id varchar(100),
    sector varchar(100),
    year_established char(4),
    revenue int,
    employees int,
    office_location varchar(50),
    subsidiary_of varchar(100),
    primary key (account_id)
) engine=innoDB default charset=utf8mb4;

load data local infile 'D:/Programes/MySQL/MySQL Server 8.0/bin/sql/crm/accounts.csv' into table accounts fields terminated by ',' ignore 1 lines;

create table sales (
	opportunity_id varchar(20),
    agent varchar(100) default NULL,
    product varchar(50) default NULL,
    account_name varchar(100) default NULL,
    deal_stage varchar(15) default NULL,
    engage_date date default NULL,
    close_date date default NULL,
    close_value int default NULL,
    primary key (opportunity_id),
    foreign key (agent) references sales_teams (sales_agent) on update cascade,
    foreign key (product) references products (product_name) on update cascade,
    foreign key (account_name) references accounts (account_id) on update cascade
) engine=innoDB default charset=utf8mb4;

load data local infile 'D:/Programes/MySQL/MySQL Server 8.0/bin/sql/crm/sales.csv' into table sales fields terminated by ',' ignore 1 lines
	(@opportunity_id, @agent, @product, @account_name, @deal_stage, @engage_date, @close_date, @close_value)
	set
		opportunity_id = @opportunity_id,
		agent = if(@agent = '', NULL, @agent),
        product = if(@product = '', NULL, @product),
        account_name = if(@account_name = '', NULL, @account_name),
        deal_stage = if(@deal_stage = '', NULL, @deal_stage),
        engage_date = if(@engage_date = '', NULL, @engage_date),
        close_date = if(@close_date = '', NULL, @close_date),
        close_value = if(@close_value = '', NULL, @close_value)
;