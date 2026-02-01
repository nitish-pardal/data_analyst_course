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

--Show employees working in the IT department

--Show department name along with employee salaries

--🟠 LEFT JOIN (IMPORTANT 🔥)

--Show all employees, even if they don’t belong to a department

--Find employees who are not assigned to any department

--🔴 Interview-Style Thinking

--Find the total salary per department

--Show departments with more than 1 employee

--List employees with salary above the department average







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
