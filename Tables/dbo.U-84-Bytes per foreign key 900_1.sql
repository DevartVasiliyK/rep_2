CREATE TABLE [dbo].[U-84-Bytes per foreign key 900/1] (
  [col1] [char](900) NULL,
  [col2] [char](1) NULL
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[U-84-Bytes per foreign key 900/1]
  ADD FOREIGN KEY ([col1]) REFERENCES [dbo].[U-84-Bytes per primary key 900/1] ([col1])
GO