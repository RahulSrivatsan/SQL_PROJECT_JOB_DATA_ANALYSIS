# Introduction
📊 Unlock insights into the data career landscape! This project investigates the current market for Data Analysts, specifically identifying 💰 premium-salary roles, 🔥 must-have technical competencies, and 📈 the "sweet spot" where high job availability intersects with top-tier compensation.

🔍 Explore the code: All SQL analysis scripts are located in the [project_sql folder](/project_sql/) directory

# Background
This project originated from a need to strategically navigate the data recruitment field. By pinpointing which skills actually drive salary growth and which are most frequently requested by employers, this analysis serves as a roadmap for finding high-value career opportunities.

The dataset is derived from a comprehensive SQL Course, providing a rich repository of job titles, compensation packages, geographic trends, and required tech stacks.

The questions I wanted to answer through my SQL queries were:
1. Which Data Analyst positions offer the highest annual pay?
2. What specific tools do these high-paying roles demand?
3. Which skills are most frequently cited across all job postings?
4. Which competencies are linked to the most significant salary bumps?
5. What are the most "optimal" skills to master for maximum ROI?
# Tools I used
To analyze the data analyst job market, I utilized a professional tech stack to ensure my findings were accurate, organized, and easily accessible:

- **SQL**: The primary tool used to explore the data. 
- **PostgreSQL**: The database engine used to house the data.
- **Visual Studio Code**: My central workspace for writing and testing scripts.
- **Git & GitHub**: My tools for version control and project hosting. 

# The Analysis
Each query for this project aimed at investigating specific aspects of the data analyst job market. Here’s how I approached each question:

### 1. Top Paying Data Analyst Jobs
To identify the highest-paying roles, I filtered data analyst positions by average yearly salary and location, focusing on remote jobs. This query highlights the high paying opportunities in the field.

```sql
SELECT
   job_id,
   job_title,
   job_location,
   job_schedule_type,
   salary_year_avg,
   job_posted_date,
   name as company_name
FROM
   job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
   job_title_short = 'Data Analyst' AND
   job_location = 'Anywhere' AND
   salary_year_avg IS NOT NULL
ORDER BY
   salary_year_avg DESC
LIMIT 10;
```
Here's the breakdown of the top data analyst jobs in 2023:

- **Top Earner**: The "Data Analyst" role leads the list with a peak average salary of $650,000.
- **Large Pay Gap**: There is a massive drop-off of over $300,000 between the first and second-highest paying roles.
- **High Minimum Pay**: Every job in this top 10 list earns at least $184,000 per year.

![Top Paying Roles](assets/1_Salary(Avg)_JobTitle.png)
*Bar graph visualizing the salary for the top 10 salaries for data analysts; Gemini generated this graph from my SQL query results*

### 2. Skills for Top Paying Jobs
To understand what skills are required for the top-paying jobs, I joined the job postings with the skills data, providing insights into what employers value for high-compensation roles.

```sql
WITH top_paying_jobs AS (
    SELECT
    job_id,
    job_title,
    salary_year_avg,
    name as company_name
    FROM
    job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
    job_title_short = 'Data Analyst' AND
    job_location = 'Anywhere' AND
    salary_year_avg IS NOT NULL
    ORDER BY
    salary_year_avg DESC
    LIMIT 10
)

SELECT
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC; 
```
-   SQL is leading with a bold count of 8.
Python follows closely with a bold count of 7.
-   Tableau is also highly sought after, with a bold count of 6. 
- Other skills like R, Snowflake, Pandas, and Excel show varying degrees of demand.

![Skills Frequency](assets/2_skills_frequency.png)
*Bar graph visualizing the count of skills for the top 10 paying jobs for data analysts; Gemini generated this graph from my SQL query results*

### 3.In-Demand Skills for Data Analysts
This query helped identify the skills most frequently requested in job postings, directing focus to areas with high demand.

```sql
SELECT
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;
```
Here's the breakdown of the most demanded skills for data analysts in 2023

- SQL and Excel remain fundamental, emphasizing the need for strong foundational skills in data processing and spreadsheet manipulation.
- Programming and Visualization Tools like Python, Tableau, and Power BI are essential, pointing towards the increasing importance of technical skills in data storytelling and decision support.

| Skill    | Demand Count |
|----------|-------------:|
| SQL      | 92,628       |
| Excel    | 67,031       |
| Python   | 57,326       |
| Tableau  | 46,554       |
| Power BI | 39,468       |


*Table of the demand for the top 5 skills in data analyst job postings*

### 4. Skills Based on Salary

Exploring the average salaries associated with different skills revealed which skills are the highest paying.

