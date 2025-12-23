USE HW_RequestDB;
GO
--main thing is select here ( select 3 tables )

SELECT 
    e.EmpID, e.FullName, d.Name AS DeptName, a.Name AS AdminName, o.Name AS OrgName
FROM Employee e
INNER JOIN Department d ON e.DeptID = d.DeptID
INNER JOIN Administration a ON d.AdminID = a.AdminID
INNER JOIN Organization o ON a.OrgID = o.OrgID
WHERE e.IsReviewer = 1 AND o.OrgID = 1
ORDER BY e.FullName;
GO

-- processing 

CREATE PROCEDURE dbo.SP_GetReviewersByOrg
    @OrgID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        e.EmpID, e.FullName, d.Name AS DeptName, a.Name AS AdminName, o.Name AS OrgName
    FROM Employee e
    INNER JOIN Department d ON e.DeptID = d.DeptID
    INNER JOIN Administration a ON d.AdminID = a.AdminID
    INNER JOIN Organization o ON a.OrgID = o.OrgID
    WHERE e.IsReviewer = 1 AND o.OrgID = @OrgID
    ORDER BY e.FullName;
END;
GO

-- execute
EXEC dbo.SP_GetReviewersByOrg @OrgID = 1;
GO
