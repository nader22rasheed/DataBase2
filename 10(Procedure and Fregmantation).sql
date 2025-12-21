CREATE PROCEDURE dbo.SP_Test_Request_Fragmentation
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;

    WHILE @i <= 1000
	BEGIN
        -- INSERT: add new requests
        INSERT INTO Request
        (
            CreatorEmpID,
            DeptID,
            Title,
            Description,
            CurrentStatus,
            IsPaper,
            CreatedAt,
            LastUpdatedAt
        )
        VALUES
        (
            1,                  -- existing Employee
            1,                  -- existing Department
            'Test Request ' + CAST(@i AS NVARCHAR),
            'Fragmentation test data',
            1,                  -- existing Status
            0,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );

        -- UPDATE: modify existing rows
        UPDATE Request
        SET LastUpdatedAt = SYSUTCDATETIME()
        WHERE RequestID = @i;

        -- DELETE: remove some rows to increase fragmentation
        IF (@i % 10 = 0)
        BEGIN
            DELETE FROM Request
            WHERE RequestID = @i;
        END

        SET @i = @i + 1;
    END
END;
GO

--run Procedure
exec dbo.SP_Test_Request_Fragmentation

--show if it has done its Commends
select * from Request



--show Fragmentation
SELECT  
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc AS IndexType,
    ips.avg_fragmentation_in_percent AS FragmentationPercent,
    ips.page_count
FROM sys.dm_db_index_physical_stats
    (DB_ID(), OBJECT_ID('Request'), NULL, NULL, 'DETAILED') ips
JOIN sys.indexes i
    ON ips.object_id = i.object_id
    AND ips.index_id = i.index_id
WHERE ips.page_count > 100
ORDER BY ips.avg_fragmentation_in_percent DESC;

/*All indexes have fragmentation levels below 30%,
so they do not require rebuilding. However, one index has fragmentation above 5%,
therefore we will perform index reorganization using the following command:*/
ALTER INDEX IX_Request_Covering
ON Request
REORGANIZE;



--if we want to increase the counter to 20000:
CREATE PROCEDURE dbo.SP_Test_Request_Fragmentation_bigger
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;

    WHILE @i <= 20000
	BEGIN
        -- INSERT: add new requests
        INSERT INTO Request
        (
            CreatorEmpID,
            DeptID,
            Title,
            Description,
            CurrentStatus,
            IsPaper,
            CreatedAt,
            LastUpdatedAt
        )
        VALUES
        (
            1,                  -- existing Employee
            1,                  -- existing Department
            'Test Request ' + CAST(@i AS NVARCHAR),
            'Fragmentation test data',
            1,                  -- existing Status
            0,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );

        -- UPDATE: modify existing rows
        UPDATE Request
        SET LastUpdatedAt = SYSUTCDATETIME()
        WHERE RequestID = @i;

        -- DELETE: remove some rows to increase fragmentation
        IF (@i % 10 = 0)
        BEGIN
            DELETE FROM Request
            WHERE RequestID = @i;
        END

        SET @i = @i + 1;
    END
END;
GO


--run the bigger Procedure 
exec dbo.SP_Test_Request_Fragmentation_bigger


/*the covering index reached 42% fregmantation,
this is more 30% ,s0 it requires a full re build.
*/
ALTER INDEX IX_Request_Covering
ON Request
REBUILD;
