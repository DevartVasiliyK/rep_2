﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[U-44-READUNCOMMITTED/REPEATABLEREAD]
AS SELECT TOP 10 PERCENT * FROM [U-44-DEPT] AS [U-44-DEPT] WITH(READUNCOMMITTED);
GO