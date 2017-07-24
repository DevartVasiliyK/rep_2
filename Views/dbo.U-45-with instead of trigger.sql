SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--------------------------------------

CREATE VIEW [dbo].[U-45-with instead of trigger]
AS SELECT dname, loc, ename FROM [U-45-DEPT], [U-45-EMP];
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[U-45-Trigger On View] ON [U-45-with instead of trigger]
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
IF (NOT EXISTS(SELECT * FROM [U-45-DEPT] WHERE deptno IS NULL and dname IS NOT NULL))
 INSERT INTO [U-45-DEPT] VALUES(1, 2,3)
ELSE 
 INSERT INTO [U-45-DEPT] VALUES(1, 2,4)
END
GO