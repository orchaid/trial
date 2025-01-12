SELECT 
    job_posted_date, job_posted_date::DATE, 
    DATE (job_posted_date),
    EXTRACT (year from job_posted_date),
    job_posted_date at time zone 'UTC' AT TIME ZONE 'PST'
FROM job_postings_fact
LIMIT 10; --trainig with date and time functions


SELECT 
    EXTRACT (MONTH FROM job_posted_date) AS month,
    COUNT(EXTRACT (MONTH FROM job_posted_date)) AS count
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst' -- the month of january has the most data analyst job postings
GROUP BY month
ORDER BY count DESC;


SELECT  
    AVG(salary_year_avg) AS yearly,
    AVG(salary_hour_avg) AS hourly,
    job_schedule_type
FROM 
    job_postings_fact
WHERE 
    job_posted_date > '2023-06-01' AND (salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL) 
GROUP BY    
    job_schedule_type
LIMIT 1000 --average yearly and hourly salary for job postings after june 2023


SELECT  
    EXTRACT (MONTH FROM job_posted_date) AS month,
    COUNT(EXTRACT (MONTH FROM job_posted_date AT TIME ZONE 'UTC')) AS count
FROM 
    job_postings_fact 
GROUP BY    
    month
ORDER BY month; --the month of january has the most job postings


SELECT
    company_dim.name,
    EXTRACT (MONTH FROM job_posted_date) AS month
FROM job_postings_fact
LEFT JOIN company_dim 
    ON job_postings_fact.company_id = company_dim.company_id
WHERE job_health_insurance = 'true' AND job_posted_date BETWEEN '2023-04-01' AND '2023-06-30'; --companies name with health insurance in the second quarter of 2023

---------------------

CREATE TABLE jan_jobs AS
SELECT 
    *
FROM 
    job_postings_fact
WHERE 
    EXTRACT (MONTH FROM job_posted_date) = 1;


CREATE TABLE feb_jobs AS
SELECT 
    *
FROM 
    job_postings_fact
WHERE 
    EXTRACT (MONTH FROM job_posted_date) = 2;


CREATE TABLE mar_jobs AS
SELECT 
    *
FROM 
    job_postings_fact
WHERE 
    EXTRACT (MONTH FROM job_posted_date) = 3;

---------------------

SELECT
    COUNT(job_id) AS count,
    
    CASE
        WHEN job_location = 'New York, NY' THEN 'local'
        WHEN job_location = 'Anywhere' THEN 'remote'
        ELSE 'On site'
    END AS location_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category; --count of data analyst job postings by location category in relation to New York, NY



SELECT 
    COUNT(job_id) AS count,
    CASE
        WHEN salary_year_avg < 50000 THEN 'low'
        WHEN salary_year_avg BETWEEN 50000 AND 100000 THEN 'medium'
        ELSE 'high'
    END AS salary_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst' --average yearly salary for data analyst job postings by salary category
GROUP BY salary_category;

----------------------

SELECT 
    COUNT(job_id) AS count,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM    
    (SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1 OR EXTRACT(MONTH FROM job_posted_date) = 2
    ) AS january_jobs
GROUP BY month


WITH february_jobs AS (
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2
)
SELECT 
    job_title_short,
    COUNT(job_id) AS count
FROM february_jobs
GROUP BY job_title_short



SELECT
    name,
    company_id
    
FROM company_dim
WHERE company_id IN (      --IN operator is for more than one value within a column
SELECT
    company_id
FROM job_postings_fact
WHERE job_no_degree_mention = 'true' --companies that do not require a degree
);


/* 
    The following query finding the companies that has the most job openings 
    The results will be ordered by the number of job postings in descending order.
*/

WITH jobs AS (
    SELECT 
        company_id,
        COUNT(*) AS count
    FROM job_postings_fact
    GROUP BY company_id
)
SELECT 
    name,
    count
FROM company_dim
LEFT JOIN jobs ON
    company_dim.company_id = jobs.company_id
ORDER BY count DESC

--or through this query

SELECT 
    COUNT(job_title_short),
    company_dim.company_id,
    name
FROM job_postings_fact
RIGHT JOIN company_dim ON
    company_dim.company_id = job_postings_fact.company_id 
GROUP BY 
    company_dim.company_id
ORDER BY 
    COUNT(job_title_short) DESC


-- Top 5 skills that are most frequently mentioned in job postings


WITH job_skills AS
(
    SELECT 
        job_id,
        skills_job_dim.skill_id
    FROM skills_job_dim
    LEFT JOIN skills_dim ON
        skills_job_dim.skill_id = skills_dim.skill_id 
)
SELECT 
    skills_dim.skills,
   -- skills_dim.skill_id,
    COUNT(job_id) AS count
FROM skills_dim
left JOIN job_skills ON
    job_skills.skill_id = skills_dim.skill_id
GROUP BY skills_dim.skills    --skills_dim.skill_id
ORDER BY count DESC; --1.sql, 2.python, 3.aws, 4.azure, 5.r are the top 5 skills that are most frequently mentioned in job postings




-- determine the size catogory of companies ('small','medium' or 'large') based on job postings they have 

