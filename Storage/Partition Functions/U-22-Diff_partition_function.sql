﻿CREATE PARTITION FUNCTION [U-22-Diff_partition_function] ([int])
  AS RANGE RIGHT FOR VALUES (1000, 2000)
GO