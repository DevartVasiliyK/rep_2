﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[U-44-ON different columns]
AS
 SELECT dname, loc, ename FROM [U-44-DEPT] FULL JOIN [U-44-EMP] ON dname = ename;
GO