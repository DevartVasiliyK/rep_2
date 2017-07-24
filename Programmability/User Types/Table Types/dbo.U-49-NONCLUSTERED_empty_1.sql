CREATE TYPE [dbo].[U-49-NONCLUSTERED/empty_1] AS TABLE (
  [col1] AS ([col2]*[col3]) PERSISTED NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY NONCLUSTERED ([col1])
)
GO