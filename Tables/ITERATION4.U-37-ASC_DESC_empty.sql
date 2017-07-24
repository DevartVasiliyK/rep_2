CREATE TABLE [ITERATION4].[U-37-ASC_DESC/empty] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [U-37-ASC_DESC/empty]
  ON [ITERATION4].[U-37-ASC_DESC/empty] ([col2], [col3] DESC, [col4], [col5] DESC)
  ON [PRIMARY]
GO