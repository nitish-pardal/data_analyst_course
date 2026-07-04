-------------------------------------------------------------------------------------------------------------
--SEGMENT ALL ORDERS INTO 3 CATAOGORIES : HIGH , MEDIUM AND LOW 

SELECT * ,
CASE
	WHEN BUCKETS =1 THEN 'HIGH'
	WHEN BUCKETS =2 THEN 'MEDIUM'
	ELSE 'LOW'
END AS [SALES SEGMENTATION]
FROM ( 
	SELECT 
		OrderID,
		OrderDate,
		Sales,
		NTILE(3) OVER (ORDER BY SALES DESC) BUCKETS
	FROM Sales.Orders
)T

--USING NTILE TO CREATE BUCKETS 
SELECT 
	OrderID,
	Sales,
	NTILE(3) OVER (ORDER BY SALES DESC) [3BUCKET],
	NTILE(2) OVER(ORDER BY SALES DESC) [2BUCKET],
	NTILE (1) OVER (ORDER BY SALES ) [1BUCKET]
FROM Sales.Orders

SELECT 
DATETRUNC(YEAR,GETDATE()), --FIRST DATE OF THE CURRENT MONTH
DATEADD(MONTH,-1,DATETRUNC(MONTH,GETDATE())) --FIRST DATE OF THE PREVIOUS MONTH
--ANOTHER WAY TO DO THE SAME THING DONE ABOVE
SELECT 
DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1), 
DATEADD(MONTH,-1,DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1))
SELECT 
	OrderID,
	DATEADD(MONTH,12,GETDATE()),	
	MONTH(GETDATE())
FROM Sales.Orders
WHERE OrderDate <= GETDATE() AND OrderDate >= DATEADD(MONTH,-24,GETDATE()) 

--IDENTIFY THE DUPLICATES USING THE RANK WINDOW FUNCTION 

SELECT 
RANK() OVER (PARTITION BY ORDERID ORDER BY CREATIONTIME DESC) RN,
*
FROM SALES.OrdersArchive

-- IDENTIFY THE DUPLICATES AND ALSO DISPLAY THE DUPLICATE RECORDS FROM TABLES .ARCHIVE 
SELECT * FROM (
SELECT 
	ROW_NUMBER () OVER (PARTITION BY ORDERID ORDER BY CREATIONTIME) RN,
	*
FROM Sales.OrdersArchive
) T 
WHERE RN >1 --ALL THE ROWS THAT HAVE RANK > 1 ARE DUPLICATED VALUES 


-- IDENTIFY DUPLICATE ROWS IN THE TABLE ORDER ARCHIVE AND 
--RETURN A CLEAN RESULT WITHOUT ANY DUPLICATES 

SELECT * FROM (
SELECT 
ROW_NUMBER() OVER (PARTITION BY ORDERID ORDER BY CREATIONTIME) RN,
*
FROM Sales.OrdersArchive
) T 
WHERE RN =1

--ASSIGN UNIQUE IDS TO THE ROWS OF 'ORDER ARCHIEVE' TABLE
SELECT
	ROW_NUMBER() OVER (ORDER BY ORDERID,ORDERDATE) UNIQUEID,
	*
FROM Sales.OrdersArchive

--FIND THE LOWEST 2 CUSTOMERS BASED ON THEIR TOTAL SALES 
SELECT *
FROM (
SELECT 
	CustomerID,
	SUM(Sales) [TOTAL SALES],
	ROW_NUMBER () OVER (ORDER BY SUM(SALES)) [RANK BY SUM(SALES)] --WHEN YOU USE GROUP BY AND WINDOW TOGETHER ALWAYS USE THE COLUMNS IN THE GROUP BY
FROM Sales.Orders
GROUP BY CUSTOMERID )T -- ALWAYS GROUP BY AND AGGREGATE FIRST , THEN USE WINDOW FUNCTIONS T 
WHERE [RANK BY SUM(SALES)] <= 2

--FIND THE TOP HIGHEST SALES FOR EACH PRODUCT 
--SELECT * FROM (
SELECT 
OrderID,
ProductID,
Sales,
ROW_NUMBER() OVER (PARTITION BY PRODUCTID ORDER BY SALES DESC) [TOP HIGHEST SALES]
FROM Sales.Orders
--)T WHERE [TOP HIGHEST SALES] = 2

--RANKD THE ORDER BASED ON THEIR SALES FROM HIGHEST TO LOWEST 

SELECT 
	OrderDate,
	OrderID,
	ProductID,
	Sales,
	ROW_NUMBER()  OVER (ORDER BY SAles DESC) [ROW_NUMBER],
	RANK() OVER (ORDER BY SALES DESC) [RANK FUNCTION],
	DENSE_RANK() OVER (ORDER BY SALES DESC) [DENSE RANK]
FROM Sales.Orders

--CALCULATE THE MOVING AVERAGE OF SALES FOR EACH PRODUCT OVER TIME, INCLUDING ONLY THE NEXT ORDER
SELECT 
	ProductID,
	OrderID,
	OrderDate,
	SALES,
	AVG (Sales) OVER (PARTITION BY PRODUCTID) [AVERAGEBYPRODUCT],
	AVG (Sales) OVER (PARTITION BY PRODUCTID ORDER BY ORDERDATE) [MOVING AVERAGE],
	AVG (Sales) OVER (PARTITION BY PRODUCTID ORDER BY ORDERDATE ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING ) [ROLLING AVERAGE]
