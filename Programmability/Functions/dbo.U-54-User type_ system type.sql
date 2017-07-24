SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-54-User type/ system type]
(@param_name1 AS dbo.[U-54-TypeFromINT], @param_name2 [U-54-TypeFromINT]) RETURNS int
BEGIN 
 set @param_name1 = @param_name1 + 1
 RETURN @param_name1
END;
GO