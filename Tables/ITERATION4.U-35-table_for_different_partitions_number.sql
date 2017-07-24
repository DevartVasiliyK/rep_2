CREATE TABLE [ITERATION4].[U-35-table_for_different_partitions_number] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-35-different_partitions_number]
  ON [ITERATION4].[U-35-table_for_different_partitions_number] ([col1])
  ON [U-35-partition_scheme_to_filegroup] ([col1])
GO