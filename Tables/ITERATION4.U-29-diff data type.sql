CREATE TABLE [ITERATION4].[U-29-diff data type] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-29-diff data type]
  ADD FOREIGN KEY ([col4]) REFERENCES [ITERATION4].[U-29-DIFFERENT DATATYPE ALIAS] ([col1])
GO