FROM Sales.Orders
--CALCULATE THE MOVING AVERAGE OF SALES FOR EACH PRODUCT OVER TIME .

SELECT 
	ProductID,
	OrderID,
	OrderDate,
	SALES,
	AVG (Sales) OVER (PARTITION BY PRODUCTID) [AVERAGEBYPRODUCT],
	AVG(Sales) OVER (PARTITION BY PRODUCTID ORDER BY ORDERDATE) [MOVING AVERAGE]
FROM Sales.Orders

--RUNNING AND ROLLING CONCEPTS  ^
--FIND THE DEVIATION OF EACH SALES 
--FROM THE MINIMUM AND MAXIMUM SALES AMOUNT

SELECT 
	OrderID,
	OrderDate,
	Sales,
	MAX(Sales) OVER () AS HIGHESTSALES,
	MIN(Sales) OVER () AS LOWESTSALES,
	SALES - MIN (SALES) OVER () DEVIATION_FROM_MIN,
	MAX(SALES) OVER () - SALES DEVIATION_FROM_MAX
FROM Sales.Orders

--SHOW THE EMPLOYEES WITH THE HIGHEST SALARIES 
SELECT * FROM (
SELECT
	EmployeeID,
	Salary,
	MAX(Salary) OVER() MAX_SALARY
FROM Sales.Employees
)T WHERE Salary = MAX_SALARY

--FIND THE HIGHEST AND LOWEST SALES ACROSS ALL ORDERS
--AND THE HIGHEST AND THE LOWEST SALES FOR EACH PRODUCT
--ADDITIONALLY , PROVIDE DETAILS SUCH AS ORDERID AND ORDERDATE .

SELECT 
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	MAX(Sales) OVER () HIGHEST_SALES,
	MIN(Sales) OVER () LOWEST_SALES,
	MAX(Sales) OVER (PARTITION BY PRODUCTID) MAX_SALES_PER_PRODUCT,
	MIN(Sales) OVER (PARTITION BY PRODUCTID) MIN_SALES_PER_PRODUCT
FROM Sales.Orders

--FIND ALL ORDERS WHERE SALES IS HIGHER THAN THE AVERAGE SALES ACROSS ALL ORDERS 
SELECT * FROM (
SELECT 
	OrderID,
	Sales,
	ProductID,
	AVG(COALESCE(Sales,0)) OVER () AVERAGE_SALES
FROM SALES.Orders )T WHERE COALESCE(Sales,0) > AVERAGE_SALES -- CAN ONLY INCLUDE THE COLUMNS IN THE OUTER QUERY THAT IS INCLUDED IN THE INNER QUERY



--FIND THE AVERAGE SCORE OF THE CUSTOMERS AND 
--ADDITIONALLY PROVIDE ALL THE INFORMATIONS SUCH AS CUSTOEMRID AND LAST NAME 
SELECT 
	CustomerID,
	LastName,
	Score,
	SUM (COALESCE(SCORE,0)) OVER() TOTALSCORE,
	AVG (SCORE) OVER() AVERAGE, -- AVERAGE WITHOUT HANDLING NULL 
	AVG(COALESCE(SCORE,0)) OVER() AVGSCORE -- AVERAGE WITH NULLS HANDLED
FROM Sales.Customers

--FIND THE AVERAGE SALES ACROSS ALL ORDERS AND 
--AND FIND THE AVERAGE SALES FOR EACH PRODUCT	
--ADDITIONALLY PROVIDE DETAILS SUCH AS ORDERID ORDERDATE 

SELECT 
	OrderDate,
	OrderID,
	Sales,
	ProductID,
	AVG (COALESCE(SALES,0)) OVER() TOTAL_AVERAGE, -- COALESCE IS FOR HANDLING THE NULL 
	AVG (COALESCE(Sales,0)) OVER (PARTITION BY PRODUCTID) AVGPERPRODUCT
FROM Sales.Orders

--FIND THE PERCENTAGE CONTIRBUTION OF EACH PRODUCT'S 
--SALE TO THE TOTAL SALE
SELECT 
	OrderID,
	OrderDate,
	SUM (Sales) OVER () AS TOTAL_SALES,
	ROUND(CAST(SALES AS float)/SUM(SALES) OVER () * 100,3) PERCENT_OF_TOTAL 

	FROM Sales.Orders
--FIND THE TOTAL SALES ACROSS ALL ORDERS
--FIND THE TOTAL SALES FOR EACH PRODUCT 
--ADDITIONALLY PROVIDE DETAILS SUCH AS ORDERID AND ORDER DATE  
SELECT 
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	SUM(Sales) OVER() AS TOTAL_SALES,
	SUM(Sales) OVER(PARTITION BY PRODUCTID) AS SALES_PER_PRODUCT
FROM Sales.Orders

--CHECK WHETHER THE TABLE 'ORDERS' CONTAIN ANY DUPLICATE ROWS.
SELECT
	COUNT (*) OVER(PARTITION BY )
FROM Sales.Orders
--FIND THE TOTAL NUMBER OF SCORES FROM CUSTOMERS 
SELECT
	COUNT (*) OVER () TotalCustomers,
	COUNT (Score) OVER() TotalScores

FROM Sales.Customers

--FIND THE TOTAL NUMBER OF CUSTOMERS 
--ADDITIONALL PROVIDE ALL THE CUSTOMERS DETAILS 

