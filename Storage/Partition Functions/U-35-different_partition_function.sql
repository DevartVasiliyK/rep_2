CREATE PARTITION FUNCTION [U-35-different_partition_function] ([int])
  AS RANGE RIGHT FOR VALUES (1000, 2000)
GO