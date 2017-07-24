CREATE TABLE [dbo].[TestConstr] (
  [col] [int] NULL,
  [col2] [varchar](50) NULL
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TestConstr] WITH NOCHECK
  ADD CONSTRAINT [CK_TestConstr] CHECK ([col]=(2))
GO