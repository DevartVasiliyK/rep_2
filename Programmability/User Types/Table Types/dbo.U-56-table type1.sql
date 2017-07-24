CREATE TYPE [dbo].[U-56-table type1] AS TABLE (
  [col1] AS ([col3]+(1)) PERSISTED NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NOT NULL,
  PRIMARY KEY CLUSTERED ([col1]),
  UNIQUE ([col2]),
  CHECK ([col1]>=(0))
)
GO