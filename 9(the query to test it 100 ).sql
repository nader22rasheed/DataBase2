

DECLARE @i INT = 1;

WHILE @i <= 100
BEGIN

--the quere for 5
SELECT RequestID, Title, CreatedAt, CurrentStatus
FROM Request with(INDEX(IX_Request_DeptID))
WHERE DeptID = 1 AND CurrentStatus = 2
ORDER BY CreatedAt DESC;


--the quere for 6
WITH OrderedRequests AS
(
    SELECT 
        RequestID,
        Title,
        CreatedAt,
        CurrentStatus,
        ROW_NUMBER() OVER (ORDER BY CreatedAt DESC) AS RowNum
    FROM Request WITH (INDEX(IX_Request_Covering))  
    WHERE DeptID = 1
      AND CurrentStatus = 2
)
SELECT
    RequestID,
    Title,
    CreatedAt,
    CurrentStatus,
    CASE 
        WHEN RowNum <= 10 THEN 'Top'
        ELSE 'Rest'
    END AS RowCategory
FROM OrderedRequests
ORDER BY RowNum;

--the quere for 7
SELECT RequestID, Title,  LastUpdatedAt
FROM Request
WHERE CreatorEmpID = 5
  AND DeptID = 2;


--Nested Loops Join 
SELECT e.EmpID,e.FullName,d.Name AS DeptName,a.Name AS AdminName, e.IsReviewer
FROM Employee e
INNER  JOIN Department d ON e.DeptID = d.DeptID
INNER  JOIN Administration a ON d.AdminID = a.AdminID
WHERE e.IsReviewer = 1
ORDER BY e.FullName;


--Hash Join 
SELECT e.EmpID,e.FullName,d.Name AS DeptName,a.Name AS AdminName, e.IsReviewer
FROM Employee e
INNER hash JOIN Department d ON e.DeptID = d.DeptID
INNER hash JOIN Administration a ON d.AdminID = a.AdminID
WHERE e.IsReviewer = 1
ORDER BY e.FullName;

--Merge Join 
SELECT e.EmpID,e.FullName,d.Name AS DeptName,a.Name AS AdminName, e.IsReviewer
FROM Employee e
INNER merge JOIN Department d ON e.DeptID = d.DeptID
INNER merge JOIN Administration a ON d.AdminID = a.AdminID
WHERE e.IsReviewer = 1
ORDER BY e.FullName;

    SET @i = @i + 1;
END