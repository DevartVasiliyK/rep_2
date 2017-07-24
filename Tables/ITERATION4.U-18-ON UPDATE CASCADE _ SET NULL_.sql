﻿CREATE TABLE [ITERATION4].[U-18-ON UPDATE CASCADE _ SET NULL_] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-18-ON UPDATE CASCADE _ SET NULL_]
  ADD FOREIGN KEY ([col2]) REFERENCES [ITERATION4].[U-18-PK_INT_AND_ALL_INT] ([col1]) ON UPDATE CASCADE
GO