SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-54-AS BEGIN/BEGIN]
(@param_name1 AS int) RETURNS int
AS BEGIN 
 set @param_name1 = @param_name1 + 1
 RETURN @param_name1
END;
GO