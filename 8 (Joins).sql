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