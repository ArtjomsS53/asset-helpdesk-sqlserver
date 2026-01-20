USE AssetHelpdesk;

IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Name = N'IT Department')
    INSERT INTO dbo.Departments (Name) VALUES (N'IT Department');

IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Name = N'Accounting')
    INSERT INTO dbo.Departments (Name) VALUES (N'Accounting');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = N'artjoms@example.com')
BEGIN
    INSERT INTO dbo.Users (DepartmentId, FullName, Email)
    SELECT d.DepartmentId, N'Artjoms Jansons', N'artjoms@example.com'
    FROM dbo.Departments d
    WHERE d.Name = N'IT Department';
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Devices WHERE AssetTag = N'ASSET-0001')
BEGIN
    INSERT INTO dbo.Devices
        (AssetTag, DeviceType, HostName, SerialNumber, IPv4, MacAddress, Status, PurchasedAt, Notes)
    VALUES (N'ASSET-0001', N'Laptop', N'ARTJOMS-LAPTOP', N'SN123456789', '192.168.1.100', 'AA-BB-CC-DD-EE-FF',
        N'InStock', '2023-01-15', N'InStock');

END;
go

