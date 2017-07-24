CREATE TABLE [dbo].[U-16-with_CONSTRAINT_without_CONSTRAINT] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]),
  CONSTRAINT [U-16-constr1] CHECK ([col3] IS NOT NULL)
)
ON [PRIMARY]
GO