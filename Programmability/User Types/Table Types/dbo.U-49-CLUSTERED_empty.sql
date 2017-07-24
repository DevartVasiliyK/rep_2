CREATE TYPE [dbo].[U-49-CLUSTERED/empty] AS TABLE (
  [col1] [uniqueidentifier] NOT NULL ROWGUIDCOL,
  PRIMARY KEY CLUSTERED ([col1])
)
GO