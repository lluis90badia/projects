drop database if exists asylum;
create database asylum;
use asylum;

create table asylum (
	id int not null,
	year char(4),
	c_origin varchar(50),
	iso_origin char(3),
	c_asylum varchar(100),
	iso_asylum char(3),
	female0_4 int,
	female5_11 int,
	female12_17 int,
	female18_59 int,
	female60over int,
	female_total int,
	male0_4 int,
	male5_11 int,
	male12_17 int,
	male18_59 int,
	male60over int,
	male_total int,
	total int
) engine = innodb default charset = utf8;

load data local infile 'asylum.csv' into table asylum fields terminated by ',' enclosed by '"' ignore 1 lines;

create table seekers (
	year char(4),
	c_origin varchar(20),
	iso_origin char(3),
	c_asylum varchar(100),
	iso_asylum char(3),
	refugees int,
	seekers int
) engine = innodb default charset = utf8;

load data local infile 'total_per_country.csv' into table seekers fields terminated by ',' enclosed by '"' ignore 1 lines;

create table app (
	year char(4),
	c_origin varchar(20),
	iso_origin char(3),
	c_asylum varchar(100),
	iso_asylum char(3),
	authority char(3),
	app_type char(3),
	stage char(3),
	cases char(3),
	applied int
) engine = innodb default charset = utf8;

load data local infile 'asylum-applications.csv' into table app fields terminated by ',' enclosed by '"' ignore 1 lines;