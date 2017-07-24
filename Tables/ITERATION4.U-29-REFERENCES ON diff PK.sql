CREATE TABLE [ITERATION4].[U-29-REFERENCES ON diff PK] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-29-REFERENCES ON diff PK]
  ADD FOREIGN KEY ([col4]) REFERENCES [ITERATION4].[U-29-differently defined PK] ([col1])
GO