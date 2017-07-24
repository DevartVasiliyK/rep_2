SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[adm_ServerPlatform]
  (@platform NVARCHAR(255) OUTPUT)
AS
SET @platform = 'WINDOWS';

IF EXISTS (SELECT * FROM sys.all_objects ao WHERE name = 'dm_os_windows_info') BEGIN
  EXEC ('SELECT windows_release INTO ##windows_release FROM sys.dm_os_windows_info');
  IF DATALENGTH((SELECT TOP 1 windows_release FROM ##windows_release))=0
    SET @platform = 'LINUX';
  DROP TABLE ##windows_release;
END;
RETURN;
GO