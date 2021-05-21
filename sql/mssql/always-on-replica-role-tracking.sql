-- This queries the sys.dm_hadr_availability_replica_states table to determine whether the local server's role in the Availability Group.  The possible values of the role field are:
-- 1 = Primary
-- 2 = Secondary
-- More info: https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ff877972%28v%3dsql.110%29

select role 
from sys.dm_hadr_availability_replica_states 
where is_local = 1