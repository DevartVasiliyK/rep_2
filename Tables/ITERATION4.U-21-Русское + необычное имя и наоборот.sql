SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-21-Русское + необычное имя и наоборот] (
  [col1] AS ([столбец2]+[_~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/]) PERSISTED NOT NULL,
  [столбец2] [int] NULL,
  [_~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO