﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-54-WITH EXEC AS CALLER/WITH EXECUTE AS SELF]
(@param_name1 AS int) RETURNS int
WITH RETURNS NULL ON NULL INPUT, EXEC AS CALLER BEGIN 
 set @param_name1 = @param_name1 + 1
 RETURN @param_name1
END;
GO