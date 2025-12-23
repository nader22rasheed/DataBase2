USE HW_RequestDB;
GO

--tigger for employee

CREATE TRIGGER TR_Employee_OperationLog
ON Employee
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        PRINT 'Operation: INSERT - New employee record added.';
    END
    ELSE IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        PRINT 'Operation: DELETE - Employee record removed.';
    END
    ELSE IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        PRINT 'Operation: UPDATE - Employee record modified.';
    END
END;
GO

/*
extra thing for ensure that is right or not 

- INSERT INTO Employee (DeptID, FullName) VALUES (1, 'Test Employee');  -- print INSERT
- UPDATE Employee SET FullName = 'Updated Name' WHERE EmpID = @@IDENTITY;  -- print UPDATE
- DELETE FROM Employee WHERE EmpID = @@IDENTITY;  -- print DELETE
*/