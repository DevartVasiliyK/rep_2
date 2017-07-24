SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RUSXDE_AddDFSp](
  @TABLE_NAME     nvarchar(128)
, @Infobar        nvarchar (4000) OUTPUT
, @TempTableName  nvarchar(128) = NULL
)
AS

IF @TempTableName is NULL
  SET @TempTableName = '#RUSDF_' + @TABLE_NAME

DECLARE
  @COLUMN_NAME    nvarchar(128)
, @COLUMN_DEFAULT nvarchar(4000)
, @DATA_TYPE      nvarchar(128)
, @tSQL           nvarchar(4000)
, @IS_NULLABLE    varchar(3)
, @FirstColumn    nvarchar(128)

DECLARE DF_cur CURSOR LOCAL FOR
SELECT
  COLUMN_NAME
, COLUMN_DEFAULT
, DATA_TYPE
, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TABLE_NAME
ORDER BY ORDINAL_POSITION

OPEN DF_cur
WHILE 1 = 1
BEGIN
  FETCH DF_cur INTO
    @COLUMN_NAME
  , @COLUMN_DEFAULT
  , @DATA_TYPE
  , @IS_NULLABLE
  IF @@fetch_status <> 0 BREAK
  IF @FirstColumn IS NULL SET @FirstColumn = @COLUMN_NAME
  IF @COLUMN_DEFAULT is NULL AND @IS_NULLABLE = 'YES' CONTINUE
  IF @COLUMN_DEFAULT is NULL AND @IS_NULLABLE = 'NO'
    SET @COLUMN_DEFAULT = CASE WHEN @DATA_TYPE in ('bigint', 'bit', 'decimal', 'float', 'int', 'numeric', 'smallint', 'tinyint')
                               THEN '(0)'
                               WHEN @DATA_TYPE in ('char', 'varchar', 'text', 'nchar', 'nvarchar', 'ntext', 'sql_variant')
                               THEN '('''')'
                               WHEN @DATA_TYPE = 'datetime' THEN '(getdate())'
                               WHEN @DATA_TYPE = 'uniqueidentifier' THEN '(newid())'
			       ELSE '('')'
                          END
  SET @tSQL = 'ALTER TABLE ' + @TempTableName + ' WITH NOCHECK ADD CONSTRAINT [DF_' + @TempTableName + '_' + @COLUMN_NAME + '] DEFAULT ' + @COLUMN_DEFAULT + ' FOR [' + @COLUMN_NAME + ']'
  EXEC (@tSQL)

END
CLOSE DF_cur
DEALLOCATE DF_cur

IF NOT @FirstColumn is NULL BEGIN
  SET @tSQL = 'INSERT INTO ' + @TempTableName + ' (' + @FirstColumn + ') values( DEFAULT)'
  EXEC (@tSQL)
END
GO