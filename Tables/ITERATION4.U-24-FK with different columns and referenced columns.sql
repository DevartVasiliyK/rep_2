SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-24-FK with different columns and referenced columns] (
  [col1] [int] NOT NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NOT NULL,
  [col4] AS ([col2]+[col3]) PERSISTED,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-24-FK with different columns and referenced columns]
  ADD FOREIGN KEY ([col2], [col4]) REFERENCES [ITERATION4].[U-24-ALL PK] ([col2], [col4])
GO