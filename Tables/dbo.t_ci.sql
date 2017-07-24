CREATE TABLE [dbo].[t_ci] (
  [c1] [int] NULL,
  [c2] [char](100) NULL,
  [c3] [int] NULL,
  [c4] [varchar](1000) NULL
)
ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [ci]
  ON [dbo].[t_ci] ([c1])
  ON [PRIMARY]
GO