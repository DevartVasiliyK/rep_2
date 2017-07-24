CREATE TABLE [ITERATION4].[U-36-COMPARISON|empty] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-36-COMPARISON|empty]
  ON [ITERATION4].[U-36-COMPARISON|empty] ([col2])
  WHERE ([col2] IS NOT NULL)
  ON [PRIMARY]
GO