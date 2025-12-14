CREATE TABLE Institution (
    InstitutionID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    Code VARCHAR(50),
    Address VARCHAR(300),
    Phone VARCHAR(50),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE Department (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    InstitutionID INT NOT NULL,
    Name VARCHAR(200) NOT NULL,
    ManagerEmployeeID INT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive TINYINT(1) DEFAULT 1,
    CONSTRAINT FK_Department_Institution
        FOREIGN KEY (InstitutionID)
        REFERENCES Institution(InstitutionID)
) ENGINE=InnoDB;

CREATE TABLE Section (
    SectionID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentID INT NOT NULL,
    Name VARCHAR(200) NOT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive TINYINT(1) DEFAULT 1,
    CONSTRAINT FK_Section_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES Department(DepartmentID)
) ENGINE=InnoDB;

CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    SectionID INT NULL,
    FullName VARCHAR(200) NOT NULL,
    Username VARCHAR(100) UNIQUE,
    Email VARCHAR(200),
    Phone VARCHAR(50),
    Position VARCHAR(100),
    HireDate DATE,
    IsActive TINYINT(1) DEFAULT 1,
    RowVersion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT FK_Employee_Section
        FOREIGN KEY (SectionID)
        REFERENCES Section(SectionID)
) ENGINE=InnoDB;

/* ================= ROLES ================= */

CREATE TABLE Role (
    RoleID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(300)
) ENGINE=InnoDB;

CREATE TABLE UserRole (
    UserRoleID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT NOT NULL,
    RoleID INT NOT NULL,
    AssignedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_UserRole_Employee
        FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    CONSTRAINT FK_UserRole_Role
        FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
) ENGINE=InnoDB;

/* ================= LOOKUPS ================= */

CREATE TABLE RequestType (
    RequestTypeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(300)
) ENGINE=InnoDB;

