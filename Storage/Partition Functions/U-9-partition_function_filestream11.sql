CREATE PARTITION FUNCTION [U-9-partition_function_filestream11] ([int])
  AS RANGE RIGHT FOR VALUES (1000, 2000)
GO