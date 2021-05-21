-- This queries the sys.dm_hadr_database_replica_states table to get the synchronisation health of the local replicas and returns a count of the number of non-healthy databases.  Possible values for synchronization_health are:
-- 0 = Not Healthy
-- 1 = Partially Healthy
-- 2 = Healthy
-- More info: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-hadr-database-replica-states-transact-sql?view=sql-server-2017

select count(*)
from sys.dm_hadr_database_replica_states
where synchronization_health != 2 and is_local = 1