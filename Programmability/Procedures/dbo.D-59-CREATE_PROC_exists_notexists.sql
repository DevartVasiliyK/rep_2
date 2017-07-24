SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[D-59-CREATE_PROC_exists_notexists]
AS 
BEGIN
select * from [D-59-TABLE_FOR_CREATE_PROC_EXISTS_NOTEXISTS]
END;
-----------------Task 60 VladimirD Create procedure with CLR method
GO