SELECT
    name,
    COUNT(job_id) AS count,
    CASE
        WHEN COUNT(job_id) < 10 THEN 'small'
        WHEN COUNT(job_id) BETWEEN 10 AND 50 THEN 'medium'
        ELSE 'large'
    END AS category
FROM company_dim
RIGHT JOIN job_postings_fact ON
    company_dim.company_id = job_postings_fact.company_id
GROUP BY  name
ORDER BY count DESC; --without supquery



SELECT
    name,
    count,
    CASE
        WHEN count < 10 THEN 'small'
        WHEN count BETWEEN 10 AND 50 THEN 'medium'
        ELSE 'large'
    END AS category
FROM (
    SELECT 
        name,
        COUNT(job_id) AS count
    FROM job_postings_fact
    left JOIN company_dim ON
    company_dim.company_id = job_postings_fact.company_id
    GROUP BY name
) AS job_counts
ORDER BY count DESC;  --with subquery




/* 
find the count of the number of remote job postings per skill 
    - display the top 5 skills by their demand in remote jobs 
    - include the skill id, name and the count of postings requiring the skill  
*/

WITH remote_jobs AS (
    
    SELECT
        job_postings_fact.job_id,
        skills_job_dim.skill_id,
        skiLls_dim.skills 
    FROM 
        job_postings_fact
    LEFT JOIN skills_job_dim ON
        job_postings_fact.job_id = skills_job_dim.job_id
    left JOIN skills_dim ON
        skills_job_dim.skill_id = skills_dim.skill_id
    WHERE 
        --job_location = 'Anywhere' or
        job_work_from_home = true
)
SELECT
    remote_jobs.skills,
    COUNT(job_id) AS count
FROM 
    remote_jobs
GROUP by 
    remote_jobs.skills 
ORDER BY count DESC
LIMIT 5; 

--OR

WITH job_remote AS(
    SELECT     
        skills_job_dim.skill_id,
        COUNT(*) AS count
    FROM job_postings_fact
    JOIN skills_job_dim ON
        job_postings_fact.job_id = skills_job_dim.job_id
    WHERE job_work_from_home = true
    GROUP BY skills_job_dim.skill_id
)
SELECT
    skills_dim.skills,
    job_remote.skill_id,
    count
FROM job_remote
JOIN skills_dim ON
    job_remote.skill_id = skills_dim.skill_id
ORDER BY count DESC
LIMIT 5;

/* using UNION */

SELECT 
    job_title_short,
    company_id,
    job_location
FROM jan_jobs
UNION 
SELECT 
    job_title_short,
    company_id,
    job_location
FROM feb_jobs
UNION 
SELECT
    job_title_short,
    company_id,
    job_location
FROM mar_jobs; --union of january, february and march job postings (compining tables)




-- skills, type and job title of job postings first quarter of 2023 with salary greater than 70000
SELECT
    skills,
    type,
    job_title_short
FROM skills_dim
right JOIN skills_job_dim ON
    skills_dim.skill_id = skills_job_dim.skill_id
right JOIN job_postings_fact ON
    job_postings_fact.job_id = skills_job_dim.job_id
WHERE job_posted_date < '2023-04-01' AND salary_year_avg > 70000; --skills, type and job title of job postings before april 2023 with salary greater than 70000


WITH cte_tab AS (  
    SELECT 
        salary_year_avg,
        job_id,
        job_title_short
    FROM jan_jobs
    UNION ALL
    SELECT 
        salary_year_avg,
        job_id,
        job_title_short
    FROM feb_jobs
    UNION ALL
    SELECT
        salary_year_avg,
        job_id,
        job_title_short
    FROM mar_jobs
), cte2 AS (
    SELECT 
        salary_year_avg,
        job_title_short,
        skills_job_dim.skill_id 
    FROM cte_tab
    LEFT JOIN skills_job_dim ON
        cte_tab.job_id = skills_job_dim.job_id
)
SELECT 
    job_title_short,
    skills,
    type
FROM cte2
LEFT JOIN skills_dim ON
    skiLls_dim.skill_id = cte2.skill_id
WHERE salary_year_avg > 70000; --union of job postings with skills and salary greater than 70000

--or much much easier
SELECT
    job_title_short,
    salary_year_avg,
    skills_job_dim.skill_id AS skillid,
    skills_dim.skills,
    skills_dim.type
FROM 
    (
    SELECT 
        *
    FROM jan_jobs
    UNION 
    SELECT 
        *
    FROM feb_jobs
    UNION 
    SELECT
        *
    FROM mar_jobs
    ) AS quarter1
LEFT JOIN skills_job_dim ON
        quarter1.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim ON
    skills_dim.skill_id = skills_job_dim.skill_id
WHERE 
    salary_year_avg > 70000;-- AND job_title_short = 'Data Analyst'


SELECT
    job_title_short,
    job_location,
    job_via,
    job_posted_date::DATE
    salary_year_avg
FROM 
    (
    SELECT 
        *
    FROM jan_jobs
    UNION 
    SELECT 
        *
    FROM feb_jobs
    UNION 
    SELECT
        *
    FROM mar_jobs
    ) AS quarter1
WHERE 
    salary_year_avg > 70000 AND
    job_title_short = 'Data Analyst';
-- job postings with salary higher than 70k for data analyst
