SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[adm_create_database](
  @db_name NVARCHAR(2550),
  @filepath NVARCHAR(2550) = NULL
  )
AS
DECLARE @sql_cmd NVARCHAR(MAX);

IF DB_ID(@db_name) IS NOT NULL
  BEGIN
    SET @sql_cmd = N'ALTER DATABASE '+@db_name+N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE';
    EXEC (@sql_cmd);
    EXEC msdb.dbo.sp_delete_database_backuphistory @db_name;
    SET @sql_cmd = N'DROP DATABASE '+@db_name;
    EXEC (@sql_cmd);
  END;
IF @filepath IS NULL
  BEGIN
    SET @sql_cmd = N'CREATE DATABASE '+@db_name;
    EXEC (@sql_cmd);
  END
ELSE
  BEGIN
    SET @sql_cmd = N'
    CREATE DATABASE ' + @db_name + '
      ON PRIMARY (
        NAME = N'''+@db_name+'_Data'',
        FILENAME = N''' + @filepath + @db_name + '_AS_Data.mdf''
        ) LOG ON (
            NAME = N''' + @db_name + '_Log'',
            FILENAME = N''' + @filepath + @db_name + '_Log.ldf''
            )';
    EXEC (@sql_cmd);
  END;
RETURN;
GO