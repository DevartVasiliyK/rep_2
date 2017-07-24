CREATE TABLE [ITERATION4].[U-13-Русское ограничение] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  [col6] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]),
  CONSTRAINT [Русское_ограничение] UNIQUE ([col2])
)
ON [PRIMARY]
GO