CREATE TABLE RequestStatus (
    RequestStatusID INT AUTO_INCREMENT PRIMARY KEY,
    Code VARCHAR(50) UNIQUE,
    Name VARCHAR(100),
    IsFinal TINYINT(1) DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE Priority (
    PriorityID INT AUTO_INCREMENT PRIMARY KEY,
    Level INT,
    Name VARCHAR(50)
) ENGINE=InnoDB;

/* ================= REQUESTS ================= */

CREATE TABLE Requests (
    RequestID INT AUTO_INCREMENT PRIMARY KEY,
    RequestNumber VARCHAR(50) UNIQUE,
    CreatedBy INT NOT NULL,
    RequestTypeID INT NOT NULL,
    PriorityID INT NOT NULL,
    CurrentReviewerID INT NULL,
    Title VARCHAR(300),
    Content TEXT,
    Status VARCHAR(50),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    DueDate DATETIME NULL,
    ClosedAt DATETIME NULL,
    IsEscalated TINYINT(1) DEFAULT 0,
    ParentRequestID INT NULL,
    RowVersion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT FK_Requests_Creator FOREIGN KEY (CreatedBy) REFERENCES Employee(EmployeeID),
    CONSTRAINT FK_Requests_Type FOREIGN KEY (RequestTypeID) REFERENCES RequestType(RequestTypeID),
    CONSTRAINT FK_Requests_Priority FOREIGN KEY (PriorityID) REFERENCES Priority(PriorityID),
    CONSTRAINT FK_Requests_Reviewer FOREIGN KEY (CurrentReviewerID) REFERENCES Employee(EmployeeID),
    CONSTRAINT FK_Requests_Parent FOREIGN KEY (ParentRequestID) REFERENCES Requests(RequestID)
) ENGINE=InnoDB;

/* ================= DETAILS ================= */

CREATE TABLE RequestHistory (
    HistoryID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    FromEmployeeID INT NULL,
    ToEmployeeID INT NULL,
    Action VARCHAR(100),
    ActionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Notes TEXT,
    CONSTRAINT FK_History_Request FOREIGN KEY (RequestID) REFERENCES Requests(RequestID)
) ENGINE=InnoDB;

CREATE TABLE RequestNotes (
    NoteID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    EmployeeID INT NOT NULL,
    NoteText TEXT,
    NoteDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Notes_Request FOREIGN KEY (RequestID) REFERENCES Requests(RequestID),
    CONSTRAINT FK_Notes_Employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
) ENGINE=InnoDB;

CREATE TABLE RequestReviewer (
    ReviewerID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    EmployeeID INT NOT NULL,
    Sequence INT,
    Status VARCHAR(50),
    DecisionDate DATETIME NULL,
    Comments TEXT,
    CONSTRAINT FK_Reviewer_Request FOREIGN KEY (RequestID) REFERENCES Requests(RequestID),
    CONSTRAINT FK_Reviewer_Employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
) ENGINE=InnoDB;

/* ================= FILES ================= */

CREATE TABLE Attachments (
    AttachmentID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    FileName VARCHAR(200),
    FilePath VARCHAR(500),
    MimeType VARCHAR(100),
    Size INT,
    UploadedBy INT,
    UploadedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Attachments_Request FOREIGN KEY (RequestID) REFERENCES Requests(RequestID)
) ENGINE=InnoDB;

CREATE TABLE Documents (
    DocumentID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    FileName VARCHAR(200),
    Version INT,
    FilePath VARCHAR(500),
    UploadedBy INT,
    UploadedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    Notes VARCHAR(300),
    CONSTRAINT FK_Documents_Request FOREIGN KEY (RequestID) REFERENCES Requests(RequestID)
) ENGINE=InnoDB;

/* ================= SYSTEM ================= */

CREATE TABLE AuditLog (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    TableName VARCHAR(100),
    OperationType VARCHAR(20),
    KeyValue VARCHAR(100),
    ChangedBy VARCHAR(100),
    ChangedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    Details TEXT
) ENGINE=InnoDB;

CREATE TABLE WorkflowStep (
    StepID INT AUTO_INCREMENT PRIMARY KEY,
    RequestTypeID INT NOT NULL,
    Name VARCHAR(100),
    Sequence INT,
    AutoAction VARCHAR(100),
    SLAHours INT,
    CONSTRAINT FK_Workflow_RequestType FOREIGN KEY (RequestTypeID) REFERENCES RequestType(RequestTypeID)
) ENGINE=InnoDB;

CREATE TABLE Escalation (
    EscalationID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    EscalatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    EscalatedToEmployeeID INT,
    Reason VARCHAR(300),
    ResolvedAt DATETIME NULL,
    CONSTRAINT FK_Escalation_Request FOREIGN KEY (RequestID) REFERENCES Requests(RequestID)
) ENGINE=InnoDB;

CREATE TABLE Notification (
    NotificationID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    RecipientEmployeeID INT NOT NULL,
    Channel VARCHAR(50),
    Message TEXT,
    SentAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(50),
    CONSTRAINT FK_Notification_Request FOREIGN KEY (RequestID) REFERENCES Requests(RequestID)
) ENGINE=InnoDB;

CREATE TABLE Tag (
    TagID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50),
    Color VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE RequestTag (
    RequestTagID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    TagID INT NOT NULL,
    CONSTRAINT FK_RequestTag_Request FOREIGN KEY (RequestID) REFERENCES Requests(RequestID),
    CONSTRAINT FK_RequestTag_Tag FOREIGN KEY (TagID) REFERENCES Tag(TagID)
) ENGINE=InnoDB;

CREATE TABLE SLA (
    SLAID INT AUTO_INCREMENT PRIMARY KEY,
    RequestTypeID INT NOT NULL,
    ResponseHours INT,
    ResolveHours INT,
    CONSTRAINT FK_SLA_RequestType FOREIGN KEY (RequestTypeID) REFERENCES RequestType(RequestTypeID)
) ENGINE=InnoDB;

CREATE TABLE Queue (
    QueueID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Description VARCHAR(300),
    OwnerEmployeeID INT,
    CONSTRAINT FK_Queue_Employee FOREIGN KEY (OwnerEmployeeID) REFERENCES Employee(EmployeeID)
) ENGINE=InnoDB;
