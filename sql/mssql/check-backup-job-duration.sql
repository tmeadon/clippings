-- this returns the duration of the last run for a job called 'Backup.Full Backup'

select COALESCE(SUM(datediff(MINUTE, start_execution_date, getdate())), 0) 
from msdb.dbo.sysjobactivity ja 
left join msdb.dbo.sysjobhistory jh on ja.job_history_id = jh.instance_id
join msdb.dbo.sysjobs j on ja.job_id = j.job_id
join msdb.dbo.sysjobsteps js on ja.job_id = js.job_id and isnull(ja.last_executed_step_id,0)+1 = js.step_id
where ja.session_id = 
(
	select top 1 session_id 
	from msdb.dbo.syssessions 
	order by agent_start_date desc
)
and start_execution_date is not null
and stop_execution_date is null
and j.name = 'Backup.Full Backup'