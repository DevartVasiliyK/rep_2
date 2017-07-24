SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-33-diff GO TEST] (
  [col1] AS ([col2]+[col5]) PERSISTED NOT NULL,
  [col2] [int] NULL,
  [col3] AS ([col2]+[col4]) PERSISTED,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-33-diff GO TEST]
  ADD FOREIGN KEY ([col1]) REFERENCES [ITERATION4].[U-33-different table name1] ([col1])
GO

ALTER TABLE [ITERATION4].[U-33-diff GO TEST]
  ADD FOREIGN KEY ([col2]) REFERENCES [ITERATION4].[U-33-DIFFERENT DATATYPE ALIAS] ([col1])
GO

ALTER TABLE [ITERATION4].[U-33-diff GO TEST]
  ADD FOREIGN KEY ([col3]) REFERENCES [ITERATION4].[U-33-бэд руский талица _~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/] ([BADname_~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/ тоже пляхой сталябэц])
GO

ALTER TABLE [ITERATION4].[U-33-diff GO TEST]
  ADD FOREIGN KEY ([col4]) REFERENCES [ITERATION4].[U-33-differently defined PK] ([col1])
GO