CREATE PARTITION FUNCTION [U-7-BADname_godName of partition schema] ([int])
  AS RANGE FOR VALUES (10, 100, 1000, 10000)
GO