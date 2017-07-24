CREATE TABLE [ITERATION4].[U-29-diff GO TEST] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-29-diff GO TEST]
  ADD FOREIGN KEY ([col1]) REFERENCES [ITERATION4].[U-29-different table name1] ([col1])
GO

ALTER TABLE [ITERATION4].[U-29-diff GO TEST]
  ADD FOREIGN KEY ([col2]) REFERENCES [ITERATION4].[U-29-DIFFERENT DATATYPE ALIAS] ([col1])
GO

ALTER TABLE [ITERATION4].[U-29-diff GO TEST]
  ADD FOREIGN KEY ([col3]) REFERENCES [ITERATION4].[U-29-бэд руский талица _~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/] ([BADname_~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/ тоже пляхой сталябэц])
GO

ALTER TABLE [ITERATION4].[U-29-diff GO TEST]
  ADD FOREIGN KEY ([col4]) REFERENCES [ITERATION4].[U-29-differently defined PK] ([col1])
GO