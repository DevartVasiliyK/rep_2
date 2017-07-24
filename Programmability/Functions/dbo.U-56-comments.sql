SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-56-comments]
( @parameter_name AS int, @p as int = 1 )
RETURNS @retu1 /* comment*/ TABLE (c1 int not Null primary key /* comment*/ CLUSTERED with fillfactor = 20 on "default", c2 int not null check(c2>0))
WITH Exec/* comment*/ as /* comment*/ Owner/* comment*/ AS
BEGIN /* comment*/ 
set @p = @p/* comment*/ + /* comment*/ 1/* comment*/ ;/* comment*/ --comment
 /* comment*/ RETURN/* comment*/ /* comment*/ 
END/* comment*/ ; 
GO