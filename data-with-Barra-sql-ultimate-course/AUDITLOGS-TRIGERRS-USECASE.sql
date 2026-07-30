--======================================================================
--STEP 4 : SELECTING THE RECORDS FROM EMPLOYEE_LOGS TABLE TO SEE IF THE TRIGGER HAS FIRED AND INSERTED A RECORD INTO EMPLOYEE_LOGS TABLE
--======================================================================

SELECT * FROM Sales.EMPLOYEE_LOGS;

--=======================================================================
--STEP 3 : INSERTING A NEW RECORD INTO EMPLOYEES TABLE THAT WILL FIRE THE TRIGGER AND INSERT A RECORD INTO EMPLOYEE_LOGS TABLE
--=======================================================================

INSERT INTO Sales.Employees
	VALUES
(8,'NITISH','PARDAL','IT','2000-08-08','M',55000,3);

--==========================================
--step2 : create trigger on Employees Table
--==========================================

CREATE TRIGGER trg_afterInsertEmployee ON sales.Employees
AFTER INSERT 
AS
BEGIN 
	INSERT INTO Sales.Employee_LOGS (EMPLOYEEID,LOGMESSAGE,LOGDATE)
	SELECT 
		EmployeeID,
		'NEW EMPLOYEE ADDED = '+ CAST(EMPLOYEEID AS NVARCHAR),
		GETDATE()
	FROM inserted -- INSERTED IS A SPECIAL VITUAL TABLE THAT HOLDS A COPY OF THE ROWS THAT ARE BEING INSERTED INTO THE TARGET TABLE
	--THIS IS ONLY AVAILABLE DURING THE EXECUTION OF THIS TRIGGER
END;




/*========================================
--STEP1 : CREATE TABLE AS EMPLOYEES LOGS
--========================================*/

CREATE TABLE SALES.Employee_logs  
(	Logid INT IDENTITY(1,1) PRIMARY KEY,
	EmployeeId INT ,
	LogMessage VARCHAR(255),
	LogDate DATETIME
)
