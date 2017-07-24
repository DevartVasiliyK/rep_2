SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-54-WITH EXEC AS OWNER/WITH EXECUTE AS 'петров']
(@param_name1 AS int) RETURNS int
WITH EXEC AS OWNER BEGIN 
 set @param_name1 = @param_name1 + 1
 RETURN @param_name1
END;
GO