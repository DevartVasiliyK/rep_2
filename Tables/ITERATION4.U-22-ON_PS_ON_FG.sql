SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-22-ON_PS_ON_FG] (
  [col1] [int] NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [computed_col3] AS ([col1]*[col2]) PERSISTED NOT NULL,
  PRIMARY KEY CLUSTERED ([computed_col3]) ON [U-22-partition_scheme_to_filegroup] ([computed_col3])
)
ON [U-22-partition_scheme_to_filegroup] ([computed_col3])
GO