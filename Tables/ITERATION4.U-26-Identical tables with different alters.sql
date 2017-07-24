CREATE TABLE [ITERATION4].[U-26-Identical tables with different alters] (
  [col1] [int] NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  UNIQUE ([col4], [col5]),
  UNIQUE ([col1], [col2], [col3])
)
ON [PRIMARY]
GO