﻿CREATE TYPE [dbo].[U-49-WITH = ON/WITH = OFF_1] AS TABLE (
  [col1] AS ([col2]*[col3]) PERSISTED NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]) WITH (IGNORE_DUP_KEY = ON)
)
GO