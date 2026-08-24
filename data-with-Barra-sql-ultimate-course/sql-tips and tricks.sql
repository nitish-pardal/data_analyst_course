/*SQL tips and tricks*/

--=========================================================
--FETCHING DATA :
--=========================================================

--=========================================================
--TIP 1 : SELECT ONLY WHAT YOU NEED 

--BAD PRACTICE:
SELECT * FROM Sales.Customers

--GOOD PRRACTICE:
SELECT 
	CustomerID,FirstName,LastName
FROM Sales.Customers

--=========================================================
--TIP 2 : AVOID UNNECESSARY DISTINCT AND ORDER BY 

--BAD PRACTICE:
SELECT DISTINCT 
	FirstName
FROM Sales.Customers
ORDER BY FirstName

--GOOD PRACTICE:
SELECT 
	FirstName
FROM Sales.Customers