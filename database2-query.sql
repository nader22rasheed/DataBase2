-- Symbol legend:
--   [REQ 1]   = ERD / Table model
--   [REQ 2.x] = CREATE DATABASE, files, filegroup (specific subitems)
--   [REQ 3.x] = CREATE TABLES, ON filegroup, PKs and FKs
-- ======================================================

-- 0. Safety: drop DB if exists (non-destructive for fresh test)
-- -------------------------
-- [REQ 2.a] : ensure clean create for HW_RequestDB (db-level requirement)

IF DB_ID(N'HW_RequestDB') IS NOT NULL
BEGIN
    ALTER DATABASE HW_RequestDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HW_RequestDB;
END
GO

-- 1) CREATE DATABASE with multiple files and a dedicated filegroup

-- [REQ 2.a] Create primary .mdf and additional .ndf files on PRIMARY
-- [REQ 2.b] Create separate FILEGROUP named HW_FileGroup and place files on it
-- [REQ 2.c] Create LOG files (.ldf)
CREATE DATABASE HW_RequestDB
ON PRIMARY 
(
    NAME = N'HW_main', 
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\HW_main.mdf',
    SIZE = 200MB, 
    FILEGROWTH = 20MB
),
(
    NAME = N'HW_file1', 
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\HW_file1.ndf',
    SIZE = 100MB, 
    FILEGROWTH = 20MB
),
(
    NAME = N'HW_file2', 
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\HW_file2.ndf',
    SIZE = 100MB, 
    FILEGROWTH = 20MB
),
FILEGROUP [HW_FileGroup] 
(
    NAME = N'HW_file3',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\HW_file3.ndf',
    SIZE = 100MB,
    FILEGROWTH = 20MB
),
(
    NAME = N'HW_file4',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\HW_file4.ndf',
    SIZE = 100MB,
    FILEGROWTH = 20MB
)
LOG ON
(
    NAME = N'HW_log1',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Log\HW_log1.ldf',
    SIZE = 100MB,
    FILEGROWTH = 50MB
),
(
    NAME = N'HW_log2',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Log\HW_log2.ldf',
    SIZE = 100MB,
    FILEGROWTH = 50MB
);
GO

-- -------------------------
-- 2) Use the newly created database
-- -------------------------
USE HW_RequestDB;
GO

-- -------------------------
-- 3) Tables & relationships (ERD) — core data model
-- -------------------------
-- [REQ 1] ERD: The following tables constitute the ER model described in the project:
--         Organization, Administration, Department, Employee, RequestStatus, Request,
--         RequestHistory, RequestAttachment
-- [REQ 3.a] Place large/content table 'Request' on HW_FileGroup
-- [REQ 3.b] Define PKs and FK relationships explicitly for referential integrity

-- Organization table (top-level entity)
-- [REQ 1] [REQ 3.b]
CREATE TABLE Organization (
  OrgID      INT IDENTITY(1,1) PRIMARY KEY,   -- [REQ 3.b] primary key
  Name       NVARCHAR(200) NOT NULL,
  Address    NVARCHAR(500) NULL,
  CreatedAt  DATETIME2 DEFAULT SYSUTCDATETIME()
) ON [PRIMARY];
GO

-- Administration belongs to an Organization
-- [REQ 1] [REQ 3.b]
CREATE TABLE Administration (
  AdminID   INT IDENTITY(1,1) PRIMARY KEY,    -- [REQ 3.b]
  OrgID     INT NOT NULL,                     -- [REQ 3.b] FK column
  Name      NVARCHAR(200) NOT NULL,
  Description NVARCHAR(400) NULL,
  CONSTRAINT FK_Administration_Organization FOREIGN KEY (OrgID) REFERENCES Organization(OrgID)  -- [REQ 3.b] foreign key
) ON [PRIMARY];
GO

-- Department belongs to an Administration
-- [REQ 1] [REQ 3.b]
CREATE TABLE Department (
  DeptID   INT IDENTITY(1,1) PRIMARY KEY,     -- [REQ 3.b]
  AdminID  INT NOT NULL,                      -- [REQ 3.b] FK column
  Name     NVARCHAR(200) NOT NULL,
  CONSTRAINT FK_Department_Administration FOREIGN KEY (AdminID) REFERENCES Administration(AdminID) -- [REQ 3.b]
) ON [PRIMARY];
GO