SELECT 
	*,
	COUNT(*) OVER() CUSTOMER_COUNT
FROM Sales.Customers

--FIND THE TOTAL NUMBER OF ORDERS 
--FIDN THE TOTAL NUMBER ORDER FOR EACH CUSTOMER
--PROVIDE DETAILS SUCH AS THE ORDERID AND THE ORDERDATE

SELECT
	CustomerID,
	OrderID,
	OrderDate,
	COUNT(*) OVER() TotalOrders ,
	COUNT (*) OVER (PARTITION BY CUSTOMERID) ORDERBYCUSTOMERS
FROM Sales.Orders

--RANK THE CUSTOMERS BASED ON THEIR TOTAL SALES .
SELECT 
	CustomerID,
	SUM(Sales) TOTAL_SALES, --SINCE WE HAVE AGGREGATED HERE SO THIS WILL BE A PART OF GROUP BY WE HAVE TO USE THIS IN THE WINDOW ALSO 
	RANK () OVER (ORDER BY SUM(SALES) DESC) RankCustomers --THE YOU CAN ADD THE WINDOW FUNCTIONS 
FROM Sales.Orders 
GROUP BY CustomerID --ADD GROUP BY FIRST


--find the total sales for each order status ,
--only for two productid 101 and 102 
SELECT  
	OrderStatus,
	SUM(Sales) OVER(PARTITION BY ORDERSTATUS)
FROM Sales.Orders
WHERE ProductID IN (101,102)
--GROUP BY OrderStatus

--FRAME SHORT FORM AND FRAME FULL FORM  
SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER(ORDER BY ORDERDATE ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) TOTAL_SALES
FROM Sales.Orders

--SHORT FORM OF FRAME 
SELECT 
	OrderID,
	OrderStatus,
	OrderDate,
	Sales,
	SUM(SALES) OVER (ORDER BY ORDERDATE ROWS 2 PRECEDING) TOTAL_SALES
FROM Sales.Orders

--SELF PRACTICE  
SELECT
	ORDERID,
	ORDERDATE,
	ORDERSTATUS,
	SALES,
	SUM(SALES) OVER(PARTITION BY ORDERSTATUS ORDER BY ORDERDATE
	ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING ) TOTAL_SALES
FROM SALES.Orders


--RANK EACH ORDER BASED ON THEIR SALES FROM HIGEST TO LOWEST 
--ADDITIONALLY PROVIDE INFORMATION SUCH AS ORDERID AND ORDER DATE
SELECT
	OrderID,
	OrderDate,
	Sales,
	RANK() OVER(ORDER BY SALES DESC) RANKSALES
FROM Sales.Orders

--SELF PRACTICE : SALES RAND IN DESCENDING OVER MONTH OF SHIPPING DATE
SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	MONTH(ShipDate) AS ORDER_MONTH,
	RANK() OVER (PARTITION BY MONTH(SHIPDATE) ORDER BY SALES DESC)
FROM Sales.Orders 

--ALSO FIND THE TOTAL SALES ACROSS ALL ORDERS
--FIND THE TOTAL SALES FOR EACH PRODUCT 
--FIND THE TOTAL SALES FOR EACH COMBINATION OF PRODUCT AND ORDERSTATUS 
--ADDITIONALLY PROVIDE DETAILS SUCH AS ORDERID AND ORDERDATE

SELECT
	
	OrderID,
	OrderDate,
	ProductID,
	OrderStatus,
	Sales,
	SUM(Sales) OVER() TOTAL_SALES,
	SUM(Sales) OVER (PARTITION BY PRODUCTID) SALES_PER_PRODUCT,
	SUM(Sales) OVER (PARTITION BY PRODUCTID,ORDERSTATUS) SALES_BY_PRODUCTSAND_STATUS
FROM Sales.Orders

--FIND THE TOTAL SALES ACROSS ALL ORDERS 
--ADDITIONALLY PROVIDE ADDITIONAL INFORMATION LIKE ORDERID AND ORDERDATE  \
SELECT 
	OrderID,
	OrderDate,
	SUM(Sales) OVER () --WE DO NOT HAVE TO GIVE ANY WINDOW BECAUSE WE HAVE TO FIND THE TOTAL SALES ACROSS ALL ORDERS
FROM Sales.Orders

--FIND THE TOTAL SALES FOR EACH PRODUCT , 
--ADDITIONALLY PROVIDE DETAILS	SUCH AS ORDER ID & ORDER DATE

SELECT 
	ProductID,
	OrderID,
	OrderDate,
	SUM(Sales) OVER(PARTITION BY PRODUCTID)
FROM Sales.Orders


--FIND THE TOTAL SALES FOR EACH PRODUCT  
SELECT 
	ProductID,
	SUM(SALES) SALES_PER_PROD
FROM Sales.Orders
GROUP BY ProductID


--------------------------------------^WINDOW FUNCTIONS^----------------------------------------------------
SELECT* 
FROM Sales.Orders
--find the total sales across all orders 
SELECT SUM(Sales) TOTAL_SALES
FROM Sales.Orders


--ANALYSE THE CUSTOMER DATA  
-- THIS IS ALL BASIC ANALYTICS
SELECT 
	country,
	MIN(score) AS LOWEST_SCORE,
	MAX(score) AS HIGHEST_SCORE,
	SUM(score) AS TOTAL_SCORE,
	AVG(score) AS AVG_SCORE,
	COUNT(*) AS COUNT_OF_CUSTOMERS
