-- This queries the sys.dm_hadr_availability_replica_states table to get the local server's synchronization health.  Possible values of synchronization_health:
-- 0 = Not Healthy
-- 1 = Partially Healthy
-- 2 = Healthy
-- More info: https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ff877972%28v%3dsql.110%29

select synchronization_health 
from sys.dm_hadr_availability_replica_states 
where is_local = 1