-- Employee belongs to a Department
-- [REQ 1] [REQ 3.b]
CREATE TABLE Employee (
  EmpID       INT IDENTITY(1,1) PRIMARY KEY,  -- [REQ 3.b]
  DeptID      INT NOT NULL,                   -- [REQ 3.b] FK column
  EmpCode     NVARCHAR(50) UNIQUE NULL,
  FullName    NVARCHAR(250) NOT NULL,
  Email       NVARCHAR(200) NULL,
  IsReviewer  BIT DEFAULT 0,
  CreatedAt   DATETIME2 DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_Employee_Department FOREIGN KEY (DeptID) REFERENCES Department(DeptID) -- [REQ 3.b]
) ON [PRIMARY];
GO

-- RequestStatus lookup table (part of ERD)
-- [REQ 1] [REQ 3.b]
CREATE TABLE RequestStatus (
  StatusID INT PRIMARY KEY,                   -- [REQ 3.b] explicit PK
  StatusName NVARCHAR(100) NOT NULL
) ON [PRIMARY];
GO

-- Main Request table: placed on the dedicated filegroup for heavy data
-- [REQ 1] [REQ 3.a] [REQ 3.b]
CREATE TABLE [Request] (
  RequestID     INT IDENTITY(1,1) PRIMARY KEY,  -- [REQ 3.b]
  CreatorEmpID  INT NOT NULL,                   -- [REQ 3.b] FK to Employee
  DeptID        INT NOT NULL,                   -- [REQ 3.b] FK to Department
  Title         NVARCHAR(250) NOT NULL,
  Description   NVARCHAR(MAX) NULL,             -- potentially large -> justify filegroup placement
  CurrentStatus INT NOT NULL,                   -- [REQ 3.b] FK to RequestStatus
  IsPaper       BIT DEFAULT 0,
  CreatedAt     DATETIME2 DEFAULT SYSUTCDATETIME(),
  LastUpdatedAt DATETIME2 NULL,
  CONSTRAINT FK_Request_Creator FOREIGN KEY (CreatorEmpID) REFERENCES Employee(EmpID),   -- [REQ 3.b]
  CONSTRAINT FK_Request_Dept FOREIGN KEY (DeptID) REFERENCES Department(DeptID),        -- [REQ 3.b]
  CONSTRAINT FK_Request_Status FOREIGN KEY (CurrentStatus) REFERENCES RequestStatus(StatusID) -- [REQ 3.b]
) ON [HW_FileGroup];  -- [REQ 3.a] explicitly place Request on HW_FileGroup
GO


-- [REQ 1] [REQ 3.b]
CREATE TABLE RequestHistory (
  HistoryID    INT IDENTITY(1,1) PRIMARY KEY,   -- [REQ 3.b]
  RequestID    INT NOT NULL,                    -- [REQ 3.b] FK to Request
  FromEmpID    INT NULL,                        -- optional FK to Employee
  ToEmpID      INT NULL,                        -- optional FK to Employee
  Action       NVARCHAR(100) NOT NULL,
  Comment      NVARCHAR(MAX) NULL,
  ActionDate   DATETIME2 DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_RequestHistory_Request FOREIGN KEY (RequestID) REFERENCES [Request](RequestID), -- [REQ 3.b]
  CONSTRAINT FK_RequestHistory_FromEmp FOREIGN KEY (FromEmpID) REFERENCES Employee(EmpID),      -- [REQ 3.b]
  CONSTRAINT FK_RequestHistory_ToEmp FOREIGN KEY (ToEmpID) REFERENCES Employee(EmpID)           -- [REQ 3.b]
) ON [PRIMARY];
GO

-- RequestAttachment (attachments metadata)
-- [REQ 1] [REQ 3.b]
CREATE TABLE RequestAttachment (
  AttachmentID INT IDENTITY(1,1) PRIMARY KEY,   -- [REQ 3.b]
  RequestID     INT NOT NULL,                   -- [REQ 3.b] FK
  FileName      NVARCHAR(260),
  FilePath      NVARCHAR(500),
  UploadedBy    INT NULL,
  UploadedAt    DATETIME2 DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_RequestAttachment_Request FOREIGN KEY (RequestID) REFERENCES [Request](RequestID),  -- [REQ 3.b]
  CONSTRAINT FK_RequestAttachment_Employee FOREIGN KEY (UploadedBy) REFERENCES Employee(EmpID)       -- [REQ 3.b]
) ON [PRIMARY];
GO
