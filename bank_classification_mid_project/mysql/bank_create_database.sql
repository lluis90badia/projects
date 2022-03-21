drop database if exists credit_card_classification;
create database credit_card_classification;
use credit_card_classification;

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

load data local infile 'bank_details.csv' into table credit_card_data fields terminated by ',' ignore 1 lines;