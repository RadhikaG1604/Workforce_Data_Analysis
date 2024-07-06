/* Viewing sample data from all tables */
SELECT * FROM company_divisions
LIMIT 5;

SELECT * FROM company_regions
LIMIT 5;

SELECT * FROM staff
LIMIT 5;

/* Total number of employees */
SELECT COUNT(*) AS total_employee_count
  FROM staff;
/* There a total of 1000 employees in the company. */

/* Distribution of gender */
SELECT 
      SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS "Male",
	  SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS "Female"
  FROM staff;
/* There are around 504 men and 496 women in the company */

/* Distinct departments in the company */
SELECT DISTINCT(department)
  FROM staff
ORDER BY department;

/* Distribution of employees acrosss departments */
SELECT c.department, COUNT(s.id) AS employee_count
  FROM staff s JOIN
       company_divisions c ON
	   s.department = c.department
GROUP BY c.department
ORDER BY employee_count DESC;
/* When joining the staff with company_divisions, it was observed that the number of employees did not sum upto 1000,
which is the actual number of employees in the company */

/* Distribution of employees acrosss departments */
SELECT c.department, COUNT(s.id) AS employee_count
  FROM staff s LEFT JOIN
       company_divisions c ON
	   s.department = c.department
GROUP BY c.department
ORDER BY c.department;
/* On doing a LEFT JOIN, it can be seen that the 'Books' department is not updated in the 'company_divisions',
hence it has to be added to the company divisions. */

/* Adding 'Books' department to company_divisions */
INSERT INTO company_divisions VALUES('Books', 'Entertainment')

/* Distribution of gender across departments */
SELECT department,
       SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS "Male",
	   SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS "Female"
  FROM staff
GROUP BY department
ORDER BY department;
/* On observing the gender distribution across multiple departments, it can be observed that 'Automotive', 
'Electronics', 'Industrial', 'Movies' and 'Toys' have higher number of men, while departments such as 'Clothing',
'Home', and 'Outdoors' have higher number of women. Other departments have almost an equal proportion of 
both gender */

/* Salary differences between gender */
SELECT gender, ROUND(MIN(salary),2) As Min_Salary, 
               ROUND(MAX(salary),2) AS Max_Salary, 
			   ROUND(AVG(salary),2) AS Average_Salary
  FROM staff
GROUP BY gender;
/* When analyzing the average salary, a pay gap doesn't seem to exist between men and women. */

/* Salary by job title */
SELECT job_title, gender, ROUND(MIN(salary),2) As Min_Salary,
                  ROUND(MAX(salary),2) AS Max_Salary, 
			      ROUND(AVG(salary),2) AS Average_Salary
  FROM staff
GROUP BY job_title, gender
ORDER BY job_title DESC;
/* Even upon analyzing the job specific pay, it can be observed that there are various roles in which females earn
higher in comparison to male and vice versa as well. There are also roles where in they have equal pay. Hence there
is no clear evidence of any distinct wage gap from the given dataset. */

/* Salary by department */
SELECT department, ROUND(MIN(salary),2) As Min_Salary, 
                   ROUND(MAX(salary),2) AS Max_Salary, 
			       ROUND(AVG(salary),2) AS Average_Salary
  FROM staff
GROUP BY department
ORDER BY Average_Salary DESC
LIMIT 5;
/* The departments with highest average salary are Outdoors, Tools, Games, Beauty and Garden */

/* Which department has the highest salary spread out ? */
SELECT 
	department, 
	ROUND(MIN(salary),2) As Min_Salary, 
	ROUND(MAX(salary),2) AS Max_Salary, 
	ROUND(AVG(salary),2) AS Average_Salary,
	ROUND(STDDEV_POP(salary),2) AS StandardDev_Salary,
	COUNT(*) AS total_employees
FROM staff
GROUP BY department
ORDER BY StandardDev_Salary DESC;
/* The Health Department has the highest variation in the salary of individuals */

/* Creating earning categories to see the salary earning status for Health Department */
CREATE VIEW health_dept_earning_status
AS 
	SELECT 
		CASE
			WHEN salary >= 100000 THEN 'high earner'
			WHEN salary >= 50000 AND salary < 100000 THEN 'middle earner'
			ELSE 'low earner'
		END AS earning_status
	FROM staff
	WHERE department LIKE 'Health';

SELECT earning_status, COUNT(*)
FROM health_dept_earning_status
GROUP BY 1;
/* It can be observed that there are 2 individuals in the high earners category, 14 workers in the medium earning
and 2 workers in the low earning category */

/* Creating earning categories to see the salary earning status for Outdoors Department */
CREATE VIEW outdoors_dept_earning_status
AS 
	SELECT 
		CASE
			WHEN salary >= 100000 THEN 'high earner'
			WHEN salary >= 50000 AND salary < 100000 THEN 'middle earner'
			ELSE 'low earner'
		END AS earning_status
	FROM staff
	WHERE department LIKE 'Outdoors';
	
SELECT earning_status, COUNT(*)
FROM outdoors_dept_earning_status
GROUP BY 1;
/* It can be observed that there are 34 individuals in the high earners category, 12 workers in the medium earning
and 2 workers in the low earning category */

/* Comparing to his/her department average salary */
SELECT
	s.last_name,s.salary,s.department,
	(SELECT ROUND(AVG(salary),2)
	 FROM staff s2
	 WHERE s2.department = s.department) AS department_average_salary
FROM staff s
ORDER BY s.department;

/* Count of people earning above/below the average salary of his/her department */
CREATE VIEW vw_salary_comparision_by_department
AS
	SELECT 
	s.department,
	(
		s.salary > (SELECT ROUND(AVG(s2.salary),2)
					 FROM staff s2
					 WHERE s2.department = s.department)
	)AS is_higher_than_dept_avg_salary
	FROM staff s
	ORDER BY s.department;
		
SELECT * FROM vw_salary_comparision_by_department;

SELECT department, is_higher_than_dept_avg_salary, COUNT(*) AS total_employees
FROM vw_salary_comparision_by_department
GROUP BY 1,2;
/* Beauty, Games, Computers, and Outdoors have relatively higher number of individuals earning salary higher than 
the department's average salary. Conversely, categories like Industrial, Garden, Sports, and Music has higher number
of individuals lower than the department's average salary */

/* Finding the highest salary in each department */
SELECT department, salary, dept_rank
  FROM (SELECT department, last_name, salary,
	      RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
          FROM staff) temp_table
WHERE dept_rank = 1;
/* The Grocery department has the highest salary at $149,929, while the Music department has the lowest at $144,608 */