﻿SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-24-NOT FOR REPLICATION - EMPTY_] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] AS ([col2]+[col3]) PERSISTED,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-24-NOT FOR REPLICATION - EMPTY_] WITH NOCHECK
  ADD FOREIGN KEY ([col4]) REFERENCES [ITERATION4].[U-24-PK_INT_AND_ALL_INT] ([col1]) NOT FOR REPLICATION
GO