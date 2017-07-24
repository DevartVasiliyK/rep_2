SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-33-Different PK count] (
  [col1] AS ([col2]+[col3]) PERSISTED NOT NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NOT NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1], [col2])
)
ON [PRIMARY]
GO