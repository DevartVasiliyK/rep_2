﻿CREATE TABLE [ITERATION4].[U-7-different_partition_schema_in_table_constraint] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]) ON [U-7-partition_scheme2] ([col1])
)
ON [U-7-partition_scheme2] ([col1])
GO