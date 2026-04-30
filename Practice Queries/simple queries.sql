SELECT 
job_title_short as title,
job_location as job_location,
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' as date_time,
EXTRACT(MONTH FROM job_posted_date) AS date_month
FROM job_postings_fact
LIMIT 5;

/*query to find the average salary both yearly (salary_year_avg) and hourly (salary_hour_avg) 
for job postings that were posted after June 1, 2023. 
Group the results by job schedule type*/

SELECT
job_schedule_type,
ROUND(AVG(salary_year_avg),2) AS avg_salary_year,
ROUND(AVG(salary_hour_avg),2) AS avg_salary_hour
FROM job_postings_fact
WHERE job_posted_date >= '2023-06-01' 
GROUP BY job_schedule_type
LIMIT 50;


/* Count the number of job postings for each month in 2023,
   adjusting the job_posted_date to 'America/New_York' time zone
   before extracting the month. Assume job_posted_date is stored in UTC. */
SELECT 
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS date_month,
    COUNT(*) AS postings_count
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') = 2023
GROUP BY date_month
ORDER BY date_month;

/*find companies (include company name) that have posted jobs offering health insurance, 
where these postings were made in the second quarter of 2023. 
Use date extraction to filter by quarter.*/

SELECT c.name as company_name,
COUNT(j.job_id) AS postings_count
FROM job_postings_fact j
JOIN company_dim c
ON j.company_id = c.company_id
WHERE job_health_insurance = TRUE
AND EXTRACT(YEAR FROM j.job_posted_date) = 2023
AND EXTRACT(QUARTER FROM j.job_posted_date) = 2
GROUP BY c.name
ORDER BY postings_count DESC;

--Salary buckets
SELECT 
    CASE 
        WHEN salary_year_avg >= 100000 THEN 'High Salary'
        WHEN salary_year_avg BETWEEN 60000 AND 99999 THEN 'Standard Salary'
        ELSE 'Low Salary'
    END AS salary_bucket,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY salary_bucket
ORDER BY job_count DESC;

--CTE
WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)

SELECT 
company_dim.name AS company_name,
company_job_count.total_jobs
FROM company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id

/*Identify the top 5 skills that are most frequently mentioned in job postings. 
Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table 
and then join this result with the skills_dim table to get the skill names. */

SELECT
sd.skill_id,
sd.skills,
skill_counts.skill_count
FROM(
    SELECT 
    sjd.skill_id, COUNT(*) as skill_count
    FROM skills_job_dim sjd
    GROUP BY skill_id
    ORDER BY skill_count DESC
    LIMIT 5
)AS skill_counts
JOIN skills_dim sd 
    ON sd.skill_id = skill_counts.skill_id

/*Determine the size category (Small, Medium, or Large) for each company by 
first identifying the number of job postings they have. Use a subquery 
to calculate the total job postings per company.

A company is considered Small if it has less than 10 job postings
Medium if the number of job postings is between 10 and 50
Large if it has more than 50 job postings

Implement a subquery to aggregate job counts per company before classifying them based on size.*/

SELECT
cd.company_id,
cd.name,
job_counts.job_count,
    CASE
        WHEN job_counts.job_count <= 10 THEN 'Small'
        WHEN job_counts.job_count <= 50 THEN 'Medium'
        ELSE 'Large'
    END AS company_size
FROM
(SELECT
j.company_id,
COUNT(job_id) AS job_count
FROM job_postings_fact j
GROUP BY company_id
LIMIT 100) as job_counts
LEFT JOIN company_dim cd
    ON cd.company_id = job_counts.company_id;


/*- Get the corresponding skill and skill type for each job posting in Q1
- Include those without any skills, too
- Why? Look at the skills and the type for each job in the first quarter that has a salary > $70,000*/

WITH skill_details AS (
    SELECT
        j.job_id,
        j.job_title_short,
        sjd.skill_id
    FROM job_postings_fact j
    LEFT JOIN skills_job_dim sjd
        ON sjd.job_id = j.job_id
    WHERE EXTRACT(QUARTER FROM j.job_posted_date) = 1
      AND j.salary_year_avg > 70000
)

SELECT
    sd.job_title_short,
    sd.job_id,
    sk.skills,
    sk.type
FROM skill_details sd
LEFT JOIN skills_dim sk
    ON sd.skill_id = sk.skill_id
WHERE 
sk.skills IS NULL
ORDER BY sd.job_title_short;



