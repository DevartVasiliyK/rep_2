SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[D-59-TABLE_FOR_CREATE_PROC_multy];1
AS 
begin
select col1 from [D-59-TABLE_FOR_CREATE_PROC_9]
end;
GO

CREATE PROCEDURE [dbo].[D-59-TABLE_FOR_CREATE_PROC_multy];2
AS 
begin
select col2 from [D-59-TABLE_FOR_CREATE_PROC_9]
end;
GO

CREATE PROCEDURE [dbo].[D-59-TABLE_FOR_CREATE_PROC_multy];3
AS 
BEGIN 
SELECT col3 from [D-59-TABLE_FOR_CREATE_PROC_9]
END;
GO

CREATE PROCEDURE [dbo].[D-59-TABLE_FOR_CREATE_PROC_multy];4
AS 
BEGIN 
SELECT * from [D-59-TABLE_FOR_CREATE_PROC_9]
END









-----------------Task 60 VladimirD Create procedure with CLR method





GO