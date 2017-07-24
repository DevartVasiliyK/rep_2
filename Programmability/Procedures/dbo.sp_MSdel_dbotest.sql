SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


 
 
 

-- ============================================================
-- Сюда будем заносить баги наши и наших конкурентов
-- ============================================================
/*
EvgeniyP: не смогли синхронизировать в пустую базу!!!
http://www.red-gate.com/messageboard/viewtopic.php?t=8103
Hello, I found the problem with synchronize databases (SQL Server 2000) using SQL Compare 7.0. 
When I try synchronize one group procedures with two stored procedure:
*/
create procedure [dbo].[sp_MSdel_dbotest] @pkc1 varchar(19)
as
delete "dbo"."test"
where "client" = @pkc1
if @@rowcount = 0
if @@microsoftversion>0x07320000
exec sp_MSreplraiserror 20598

GO

create procedure [dbo].[sp_MSdel_dbotest];2 @pkc1 varchar(19)
as
delete "dbo"."test"
where "client" = @pkc1

GO