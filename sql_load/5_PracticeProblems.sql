/*
Find the count of the number of remote job postings per skill
    - Display the top 5 skills by their demand in remote jobs
    - Include skill ID, name, and count of postings requiring the skill
*/

WITH remote_job_skills AS (
    SELECT
        skills_job_dim.skill_id,
        COUNT(*) AS skills_count
    FROM
        skills_job_dim
    INNER JOIN job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id
    WHERE job_postings_fact.job_work_from_home = TRUE
    GROUP BY
        skill_id
    )

SELECT 
    skills.skill_id, 
    skills as skill_name,
    skills_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY skill_id
LIMIT 5;
