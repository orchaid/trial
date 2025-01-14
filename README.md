# Introduction
Dive into the data jobs, and specifically foucusing into data analyst roles to find out what are the most required skills for this field, what are the top paying and most demanded skills in data analytics.

You will be able to find SQL queries here: [Project_sql folder](/Project_sql/)  


# Background
while learning SQL i found Luke Barousse channel in youtube and this data set and the idea behinde the project is from him.
### the questions that got answered through my SQL queries are:
1. what are the most paid data analyst jobs?
2. what are the skills required for these top-paying jobs?
3. what skills are most in-demand for data analytics?
4. which skills are associated with higher salaries?
5. what are the most optimal skills to learn?

# Tools I Used
I used several key tools:
- **SQL**: Quering my database and extracting insights
- **PostgreSQL**: The chosen database management system
- **Git & Github**: Version control and sharing my SQL scripts and analysis
- **Visual Studio Code**: My go-to for database management and executing SQL queries
# The Analysis
Each query tried to answer a pecific question we had about the data analyst job market.
Here is how aproached each question:
### 1. top paying data analyst jobs
To find the highest paying data analyst opportunities, i wrote a query that provide values where it is only data analyst jobs and for the specific case of being remote to be able to work from anywhere.
```sql
SELECT 
    job_title_short,
    job_title,
    salary_year_avg AS salary,
    name AS company_name
FROM job_postings_fact
LEFT JOIN company_dim ON
    company_dim.company_id = job_postings_fact.company_id
WHERE 
    job_title_short = 'Data Analyst' AND
    job_location = 'Anywhere' AND 
    salary_year_avg IS NOT NULL
ORDER BY salary DESC
LIMIT 10;
```
**Key Insights from the Data:**

* **Data Analyst Demand:** The presence of various job titles (Data Analyst, Director of Analytics, Principal Data Analyst) indicates a diverse range of roles and skill levels within the Data Analyst field.
* **High Average Salary:** The average salary for the top 10 highest-paying remote Data Analyst jobs is $264,506.15 per year. This suggests a strong demand for skilled data analysts in these top 10 remote roles.
* **Significant Variation:** Salaries exhibit significant variation, with one outlier at $650,000 potentially skewing the average. This highlights the importance of considering individual roles and company factors.
* **Company Salary Rankings:** The top 5 highest-paying companies are:
    1. Mantys stands out as the highest-paying company 
    2. Meta
    3. AT&T
    4. Pinterest Job Advertisements
    5. Uclahealthcareers
 
 ![Top paying roles](/assets/1_top%20paying%20roles.png) *this graph shows the most paying data analytics role; this graph was created by ChatGPT
 from my SQL query results.*

 ### 2. Skills for top paying jobs
 After looking at the top paying roles, I wanted to find out what kind of skills do these high paying jobs require. 
 ```sql
WITH top_paying_jobs AS 
(
    SELECT 
        job_postings_fact.job_id,
        
        job_title_short,
        job_title,
        salary_year_avg AS salary,
        name AS company_name
    FROM job_postings_fact
    LEFT JOIN company_dim ON
        company_dim.company_id = job_postings_fact.company_id
    
    WHERE 
        job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere' AND 
        salary_year_avg IS NOT NULL
    ORDER BY salary DESC
    LIMIT 10
)
SELECT
    job_title,
    skills,
    salary,
    company_name
FROM top_paying_jobs
LEFT JOIN skills_job_dim ON
        skills_job_dim.job_id = top_paying_jobs.job_id
JOIN skills_dim ON
    skills_job_dim.skill_id = skills_dim.skill_id
 ```
**Key Insights from the Data:**
The top 10 most in-demand skills across all roles are:

1. **SQL** is leading with  (8 mentions)
2. **Python** follows closely with (7 mentions)
3. **Tableau** is highly sought after (6 mentions)
4. **R** with (4 mentions)
5. **Snowflake** with (3 mentions)
6. **Pandas** with (3 mentions)
7. **Excel** with (3 mentions)
8. **Azure** with (2 mentions)
9. **Bitbucket** with (2 mentions)
10. **Go** with (2 mentions)

SQL and Python are the most frequently required skills.

![In-demand skills](/assets/3_top10%20paying%20skills.png) *bar graph visualizing the most demanded skills for data analyst role; this graph was created by ChatGPT
 from my SQL query results.*


 ### 3. In-demand skills for data analyst jobs
 I wanted to know what are the most asked for skills that is required from a data analyst in genral.
 ```sql
 SELECT
    skills,
    COUNT(job_postings_fact.job_id) count
FROM skills_dim
    JOIN skills_job_dim ON
        skills_dim.skill_id = skills_job_dim.skill_id
    JOIN job_postings_fact ON
        skills_job_dim.job_id = job_postings_fact.job_id
WHERE job_location = 'Anywhere' AND job_title_short = 'Data Analyst'
GROUP BY skills
ORDER BY count DESC
LIMIT 5;
 ```
The results show a blend of traditional tools like **SQL** and **Excel** with modern programming languages like **Python** and data visualization tools like **Tableau** and **Power BI**.

| Skills | Count |
|---|--------|
| sql | 7291 |
| excel | 4611 |
| python | 4330 |
| tableau | 3745 |
| power bi | 2609 |
| r | 2142 |
| sas | 1866 |


 *The table of the demand on skills data analysis jobs*
 
 Staying updated on the first 5 in-demand skills is crucial for aspiring and current remote Data Analysts.

 
 ### 4. Skills based on salary
