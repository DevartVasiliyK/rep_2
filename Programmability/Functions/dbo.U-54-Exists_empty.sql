SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

------------------------- Viktoru -- Task54 -- Scalar Functions --

CREATE FUNCTION [dbo].[U-54-Exists/empty]
(@param_name int) RETURNS int
BEGIN 
 set @param_name = @param_name + 1
 RETURN @param_name
END;
GO