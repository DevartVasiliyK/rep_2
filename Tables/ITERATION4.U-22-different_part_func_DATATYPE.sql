SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-22-different_part_func_DATATYPE] (
  [col1] [bigint] NULL,
  [col2] [bigint] NULL,
  [col3] [int] NULL,
  [computed_col3] AS ([col1]*[col2]) PERSISTED NOT NULL,
  PRIMARY KEY CLUSTERED ([computed_col3]) ON [U-22-partition_scheme_diff_par_f_DATATYPE] ([computed_col3])
)
ON [U-22-partition_scheme_diff_par_f_DATATYPE] ([computed_col3])
GO