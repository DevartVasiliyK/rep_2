CREATE TABLE [ITERATION4].[U-26-ASC_DESC_EMPTY_U] (
  [col1] [int] NOT NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NULL,
  UNIQUE ([col1], [col2] DESC)
)
ON [PRIMARY]
GO