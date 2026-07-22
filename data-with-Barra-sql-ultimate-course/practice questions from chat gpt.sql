--TO ANALYZE THE CUSTOMER LOYALTY RANK THE CUSTOMERS BASED ON THEIR AVERAGE DAYS BETWEEN THE ORDERS
SELECT 
    CustomerID,
    AVG([DAYS BETWEEN THE ORDERS]) [AVERAGE DAYS],
    RANK() OVER( ORDER BY AVG([DAYS BETWEEN THE ORDERS])) [CUSTOMER RANKS]
FROM (
        SELECT 
            CustomerID,
            OrderDate,
            LEAD(OrderDate,1)OVER(PARTITION BY CUSTOMERID ORDER BY ORDERDATE)[NEXT ORDER DATE],
            DATEDIFF(DAY,ORDERDATE,LEAD(OrderDate,1)OVER(PARTITION BY CUSTOMERID ORDER BY ORDERDATE))[DAYS BETWEEN THE ORDERS]
            FROM DBO.ORDER_PRACTICE
)T
GROUP BY CustomerID

-- analyse the month over month analysis by finding the percentage of change in the sales between the current and the previous month.
SELECT  *,
   [CURRENT SALES]-[PREVIOUS SALES] AS [MOM DIFFERENCE],
  ROUND(CAST( [CURRENT SALES]-[PREVIOUS SALES] AS float) * 100 /[PREVIOUS SALES],2) [PERCENT MOM]
FROM ( 
    SELECT 
        MONTH(OrderDate) [SALES MONTH],
        SUM(Sales) [TOTAL SALES],
        SUM(Sales) [CURRENT SALES],
        LAG(SUM(Sales),2) OVER(ORDER BY MONTH(ORDERDATE)) [PREVIOUS SALES]
    FROM dbo.ORDER_PRACTICE
    GROUP BY MONTH(OrderDate)
)T

SELECT * INTO ORDER_PRACTICE2 
FROM Sales.OrdersArchive

SELECT * FROM ORDER_PRACTICE2


DELETE FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ORDERID ORDER BY ORDERDATE ) [ROW_NUM]
FROM dbo.ORDER_PRACTICE
)T 
WHERE [ROW_NUM] > 1 

WITH T AS (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ORDERID ORDER BY ORDERDATE ) ROW_NUM
	FROM dbo.ORDER_PRACTICE
)
DELETE FROM T 
WHERE ROW_NUM > 1 




-- practice questions  - 1-02-2026

--🟢 Basics

--Display all employees
SELECT * FROM  [dbo].[employees]

--Show only emp_name, job_title, and salary

SELECT emp_name ,job_title , salary
FROM employees 

--Find employees with salary greater than 50,000

SELECT * FROM employees 
WHERE salary > 50000

--List employees hired after 1st Jan 2022
SELECT * 
FROM EMPLOYEES
WHERE hire_date  > '2022-01-01'

--🔵 Aggregates

--Find the average salary of employees

SELECT avg(salary)
FROM employees

--Find the highest salary
SELECT MAX(salary)
FROM employees

--Count number of employees per job title
SELECT job_title , count(emp_id) as employee_count
FROM employees
group by job_title

--🟣 INNER JOIN

--Show employee name and department name
SELECT E.emp_name, D.dept_name
FROM employees AS E
INNER JOIN departments AS D
ON E.dept_id = D.dept_id

--Show employees working in the IT department
SELECT E.emp_name, D.dept_name
FROM employees AS E
INNER JOIN departments AS D
ON E.dept_id = D.dept_id
WHERE d.dept_name = 'IT'


--Show department name along with employee salaries

SELECT E.salary, D.dept_name
FROM employees AS E
INNER JOIN departments AS D
ON E.dept_id = D.dept_id


--🟠 LEFT JOIN (IMPORTANT 🔥)
select * from employees ;
select * from departments;

--Show all employees, even if they don’t belong to a department
SELECT * 
FROM employees as E
LEFT JOIN departments AS D 
ON E.dept_id = D.dept_id

--Find employees who are not assigned to any department
SELECT * 
FROM employees as E
LEFT JOIN departments AS D 
ON E.dept_id = D.dept_id
WHERE  e.dept_id IS NULL --this works OR 
WHERE d.dept_id is NULL -- this is better because if there is any unmathed row int the case of left join the table created in the left join 
--will have nulls in the rows for which it has no match in the left  

--🔴 Interview-Style Thinking

--Find the total salary per department


SELECT D.dept_id ,D.dept_name, SUM(E.salary) AS TOTAL_SALARY
FROM employees AS E
INNER JOIN departments AS D
ON E.dept_id = D.dept_id
GROUP BY D.dept_id,D.dept_name


--Show departments with more than 1 employee
SELECT * FROM employees
SELECT * FROM departments

--List employees with salary above the department average
-- THIS IS A CLASSIC EXAMPLE OF CORRELATED SUBQUERY AS 
SELECT * 
FROM employees AS E
INNER JOIN departments AS D
ON E.dept_id = D.dept_id
WHERE E.salary > (SELECT AVG(E2.SALARY) FROM employees AS E2 WHERE E.dept_id = E2.dept_id)





-- table creation and data insertion  

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    job_title VARCHAR(50),
    salary INT,
    dept_id INT,
    hire_date DATE
);
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
INSERT INTO departments VALUES
(10, 'IT', 'Bangalore'),
(20, 'HR', 'Mumbai'),
(30, 'Finance', 'Delhi'),
(40, 'Marketing', 'Pune');

INSERT INTO employees VALUES
(1, 'Rahul', 'Software Engineer', 60000, 10, '2022-01-10'),
(2, 'Anita', 'HR Executive', 45000, 20, '2021-03-15'),
(3, 'Vikram', 'Accountant', 50000, 30, '2020-07-01'),
(4, 'Neha', 'Software Engineer', 65000, 10, '2023-02-20'),
(5, 'Arjun', 'Marketing Lead', 70000, 40, '2019-11-05'),
(6, 'Kiran', 'Data Analyst', 55000, NULL, '2023-06-01');
