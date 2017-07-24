SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-23-without_CHECK_with_CHECK] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [computed_col3] AS ([col1]*[col2]) PERSISTED NOT NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO