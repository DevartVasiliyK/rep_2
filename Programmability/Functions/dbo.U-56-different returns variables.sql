SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-56-different returns variables] 
( @parameter_name AS int, @p as int = 1 )
RETURNS @retu1 TABLE (c1 int, primary key (c1), c2 int not null check(c2>0))
WITH ENCRYPTION AS
BEGIN 
set @p = @p + 1;
 RETURN
END; 
GO