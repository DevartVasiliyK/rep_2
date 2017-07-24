SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-24-ALL PK] (
  [col1] [int] NOT NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NOT NULL,
  [col4] AS ([col2]+[col3]) PERSISTED NOT NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col2], [col4])
)
ON [PRIMARY]
GO