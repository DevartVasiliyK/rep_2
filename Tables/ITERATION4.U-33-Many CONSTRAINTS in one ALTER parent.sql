CREATE TABLE [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER parent] (
  [col8] [int] NULL,
  [col9] [int] NULL,
  [col10] [int] NOT NULL,
  [col11] [int] NULL,
  [col12] [int] NULL,
  [col13] [int] NULL,
  [col14] [int] NULL,
  [col15] [int] NULL,
  UNIQUE ([col8]),
  UNIQUE ([col9]),
  UNIQUE ([col12]),
  UNIQUE ([col11]),
  UNIQUE ([col10])
)
ON [PRIMARY]
GO