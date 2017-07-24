SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-20-CONSTR/empty] (
  [col1] AS ([col2]+cos(sin((1)+[col3]))) PERSISTED NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  CONSTRAINT [U-20 constr1] PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO