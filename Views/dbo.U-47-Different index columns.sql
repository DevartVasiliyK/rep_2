SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE VIEW [dbo].[U-47-Different index columns]
WITH SCHEMABINDING
AS SELECT deptno, loc, dname FROM [dbo].[U-47-DEPT];
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE CLUSTERED INDEX [U-47-different column]
  ON [dbo].[U-47-Different index columns] ([deptno])
  ON [PRIMARY]
GO