Then I was curious to find which skills are the highest paid by exploring it with the average salary.

 ```sql
 SELECT 
    ROUND (AVG (salary_year_avg)) AS average_salary ,
    --salary_year_avg AS average_salary,
    skills
    --job_title_short
FROM
    (SELECT 
        skills_dim.skills,
        skills_job_dim.job_id
    FROM skills_dim
    JOIN skills_job_dim ON
        skills_dim.skill_id = skills_job_dim.skill_id
    ) AS skills_job_id
JOIN job_postings_fact ON
    skills_job_id.job_id = job_postings_fact.job_id
WHERE salary_year_avg IS NOT NULL AND
    job_title_short = 'Data Analyst' AND
    job_location = 'Anywhere'
GROUP BY skills
ORDER BY average_salary DESC
LIMIT 25;
```
Here are the insights :

- **Specialized Tools Dominate**: High-paying skills like PySpark ($208,172), Databricks, and Pandas
 show the importance of big data frameworks and data manipulation libraries for data analyst roles.

- **Cloud & Infrastructure Skills**: Expertise in Kubernetes ($132,500), GCP ($122,500), and Jenkins 
 highlights the growing demand for cloud and workflow automation skills.

- **AI & Machine Learning Platforms**: Tools like Watson ($160,515), DataRobot ($155,486), and Scikit-learn
 reflect the integration of advanced analytics and machine learning in data analyst roles.

- **Database and Programming Skills**: Knowledge of PostgreSQL ($123,879), Scala ($124,903), and Elasticsearch ($145,000) remains essential,
 showcasing the need for both database management and coding expertise.

| Average Salary | Skills       |
|----------------|--------------|
| 208172         | pyspark      |
| 189155         | bitbucket     |
| 160515         | couchbase    |
| 160515         | watson       |
| 155486         | datarobot    |
| 154500         | gitlab       |
| 153750         | swift        |
| 152777         | jupyter      |
| 151821         | pandas       |
| 145000         | elasticsearch|


*This table presents the top 10 skills along with their associated average salaries.*

 ### 5. Most optimal skills to learn.
Having in mind both the most in demand skills and their average salary to weigh the skills to learn for the future.
```sql
SELECT
    --skills_job_dim.skill_id,
    skills,
    COUNT(job_postings_fact.job_id) count,
    ROUND(AVG (salary_year_avg)) AS average_sal
FROM skills_dim
JOIN skills_job_dim ON
    skills_dim.skill_id = skills_job_dim.skill_id
JOIN job_postings_fact ON
    skills_job_dim.job_id = job_postings_fact.job_id
WHERE 
    job_location = 'Anywhere' AND
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
GROUP BY skills--,skills_job_dim.skill_id
HAVING COUNT(job_postings_fact.job_id) > 10
ORDER BY 
    average_sal DESC
LIMIT 25
```
| Skills    | Count | Average Salary |
|-----------|-------|---------------|
| go        | 27    | 115320        |
| confluence| 11    | 114210        |
| hadoop    | 22    | 113193        |
| snowflake | 37    | 112948        |
| azure     | 34    | 111225        |
| bigquery  | 13    | 109654        |
| aws       | 32    | 108317        |
| java      | 17    | 106906        |
| ssis      | 12    | 106683        |
| jira      | 20    | 104918        |

*This table provides a breakdown of 10 skills, showing their frequency (count) and the average salary associated with those skills.*

The provided query reveals several key insights into the current data landscape:

* **Cloud Dominance:** Cloud platforms like Snowflake, Azure, and AWS are highly sought after, reflecting the industry's shift towards cloud-based data solutions.
* **Emerging Technologies:** Skills like Go and BigQuery, while less common, command premium salaries, indicating a growing demand for specialists in these emerging technologies.
* **Collaboration and Workflow:** Tools like Confluence and Jira are essential for data professionals, highlighting the importance of teamwork and project management in modern data analytics.
* **Legacy Systems:** While cloud-based solutions are gaining prominence, skills related to legacy systems like Hadoop and SSIS remain valuable.


The data highlights the growing need for cloud computing, big data, and collaboration tools in data analytics roles, with niche or emerging skills like **Go** commanding premium salaries. This reflects the evolving nature of the data landscape toward more integrated and scalable systems.


# Conculsions

From the analysis, several general insights emerged:

I can't visualize the data because the data variable is not defined. However, I can rephrase the provided insights:

**1. Top-Paying Data Analyst Jobs**: The highest-paying remote data analyst jobs offer a wide range of salaries, with some positions reaching over $650,000 per year.

**2. SQL Dominance**: SQL is a critical skill for high-paying data analyst roles, as it is both highly in-demand and associated with the highest average salaries.

**3. Skill Specialization:** Niche skills like SVN and Solidity are associated with premium salaries, suggesting that specializing in emerging technologies can be beneficial for career advancement.

**4. Optimal Skills for Job Market Value**: SQL emerges as the most valuable skill for data analysts, given its high demand and association with competitive salaries.

These insights highlight the importance of developing a strong foundation in SQL, while also considering the potential benefits of specializing in niche or emerging technologies to enhance career prospects.

# What I Learned
Throughout this adventure, I've refined my SQL toolkit with some serious firepower and learned to think more like an analyst in term of trends and finding insights from a bunch of data.
And I believe that I've significantly enhanced my SQL expertise, enabling me to tackle complex data challenges.

Some of what I've learned include:
- **Complex Query Crafting:** Mastered the art of advanced SQL, merging tables like a pro and using CTEs and subqueries.
- **Data Aggregation:** Got cozy with GROUP BY and became proficient in using aggregate functions like COUNT() and AVG() to summarize data efficiently.
- **Analytical Wizardry:** developed strong analytical abilities, allowing me to translate real-world questions into insightful SQL queries.