FROM customers
GROUP BY country

--ALL THE BELOW TASK TOGETHER IS BASIC DATA ANALYSIS .
SELECT
	customer_id,
	MIN(sales) AS LOWEST_SALES,
	MAX(sales) AS HIGHEST_SALES,
	SUM(sales) AS TOTAL_SALES,
	AVG(SALES) AS AVERAGE_SALE,
	COUNT(*) AS COUNT_SALES
FROM orders
GROUP BY customer_id -- GROUPING BY WILL BREAK THE DATA HENCE INCREASE ITS GRANULAIRTY OR LEVEL OF DETAILS 

--FIND THE LOWEST SALES AMONG THE ORDERS
SELECT 
	MIN(sales) AS LOWEST_SALES
FROM orders

--FIND THE HIGHES SALES AMONG THE ORDERS
SELECT 
	MAX(sales) AS HIGHEST_SALES
FROM orders
--FIND THE AVERAGE SALE OF ALL ORDERS
SELECT 
	AVG(sales) AS AVERAGE_SALES
FROM orders 
--FIND THE TOTAL SALES OF ALL THE ORDERS  
SELECT 
	SUM(SALES) AS TOTAL_SALES
FROM orders

--FIND THE TOTAL NUMBER OF CUSTOMERS 
SELECT 
	COUNT(*) AS TOTAL_NR_ORDERS
FROM Orders

--COUNT HOW MANY TIMES EACH CUSTOMER HAS MADE AN ORDER WITH SALES > 30  

SELECT 
	CustomerID,
	SUM(CASE 
		WHEN Sales > 30 THEN 1
		ELSE 0
	END) AS [TOTAL_SALES>30],
	COUNT(*) AS TOTAL_SALES
FROM Sales.Orders
GROUP BY CustomerID


-- FIND THE AVEREAGE SCORE OF CUSTOMERS AND TREAT NULLS AS 0 
-- AND ADDITIONALLY PROVIDE DETAILS SUCH AS CUSTOMERID AND LASTNAME  

SELECT 
CustomerID,
LastName,
AVG (COALESCE(SCORE,0)) OVER() AS [AVG WITH COALESCE], -- AVERAGE WITH COALESCE 
AVG(CASE                                              -- AVERAGE WITH CASE  
	WHEN SCORE IS NULL THEN 0
	ELSE SCORE
END) OVER() AS [AVG WITH CASE],
AVG(Score) OVER() AS [AVG UNCLEANED]                  -- AVERAGE WITHOUT CLEANING 
FROM Sales.Customers

--RETRIEVE CUSTOMER DETAILS WITH ABBREVIATED COUNTRY CODE 
SELECT DISTINCT 
Country
FROM Sales.Customers

SELECT 
CustomerID,
FirstName,
LastName,
Country,
	CASE
		WHEN Country = 'Germany' then 'DE'
		WHEN Country = 'USA' THEN 'US'
		ELSE 'N/A'
	END AS CountryCode
FROM Sales.Customers
-- WRITING THE ABOVE LOGIC WITH THE QUICK CASE FORMAT  

SELECT 
CustomerID,
FirstName,
LastName,
Country,
	CASE Country
		WHEN 'Germany' then 'DE'
		WHEN 'USA' THEN 'US'
		ELSE 'N/A'
	END AS CountryCode
FROM Sales.Customers
--retrieve employee details as gender displayed as full text
SELECT 
	EmployeeID,
	FirstName,
	LastName,
	Gender,
	CASE
		WHEN Gender = 'M' THEN 'MALE'
		WHEN Gender = 'F' THEN 'FEMALE'
		ELSE 'NOT AVAILABLE'
	END GENDER
FROM Sales.Employees



--CASE WHEN THEN ELSE END  
--GENERATE A REPORT SHOWING THE TOTAL SALES FOR EACH CATEGORY:
--HIGH: IF THE SALES IS GREATER THAN 50 
--MEDIUM: IF HTE SALES IS BETWEEN 20 AND 50 
--LOW : IF THE SALES IS LOWER THAN 20 
--SORT THE RESULTS FROM HIGHEST SALES TO THE LOWEST 
SELECT 
CATEGORY,
SUM(Sales) TOTAL_SALES --USED THE SUB QUERY TO CREATE A CATEGORY COLUMN AND THEN USE THE OUTER QUERY TO SUM THE SALES FOR EACH CATEGORY
FROM (
	SELECT 
		OrderID,
		Sales,
		CASE 
			WHEN Sales > 50 THEN 'HIGH'
			WHEN Sales > 20 THEN 'MEDIUM'
			ELSE 'LOW'
		END CATEGORY
	FROM Sales.Orders
)T
GROUP BY CATEGORY
ORDER BY TOTAL_SALES DESC


--LIST OF ALL DETAILS FROM CUSTOMERS WHO HAVE NOT PLACED AND ORDERS 
--USECASE OF IS NULL AND IS NOT NULL 
SELECT C.*,
O.OrderID
FROM Sales.Customers C
LEFT JOIN Sales.Orders O
ON C.CustomerID =O.CustomerID
WHERE O.CustomerID IS NULL 

SELECT * 
FROM Sales.Orders
--SHOW THE LIST OF ALL THE CUSTOMERS WHO HAVE SCORES 
SELECT 
	*
