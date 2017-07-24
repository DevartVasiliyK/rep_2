SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-54-comments]
(@param_name1 AS int) RETURNS int
WITH EXEC AS /* comment*/ OWNER BEGIN 
 set @param_name1/* comment*/ = /* comment*/ @param_name1 + 1 -- comment
 RETURN /* comment*/ @param_name1
END;
GO