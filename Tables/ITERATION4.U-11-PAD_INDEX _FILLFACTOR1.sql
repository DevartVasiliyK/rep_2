﻿CREATE TABLE [ITERATION4].[U-11-PAD_INDEX _FILLFACTOR1] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  [col6] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]) WITH (PAD_INDEX = ON)
)
ON [PRIMARY]
GO