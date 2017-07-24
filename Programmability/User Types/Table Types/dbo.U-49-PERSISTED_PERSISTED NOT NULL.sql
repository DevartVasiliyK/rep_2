CREATE TYPE [dbo].[U-49-PERSISTED/PERSISTED NOT NULL] AS TABLE (
  [col1] AS ([col2]*[col3]) PERSISTED,
  [col2] [int] NULL,
  [col3] [int] NULL
)
GO