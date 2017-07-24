SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-31-Different UK] (
  [col1] AS ([col2]+[col5]) PERSISTED NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  UNIQUE ([col2]),
  UNIQUE ([col1])
)
ON [PRIMARY]
GO