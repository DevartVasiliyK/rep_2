﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[D-59-TABLE_FOR_CREATE_PROC_without_BEGINEND]
AS 
begin
select * from [D-59-TABLE_FOR_CREATE_PROC_begin_end]
end;
GO