﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE VIEW [dbo].[U-46-UNION ALL/ SINGLE]
AS SELECT * FROM [U-46-DEPT]
UNION ALL
SELECT * FROM [U-46-DEPT1];
GO