﻿CREATE TABLE [ITERATION4].[U-7-PARTITIONS_RANGE_PARTITIONS_NUMBER] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]) ON [U-7-partition_scheme1] ([col1])
)
ON [U-7-partition_scheme1] ([col1])
GO