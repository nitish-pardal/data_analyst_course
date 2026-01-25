
-- practice session 25-01-2026
create table customers2 (
	id int not null ,
	first_name varchar(20) ,
	phone_number varchar(10),
	country char(20) ,
	score integer 
)

insert into customers2 (id,first_name,phone_number,country,score)
	SELECT id,first_name,'UNKNOWN',country,score
	FROM customers


UPDATE customers2 
SET phone_number  = NULL 
where id  = 10 and first_name =  'sahra'

select * from customers2

select first_name,country,sum(score) as total_score
from customers
group by first_name,country


insert into customers
values (11,'ANNA','Germany',600)

-- change the	score of the customer with id 10 to 0 and update the country to UK .

UPDATE customers 
set score = 0, country = 'UK'
WHERE id = 10

SELECT * FROM customers
WHERE id = 10


-- update the score of the customer with id 6 to 0.
UPDATE customers
SET score =0
WHERE id = 6


-- UPDATES THE columns OF THE CUSTOMER WHOSE ID IS 6 .
UPDATE customers
SET first_name = 'ANNA',
	country = 'USA',
	score = 600
WHERE id = 6    -- always use where with the UPDATE clause other wise it will update all the other data  



SELECT * FROM customers
/*
INSERT INTO persons (id,person_name,birth_date,phone) (
	SELECT 
	id,
	first_name,Null,'unknown'
	From customers

)
*/
SELECT * FROM persons

--use MyDatabase;
-- this will point to the name of the database instead of whatever datbase you are using  .

--SELECT * FROM persons
--INSERT using SELECT (INSERT  from the customer table to the person table)--
/*
--first SELECT the columns as the colums in the persons table
-- Then INSERT it into the table
INSERT INTO persons (id,person_name,birth_date,phone)
-- you can always leave out the columns names if you define the insert values according to the table defintion
SELECT 
id,first_name,NULL,'unknown'
FROM customers
*/


/* created the table again for furure use and demonstrations 

create table persons (
	id INT  NOT NULL ,
	person_name CHAR (50) NOT NULL,
	birth_date DATE,
	phone VARCHAR (15) NOT NULL ,	
	CONSTRAINT pk_persons PRIMARY KEY(id)
*/

--INSERT INTO customers (id,first_name)
--VALUES (8,'Manny')
 
--INSERT INTO customers (id,first_name,score)
--VALUES (9,'USA',900)

--SELECT * FROM customers;
-- Inserting new values into customer table using INSERT INT
 /*INSERT INTO mydatabase.customers 
	(id, first_name, country, score)
VALUES(6,'Anna','USA', NULL),
	  (7,'Sam',NULL,100)
*/

--SELECT * FROM customers
--SELECT * FROM  persons (This table is deleted from the database

-- Delete the table persons from your database 
--DROP TABLE persons

-- delete the column phone from the persons table 
--ALTER TABLE persons
--DROP COLUMN phone

--alter the table persons and add a column email to it  
/*ALTER TABLE persons
ADD emails VARCHAR(50) NOT NULL
*/
--create a new table called persons with column id,person_name,birth_date and phone

/* create table persons (
	id INT  NOT NULL ,
	person_name CHAR (50) NOT NULL,
	birth_date DATE,
	phone VARCHAR (15) NOT NULL ,	
	CONSTRAINT pk_persons PRIMARY KEY(id)
)
*/

--selecting a static value with the colums

SELECT id,first_name, 'new customer' as customer_type
FROM customers


--select the 2 most recent orders :

SELECT TOP 2 *
FROM orders
ORDER BY order_date Desc



-- find the total scores and total number of customers from each country

select country,
sum(score) as total_score,
count(id) as total_customers
from customers
group by country;


/*find the average score for each country
considering only customers with a score not equal to 0 
and return only countries with an average score greater tha 430
*/

select country,
avg(score) as AVG_SCORE
from customers
where score !=0
Group by country
Having avg(score) > 430


/*
return unique list of all countries
*/

SELECT DISTINCT
	country
FROM  customers

-- retrieve only 3 customers

SELECT TOP 3
	*
FROM customers 

-- retrieve top 3 customers with the higest scores

SELECT TOP 3 *
FROM customers
ORDER BY score DESC


--Retrieve the lowest 2 customers based on the score

SELECT TOP 2 *
FROM customers
ORDER BY score ASC