FROM Sales.Customers
WHERE Score IS NOT NULL

--IDENTIFY THE CUSTOMERS WHO HAVE NO SCORES 
SELECT 
*
FROM Sales.Customers
WHERE Score IS NULL

--FIND THE SALES PRICE FOR EACH ORDER BY DIVIDING THE SALES BY THE QUANTITY 
--USE CASE OF NULLIF 
SELECT 
Sales,
Quantity,
(Sales/Quantity) AS SALE_PRICE -- THIS WILL GIVE A DIVIDE BY ZERO ERROR 
FROM Sales.Orders  
-- TO CORRECT THIS 
SELECT
	OrderID,
	Sales,
	Quantity,
	Sales/NULLIF(Quantity,0) AS SALE_PRICE
FROM Sales.Orders

--SORT THE CUSTOMERS FROM THE LOWEST TO THE HIGHEST SCORES WITH THE NULL APPEARING LAST 
--1 ST WAY TO DO THIS -- USING THE LAZY METHOD
SELECT 
CustomerID,
FirstName,
Score
FROM Sales.Customers
ORDER BY COALESCE(Score,99999) ASC 
--2ND WAY TO DO THIS  -- USING A FLAG LOGIC 
SELECT 
CustomerID,
FirstName,
Score
FROM Sales.Customers
ORDER BY CASE WHEN Score IS NULL THEN 1 ELSE 0 END ASC ,Score ASC


-- display the full name of customer in a single field 
--by merging their first and last name 
--and add 10 bouns points to each customers score 
SELECT 
FirstName,
LastName,
FirstName+''+COALESCE(LastName,' ') AS FULL_NAME,
Score,
COALESCE(Score,0)+10
FROM Sales.Customers

--find the average score of the customers 
SELECT 
CustomerID,
score,
AVG(COALESCE(SCORE,0)) over() AS AVERAGE_SCORE	-- WITH COALESCE
FROM Sales.Customers

--WITHOUT COALESCE 
SELECT 
CustomerID,score,AVG(SCORE) over() as average_score
FROM Sales.Customers

--


--ISDATE 
SELECT 
	ISDATE('123') DATECHECK ,
	ISDATE('2025') DATECHECK2,
	ISDATE('2025-08-20') DATECHECK3,
	ISDATE('20') DATECHECK4


--DATEDIFF 
--THIS IS ALSO CALLED AS TIME GAP ANALYSIS
--FIND THE NUMBER OF DAYS BETWEEN EACH ORDER AND PREVIOUS ORDERD

SELECT
	OrderID,
	OrderDate AS [CURRENT DATE] ,
	LAG(OrderDate) OVER (ORDER BY ORDERDATE) [PREVIOUS DATE],
	DATEDIFF(DAY,LAG(ORDERDATE) OVER(ORDER BY ORDERDATE),OrderDate) AS NROFDAYS
FROM Sales.Orders

--FIND THE AVERAGE SHIPPINING DURATION IN DAYS FOR EACH MONTH
SELECT 
	MONTH(ShipDate),
	AVG(DATEDIFF(DAY,OrderDate,ShipDate)) AS [AVG SHIPPING DURATION] -- AVERAGE SHIPPING DURATION 
FROM Sales.Orders
GROUP BY MONTH(ShipDate) --GROUPED BY EACH MONTH

--CALCULATE THE AGE OF THE EMPLOYEES 

SELECT 
	EmployeeID,FirstName,LastName,
	DATEDIFF(YEAR,BirthDate,GETDATE()) AS [AGE OF EMPLOYEE]
FROM Sales.Employees



--DATEADD(PART,INTERVAL,DATE)
SELECT 
	OrderDate,
	DATEADD(YEAR,2,OrderDate) AS [2YEARS ADDED] ,
	DATEADD(MONTH,5,OrderDate) AS [5 MONTHS ADDED],
	DATEADD(DAY,6,OrderDate) AS [6 DAYS ADDED],
	DATEADD(MONTH,-7,OrderDate) AS [7 MONTHS SUBTRACTED],
	CreationTime,
	DATEADD(DAY,5,CreationTime) [5 DAYS ADDED TO CREATION TIME],
	--OR ANOTHER WAY TO DO THIS 
	DATEADD(DAY,5,CAST(CreationTime AS date)) AS [CREATION TIME AS DATE]
FROM Sales.Orders


--CAST
SELECT CAST('123' AS INT) AS [STRING AS INTEGER],
CAST (132 AS VARCHAR) AS [INTEGER AS STRING],
CAST ('2025-03-26' AS DATE) AS [STRING AS DATE],
CAST ('2025-03-26' AS datetime2) AS [STRING AS DATETIME],
CreationTime,
CAST (CreationTime AS date) AS [DATETIME TO DATE]
FROM Sales.Orders

-- CONVERT 

SELECT 
	CONVERT(INT,'123') AS [stirng to int CONVERT],
	CONVERT(DATE,'2025-08-08') AS [string to date CONVERT],
	CONVERT(DATE,CreationTime) AS [CREATION TIME AS DATE],
	CONVERT(TIME,CreationTime) AS [CREATION TIME AS TIME],
	CreationTime,
-- YOU CAN USE FORMATTING INSIDE THE CONVERT AS WELL 
	CONVERT(VARCHAR,CreationTime,32) AS [USA TIME FORMAT STYLE: 32],
	CONVERT(VARCHAR,CreationTime,34) AS [EURO TIME FORMAT STYLE: 34]
