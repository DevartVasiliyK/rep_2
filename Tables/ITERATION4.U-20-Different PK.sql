﻿SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-20-Different PK] (
  [col1] AS ([col2]+[col5]) PERSISTED NOT NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col2])
)
ON [PRIMARY]
GO