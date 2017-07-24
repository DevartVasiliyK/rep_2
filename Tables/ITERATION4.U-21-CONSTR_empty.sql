SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-21-CONSTR/empty] (
  [col1] AS ([col2]+cos(sin((1)+[col3]))) PERSISTED NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  CONSTRAINT [U-21 constr1] UNIQUE ([col1])
)
ON [PRIMARY]
GO