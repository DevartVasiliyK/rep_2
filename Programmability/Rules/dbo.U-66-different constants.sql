SET QUOTED_IDENTIFIER OFF
GO
 
CREATE RULE [dbo].[U-66-different constants] AS 
@range>= $1000 AND @range <$20000 AND @range IN ('1389', '0736', '0877') and @range LIKE '__-%[0-9]';
GO