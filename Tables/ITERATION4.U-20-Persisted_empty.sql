SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-20-Persisted/empty] (
  [col1] AS ([col2]+cos(sin((1)+[col3]))) PERSISTED,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL
)
ON [PRIMARY]
GO