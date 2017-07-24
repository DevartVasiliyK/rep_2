CREATE TABLE [dbo].[U-16-differently_quoted_col_name] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]),
  CHECK ([col3] IS NOT NULL)
)
ON [PRIMARY]
GO