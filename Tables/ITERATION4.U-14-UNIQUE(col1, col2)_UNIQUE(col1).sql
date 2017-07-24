CREATE TABLE [ITERATION4].[U-14-UNIQUE(col1, col2)_UNIQUE(col1)] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]),
  UNIQUE ([col1], [col2])
)
ON [PRIMARY]
GO