```sql
SELECT
    skills,
    ROUND(AVG(salary_year_avg),0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;
```
Here's a breakdown of the results for top paying skills for Data Analysts:

-  SVN commands the highest salary ($400,000), likely reflecting a "maintenance premium" where specialized experts are paid significantly to manage or migrate mission-critical legacy systems
-   Solidity ($179,000) and Couchbase ($160,515) lead the modern stack, proving that niche expertise in Web3/Blockchain and NoSQL database architecture outpaces generalist skills.
-  Machine Learning frameworks (like PyTorch, Keras, and TensorFlow) show high consistency, offering a stable salary floor between $120,000 and $150,000 for data professionals.

| Skill     | Average Salary ($) |
|-----------|-------------------:|
| SVN       | $400,000           |
| Solidity  | $179,000           |
| Couchbase | $160,515           |
| DataRobot | $155,486           |
| Golang    | $155,000           |
| MXNet     | $149,000           |
| dplyr     | $147,633           |
| VMware    | $147,500           |
| Terraform | $146,734           |
| Twilio    | $138,500           |

*Table of the average salary for the top 10 paying skills for data analysts*

### 5. Most Optimal Skills to Learn
Combining insights from demand and salary data, this query aimed to pinpoint skills that are both in high demand and have high salaries, offering a strategic focus for skill development.

```sql
WITH skills_demand AS (
    SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY
    skills_dim.skill_id
), avg_salary AS (
    SELECT
    skills_job_dim.skill_id,
    ROUND(AVG(salary_year_avg),0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY
    skills_job_dim.skill_id
)

SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary
FROM
    skills_demand
INNER JOIN avg_salary ON skills_demand.skill_id = avg_salary.skill_id
WHERE
    demand_count > 10
ORDER BY
    avg_salary DESC,
     demand_count DESC
LIMIT 10;
```

| Skill ID | Skill       | Demand Count | Avg Salary ($) |
|----------|------------|-------------:|---------------:|
| 98       | Kafka      | 40           | 129,999        |
| 101      | PyTorch    | 20           | 125,226        |
| 31       | Perl       | 20           | 124,686        |
| 99       | TensorFlow | 24           | 120,647        |
| 63       | Cassandra  | 11           | 118,407        |
| 219      | Atlassian  | 15           | 117,966        |
| 96       | Airflow    | 71           | 116,387        |
| 3        | Scala      | 59           | 115,480        |
| 169      | Linux      | 58           | 114,883        |
| 234      | Confluence | 62           | 114,153        |

*Table of the most optimal skills for data analyst sorted by salary*

Here's a breakdown of the most optimal skills for Data Analysts in 2023:

-   **Kafka leads in salary** : Among this group, Kafka has the highest average salary (~$130K), indicating strong demand for streaming/data pipeline expertise.
- **Airflow has the highest demand** : With a demand count of 71, Airflow stands out as the most in-demand skill here, even though its salary is mid-range.
- **High salary ≠ high demand** : Skills like PyTorch and Perl have relatively high salaries but low demand counts, suggesting niche or specialized roles.
- **Infrastructure & data engineering skills dominate**: Tools like Airflow, Kafka, Cassandra, and Linux show that backend/data engineering skills are both in demand and well-paid.

### What I learnt
Throughout this project, I strengthened my SQL skills by building complex queries using **joins**, **subqueries**, and **CTEs** to combine and analyze data effectively. I also improved my ability to aggregate and summarize data using functions like COUNT() and AVG(), while developing a stronger analytical mindset to turn questions into meaningful insights.

### Conclusions

#### Insights
From the analysis, several general insights emerged:

1. **Top Paying Data Analyst Jobs** :
The highest-paying data analyst roles offer exceptional salaries with a sharp drop after the top position, yet all top roles maintain a very high earning baseline.
2. **Skills for Top Paying Jobs** :
Core technical skills like SQL, Python, and Tableau consistently dominate high-paying data analyst roles.
3. **In-Demand Skills for Data Analysts*** :
Strong foundations in SQL and Excel, combined with programming and visualization tools, are essential for staying competitive in data analytics.
4. **Skills Based on Salary** :
Niche and specialized technologies command the highest salaries, while machine learning skills provide consistently strong earning potential.
5. **Most Optimal Skills to Learn** :
The most valuable skills balance demand and salary, with data engineering tools offering strong career opportunities despite varying demand levels.

### Closing Thoughts

This project strengthened my SQL skills while uncovering key trends in the data analyst job market. The insights gained can help guide skill development and job search strategies by highlighting in-demand, high-paying areas. Overall, it emphasizes the importance of continuously learning and adapting to evolving tools and industry needs in data analytics.
