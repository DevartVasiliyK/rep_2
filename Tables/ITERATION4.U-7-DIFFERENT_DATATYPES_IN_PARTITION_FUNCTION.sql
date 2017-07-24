﻿CREATE TABLE [ITERATION4].[U-7-DIFFERENT_DATATYPES_IN_PARTITION_FUNCTION] (
  [col1] [date] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]) ON [U-7-ON_DIFFERENT_DATATYPES] ([col1])
)
ON [U-7-ON_DIFFERENT_DATATYPES] ([col1])
GO