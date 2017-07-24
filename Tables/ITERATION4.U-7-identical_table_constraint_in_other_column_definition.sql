CREATE TABLE [ITERATION4].[U-7-identical_table_constraint_in_other_column_definition] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]) ON [U-7-partition_scheme1] ([col1])
)
ON [U-7-partition_scheme1] ([col1])
GO