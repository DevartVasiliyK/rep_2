CREATE TABLE [dbo].[t_2] (
  [pk] [int] NULL,
  [fk] [int] NULL
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[t_2]
  ADD FOREIGN KEY ([fk]) REFERENCES [dbo].[t_3] ([pk])
GO