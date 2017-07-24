CREATE TYPE [dbo].[U-49-CHECK/PK] AS TABLE (
  [col1] [float] NULL,
  CHECK ([col1]>(0))
)
GO