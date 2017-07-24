CREATE TABLE [ITERATION4].[U-36-DIFFERENT IN AREA] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-36-DIFFERENT IN AREA]
  ON [ITERATION4].[U-36-DIFFERENT IN AREA] ([col2])
  WHERE ([col1] IN ((1), (3), (5)))
  ON [PRIMARY]
GO