SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[adm_filegroup_add](
  @db_name NVARCHAR(2550),
  @fg_name NVARCHAR(2550),
  @filename NVARCHAR(2550),
  @contains NVARCHAR(2550) = NULL,
  @filepath NVARCHAR(2550) = NULL
  )
AS
SET NOCOUNT ON;
DECLARE @sql_cmd NVARCHAR(MAX);

IF @filepath IS NULL
  SET @filepath = dbo.ServerDefaultDataFolder();

SET @sql_cmd ='ALTER DATABASE ' + @db_name + ' ADD FILEGROUP ' + @fg_name;
IF @contains IS NOT NULL
  SET @sql_cmd = @sql_cmd +' CONTAINS '+@contains;
EXEC (@sql_cmd);

SET @sql_cmd = '
ALTER DATABASE '+@db_name+'
ADD FILE (
  NAME = N'''+@fg_name+''',
  FILENAME = N'''+@filepath+@filename+'''
  ) TO FILEGROUP '+@fg_name;
EXEC (@sql_cmd);
RETURN;
GO