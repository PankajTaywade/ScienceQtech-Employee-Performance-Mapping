-- 1. Create a database named employee.
CREATE DATABASE employee;

-- 2. Import data_science_team.csv, proj_table.csv and emp_record_table.csv into the employee database.
USE employee;
SHOW TABLES;
   
/*
3. Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, and make a list of 
   employees and details of their department.
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM emp_record_table;

/*
4. Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is:
   • less than two
   • greater than four 
   • between two and four
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE  EMP_RATING < 2;

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE  EMP_RATING > 4;

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE  EMP_RATING BETWEEN 2 AND 4;

/*
5. Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department from the employee table and 
   then give the resultant column alias as NAME.
*/
SELECT CONCAT(FIRST_NAME, ' ', LAST_NAME) AS NAME
FROM emp_record_table
WHERE DEPT = 'FINANCE';

/*
6. Write a query to list only those employees who have someone reporting to them. Also, show the number of reporters 
   (including the President).
*/
SELECT E.EMP_ID, E.FIRST_NAME, E.LAST_NAME, E.ROLE, COUNT(E.EMP_ID) AS REPORTERS
FROM emp_record_table E
INNER JOIN emp_record_table M
	ON E.EMP_ID = M.MANAGER_ID
WHERE E.ROLE IN ('President', 'Manager')
GROUP BY E.EMP_ID
ORDER BY REPORTERS DESC;

/*
7. Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee 
   record table.
*/
SELECT * 
FROM emp_record_table
WHERE DEPT = 'HEALTHCARE'
UNION
SELECT * 
FROM emp_record_table
WHERE DEPT = 'FINANCE'
ORDER BY DEPT, EMP_ID;

/*
8. Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. 
   Also include the respective employee rating along with the max emp rating for the department.
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EMP_RATING, 
       MAX(EMP_RATING) OVER (PARTITION BY DEPT) AS MAX_DEPT_RATING
FROM emp_record_table
GROUP BY DEPT, EMP_ID, FIRST_NAME, LAST_NAME, ROLE, EMP_RATING;

/*
9. Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table.
*/
SELECT ROLE, MIN(SALARY) AS Min_Salary, MAX(SALARY) AS Max_Salary
FROM emp_record_table
GROUP BY ROLE;

-- 10. Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EXP,
	   RANK() OVER(ORDER BY EXP DESC) AS EMP_EXP_RANK,
       DENSE_RANK() OVER(ORDER BY EXP DESC) AS EMP_EXP_DENSE_RANK
FROM emp_record_table;

/*
11. Write a query to create a view that displays employees in various countries whose salary is more than six thousand. 
    Take data from the employee record table.
*/
CREATE OR REPLACE VIEW EMP_MORE_THAN_6K_SALARY AS
SELECT EMP_ID, ROLE, FIRST_NAME, LAST_NAME, COUNTRY, SALARY 
FROM emp_record_table
WHERE SALARY > 6000
ORDER BY SALARY DESC;

SELECT * FROM EMP_MORE_THAN_6K_SALARY;

-- 12. Write a nested query to find employees with experience of more than ten years. Take data from the employee record table.
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, EXP 
FROM (SELECT * 
      FROM emp_record_table 
      WHERE EXP > 10) AS 10_YEARS_PLUS_EXP
ORDER BY EXP DESC;

/*
13. Write a query to create a stored procedure to retrieve the details of the employees whose experience is more than three years. 
    Take data from the employee record table.
*/
DELIMITER &&
CREATE PROCEDURE EXP_MORE_THAN_3_YEARS()
BEGIN
	SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, EXP  
	FROM emp_record_table
	WHERE EXP > 3
	ORDER BY EXP DESC;
END &&

CALL EXP_MORE_THAN_3_YEARS();

/*
14. Write a query using stored functions in the project table to check whether the job profile assigned to each employee in the data 
    science team matches the organization’s set standard.
    The standard is:
    For an employee with experience less than or equal to 2 years assign 
    'JUNIOR DATA SCIENTIST',
    For an employee with the experience of 2 to 5 years assign 'ASSOCIATE 
    DATA SCIENTIST',
    For an employee with the experience of 5 to 10 years assign 'SENIOR 
    DATA SCIENTIST',
    For an employee with the experience of 10 to 12 years assign 'LEAD 
    DATA SCIENTIST',
*/
DELIMITER &&
CREATE FUNCTION EMP_ROLE(EXP INT)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN 
	DECLARE EMP_ROLE VARCHAR(225);
    IF EXP <= 2 THEN
		SET EMP_ROLE = 'JUNIOR DATA SCIENTIST';
	ELSEIF EXP BETWEEN 2 AND 5 THEN
		SET EMP_ROLE = 'ASSOCIATE DATA SCIENTIST';
	ELSEIF EXP BETWEEN 5 AND 10 THEN 
		SET EMP_ROLE = 'SENIOR DATA SCIENTIST';
	ELSEIF EXP BETWEEN 10 AND 12 THEN
		SET EMP_ROLE = 'LEAD DATA SCIENTIST';
	END IF;
    RETURN EMP_ROLE;
END &&
DELIMITER &&;

SELECT EMP_ID, FIRST_NAME, LAST_NAME, EXP, EMP_ROLE(EXP) AS JOB_PROFILE
FROM data_science_team
ORDER BY EXP DESC;

/*
15. Create an index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’ in the employee 
    table after checking the execution plan.
*/
CREATE INDEX idx_first_name 
ON emp_record_table(FIRST_NAME(10));

SELECT * FROM emp_record_table
WHERE FIRST_NAME = 'Eric';

/*
16. Write a query to calculate the bonus for all the employees, based on their ratings and salaries 
    (Use the formula: 5% of salary * employee rating).
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, SALARY, EMP_RATING, (SALARY * EMP_RATING * 0.05) AS BONUS
FROM emp_record_table
ORDER BY BONUS DESC;

/*
17. Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee 
    record table.
*/
SELECT EMP_ID, FIRST_NAME, LAST_NAME, COUNTRY, CONTINENT, 
	   ROUND(AVG(SALARY) OVER (PARTITION BY CONTINENT ORDER BY COUNTRY),0) AS AVG_SALARY
FROM emp_record_table;


