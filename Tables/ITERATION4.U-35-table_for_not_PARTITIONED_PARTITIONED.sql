﻿CREATE TABLE [ITERATION4].[U-35-table_for_not_PARTITIONED_PARTITIONED] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-35-not_PARTITIONED_PARTITIONED]
  ON [ITERATION4].[U-35-table_for_not_PARTITIONED_PARTITIONED] ([col1])
  ON [PRIMARY]
GO