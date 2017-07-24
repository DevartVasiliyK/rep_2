SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-54-different param names]
(@param_name1 int) RETURNS int
BEGIN 
 set @param_name1 = @param_name1 + 1
 RETURN @param_name1
END;
GO