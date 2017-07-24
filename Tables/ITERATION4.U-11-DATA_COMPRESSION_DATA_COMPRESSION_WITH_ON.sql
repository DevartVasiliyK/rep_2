CREATE TABLE [ITERATION4].[U-11-DATA_COMPRESSION_DATA_COMPRESSION_WITH_ON] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  [col6] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]) ON [U-11-partition_scheme1] ([col1])
)
ON [U-11-partition_scheme1] ([col1])
GO