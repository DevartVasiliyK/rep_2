CREATE PARTITION FUNCTION [U-7-bad Values] ([char](20))
  AS RANGE FOR VALUES ('+=\(),_[]`!@#$%^&*  ', 'xd                  ')
GO