CREATE TABLE [dbo].[U-84-Bytes per index key 900/1] (
  [col1] [char](900) NULL,
  [col2] [char](1) NULL
)
ON [PRIMARY]
GO

CREATE INDEX [U-84-Bytes per index key 900/1]
  ON [dbo].[U-84-Bytes per index key 900/1] ([col1])
  ON [PRIMARY]
GO