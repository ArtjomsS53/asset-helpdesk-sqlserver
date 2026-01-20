USE AssetHelpdesk;

-- Таблица выдач устройств (история)
IF OBJECT_ID(N'dbo.DeviceAssignments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DeviceAssignments (
        AssignmentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        DeviceId INT NOT NULL,
        UserId INT NOT NULL,
        AssignedAt DATETIME2 NOT NULL CONSTRAINT DF_Assign_AssignedAt DEFAULT (SYSUTCDATETIME()),
        ReturnedAt DATETIME2 NULL,

        CONSTRAINT FK_Assign_Device FOREIGN KEY (DeviceId) REFERENCES dbo.Devices(DeviceId),
        CONSTRAINT FK_Assign_User FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
    );

    CREATE INDEX IX_Assign_Device_ReturnedAt ON dbo.DeviceAssignments(DeviceId, ReturnedAt);
    CREATE INDEX IX_Assign_User_ReturnedAt ON dbo.DeviceAssignments(UserId, ReturnedAt);
END;


-- Выдаём ASSET-0001 пользователю artjoms@example.com (если ещё не выдано)
IF NOT EXISTS (
    SELECT 1
    FROM dbo.DeviceAssignments a
    JOIN dbo.Devices d ON d.DeviceId = a.DeviceId
    WHERE d.AssetTag = N'ASSET-0001' AND a.ReturnedAt IS NULL
)
BEGIN
    INSERT INTO dbo.DeviceAssignments(DeviceId, UserId)
    SELECT d.DeviceId, u.UserId
    FROM dbo.Devices d
    JOIN dbo.Users u ON u.Email = N'artjoms@example.com'
    WHERE d.AssetTag = N'ASSET-0001';

    UPDATE dbo.Devices
    SET Status = N'Assigned'
    WHERE AssetTag = N'ASSET-0001';
END;
