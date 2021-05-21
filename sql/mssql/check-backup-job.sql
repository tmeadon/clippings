-- this returns the status of a job called 'Backup.Log Backup - 3 hours'

SELECT count (*) FROM (
SELECT 
jh.run_status
,ROW_NUMBER() OVER (ORDER BY msdb.dbo.agent_datetime(jh.run_date,jh.run_time) DESC) AS [rn]
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobhistory jh ON (j.job_id = jh.job_id)
WHERE
jh.step_id=0 
AND j.name = 'Backup.Log Backup - 3 hours'
) a
WHERE 
run_status = 0
AND [rn]=1