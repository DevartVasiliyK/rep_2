CREATE PARTITION FUNCTION [U-22-partition_function_for_different_partition_scheme] ([int])
  AS RANGE RIGHT FOR VALUES (1000, 2000)
GO