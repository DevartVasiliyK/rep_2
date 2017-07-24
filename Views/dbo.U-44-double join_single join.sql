SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[U-44-double join/single join]
AS
 SELECT t1.dname, t2.ename, t3.loc FROM [U-44-DEPT] as t1 FULL JOIN [U-44-EMP] as t2 ON (t1.dname = t2.ename) FULL JOIN [U-44-DEPT] as t3 ON (t2.ename = t3.loc);
GO