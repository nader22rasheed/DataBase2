USE HW_RequestDB;
GO

/* =====================================================
   Chosen Query (used for performance testing)
   This query retrieves requests for a specific department
   and status, ordered by creation date.
===================================================== */

SELECT RequestID, Title, CreatedAt, CurrentStatus
FROM Request
WHERE DeptID = 1 AND CurrentStatus = 3
ORDER BY CreatedAt DESC;



/* =====================================================
 a) Non-Clustered Index (High Selectivity ~85%)
   DeptID is usually selective because each department
   contains a limited number of requests.
===================================================== */
CREATE NONCLUSTERED INDEX IX_Request_DeptID
ON Request(DeptID)
WITH (FILLFACTOR = 85);
GO



/* =====================================================
 b) Clustered Index
   The primary key RequestID already creates a clustered
   index automatically. This index physically orders
   the data in the table.
===================================================== */
-- This clustered index already exists because of PRIMARY KEY
CREATE CLUSTERED INDEX IX_Request_RequestID_Clusteredd ON Request(RequestID);



/* =====================================================
 c) Covering Index
   This index covers the entire query:
   - WHERE (DeptID, CurrentStatus)
   - ORDER BY (CreatedAt)
   - SELECT (RequestID, Title)
   No key lookup is needed.
===================================================== */
CREATE NONCLUSTERED INDEX IX_Request_Covering
ON Request(DeptID, CurrentStatus, CreatedAt DESC)
INCLUDE (RequestID, Title)
WITH (FILLFACTOR = 85);
GO



/* =====================================================
 d) Including Index
   This index uses INCLUDE to add extra columns
   so SQL Server does not need to access the base table.
===================================================== */
CREATE NONCLUSTERED INDEX IX_Request_Status_Include
ON Request(CurrentStatus)
INCLUDE (DeptID, CreatedAt, Title)
WITH (FILLFACTOR = 85);
GO



/* =====================================================
 e) Filtered Index
   This index only includes active requests
   (New and In Review).
   Filtered indexes are smaller and faster.
===================================================== */
CREATE NONCLUSTERED INDEX IX_Request_Filtered_Active
ON Request(DeptID, CreatedAt DESC)
INCLUDE (Title, CurrentStatus)
WHERE CurrentStatus IN (1, 2)
WITH (FILLFACTOR = 85); 
GO



