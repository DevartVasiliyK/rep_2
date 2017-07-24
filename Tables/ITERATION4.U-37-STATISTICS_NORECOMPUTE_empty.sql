﻿CREATE TABLE [ITERATION4].[U-37-STATISTICS_NORECOMPUTE/empty] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [U-37-STATISTICS_NORECOMPUTE/empty]
  ON [ITERATION4].[U-37-STATISTICS_NORECOMPUTE/empty] ([col2])
  WITH (STATISTICS_NORECOMPUTE = ON)
  ON [PRIMARY]
GO