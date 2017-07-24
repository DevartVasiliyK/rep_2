SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-31-ON PARTITION/Empty] (
  [col1] AS ([col2]+cos(sin((1)+[col3]))) PERSISTED NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  UNIQUE ([col1]) ON [U-31-partition_scheme1] ([col1])
)
ON [PRIMARY]
GO