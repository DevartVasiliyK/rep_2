CREATE TABLE [ITERATION4].[U-36-WITH IDENTICAL WHERE] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-36-Identical WHERE]
  ON [ITERATION4].[U-36-WITH IDENTICAL WHERE] ([col2])
  WHERE ([col1] IN ((1), (3), (5)))
  ON [PRIMARY]
GO