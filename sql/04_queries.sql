use AssetHelpdesk;
go

select @@servername as ServerName, db_name() as CurrentDb;

select top 10 * from dbo.Departments;
select top 10 * from dbo.Users;
select top 10 * from dbo.Devices;




