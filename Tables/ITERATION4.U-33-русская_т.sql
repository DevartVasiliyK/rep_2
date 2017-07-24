SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-33-русская_т] (
  [кол1] [int] NOT NULL,
  [кол2] [int] NULL,
  [col3] [int] NULL,
  [кол4] AS ([кол1]+[кол2]) PERSISTED,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([кол1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-33-русская_т]
  ADD FOREIGN KEY ([кол4]) REFERENCES [ITERATION4].[U-33-бэд руский талица _~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/] ([BADname_~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/ тоже пляхой сталябэц])
GO