SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-22-different_part_schema] (
  [col1] [int] NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [computed_col3] AS ([col1]*[col2]) PERSISTED NOT NULL,
  PRIMARY KEY CLUSTERED ([computed_col3]) ON [U-22-different_partition_scheme] ([computed_col3])
)
ON [U-22-different_partition_scheme] ([computed_col3])
GO