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