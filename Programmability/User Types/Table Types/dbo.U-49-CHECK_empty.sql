CREATE TYPE [dbo].[U-49-CHECK/empty] AS TABLE (
  [col1] [float] NULL,
  CHECK ([col1]>(0))
)
GO