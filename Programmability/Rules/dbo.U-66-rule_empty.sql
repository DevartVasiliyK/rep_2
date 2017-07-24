SET QUOTED_IDENTIFIER OFF
GO
 
 ------------------------- Viktoru -- Task66 -- RULE-ы -- 
 
 
 CREATE RULE [dbo].[U-66-rule/empty] AS @range>= $1000 AND @range <$20000 ;
 
GO