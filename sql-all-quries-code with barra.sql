
SELECT * FROM persons
--INSERT using SELECT (INSERT  from the customer table to the person table)--
/*
--first SELECT the columns as the colums in the persons table
-- Then INSERT it into the table
INSERT INTO persons
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


