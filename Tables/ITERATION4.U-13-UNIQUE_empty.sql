CREATE TABLE [ITERATION4].[U-13-UNIQUE_empty] (
  [col1] [int] NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  [col6] [int] NULL,
  PRIMARY KEY CLUSTERED ([col2]),
  UNIQUE ([col1])
)
ON [PRIMARY]
GO