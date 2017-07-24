SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO







CREATE FUNCTION [dbo].[U-57-Scalar/CLR Scalar]
(@param_name1 AS float) RETURNS float
WITH EXEC AS OWNER BEGIN 
 set @param_name1 = @param_name1 + 1
 RETURN @param_name1
END;
GO