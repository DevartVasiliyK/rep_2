SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-33-REFERENCES ON diff datatypeSize] (
  [col1] [int] NOT NULL,
  [col2] [char](5) NULL,
  [col3] [char](6) NULL,
  [col4] AS ([col2]+[col3]) PERSISTED,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-33-REFERENCES ON diff datatypeSize]
  ADD FOREIGN KEY ([col4]) REFERENCES [ITERATION4].[U-33-DIFFERENT DATATYPE SIZE] ([col1])
GO