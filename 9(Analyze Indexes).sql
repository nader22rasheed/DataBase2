


--For table Request
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    s.user_seeks AS UserSeeks,
    s.user_scans AS UserScans,
    s.user_lookups AS UserLookups,
    s.user_updates AS UserUpdates,
    s.last_user_seek AS LastSeek,
    s.last_user_scan AS LastScan,
    s.last_user_lookup AS LastLookup,
    s.last_user_update AS LastUpdate
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s
    ON i.object_id = s.object_id AND i.index_id = s.index_id
    AND s.database_id = DB_ID()
WHERE i.object_id = OBJECT_ID('Request')  
ORDER BY s.user_seeks +  s.user_scans DESC;


--For table Employee
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    s.user_seeks AS UserSeeks,
    s.user_scans AS UserScans,
    s.user_lookups AS UserLookups,
    s.user_updates AS UserUpdates,
    s.last_user_seek AS LastSeek,
    s.last_user_scan AS LastScan,
    s.last_user_lookup AS LastLookup,
    s.last_user_update AS LastUpdate
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s
    ON i.object_id = s.object_id AND i.index_id = s.index_id
    AND s.database_id = DB_ID()
WHERE i.object_id = OBJECT_ID('Employee')  
ORDER BY s.user_seeks +  s.user_scans DESC;



--For table Administration
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    s.user_seeks AS UserSeeks,
    s.user_scans AS UserScans,
    s.user_lookups AS UserLookups,
    s.user_updates AS UserUpdates,
    s.last_user_seek AS LastSeek,
    s.last_user_scan AS LastScan,
    s.last_user_lookup AS LastLookup,
    s.last_user_update AS LastUpdate
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s
    ON i.object_id = s.object_id AND i.index_id = s.index_id
    AND s.database_id = DB_ID()
WHERE i.object_id = OBJECT_ID('Administration')  
ORDER BY s.user_seeks +  s.user_scans DESC;


--For table Department
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    s.user_seeks AS UserSeeks,
    s.user_scans AS UserScans,
    s.user_lookups AS UserLookups,
    s.user_updates AS UserUpdates,
    s.last_user_seek AS LastSeek,
    s.last_user_scan AS LastScan,
    s.last_user_lookup AS LastLookup,
    s.last_user_update AS LastUpdate
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s
    ON i.object_id = s.object_id AND i.index_id = s.index_id
    AND s.database_id = DB_ID()
WHERE i.object_id = OBJECT_ID('Department')  
ORDER BY s.user_seeks +  s.user_scans DESC;