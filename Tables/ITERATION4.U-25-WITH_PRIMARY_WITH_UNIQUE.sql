﻿CREATE TABLE [ITERATION4].[U-25-WITH_PRIMARY_WITH_UNIQUE] (
  [col1] [int] NULL,
  [col2] [int] NULL,
  [col3] [int] NOT NULL,
  CONSTRAINT [U-25-Constr2] PRIMARY KEY CLUSTERED ([col3])
)
ON [PRIMARY]
GO