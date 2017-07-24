SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[ServerVersionYear]()
RETURNS NVARCHAR(10)
AS BEGIN
  DECLARE @version_name NVARCHAR(255);
  SET @version_name = LTRIM(REPLACE(@@version,N'Microsoft SQL Server',N''));
  SET @version_name = (SELECT LEFT(@version_name,charindex(N' ',@version_name+N' ',1)));
  
  RETURN LTRIM(RTRIM(@version_name));
END;
GO