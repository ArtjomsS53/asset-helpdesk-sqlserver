if db_id(N'AssetHelpdesk') is null
begin
    create database AssetHelpdesk;
end
go

use AssetHelpdesk;
go