CREATE TABLE [ITERATION4].[U-29-REFERENCES ON diff datatypeSize] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [char](11) NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-29-REFERENCES ON diff datatypeSize]
  ADD FOREIGN KEY ([col4]) REFERENCES [ITERATION4].[U-29-DIFFERENT DATATYPE SIZE] ([col1])
GO