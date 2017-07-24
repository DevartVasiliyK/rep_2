CREATE TABLE [ITERATION4].[U-14-UNIQUE_EMPTY] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]),
  UNIQUE ([col4]),
  UNIQUE ([col5]),
  UNIQUE ([col2]),
  UNIQUE ([col3])
)
ON [PRIMARY]
GO