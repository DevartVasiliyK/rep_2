SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-33-diff table name] (
  [col1] [int] NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] AS ([col1]+[col2]) PERSISTED NOT NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col4])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-33-diff table name]
  ADD FOREIGN KEY ([col4]) REFERENCES [ITERATION4].[U-33-different table name1] ([col1])
GO