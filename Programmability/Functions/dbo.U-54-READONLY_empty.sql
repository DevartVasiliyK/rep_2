SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-54-READONLY/empty]
(@param_name1 AS varchar(max), @param_name2 [U-54-Table Type] READONLY) RETURNS int
BEGIN 
 set @param_name1 = @param_name1 + 1
 RETURN @param_name1
END;
GO