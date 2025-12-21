--the new quere for 7
SELECT RequestID, Title,  LastUpdatedAt
FROM [Request]
WHERE CreatorEmpID = 5
  AND DeptID = 2;


--index for index intersection
CREATE NONCLUSTERED INDEX IX_Request_CreatorEmpID_Intersection
ON Request(CreatorEmpID)
INCLUDE (RequestID, Title, LastUpdatedAt, CurrentStatus)
WITH (FILLFACTOR = 85);
