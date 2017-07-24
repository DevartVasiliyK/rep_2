SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-56-different with options] 
( @parameter_name AS int, @p as int = 1 )
RETURNS @retu1 TABLE (c1 int not Null primary key CLUSTERED with fillfactor = 20 on "default", c2 int not null check(c2>0))
WITH Exec as Owner AS
BEGIN 
set @p = @p + 1;
 RETURN
END; 
GO