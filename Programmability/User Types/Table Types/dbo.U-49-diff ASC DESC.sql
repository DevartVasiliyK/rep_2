CREATE TYPE [dbo].[U-49-diff ASC DESC] AS TABLE (
  [col1] AS ([col2]*[col3]) PERSISTED NOT NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1], [col2] DESC)
)
GO