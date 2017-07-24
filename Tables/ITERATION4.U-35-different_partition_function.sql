CREATE TABLE [ITERATION4].[U-35-different_partition_function] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-35-index_for_different_partition_function]
  ON [ITERATION4].[U-35-different_partition_function] ([col1])
  ON [U-35-scheme_for_different_partition_function] ([col1])
GO