FROM Sales.Orders

--using format do the date aggregation on months 
-- THIS IS SAME AS USING THE DATEPART 
SELECT 
	FORMAT(OrderDate,'MMM yy'),
	COUNT(*)
FROM Sales.Orders
GROUP BY FORMAT(OrderDate,'MMM yy')

--SHOW CREATION TIME USING THE FOLLOWING FORMAT
--DAY WED JAN Q1 2025 12:34:56 PM SHOW THIS AS A STRING 
SELECT
CreationTime,
'DAY '+FORMAT(CreationTime,'ddd MMM')+ 
' Q'+DATENAME(QUARTER,CreationTime)+' '+
FORMAT(CreationTime,'yyyy hh:mm:ss tt')AS CUSTOM_FORMAT
FROM Sales.Orders


--using format :
SELECT 
CreationTime,
FORMAT(CreationTime,'dd/MM/yyyy') as format1,
FORMAT(CreationTime, 'MM-yyyy-dd')as format2,
FORMAT(CreationTime,'yyyy-MM-dd') format3,
FORMAT(CreationTime,'ddd-MM-yyyy') format4,
FORMAT(CreationTime, 'dd-MMM') format5,
FORMAT(CreationTime, 'dd-MMM-yyyy') format6,
FORMAT(CreationTime,'dddd-MM-yyyy') format7,
FORMAT(CreationTime,'MMMM') AS MONTH_FROM_DATE,
FORMAT(CreationTime, 'MM-dd-yyyy') AS USA_format
FROM Sales.Orders


select 
OrderDate,
CreationTime,
FORMAT(CreationTime,'dd') dd,
Format(CreationTime,'ddd') as ddd,
Format(CreationTime,'dddd') as dddd,
format(CreationTime,'mm') mm, --minutes,
--months
FORMAT(CreationTime,'MM','ja-jP')MM,
FORMAT(CreationTime,'MMM')MMM 
from Sales.Orders





--practice session 25-05
--SHOW ALL THE ORDERS THAT WAS PLACED DURING THE MONTH OF FEBRUARY

SELECT OrderID,ProductID,OrderDate
FROM Sales.Orders
WHERE MONTH(OrderDate) = 2

--HOW MANY ORDERS WERE PLACED EACH MONTH
SELECT 
	MONTH(OrderDate) ORDER_MONTH,COUNT(*) NROFORDERS
FROM Sales.Orders
GROUP BY MONTH(OrderDate)

--BETTER WAY TO DO THIS 
SELECT 
DATENAME(MONTH,OrderDate) MONTH_NAME,COUNT(*) NROFORDERS
FROM Sales.Orders
GROUP BY DATENAME(MONTH,OrderDate)

--HOW MANY ORDERS WERE PLACED EACH YEAR
SELECT 
	YEAR(OrderDate) ORDER_YEAR,COUNT(*) NROFORDERS
FROM Sales.Orders
GROUP BY YEAR(OrderDate)

SELECT month(CreationTime),
count(*)
FROM Sales.Orders
group by month(CreationTime);

SELECT CreationTime
FROM SALES.ORDERS;

SELECT 
	MONTH(CreationTime) AS MONTH_CR1,
	DAY(CreationTime) AS DAY_CR1,
	DATEPART(DAY,CreationTime) AS DAY_CR,
	DATEPART(MONTH,CreationTime) MONTH_CR,
	DATEPART(YEAR,CreationTime) YEAR_CR,
	DATETRUNC(DAY,CreationTime) AS DATE_TRUN_DAY,
	DATETRUNC(MONTH,CreationTime) AS DATE_TRUNC_MONTH,
	DATETRUNC(YEAR,CreationTime) AS DATE_TRUNC_YEAR,
	DATETRUNC(MONTH,OrderDate) AS DATE_TRUN_MONTH,
	DATETRUNC(YEAR,OrderDate) AS DATE_TRUN_YEAR,
	OrderDate,
	OrderID
FROM Sales.Orders

SELECT * 
FROM Sales.Orders


--practice session 24-03
--FIND THE TOTAL NUMBER OF SCORE FOR THE CUSTOMERS(PAY ATTENTION THAT THAT CUSTOMER SCORE HAS A NULL VALUE)
SELECT 
	*,
	COUNT(Score) OVER() TOTAL_SCORE
FROM Sales.Customers

--FIND THE TOTAL NUMBER OF CUSTOMERS AND ADDITIONALLY PROVIDE ALL THE CUSTOMER DETAILS 

SELECT	
	FirstName,
	LastName,
	Country,
	Score,
	COUNT(*) OVER () TOTAL_CUSTOMERS
FROM Sales.Customers

--FIND THE TOTAL NUMBER OF ORDERS 
--FIND THE TOTAL FOR EACH CUSTOMER
--PROVIDE OTHER DETAILS SUCH AS ORDERID AND ORDERDATE
SELECT 
	OrderID,
	OrderDate,
	CustomerID,
	COUNT(*) OVER () TOTALORDERS,     -- WE CAN HAVE MULITPLE LEVEL OF DETAILS IN ONE SINGLE QUERY WHEN WE USE WINDOW FUNCTION
	COUNT(*) OVER(PARTITION BY CUSTOMERID) ORD_BY_CUST
FROM Sales.Orders

