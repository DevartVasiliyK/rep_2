CREATE TYPE [dbo].[U-49-WITH/empty] AS TABLE (
  [col1] [uniqueidentifier] NOT NULL ROWGUIDCOL,
  PRIMARY KEY CLUSTERED ([col1]) WITH (IGNORE_DUP_KEY = ON)
)
GO