CREATE PARTITION FUNCTION [U-35-different_partition_function_DATATYPE] ([bit])
  AS RANGE RIGHT FOR VALUES (0, 1)
GO