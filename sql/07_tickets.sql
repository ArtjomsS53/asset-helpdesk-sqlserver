USE AssetHelpdesk;

-----------------------------------------------------------------------
-- 1) Tickets
-----------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Tickets', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tickets (
        TicketId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Tickets_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedByUserId INT NOT NULL,
        AssignedToUserId INT NULL,
        DeviceId INT NULL,

        Title NVARCHAR(200) NOT NULL,
        Description NVARCHAR(MAX) NULL,

        Priority NVARCHAR(10) NOT NULL CONSTRAINT DF_Tickets_Priority DEFAULT (N'Normal'), -- Low/Normal/High
        Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Tickets_Status DEFAULT (N'Open'),       -- Open/InProgress/Closed
        ClosedAt DATETIME2 NULL,

        CONSTRAINT FK_Tickets_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES dbo.Users(UserId),
        CONSTRAINT FK_Tickets_AssignedTo FOREIGN KEY (AssignedToUserId) REFERENCES dbo.Users(UserId),
        CONSTRAINT FK_Tickets_Device FOREIGN KEY (DeviceId) REFERENCES dbo.Devices(DeviceId),
        CONSTRAINT CK_Tickets_Priority CHECK (Priority IN (N'Low', N'Normal', N'High')),
        CONSTRAINT CK_Tickets_Status CHECK (Status IN (N'Open', N'InProgress', N'Closed'))
    );

    CREATE INDEX IX_Tickets_Status_CreatedAt ON dbo.Tickets(Status, CreatedAt DESC);
    CREATE INDEX IX_Tickets_DeviceId_Status ON dbo.Tickets(DeviceId, Status);
END;

-----------------------------------------------------------------------
-- 2) TicketComments
-----------------------------------------------------------------------
IF OBJECT_ID(N'dbo.TicketComments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TicketComments (
        CommentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        TicketId INT NOT NULL,
        AuthorUserId INT NOT NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Comments_CreatedAt DEFAULT (SYSUTCDATETIME()),
        Body NVARCHAR(MAX) NOT NULL,

        CONSTRAINT FK_Comments_Ticket FOREIGN KEY (TicketId) REFERENCES dbo.Tickets(TicketId),
        CONSTRAINT FK_Comments_Author FOREIGN KEY (AuthorUserId) REFERENCES dbo.Users(UserId)
    );

    CREATE INDEX IX_Comments_TicketId_CreatedAt ON dbo.TicketComments(TicketId, CreatedAt);
END;

-----------------------------------------------------------------------
-- 3) Create one demo ticket for ASSET-0001 (idempotent)
-----------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM dbo.Tickets t
    JOIN dbo.Users u ON u.UserId = t.CreatedByUserId
    JOIN dbo.Devices d ON d.DeviceId = t.DeviceId
    WHERE u.Email = N'artjoms@example.com'
      AND d.AssetTag = N'ASSET-0001'
      AND t.Title = N'Wi-Fi does not work'
)
BEGIN
    INSERT INTO dbo.Tickets (CreatedByUserId, AssignedToUserId, DeviceId, Title, Description, Priority, Status)
    SELECT
        u.UserId,
        u.UserId, -- пока назначим самому себе (позже сделаем отдельного "IT tech")
        d.DeviceId,
        N'Wi-Fi does not work',
        N'Cannot connect to Wi-Fi network. Please investigate.',
        N'Normal',
        N'Open'
    FROM dbo.Users u
    JOIN dbo.Devices d ON d.AssetTag = N'ASSET-0001'
    WHERE u.Email = N'artjoms@example.com';
END;

-----------------------------------------------------------------------
-- 4) Add a comment to the newest matching ticket (idempotent)
-----------------------------------------------------------------------
DECLARE @TicketId INT;

SELECT TOP (1) @TicketId = t.TicketId
FROM dbo.Tickets t
JOIN dbo.Users u ON u.UserId = t.CreatedByUserId
WHERE u.Email = N'artjoms@example.com'
  AND t.Title = N'Wi-Fi does not work'
ORDER BY t.CreatedAt DESC;

IF @TicketId IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM dbo.TicketComments
    WHERE TicketId = @TicketId AND Body = N'Initial report created.'
)
BEGIN
    INSERT INTO dbo.TicketComments (TicketId, AuthorUserId, Body)
    SELECT @TicketId, u.UserId, N'Initial report created.'
    FROM dbo.Users u
    WHERE u.Email = N'artjoms@example.com';
END;

-----------------------------------------------------------------------
-- 5) Reports (queries)
-----------------------------------------------------------------------
-- All open tickets
SELECT
    t.TicketId,
    t.CreatedAt,
    t.Status,
    t.Priority,
    t.Title,
    u.FullName AS CreatedBy,
    d.AssetTag
FROM dbo.Tickets t
JOIN dbo.Users u ON u.UserId = t.CreatedByUserId
LEFT JOIN dbo.Devices d ON d.DeviceId = t.DeviceId
WHERE t.Status <> N'Closed'
ORDER BY t.CreatedAt DESC;

-- Ticket details with comments (for the demo ticket)
SELECT
    t.TicketId,
    t.Title,
    t.Status,
    t.Priority,
    t.CreatedAt,
    tc.CreatedAt AS CommentAt,
    uc.FullName AS CommentAuthor,
    tc.Body
FROM dbo.Tickets t
LEFT JOIN dbo.TicketComments tc ON tc.TicketId = t.TicketId
LEFT JOIN dbo.Users uc ON uc.UserId = tc.AuthorUserId
WHERE t.Title = N'Wi-Fi does not work'
ORDER BY t.TicketId DESC, tc.CreatedAt ASC;

-- All tickets for a specific device (ASSET-0001)
SELECT
    t.TicketId,
    t.CreatedAt,
    t.Status,
    t.Priority,
    t.Title,
    u.FullName AS CreatedBy,
    d.AssetTag
FROM dbo.Tickets t
JOIN dbo.Users u ON u.UserId = t.CreatedByUserId
JOIN dbo.Devices d ON d.DeviceId = t.DeviceId
WHERE d.AssetTag = N'ASSET-0001'
ORDER BY t.CreatedAt DESC;

