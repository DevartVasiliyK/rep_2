CREATE TABLE [ITERATION4].[U-7-different_partition_column] (
  [col1] [int] NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col2]) ON [U-7-partition_scheme1] ([col2])
)
ON [U-7-partition_scheme1] ([col2])
GO