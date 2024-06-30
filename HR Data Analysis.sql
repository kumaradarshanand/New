/* Creating Table */

create table hrdata
(
	emp_no int8 PRIMARY KEY,
	gender varchar(50) NOT NULL,
	marital_status varchar(50),
	age_band varchar(50),
	age int8,
	department varchar(50),
	education varchar(50),
	education_field varchar(50),
	job_role varchar(50),
	business_travel varchar(50),
	employee_count int8,
	attrition varchar(50),
	attrition_label varchar(50),
	job_satisfaction int8,
	active_employee int8
);

/* Q1: What is the total no. of employee ? */

SELECT COUNT(emp_no) AS employee_count
FROM hrdata;

/* Q2: What is the total no. of employee whose educational qualification is High School? */

SELECT COUNT(emp_no) AS employee_count
FROM hrdata
WHERE education = 'High School';

/* Q3: What is the total no. of employee according to the department? */

SELECT department, COUNT(emp_no) AS employee_count
FROM hrdata
GROUP BY department;

/* Q4: What is the count of attrition where attrition is 'Yes' and Job role is Sales Executive? */

SELECT COUNT(attrition) 
FROM hrdata
WHERE attrition = 'Yes' AND job_role = 'Sales Executive'; 

/* Q5: What is the attrition rate? */

SELECT 
((SELECT COUNT(attrition) 
  FROM hrdata 
  WHERE attrition='Yes')/ 
  SUM(employee_count)) * 100 
AS attrition_rate
FROM hrdata;

/* Q6: What is the count of active employee? */

SELECT COUNT(attrition) AS active_employee
FROM hrdata
WHERE attrition = 'No';

/* Q7: What is the average age of employee? */

SELECT ROUND(AVG(age),0)
AS avg_age
FROM hrdata;

/* Q8: What is the attrition according to gender? */
 
SELECT gender, COUNT(attrition) AS attrition_count
FROM hrdata
Where attrition = 'Yes'
GROUP BY gender;

/* Q9: What is the attrition according to department and education is Associates Degree? */
 
SELECT department, COUNT(attrition) AS attrition_count
FROM hrdata
Where attrition = 'Yes' AND education = 'Associates Degree'
GROUP BY department;

/* Q10: What is the count of employee according to the age_band? */

SELECT age_band, COUNT(emp_no) AS employee_count
FROM hrdata
GROUP BY age_band
ORDER BY employee_count DESC;