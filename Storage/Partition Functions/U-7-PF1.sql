﻿CREATE PARTITION FUNCTION [U-7-PF1] ([int])
  AS RANGE FOR VALUES (10, 100)
GO