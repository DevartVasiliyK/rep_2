CREATE TABLE [ITERATION4].[U-35-table_for_witout_WITH_with_WITH] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-35-WITH_witout_WITH]
  ON [ITERATION4].[U-35-table_for_witout_WITH_with_WITH] ([col1])
  ON [U-35-partition_scheme_to_filegroup] ([col1])
GO