﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-54-different param datatypes]
(@param_name1 int, @param_name2 char(10)) RETURNS int
BEGIN 
 set @param_name1 = @param_name1 + 1
 RETURN @param_name1
END;
GO