--FIND THE TOTAL NUMBER OF ORDERS 
--PROVIDE OTHER DETAILS SUCH AS ORDERID AND ORDERDATE

SELECT 
	OrderID,
	OrderDate,
	COUNT(*) OVER() TOTAL_ORDERS
FROM Sales.Orders

--find the total number of orders 
SELECT 
	COUNT(*) TOTAL_ORDERS
FROM Sales.Orders



-- ranks customers based on their total sales  :
-- FIND THE TOTAL NUMBER OF ORDERS OF EACH PRODUCT :

SELECT 
	ProductID,
	OrderStatus,
	COUNT(*) OVER (PARTITION BY PRODUCTID)
FROM Sales.Orders


SELECT 
	CustomerID,
	rank() OVER(ORDER BY SUM(Sales))
FROM Sales.Orders
group by CustomerID


-- PRACITCE SESSION 20-03-2026
--WORKING WITH THE FRAMES 

SELECT 

	OrderID,OrderStatus,Sales,OrderDate,
	SUM (Sales) OVER (PARTITION BY ORDERSTATUS ORDER BY ORDERDATE ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
FROM Sales.Orders


SELECT 
	OrderID,OrderStatus,Sales,OrderDate,
	SUM (Sales) OVER (PARTITION BY ORDERSTATUS ORDER BY ORDERDATE ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING )
FROM Sales.Orders

SELECT * FROM Sales.Orders

--practice session 19-03-2026
--Write a query to fetch clients whose KYC expiry date is within the next 30 days.
SELECT * FROM Sales.Orders
SELECT
	OrderID,ProductID,DATETRUNC(MONTH,CreationTime),DATEADD(DAY,30,CreationTime)
FROM Sales.Orders
WHERE CreationTime BETWEEN DATETRUNC(MONTH,CreationTime) AND DATEADD(DAY,30,CreationTime)
	
--ADDING AND SUBTRACTING DAYS,MONTHS AND YEARS FROM THE GIVEN DATE 
select 
DATEADD(DAY,30,CreationTime) AS 'DATE+30DAYS',
CreationTime
FROM Sales.Orders

SELECT 
DATEADD(YEAR,-20,CreationTime)
FROM Sales.Orders


SELECT * FROM Sales.Orders
-- RANK EACH ORDER BASED ON THEIR SALES FROM HIGHEST TO LOWEST , ADDITIONALLY PROVIDE DETAILS : ORDERID AND ORDER DATE.

SELECT top(1)
	ORDERID,
	OrderDate,
	RANK() OVER(ORDER BY SALES DESC) Rank_sales
FROM Sales.Orders


-- THE BELOW CAN BE DONE IN A SINGLE QUERY AS WELL , THIS SHOW THE FLEXIBILTY OF THE WINDOW FUNCTIONS :
--ADD IN THE THE TOATL SALES OF EACH COMBINATION OF PRODUCT AND ORDER STATUS
SELECT 
	OrderID,
	OrderDate,
	Sales,
	OrderStatus,
	SUM(Sales) OVER() AS TOTAL_SALES,
	SUM(Sales) OVER(PARTITION BY ProductID) SALES_PER_PRODUCT,
	SUM(Sales) OVER(PARTITION BY ProductID, OrderStatus) comb_productid_status
FROM Sales.Orders

--FIND THE TOTAL SALES ACROSS ALL ORDERS AND  ADDITIONALLY PROVIDE DETAILS SUCH AS ORDER ID AND ORDER DATE 
SELECT
	OrderID,
	OrderDate,
	SUM(Sales) OVER() AS TOTAL_SALES
FROM Sales.Orders
--FIND THE TOTAL SALES FOR EACH PRODUCT AND ADDITIONALLY PROVIDE DETAILS SUCH AS ORDER ID AND ORDER DATE 
SELECT 
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER(PARTITION BY ProductID ) AS TOTAL_SALES
FROM Sales.Orders

 --find the total sales across all orders
 SELECT		
	SUM(Sales)
 FROM Sales.Orders

 --FIND THE TOTAL SALES OF EACH PRODUCT
 SELECT ProductID,SUM(Sales)
 FROM Sales.Orders
 GROUP BY ProductID
 --ORDER BY OrderID ASC

--PRACTICE SESSION 07-03-2026

--HOW MANY ORDERS WERE PLACE EAH MONTH:

SELECT 
	DATENAME(MONTH,OrderDate),
	COUNT (*)
FROM SaleS.Orders
GROUP BY DATENAME(MONTH,OrderDate)

select datename(month,(month(OrderDate)))
from Sales.Orders
-- HOW MANY ORDERS WERE PLACED EACH YEAR ;
SELECT 
	YEAR(OrderDate),
	COUNT(*)
FROM Sales.Orders
GROUP BY YEAR(OrderDate)

--USING eOMONTH():

SELECT 
	EOMONTH('2025-08-20') 
--CAN ALSO BE USED WITH THE COULMNS : DATE COLUMNS
SELECT 
	EOMONTH(CreationTime) E_OF_MONTH,
	CreationTime
FROM Sales.Orders

--ORDERS GROUPED BY CRETION TIME( GRANULARITY OF THE COLUMN IS VERY HIGH TO MUCH INFORMATION )
SELECT 
	CreationTime,
	COUNT(*)
FROM Sales.Orders
GROUP BY CreationTime

--TO GROUP THE ORDERS BY CREATION TIME /WE CAN USE THE DATETRUNC FUNCTION AS:
SELECT 
	DATETRUNC(MONTH,CreationTime), --this is actually just creation time grouped by month
	COUNT(*)
FROM Sales.Orders
GROUP BY DATETRUNC(MONTH,CreationTime)

-- WE CAN ALSO DO IT AS  :
SELECT 
	MONTH(CreationTime),
	COUNT (*)
FROM Sales.Orders
GROUP BY MONTH(CreationTime)
--USING DAATETRUNC FUNCTION:

SELECT 
	OrderID,
	CreationTime,
	DATETRUNC(MINUTE,CreationTime) AS MIN_DT,
	DATETRUNC(HOUR,CreationTime) AS HOUR_DT,
	DATETRUNC(DAY,CreationTime) AS DAY_DT,
	DATETRUNC(MONTH,CreationTime) AS MONTH_DT,
	DATETRUNC(YEAR,CreationTime) AS YEAR_DT
FROM Sales.Orders

--USING DATE NAME FUNCTION :
SELECT OrderID,
	CreationTime,
	DATENAME(WEEKDAY,CreationTime) AS DAY_OF_WEEK,
	DATENAME(YEAR,CreationTime) AS YEAR,
	DATENAME(MONTH,CreationTime) AS MONTH,
	DATENAME(HOUR,CreationTime) AS HOUR ,
	DATENAME(DAY,CreationTime) AS DAY ,-- the output is stored as string
	DATEPART(DAY,CreationTime) AS DAY_DP, -- the output is stored as integer
	--SAME WITH THE YEAR 
	DATENAME(YEAR,CreationTime) AS YEAR_DN,-- the output of this is stored as string
	DATEPART(YEAR,CreationTime) AS YEAR_DP -- the output of this is stored as integer
FROM Sales.Orders

SELECT FirstName,
	REPLACE(FirstName,'e','o') AS MODIFIED_NAME
FROM Sales.Customers

SELECT * FROM Sales.Customers

SELECT 
	OrderID,DATEPART(HOUR,GETDATE()) AS HOUR,GETDATE(),CreationTime
FROM Sales.Orders
	




--practice session 05-03-2026

--using datepart() 

SELECT 
	OrderID,
	CreationTime,
	DATEPART(MONTH,CreationTime) AS MONTH ,
	DATEPART(MINUTE,CreationTime) AS MINUTES_INSE,
	DATEPART(HOUR,CreationTime) AS HOUR_INSER,
	DATEPART(WEEKDAY,CreationTime) as week_day
FROM Sales.Orders
--using date functions DAY ,MONTH ,YEAR 
SELECT 
	OrderID,
	CreationTime,
	DAY(CreationTime) as DAY , --DAY 
	MONTH(CreationTime) AS MONTH, -- MONTH
	YEAR(CreationTime) AS YEAR -- YEAR
FROM Sales.Orders

--PRACTICE SESSION 22-1-2026
--using the given date in table , hardcoded and GETDATE() 
SELECT 
    OrderID
	OrderDate,-- GIVEN IN TABLE
	CreationTime, --GIVEN IN TABLE
	'2026-02-22' AS HARDCODED,-- HARDCODED
	GETDATE() AS CUR_DATE -- CURRENT_dATE
FROM Sales.Orders

	
--PRACTICE SESSION 21-02-2026
--use round function and round a number :

SELECT
3.516,
ROUND(3.516,2) AS ROUND_2,
ROUND(3.516,1) AS ROUND_1,
ROUND(3.516,0) AS ROUND_0
--retrieve the list of customers first name removing the first character :
SELECT 
	first_name,
	SUBSTRING(TRIM(first_name),2,LEN(first_name))
FROM customers

--retrieve the last 2 characters of each first_name 
SELECT 
	first_name,RIGHT(TRIM(first_name),2) last_2_char
FROM customers

--retrieve the first 2 characters of each first_name
SELECT first_name,LEFT(TRIM(first_name),2) FRST_2_CHAR
FROM customers

--calculte the length of each customers first name  :
SELECT first_name,
LEN(TRIM(first_name)) AS LEN_NAME
FROM customers

--use case for replace() : changing the extension of the file name from .txt to .csv
SELECT 
'filename.txt' AS OLD_FILE,
REPLACE('filename.txt','.txt','.csv') AS NEW_FILE

--Replace() practice using static value  :
SELECT 
'123-456-7890' AS PHONE_NO,
REPLACE('123-456-7890','-','') AS CLEANED_PHONE_NO

--you can also do the below finding the customers with leading or trailing space with len :
SELECT first_name
FROM customers
WHERE LEN(first_name) != LEN(TRIM(first_name))

--find customers whose first name contains leading and trailing spaces 
SELECT first_name
FROM customers
WHERE first_name != TRIM(first_name) -- THIS MEANS THAT IF THE FIRST NAME IS NOT EQUAL TO ITSELF AFTER TRIMMING THAT MEANS IT HAD SOME SPACE.
--convert the first name into upper case :

SELECT id,first_name,country,score,UPPER(first_name) AS UPP_NAME
FROM customers

--conver the first name to lower case :
SELECT id,first_name,score,LOWER(first_name) AS LOW_NAME 
FROM customers

--concatenate first name and country in one column :
SELECT id,CONCAT(first_name,' ' ,country)AS 'FIRST_NAME & COUNTRY ',score
FROM customers


select * from customers

-- practice session 12-02-2026
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


