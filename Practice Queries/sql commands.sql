--sql commands

INSERT INTO job_applied (
  job_id,
  application_sent_date,
  custom_resume,
  resume_file_name,
  cover_letter_sent,
  cover_letter_file_name,
  status
) VALUES
(101, '2026-01-15', TRUE, 'resume_data_analyst.pdf', TRUE, 'cover_letter_data_analyst.pdf', 'Under Review'),
(102, '2026-01-20', FALSE, 'resume_generic.pdf', FALSE, NULL, 'Rejected'),
(103, '2026-01-25', TRUE, 'resume_sql_dev.pdf', TRUE, 'cover_letter_sql_dev.pdf', 'Interview Scheduled'),
(104, '2026-02-01', TRUE, 'resume_bi_specialist.pdf', FALSE, NULL, 'Applied'),
(105, '2026-02-03', FALSE, 'resume_generic.pdf', TRUE, 'cover_letter_project_manager.pdf', 'Offer Received');

ALTER TABLE job_applied
ADD contact VARCHAR(50);

-- Inserting records
UPDATE job_applied
SET contact = 'Rahul'
WHERE job_id = 101;

UPDATE job_applied
SET contact = 'Anita'
WHERE job_id = 102;

UPDATE job_applied
SET contact = 'Mohan'
WHERE job_id = 103;

UPDATE job_applied
SET contact = 'Sneha'
WHERE job_id = 104;

UPDATE job_applied
SET contact = 'Arjun'
WHERE job_id = 105;

ALTER TABLE job_applied
RENAME COLUMN contact TO contact_name;

ALTER TABLE job_applied
ALTER COLUMN contact_name TYPE TEXT;

ALTER TABLE job_applied
DROP COLUMN contact_name;

DROP TABLE job_applied;

SELECT * FROM job_applied;