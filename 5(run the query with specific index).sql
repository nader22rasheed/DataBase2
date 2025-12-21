SELECT RequestID, Title, CreatedAt, CurrentStatus
FROM Request with(INDEX(IX_Request_DeptID))
WHERE DeptID = 1 AND CurrentStatus = 2
ORDER BY CreatedAt DESC;
