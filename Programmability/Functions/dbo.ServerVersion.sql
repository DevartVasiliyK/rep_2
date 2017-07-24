﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[ServerVersion]()
RETURNS REAL
AS
BEGIN
  RETURN (
    SELECT CAST(SUBSTRING(CONVERT(VARCHAR, SERVERPROPERTY('productversion')), 1, CHARINDEX('.', CONVERT(VARCHAR, SERVERPROPERTY('productversion')))+1) AS REAL)
  )
END
GO