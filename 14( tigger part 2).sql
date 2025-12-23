USE HW_RequestDB;
GO

-- add states if its not exist
INSERT INTO RequestStatus (StatusID, StatusName) VALUES 
(1, 'Draft'), (2, 'Under Review'), (3, 'Approved'), (4, 'Rejected');
GO

-- tigger
CREATE TRIGGER TR_Request_PreventModify
ON [Request]
FOR UPDATE, DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM deleted 
        WHERE CurrentStatus IN (2, 3, 4)
    )
    BEGIN
        RAISERROR('Cannot UPDATE or DELETE request in Under Review, Approved, or Rejected status.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

