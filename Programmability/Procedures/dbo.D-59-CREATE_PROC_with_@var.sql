SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[D-59-CREATE_PROC_with_@var]
@Name varchar(30) = 'world'
AS 
BEGIN
PRINT 'Hello'+@Name
END;

GO