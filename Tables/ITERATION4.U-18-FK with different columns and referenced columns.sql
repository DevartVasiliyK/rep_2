CREATE TABLE [ITERATION4].[U-18-FK with different columns and referenced columns] (
  [col1] [int] NOT NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NOT NULL,
  [col4] [int] NOT NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-18-FK with different columns and referenced columns]
  ADD FOREIGN KEY ([col2], [col3]) REFERENCES [ITERATION4].[U-18-ALL PK] ([col2], [col3])
GO