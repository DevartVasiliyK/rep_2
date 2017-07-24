CREATE TABLE [ITERATION4].[U-36-DISJUNCT/COMPARISON] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-36-DISJUNCT/COMPARISON]
  ON [ITERATION4].[U-36-DISJUNCT/COMPARISON] ([col2])
  WHERE ([col2] IN ((1), (2), (3)))
  ON [PRIMARY]
GO