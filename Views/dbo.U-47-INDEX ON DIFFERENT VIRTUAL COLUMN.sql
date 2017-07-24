﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[U-47-INDEX ON DIFFERENT VIRTUAL COLUMN](c1, c2, c3)
WITH SCHEMABINDING
AS SELECT deptno, loc, dname FROM [dbo].[U-47-DEPT];
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE CLUSTERED INDEX [U-47-different column]
  ON [dbo].[U-47-INDEX ON DIFFERENT VIRTUAL COLUMN] ([c1])
  ON [PRIMARY]
GO