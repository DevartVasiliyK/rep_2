﻿SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-33-REFERENCES ON diff PK] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] AS ([col1]+[col2]) PERSISTED,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-33-REFERENCES ON diff PK]
  ADD FOREIGN KEY ([col4]) REFERENCES [ITERATION4].[U-33-differently defined PK] ([col1])
GO