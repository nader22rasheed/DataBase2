USE HW_RequestDB;
GO

/* ================================
   1) Organization
================================ */
INSERT INTO Organization (Name, Address)
VALUES
(N'Ministry of Education', N'Berlin'),
(N'Ministry of Health', N'Hamburg'),
(N'Municipality Services', N'Munich');
GO

/* ================================
   2) Administration
================================ */
INSERT INTO Administration (OrgID, Name, Description)
VALUES
(1, N'IT Administration', N'Handles IT systems'),
(1, N'HR Administration', N'Human resources'),
(2, N'Medical Affairs', N'Medical operations'),
(3, N'Public Services', N'Citizen services');
GO

/* ================================
   3) Department
================================ */
INSERT INTO Department (AdminID, Name)
VALUES
(1, N'Software Department'),
(1, N'Infrastructure'),
(2, N'Recruitment'),
(3, N'Hospitals'),
(4, N'Licensing'),
(4, N'Support');
GO

/* ================================
   4) Employee
================================ */
INSERT INTO Employee (DeptID, EmpCode, FullName, Email, IsReviewer)
VALUES
(1, 'EMP001', N'Ahmad Ali', 'ahmad@org.com', 1),
(1, 'EMP002', N'Sara Hasan', 'sara@org.com', 0),
(2, 'EMP003', N'Mohammad Saleh', 'moh@org.com', 1),
(3, 'EMP004', N'Lina Omar', 'lina@org.com', 0),
(4, 'EMP005', N'John Smith', 'john@org.com', 1),
(5, 'EMP006', N'Anna Müller', 'anna@org.com', 0);
GO

/* ================================
   5) RequestStatus
================================ */
INSERT INTO RequestStatus (StatusID, StatusName)
VALUES
(1, N'New'),
(2, N'In Review'),
(3, N'Approved'),
(4, N'Rejected'),
(5, N'Closed');
GO

/* ================================
   6) Request (Main Table)
================================ */
INSERT INTO [Request]
(CreatorEmpID, DeptID, Title, Description, CurrentStatus, IsPaper, CreatedAt)
VALUES
(1, 1, N'System Upgrade', N'Upgrade internal systems', 1, 0, DATEADD(DAY,-15,GETUTCDATE())),
(2, 1, N'New Software License', N'Request for new IDE license', 2, 0, DATEADD(DAY,-12,GETUTCDATE())),
(3, 2, N'Server Maintenance', N'Monthly maintenance', 3, 1, DATEADD(DAY,-10,GETUTCDATE())),
(4, 3, N'Hospital Equipment', N'Need new equipment', 2, 0, DATEADD(DAY,-8,GETUTCDATE())),
(5, 4, N'Citizen Portal', N'Portal improvement request', 1, 0, DATEADD(DAY,-5,GETUTCDATE())),
(6, 5, N'License Renewal', N'Renew expired license', 4, 1, DATEADD(DAY,-3,GETUTCDATE()));
GO

/* ================================
   7) RequestHistory
================================ */
INSERT INTO RequestHistory
(RequestID, FromEmpID, ToEmpID, Action, Comment, ActionDate)
VALUES
(1, 1, 2, N'Created', N'Request created', DATEADD(DAY,-15,GETUTCDATE())),
(1, 2, 3, N'Reviewed', N'Initial review done', DATEADD(DAY,-14,GETUTCDATE())),
(2, 2, 1, N'Submitted', N'Submitted for approval', DATEADD(DAY,-12,GETUTCDATE())),
(3, 3, 5, N'Approved', N'Approved by admin', DATEADD(DAY,-10,GETUTCDATE())),
(4, 4, 5, N'In Review', N'Under review', DATEADD(DAY,-8,GETUTCDATE()));
GO

/* ================================
   8) RequestAttachment
================================ */
INSERT INTO RequestAttachment
(RequestID, FileName, FilePath, UploadedBy)
VALUES
(1, 'specs.pdf', 'C:\files\specs.pdf', 1),
(2, 'license.docx', 'C:\files\license.docx', 2),
(3, 'maintenance.xlsx', 'C:\files\maintenance.xlsx', 3),
(4, 'equipment.jpg', 'C:\files\equipment.jpg', 4);
GO

/* ================================
   9) Massive Data (Performance Test)
   Generates ~10,000 Requests
================================ */
INSERT INTO [Request]
(CreatorEmpID, DeptID, Title, Description, CurrentStatus, CreatedAt)
SELECT
    ABS(CHECKSUM(NEWID())) % 6 + 1,
    ABS(CHECKSUM(NEWID())) % 6 + 1,
    N'Auto Generated Request',
    N'Data for index intersection testing',
    ABS(CHECKSUM(NEWID())) % 5 + 1,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETUTCDATE())
FROM sys.objects o1
CROSS JOIN sys.objects o2;
GO