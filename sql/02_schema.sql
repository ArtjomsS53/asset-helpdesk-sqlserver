use AssetHelpdesk;
go

IF OBJECT_ID(N'dbo.Departments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Departments (
        DepartmentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL UNIQUE
    );
END;
go

if object_id(N'dbo.Users', N'U') is null                --Users
begin
    create table dbo.Users (
        UserId int identity(1,1) primary key,
        DepartmentId int not null,
        FullName nvarchar(150) not null,
        Email nvarchar(200) null unique,
        IsActive bit not null constraint DF_Users_IsActive default (1),
        constraint FK_Users_Departments
            foreign key (DepartmentId) references dbo.Departments(DepartmentId)
    );
end
go

if object_id(N'dbo.devices', N'U') is null              --Devices
begin
    create table dbo.Devices (
        DeviceId int identity(1,1) primary key,
        AssetTag nvarchar(50) not null unique,
        DeviceType nvarchar(30) not null,
        HostName nvarchar(100) not null,
        SerialNumber nvarchar(100) null unique,
        IPv4 varchar(15) null,
        MacAddress varchar(17) null,
        Status nvarchar(50) not null constraint DF_Devices_Status default ('In Stock'),
        PurchasedAt date null,
        Notes nvarchar(max) null,
        constraint CK_Devices_Status check (Status in (N'In Stock', N'Assigned', N'Under Repair', N'Retired'))
    );
end
go