


-- practive session 12-02-2026
--Orders data is stored in seperate tables	(orders and ordersArchive).
--combine all the data into one single report without duplicates 

SELECT * FROM Sales.Orders
UNION
SELECT * FROM Sales.OrdersArchive

--find the employees who are also customers
SELECT EmployeeID,FirstName,LastName FROM Sales.Employees 
INTERSECT
SELECT CustomerID AS ID,FirstName AS FIRST_NAME,LastName AS LAST_NAME FROM Sales.Customers
--find the employees who are not the customers at the same time 
SELECT EmployeeID,FirstName,LastName FROM Sales.Employees 
EXCEPT
SELECT CustomerID AS ID,FirstName AS FIRST_NAME,LastName AS LAST_NAME FROM Sales.Customers

--combine the data from the employees and custoemers into one table including the duplicates 

SELECT CustomerID AS ID,FirstName AS FIRST_NAME,LastName AS LAST_NAME FROM Sales.Customers
UNION ALL
SELECT EmployeeID,FirstName,LastName FROM Sales.Employees

-- practive session 08-02-2026
-- combine the data from employees and customers into one table  

SELECT CustomerID AS ID,FirstName AS FIRST_NAME,LastName AS LAST_NAME FROM Sales.Customers
UNION
SELECT EmployeeID,FirstName,LastName FROM Sales.Employees

--union the two tables : customers and employees from sales 

SELECT 
	FirstName,LastName
FROM Sales.Customers

UNION

SELECT 
	FirstName,LastName
FROM Sales.Employees

--practice session 07-02-2026
--using salesdb , Reterieve a list of all the orders, along with the related customers, products and employee details	: 
--for each display 
--orderid
--customer name 
--product name 
--sales amount 
--product price
--salesperso's name  


USE SalesDB
select O.OrderID,C.FirstName AS CUSTOMER_NAME,C.LastName AS CUSTOMER_NAME,P.Product,P.Price,O.Sales,E.FirstName AS EMPLOYEE_NAME,E.LastName
from Sales.Orders AS O
left join Sales.Customers as c
ON C.CustomerID =O.CustomerID
LEFT JOIN SALES.Products AS P 
ON O.ProductID = P.ProductID
LEFT JOIN Sales.Employees AS E
ON O .SalesPersonID =E.EmployeeID

SELECT * FROM Sales.Orders
select * from sales.Customers
SELECT * FROM Sales.Products
SELECT * FROM Sales.Employees

-- practive session 05-02-2026
-- GERENERATE ALL POSSIBLE COMBINATIONS OF CUSTOMERS AND ORDERS 

USE MyDatabase -- THIS IS SAME AS SELECTING THE DATABASE .

SELECT * 
FROM customers 
CROSS JOIN orders

-- GET ALL THE CUSTOMERS ALONG WITH THEIR OREDERS , 
--BUT ONLY FOR CUSTOMERS WHO HAVE PLACED AN ORDER (WITHOUT USING INNER JOIN  )

SELECT * FROM customers
SELECT * FROM orders

SELECT * 
FROM customers AS C
FULL JOIN orders AS O
ON C.id = O.customer_id
WHERE C.id = O.customer_id
--WHERE C.id IS NOT NULL AND O.customer_id IS NOT NULL

-- GET ALL THE CUSTOMERS ALONG WITH THEIR OREDERS , 
--BUT ONLY FOR CUSTOMERS WHO HAVE PLACED AN ORDER (WITHOUT USING INNER JOIN  )

SELECT * 
FROM customers AS C
LEFT JOIN orders AS O
ON C.id = O.customer_id
WHERE O.customer_id IS NOT NULL

-- SAME TASK USING THE LEFT JOIN -- 
-- FIND CUSTOMERS WITHOUT ORDERS AND ORDERS WITHOUT CUSTOMERS

SELECT *
FROM customers AS C 
INNER JOIN orders AS O 
ON C.id = O.customer_id

SELECT * 
FROM customers AS C
FULL JOIN orders AS O 
ON C.id = O.customer_id
WHERE C.id IS NULL 
OR O.customer_id IS NULL

--GET ALL ORDERS WITHOUT MATCHING CUSTOMERS (USING RIGHT JOIN )
SELECT * 
FROM customers AS C
RIGHT JOIN orders AS O
ON C.id = O.customer_id
WHERE  C.id IS NULL

--GET ALL ORDERS WITHOUT MATCHING CUSTOMERS (USING LEFT JOIN )

SELECT * 
FROM orders AS O
LEFT JOIN customers AS C
ON C.id = O.customer_id
WHERE  C.id IS NULL
--get all customErs who havent placed any order 

SELECT * FROM customers
SELECT * FROM orders

SELECT * 
FROM customers C
LEFT JOIN orders AS O
ON C.ID =O.customer_id
WHERE O.customer_id IS NULL


