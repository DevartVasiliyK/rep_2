SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_create_db]
(
    @db_name SYSNAME,
    @create_on_ram BIT = 0
)
AS BEGIN

    SET NOCOUNT ON;
    DECLARE @ram_path SYSNAME;
    SET @create_on_ram = 0;

    SELECT
        @db_name = LTRIM(RTRIM(@db_name)),
        @create_on_ram = ISNULL(@create_on_ram, 1),
        @ram_path = 'G:\' + CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(4000)) + '\';

    IF ISNULL(@db_name, '') = '' BEGIN

        RAISERROR('Database name is empty!', 16, 1);

    END
    ELSE BEGIN
    
        IF DB_ID(@db_name) IS NOT NULL BEGIN

            IF DATABASEPROPERTYEX(@db_name, 'Status') = 'OFFLINE' BEGIN

                EXEC('ALTER DATABASE [' + @db_name + '] SET ONLINE WITH ROLLBACK IMMEDIATE;');

            END

            EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = @db_name;
            EXEC('ALTER DATABASE [' + @db_name + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;');
            EXEC('DROP DATABASE [' + @db_name + '];');

        END;

        IF @create_on_ram = 1 BEGIN

            DECLARE @model_size SYSNAME
            SELECT TOP(1) @model_size = FLOOR(size * 8. / 1024) + 1
            FROM sys.master_files
            WHERE database_id = DB_ID('model')
                AND [file_id] = 1

            DECLARE @SQL NVARCHAR(4000);
            SET @SQL = N'
CREATE DATABASE [' + @db_name + ']
    ON PRIMARY (NAME = N''' + @db_name + ''', FILENAME = N''' + @ram_path + @db_name + '.mdf'', SIZE = ' + @model_size + 'MB, FILEGROWTH = 5MB)
    LOG ON (NAME = N''' + @db_name + '_log'', FILENAME = N''' + @ram_path + @db_name + '_log.ldf'', SIZE = 4MB, FILEGROWTH = 5MB);';

            EXEC(@SQL);

        END
        ELSE BEGIN

            EXEC('CREATE DATABASE [' + @db_name + '];');

        END

        IF CAST(SERVERPROPERTY('Edition') AS VARCHAR(4000)) LIKE '%Express%' BEGIN

            EXEC('ALTER DATABASE [' + @db_name + '] SET AUTO_CLOSE OFF;');

        END

    END

END;
GO