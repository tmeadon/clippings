-- This queries the sys.dm_hadr_cluster_members table returns a count of the cluster members that are not in an ONLINE state (i.e. member_state = 1).  Possible values for member_state are:
-- 0 = OFFLINE
-- 1 = ONLINE
-- More info: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-hadr-cluster-members-transact-sql?view=sql-server-2017

select count (*) 
from sys.dm_hadr_cluster_members
where member_state != 1


