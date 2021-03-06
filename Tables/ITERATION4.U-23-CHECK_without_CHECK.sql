﻿SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-23-CHECK_without_CHECK] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [computed_col3] AS ([col1]*[col2]) PERSISTED NOT NULL,
  PRIMARY KEY CLUSTERED ([col1]),
  CHECK ([computed_col3] IS NOT NULL)
)
ON [PRIMARY]
GO