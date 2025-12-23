USE HW_RequestDB;
GO

-- before SHRINK
SELECT 
    name AS FileName,
    size/128.0 AS CurrentSizeMB,
    (size - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT))/128.0 AS FreeSpaceMB
FROM sys.database_files
WHERE name = N'HW_file1';
GO

-- execute SHRINK
DBCC SHRINKFILE (N'HW_file1', 50);
GO

-- after SHRINK
SELECT 
    name AS FileName,
    size/128.0 AS CurrentSizeMB,
    (size - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT))/128.0 AS FreeSpaceMB
FROM sys.database_files
WHERE name = N'HW_file1';
GO


