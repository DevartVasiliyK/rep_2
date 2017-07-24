CREATE TABLE [ITERATION4].[U-25-ASC_DESC_EMPTY] (
  [col1] [int] NOT NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1], [col2] DESC)
)
ON [PRIMARY]
GO