--practice session 1-02-2026
--get all the customers and all the orders if there is not match  
SELECT * 
FROM customers AS C 
FULL JOIN orders AS O
ON C.id = O.customer_id 

--GET ALL THE CUSTOMERS ALONG WITH THEIR ORDERS AND INCLUDING ORDERS WITHOUT MATCHING CUSTOMERS.
-- SAME TASK USING THE LEFT JOIN 
SELECT 
	C.id,
	C.first_name,
	O.order_id,
	O.sales
FROM orders AS O 
LEFT JOIN customers AS C
ON O.customer_id = C.id

--GET ALL THE CUSTOMERS ALONG WITH THEIR ORDERS AND INCLUDING ORDERS WITHOUT MATCHING CUSTOMERS
SELECT * 
FROM customers AS C
RIGHT JOIN orders AS O 
ON C.id = O.customer_id

SELECT * FROM customers;
SELECT * FROM orders;
-- get all the customers along with order including those without orders :
SELECT * FROM customers AS C
LEFT JOIN orders AS O 
ON C.id = O .customer_id

--PRACTCE SESSION 29-1-2026
--Get all the customers along with their orders , but only customers who have placed an order  :
SELECT * -- NOT A GOOD PRACTICE TO KEEP THE * BECAUSE IN THE RESULT THERE WILL BE MULTIPLE REPEATED COLUMS 
FROM customers -- SO SELECT A FEW RELVENT COLUMNS
INNER JOIN orders
ON customers.id = orders.customer_id

-- ABOVE QUERY CAN BE WRITTES AS :
SELECT  C.id,C.first_name,C.country,C.score,O.order_id,O.order_date,O.sales
FROM customers AS C
INNER JOIN orders AS O
ON C.id = O.customer_id
--Retrieve all data from customers and orders in 2 different results  :
SELECT *
FROM customers;

SELECT * 
FROM orders;



-- PRACTICE SESSION 26-1-2026
--Find all the customers whose first name has r in the 3rd postion :
SELECT *
FROM customers
WHERE first_name LIKE '__r%'

--Find all customers whose first name contains an r:
SELECT *
FROM customers
WHERE first_name LIKE '%r%'

--Find all customers whose first name ends with n 
SELECT * 
FROM customers
WHERE first_name LIKE '%n'

--Find all customers whose first name starts with M :
SELECT * 
FROM customers
WHERE first_name LIKE 'M%'

--Retrieve all teh customers who are not from either Germany or USA :
SELECT * 
FROM customers
WHERE country NOT IN ('UK','Germany')

--Retrieve all the customers who are from either Germay or USA :
SELECT * 
FROM customers
WHERE country IN ('USA','Germany')

--Retrieve all the customers whose score falls between 100 and 500
SELECT * 
FROM customers
WHERE SCORE BETWEEN 100 AND 500

-- ANOTHER WAY TO WRITE THE ABOVE QUERY IS  :
SELECT * 
FROM customers
WHERE score >=100 AND score <=500

-- practice session 25-01-2026
--Retrieve all the customers who have the score not less than 500 .
SELECT * 
FROM customers
WHERE NOT SCORE < 500 -- SPECIAL NOT OPERATOR(LOGICAL OPERATOR) THAT REVERSES THE GIVEN CONDITION 
-- THE ABOVE GIVEN QUERY CAN ALSO BE WRITTEN AS  :

SELECT *
FROM customers
WHERE score >= 500 --(NOT LESS THAN 500)

--Retrieve all the customers who are either from usa or have a score > 500
SELECT * 
FROM customers
WHERE country = 'USA' OR 
	  score > 500

--Retrieve all the customers who are from USA and have a score > 500
SELECT * 
FROM customers
WHERE country = 'USA' AND 
	  score > 500

--Retrieve all customers with a score <= 500 
SELECT * 
FROM customers
WHERE  score <= 500
ORDER BY id DESC

--Retrieve all customer with a score < than 500
SELECT *
FROM customers
WHERE score<500

-- Retrieve all the customers with a score of 500 or more :
SELECT *
FROM customers
WHERE score >= 500


--Retrieve all the customers with a score > 500
SELECT *
FROM customers
WHERE score >500

--Retrieve all the customers who are not from Germany :

SELECT * 
FROM customers
WHERE country != 'Germany'

--Retrieve all customers from Germany :

SELECT  * 
FROM customers
WHERE country ='Germany'


-- Delete all data from table persons
DELETE FROM persons
--you can also use TRUNCATE in place of DELETE which will be faster .
TRUNCATE TABLE persons
--Delete all customers with an id > 5
DELETE FROM customers
WHERE id > 5


SELECT * FROM customers


UPDATE customers
SET country = 'USA'
WHERE country ='MAX'

-- update all customers with null score by setting their score to 0 
UPDATE customers
SET score = 0
WHERE score IS NULL

SELECT * FROM customers

-- Update all the customers where the country is null to unknown 
UPDATE customers 
SET country = 'UNKNOWN'
where country is NULL 

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


