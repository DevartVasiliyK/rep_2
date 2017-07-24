CREATE TABLE [dbo].[U-16-without_FOR_REPL_with_FOR_REPL] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]),
  CHECK ([col3] IS NOT NULL)
)
ON [PRIMARY]
GO