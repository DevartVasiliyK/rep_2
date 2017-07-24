CREATE TABLE [ITERATION4].[U-37-рус таблица] (
  [col1] [int] NOT NULL,
  [столбец2] [int] NULL,
  [столбец-Русский_tabлица _~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-37-рус таблица]
  ON [ITERATION4].[U-37-рус таблица] ([столбец2])
  INCLUDE ([столбец-Русский_tabлица _~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/])
  ON [PRIMARY]
GO