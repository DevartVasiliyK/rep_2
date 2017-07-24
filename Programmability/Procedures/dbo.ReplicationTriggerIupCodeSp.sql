SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--  This routine generates a result set containing the code lines to replicate
-- insert/update on the input table name.  If there are remote site link server
-- and database names available, it will generate direct transactional DML
-- statements to remote servers. It outputs multiple object creates, separated
-- by a "GO" on a line by itself. The objects are an insert/update replication
-- trigger for the input table and a stored procedure for each site linked
-- transactionally.

/* $Header: /ApplicationDB/Stored Procedures/ReplicationTriggerIupCodeSp.sp 20    4/22/05 2:08p Clarsco $  */
/*
Copyright © MAPICS, Inc. 2003 - All Rights Reserved

Use, duplication, or disclosure by the Government is subject to restrictions
as set forth in subparagraph (c)(1)(ii) of the Rights in Technical Data and
Computer Software clause at DFARS 252.227-7013, and Rights in Data-General at
FAR 52.227.14, as applicable.

Name of Contractor: MAPICS, Inc., 1000 Windward Concourse Parkway Suite 100,
Alpharetta, GA 30005 USA

Unless customer maintains a license to source code, customer shall not:
(i) copy, modify or otherwise update the code contained within this file or
(ii) merge such code with other computer programs.

Provided customer maintains a license to source code, then customer may modify
or otherwise update the code contained within this file or merge such code with
other computer programs subject to the following: (i) customer shall maintain
the source code as the trade secret and confidential information of MAPICS,
Inc. ("MAPICS"), (ii) the source code may only be used for so long as customer
maintains a license to source code pursuant to a separately executed license
agreement, and only for the purpose of developing and supporting customer
specific modifications to the source code, and not for the purpose of
substituting or replacing software support provided by MAPICS; (iii) MAPICS
will have no responsibility to provide software support for any customer
specific modifications developed by or for the customer, including those
developed by MAPICS, unless otherwise agreed to by MAPICS on a time and
materials basis pursuant to a separately executed services agreement;
(iv) MAPICS exclusively retains ownership to all intellectual property rights
associated with the source code, and any derivative works thereof;
(v) upon any expiration or termination of the license agreement, or upon
customer's termination of software support, customer's license to the source
code will immediately terminate and customer shall return the source code to
MAPICS or prepare and send to MAPICS a written affidavit certifying destruction
of the source code within ten (10) days following the expiration or termination
of customer's license right to the source code;
(vi) customer may not copy the source code and may only disclose the source code
to its employees or the employees of a MAPICS affiliate or business partner with
which customer contracts for modifications services, but only for so long as
such employees remain employed by customer or a MAPICS affiliate or business
partner and/or only for so long as there is an agreement in effect between
MAPICS and such affiliate or business partner authorizing them to provide
modification services for the source code ("Authorized Partner" a current list
of Authorized Partners can be found at the following link
http://www.mapics.com/company/SalesOffices/);
(vii) customer shall and shall obligate all employees of customer or an
Authorized Partner that have access to the source code to maintain the source
code as the trade secret and confidential information of MAPICS and to protect
the source code from disclosure to any third parties, including employees of
customer or an Authorized Partner that are not under an obligation to maintain
the confidentiality of the source code; (viii) MAPICS may immediately terminate
a source code license in the event that MAPICS becomes aware of a breach of
these provisions or if, in the commercially reasonable discretion of MAPICS, a
breach is probable; (ix) any breach by customer of its confidentiality
obligations hereunder may cause irreparable damage for which MAPICS may have no
adequate remedy at law, and that MAPICS may exercise all available equitable
remedies, including seeking injunctive relief, without having to post a bond;
and, (x) if Customer becomes aware of a breach or if a breach is probable,
customer will promptly notify MAPICS, and will provide assistance and
cooperation as is necessary to remedy a breach that has already occurred or to
prevent a threatened breach.

MAPICS is a trademark of MAPICS, Inc.

All other product or brand names used in this code may be trademarks,
registered trademarks, or trade names of their respective owners.
*/

/* $Archive: /ApplicationDB/Stored Procedures/ReplicationTriggerIupCodeSp.sp $
 *
 * SL7.04 20 86928 Clarsco Fri Apr 22 14:08:40 2005
 * Unit of Measure defaults to Blank when ShipSite is changed
 * For Manual Replication, REALLY fake an Insert, by forcing @UpdateAll to 1.
 *
 * $NoKeywords: $
 */
CREATE  PROCEDURE [dbo].[ReplicationTriggerIupCodeSp] (
 @TableName  SYSNAME
)
AS
DECLARE
  @SourceSite  SiteType
, @SQL         LongListType
, @SpName      SYSNAME
, @TriggerName SYSNAME
, @SourcePath  LongListType
, @TrackRowsTableName SYSNAME

--  The RowPointer unique table is used to transfer data to stored procedures.  The
-- primary key is not used
SET @TrackRowsTableName = dbo.ReplKeysTableName(@TableName, 1)

SELECT
  @SourceSite = site
FROM parms

DECLARE
  @Columns TABLE (
  ColumnID       INT     IDENTITY
, ColumnName     SYSNAME
, iiColumnName   SYSNAME
, DataType       SYSNAME
, ConstraintType SYSNAME
)

DECLARE
  @TriggerCode TABLE (
    CodeLine NVARCHAR(4000) NOT NULL
  , LineNum  INT IDENTITY
  )
DECLARE
  @TriggerCode2 TABLE (
    CodeLine NVARCHAR(4000) NOT NULL
  , LineNum  INT IDENTITY
  )
DECLARE
  @ProcCode TABLE (
    CodeLine NVARCHAR(4000) NOT NULL
  , LineNum  INT IDENTITY
  )
DECLARE
  @ColumnList TABLE (
    CodeLine NVARCHAR(4000) NOT NULL
  , LineNum  INT IDENTITY
  )

DECLARE
  @iiColumnList TABLE (
    CodeLine NVARCHAR(4000) NOT NULL
  , LineNum  INT IDENTITY
  )

DECLARE
  @UpdateColumnList TABLE (
    CodeLine NVARCHAR(4000) NOT NULL
  , LineNum  INT IDENTITY
  )

DECLARE
  @ColumnName      SYSNAME
, @ColNameVar      SYSNAME
, @iiColumnName    SYSNAME
, @ColumnID        INT
, @Severity        INT
, @DataType        SYSNAME
, @PrimaryKeyWhere NVARCHAR(4000)
, @ConstraintType  SYSNAME

--  The bt. = rt. where clause for all the primary key columns is created.
-- The REPLACESPACE@ will be used to put proper indentation into this string
-- when it is used later in this procedure.
SET @PrimaryKeyWhere = dbo.ReplicationTriggerWhere(@TableName, 'bt', 'rt', 0, 0)

SET @Severity = 0
SET @TriggerName = @TableName + 'IupReplicate'

INSERT INTO @TriggerCode VALUES (
'CREATE TRIGGER ' + @TriggerName + ' ON ' + @TableName )
INSERT INTO @TriggerCode VALUES (
'AFTER INSERT, UPDATE')
INSERT INTO @TriggerCode VALUES (
'AS')
INSERT INTO @TriggerCode VALUES (
'IF @@ROWCOUNT = 0')
INSERT INTO @TriggerCode VALUES (
'    RETURN')

INSERT INTO @TriggerCode VALUES (
'IF dbo.SkipReplicatingTrigger() = 1')
IF @TableName LIKE '%[_]all'
BEGIN
   IF EXISTS (SELECT 1
     FROM sysobjects AS so
     WHERE so.type = 'U'
     AND so.name = SUBSTRING(@TableName, 1, LEN(@TableName) - 4))
      INSERT INTO @TriggerCode VALUES (
      '   IF dbo.SkipAllReplicate() = 1')
END

INSERT INTO @TriggerCode VALUES (
'       RETURN')

INSERT INTO @TriggerCode VALUES (
'')
INSERT INTO @TriggerCode VALUES (
'SET XACT_ABORT ON -- Required for OLEDB embeded transactions to remote servers')
INSERT INTO @TriggerCode VALUES (
'DECLARE')
INSERT INTO @TriggerCode VALUES (
'  @OperationType    ReplicationOperationType')
INSERT INTO @TriggerCode VALUES (
', @RowCount         INT')
INSERT INTO @TriggerCode VALUES (
', @OperationNumber  OperationCounterType')
INSERT INTO @TriggerCode VALUES (
', @Severity         INT')
INSERT INTO @TriggerCode VALUES (
', @FromSite         SiteType')
INSERT INTO @TriggerCode VALUES (
', @ToSite           SiteType')
INSERT INTO @TriggerCode VALUES (
', @SessionID        RowPointer')
INSERT INTO @TriggerCode VALUES (
', @SaveSessionID    RowPointer')
INSERT INTO @TriggerCode VALUES (
', @UserName         UsernameType')
INSERT INTO @TriggerCode VALUES (
', @Infobar          InfobarType')
INSERT INTO @TriggerCode VALUES (
', @SQL              LongListType')
INSERT INTO @TriggerCode VALUES (
', @UpdateAll        ListYesNoType')
INSERT INTO @TriggerCode VALUES (
', @Transactional    ListYesNoType')
INSERT INTO @TriggerCode VALUES (
', @Delayed          ListYesNoType')
INSERT INTO @TriggerCode VALUES (
', @TrackRowsIn      ListYesNoType')
INSERT INTO @TriggerCode VALUES (
'')
INSERT INTO @TriggerCode VALUES (
'SET @TrackRowsIn = 0')

INSERT INTO @TriggerCode VALUES (
'SELECT @FromSite = parms.site')
INSERT INTO @TriggerCode VALUES (
'from parms')
INSERT INTO @TriggerCode VALUES (
'SET @UpdateAll = dbo.ReplicationUpdateAll(@FromSite, NULL, N'''
    + @TableName + ''', 1)')


INSERT INTO @TriggerCode VALUES (
'')

INSERT INTO @TriggerCode VALUES (
'SET @SessionID = NEWID() -- dbo.SessionIDSp()')
INSERT INTO @TriggerCode VALUES (
'SET @UserName = dbo.UserNameSp()')

INSERT INTO @TriggerCode VALUES (
'')

INSERT INTO @TriggerCode VALUES (
'--  Manual replication will fake an insert operation')
INSERT INTO @TriggerCode VALUES (
'IF dbo.ManualReplicationRunning(NULL) = 1')
INSERT INTO @TriggerCode VALUES (
'BEGIN')
INSERT INTO @TriggerCode VALUES (
'   SET @OperationType = 1 -- Fakes an insert for manual replication.')
INSERT INTO @TriggerCode VALUES (
'   SET @UpdateAll = 1')
INSERT INTO @TriggerCode VALUES (
'END')
INSERT INTO @TriggerCode VALUES (
'ELSE')
INSERT INTO @TriggerCode VALUES (
'   SELECT')
INSERT INTO @TriggerCode VALUES (
'     @OperationType = CASE')
INSERT INTO @TriggerCode VALUES (
'       WHEN EXISTS ( SELECT 1 FROM deleted ) THEN 2')
INSERT INTO @TriggerCode VALUES (
'         ELSE 1')
INSERT INTO @TriggerCode VALUES (
'       END')

INSERT INTO @TriggerCode VALUES (
'')

INSERT INTO @Columns (ColumnName, iiColumnName, DataType, ConstraintType)
SELECT
  sc.name
, 'bt.' + sc.name
, c.DATA_TYPE
, CASE WHEN EXISTS (select 1
from information_schema.key_column_usage AS isk
inner join information_schema.table_constraints AS ist ON
  ist.constraint_type = 'PRIMARY KEY'
and ist.table_name = isk.table_name
AND ist.constraint_name = isk.constraint_name
where isk.table_name = @TableName
and isk.column_name = sc.name)
then 'PRIMARY KEY' else 'NOT PRIMARY' end
FROM syscolumns AS sc
INNER JOIN INFORMATION_SCHEMA.COLUMNS AS c ON
  c.TABLE_NAME = @TableName
AND c.COLUMN_NAME = sc.name
WHERE sc.id = OBJECT_ID(@TableName)
-- You can't insert or update computed columns.
AND COLUMNPROPERTY ( sc.id , sc.name , 'IsComputed') = 0
-- RowPointer now being handled as a regular column name/value pair.
--AND sc.name NOT IN ('RowPointer')
ORDER BY sc.colid

DECLARE
  ColumnCrs CURSOR LOCAL STATIC FOR
SELECT
  ColumnName
, iiColumnName
, ColumnID
, DataType
, ConstraintType
FROM @Columns
ORDER BY ColumnID

OPEN ColumnCrs
WHILE @Severity = 0
BEGIN
    FETCH ColumnCrs INTO
      @ColumnName
    , @iiColumnName
    , @ColumnID
    , @DataType
    , @ConstraintType

    IF @@FETCH_STATUS = -1
        BREAK

    SET @ColNameVar  = 'Name' + CAST(@ColumnID AS NVARCHAR(10))

    IF @ColumnId = 1
    BEGIN
        INSERT INTO @TriggerCode VALUES (
        'DECLARE')
        INSERT INTO @TriggerCode VALUES (
        '  @' + @ColNameVar + ' SYSNAME')
    END
    ELSE
    BEGIN
        INSERT INTO @TriggerCode VALUES (
        ', @' + @ColNameVar + ' SYSNAME')
    END

    --  Primary key columns are always stored for the record, whether they
    -- were updated or not.
    IF @ConstraintType = 'PRIMARY KEY'
    BEGIN
       INSERT INTO @TriggerCode2 VALUES (
'--  Primary keys are marked with :N for updates so they will be listed, but
-- not be updated.
IF @OperationType = 1
   SET @' + @ColNameVar +  ' = N''' + @ColumnName + '''
ELSE
   SET @' + @ColNameVar + ' = N''' + @ColumnName + ':N'''
)
    END
    ELSE -- not a primary key column
    BEGIN
       INSERT INTO @TriggerCode2 VALUES (
'IF UPDATE(' + @ColumnName + ') OR @UpdateAll = 1 SET @' + @ColNameVar +  ' = N'''
+ @ColumnName + '''')
    END

    IF @ColumnId = 1
    BEGIN
        INSERT INTO @ColumnList VALUES (
'  ' + @ColumnName)
    END
    ELSE
    BEGIN
        INSERT INTO @ColumnList VALUES (
', ' + @ColumnName)
    END

    IF @ColumnId = 1
    BEGIN
        INSERT INTO @iiColumnList VALUES (
'  ' + dbo.ReplicationColumn(@iiColumnName, @DataType))
    END
    ELSE
    BEGIN
        INSERT INTO @iiColumnList VALUES (
', ' + dbo.ReplicationColumn(@iiColumnName, @DataType))
    END

    --  Primary key columns are not to be updated, only inserted. RowPointer
    -- shouldn't be updated either, it's always indexed.
    IF @ConstraintType <> 'PRIMARY KEY' AND @ColumnName != 'RowPointer'
    BEGIN
       IF EXISTS (SELECT 1 FROM @UpdateColumnList)
       BEGIN
           INSERT INTO @UpdateColumnList VALUES (
',  ' + @ColumnName + ' = ' + dbo.ReplicationColumn(@iiColumnName, @DataType))
       END
       ELSE
       BEGIN
           INSERT INTO @UpdateColumnList VALUES (
'SET ' + @ColumnName + ' = ' + dbo.ReplicationColumn(@iiColumnName, @DataType))
       END
    END

END
CLOSE ColumnCrs

INSERT INTO @TriggerCode VALUES (
'')
INSERT INTO @TriggerCode (CodeLine)
SELECT CodeLine FROM @TriggerCode2
DELETE @TriggerCode2

DECLARE
SiteCrs CURSOR LOCAL STATIC FOR
  SELECT DISTINCT
  rr.target_site
, CASE WHEN sll.linked_server_name IS NOT NULL AND site.app_db_name IS NOT NULL
THEN '[' + sll.linked_server_name + '].[' + site.app_db_name + '].dbo.'
ELSE NULL END
, dbo.ReplicationFilters(@SourceSite, rr.target_site, @TableName)
, roc.to_object_name
, roc.skip_insert
, roc.skip_update
, ISNULL(roc.insert_from_view, @TableName)
  FROM rep_rule AS rr
  INNER JOIN rep_object_category AS roc ON
    roc.category = rr.category
  AND roc.object_name =  @TableName
  AND roc.object_type = 1 -- Table
  AND roc.to_object_name = roc.object_name
  AND (roc.skip_insert = 0 or roc.skip_update = 0)
INNER JOIN site ON
  site.site = rr.target_site
LEFT OUTER JOIN site_live_link AS sll ON
  sll.from_site = @SourceSite
AND sll.to_site = rr.target_site
  WHERE rr.source_site = @SourceSite
UNION
  SELECT DISTINCT
  rr.target_site
, NULL -- no transactional if to_object_name different from object_name
, dbo.ReplicationFilters(@SourceSite, rr.target_site, @TableName)
, roc.to_object_name
, roc.skip_insert
, roc.skip_update
, ISNULL(roc.insert_from_view, @TableName)
  FROM rep_rule AS rr
  INNER JOIN rep_object_category AS roc ON
    roc.category = rr.category
  AND roc.object_name =  @TableName
  AND roc.object_type = 1 -- Table
  AND roc.to_object_name != roc.object_name
  AND (roc.skip_insert = 0 or roc.skip_update = 0)
INNER JOIN site ON
  site.site = rr.target_site

DECLARE
  @Site         SiteType
, @SitePath     SYSNAME
, @Filter       LongListType
, @ToObjectName SYSNAME
, @InsertView   SYSNAME
, @SkipInsert   ListYesNoType
, @SkipUpdate   ListYesNoType

OPEN SiteCrs
WHILE @Severity = 0
BEGIN
    FETCH SiteCrs INTO
      @Site
    , @SitePath
    , @Filter
    , @ToObjectName
    , @SkipInsert
    , @SkipUpdate
    , @InsertView

    IF @@FETCH_STATUS = -1
        BREAK

    SET @SourcePath = ''
    SELECT
      @SourcePath = '[' + sll.linked_server_name + '].[' + site.app_db_name + '].dbo.'
    FROM site
    INNER JOIN site_live_link AS sll ON
      sll.from_site = @Site
    AND sll.to_site = @SourceSite
    WHERE site.site = @SourceSite

    INSERT INTO @TriggerCode VALUES (
    '')

        INSERT INTO @TriggerCode VALUES (
'SET @ToSite = N''' + dbo.DoubleQuote(@Site) + '''')

        --  If a view is being used, then do a check to see if any of the
        -- columns inthe view are even being updated.
        IF @TableName <> @InsertView
        BEGIN
           DECLARE
             @TempText LongListType
           , @Idx      INT
           SET @TempText = 'IF NOT (1=2'
           SET @Idx = 0
           SELECT
             @TempText = @TempText + ' OR UPDATE(' + isc.COLUMN_NAME + ')'
--  Carriage returns to make it easier on the eyes.
             + CASE WHEN @Idx % 4 = 3 THEN '
' ELSE '' END
           , @Idx = @Idx + 1
           FROM INFORMATION_SCHEMA.VIEW_COLUMN_USAGE isc
           WHERE isc.VIEW_NAME = @InsertView
           AND isc.TABLE_NAME = @TableName
           SET @TempText = @TempText + ')
   GOTO SKIP_' + @Site
           INSERT INTO @TriggerCode VALUES (@TempText);

END

        INSERT INTO @TriggerCode VALUES (
'EXEC @Severity = dbo.GetReplicationOnSp')
        INSERT INTO @TriggerCode VALUES (
'  @SourceSite = @FromSite')
        INSERT INTO @TriggerCode VALUES (
', @TargetSite = @ToSite')
        INSERT INTO @TriggerCode VALUES (
', @ObjectName = N''' + @TableName + '''')
        INSERT INTO @TriggerCode VALUES (
', @ObjectType = 1')
        INSERT INTO @TriggerCode VALUES (
', @Transactional = @Transactional OUTPUT')
        INSERT INTO @TriggerCode VALUES (
', @Delayed = @Delayed OUTPUT')
        INSERT INTO @TriggerCode VALUES (
', @Infobar = @Infobar OUTPUT')
        INSERT INTO @TriggerCode VALUES (
'')

INSERT INTO @TriggerCode VALUES (
'IF @TrackRowsIn = 0 AND @Transactional = 1')
INSERT INTO @TriggerCode VALUES (
'BEGIN')
--INSERT INTO @TriggerCode VALUES (
--'   INSERT INTO TrackRows (')
--INSERT INTO @TriggerCode VALUES (
--'   SessionID, RowPointer)')
--INSERT INTO @TriggerCode VALUES (
--'   SELECT @SessionID, RowPointer FROM inserted')

INSERT INTO @TriggerCode VALUES (
'   INSERT INTO ' + @TrackRowsTableName + '(')

SET @SQL = ''
SELECT
  @SQL = @SQL + ', ' + pkc.column_name
FROM dbo.RowPointerUniqueColumns(@TableName) AS pkc
ORDER by pkc.ordinal_position

INSERT INTO @TriggerCode VALUES (
'  SessionID' + @SQL  )
INSERT INTO @TriggerCode VALUES (
  ') SELECT @SessionID' + @SQL + '
')
INSERT INTO @TriggerCode VALUES (
'    FROM inserted')

INSERT INTO @TriggerCode VALUES (
'   SET @TrackRowsIn = 1')
INSERT INTO @TriggerCode VALUES (
'END')

    IF @SitePath IS NOT NULL
    BEGIN

        INSERT INTO @TriggerCode VALUES (
'')
        INSERT INTO @TriggerCode VALUES (
'IF @Transactional = 1')
        INSERT INTO @TriggerCode VALUES (
'BEGIN')
        INSERT INTO @TriggerCode VALUES (
'    SET @SaveSessionID = dbo.SessionIDSp()')
        INSERT INTO @TriggerCode VALUES (
'    EXEC @Severity = ' + @SitePath + 'InitRemoteServerSp')
        INSERT INTO @TriggerCode VALUES (
'      @SessionID')
        INSERT INTO @TriggerCode VALUES (
'    , @Username')
        INSERT INTO @TriggerCode VALUES (
'    , 1 -- @SkipReplicating')
        INSERT INTO @TriggerCode VALUES (
'    , 1 -- @SkipBase')
        INSERT INTO @TriggerCode VALUES (
'    , @Infobar OUTPUT')
        INSERT INTO @TriggerCode VALUES (
'')

        SET @SpName = dbo.ReplTriggerProcName(@TableName, @Site, 'Iup')
        INSERT INTO @TriggerCode VALUES (
'    EXEC @Severity = ' + @SpName + ' @OperationType, @SessionID')

-- Create the table containing RowPointer unique key columns for this table.  Primary
-- keys are not used because TBD primary key values would fail on the join.
SET @SQL = dbo.ReplTriggerTemp(@TableName, 1)

INSERT INTO @ProcCode VALUES (
 @SQL)
INSERT INTO @ProcCode VALUES (
'  ') -- Keeps odbc from getting buffer errors on empty strings.
INSERT INTO @ProcCode VALUES (
'GO')
        INSERT INTO @ProcCode VALUES (
'CREATE PROCEDURE dbo.' + @SpName + ' (
  @OperationType RepObjectType
, @SessionID     RowPointerType
) AS
')
        INSERT INTO @ProcCode VALUES (
'DECLARE
  @FromSite SiteType
, @ToSite   SiteType
SET @FromSite = N''' + dbo.DoubleQuote(@SourceSite) + '''
SET @ToSite = N''' + dbo.DoubleQuote(@Site) + '''')

        --  If the update is skipped, then the update is only done for an
        -- insert operation.  Insert always does update, insert where not
        -- exists.
        IF @SkipUpdate = 1
        INSERT INTO @ProcCode VALUES (
'IF @OperationType = 1')
        INSERT INTO @ProcCode VALUES (
'BEGIN')
        INSERT INTO @ProcCode VALUES (
'   EXECUTE ' + @SitePath + 'sp_executesql
N''')

        INSERT INTO @ProcCode VALUES (
'    SELECT bt.* INTO #tt')
        INSERT INTO @ProcCode VALUES (
'    FROM ' + @SourcePath + @TrackRowsTableName + ' AS rws ')
        INSERT INTO @ProcCode VALUES (
'     INNER JOIN ' + @SourcePath + @TableName + ' AS bt ON')
        INSERT INTO @ProcCode VALUES (
REPLACE(dbo.ReplicationTriggerWhere(@TableName, 'bt', 'rws', 1, 1),
   'REPLACESPACE@', '    '))
        INSERT INTO @ProcCode VALUES (
'    WHERE rws.SessionID = @SessionID')
        IF @Filter <> ''
        BEGIN
            INSERT INTO @ProcCode VALUES (
'    AND ' + dbo.DoubleQuote(@Filter))
        END


        INSERT INTO @ProcCode VALUES (
'    UPDATE rt')
        INSERT INTO @ProcCode (CodeLine)
        SELECT '    ' + CodeLine
        FROM @UpdateColumnList
        ORDER BY LineNum

        INSERT INTO @ProcCode VALUES (
'    FROM ' + @TableName + ' AS rt')
--        INSERT INTO @ProcCode VALUES (
--'    INNER JOIN ' + @SourcePath + @TrackRowsTableName + ' AS rws ON')

--        INSERT INTO @ProcCode VALUES (
--'    rws.SessionID = @SessionID')

--        INSERT INTO @ProcCode VALUES (
--'    INNER JOIN ' + @SourcePath + @TableName + ' AS bt ON')

        INSERT INTO @ProcCode VALUES ('    INNER JOIN #tt AS bt ON')
        INSERT INTO @ProcCode VALUES (
          REPLACE(@PrimaryKeyWhere, 'REPLACESPACE@', '    '))
--        INSERT INTO @ProcCode VALUES ('    AND ' +
--REPLACE(dbo.ReplicationTriggerWhere(@TableName, 'bt', 'rws', 1, 1),
--   'REPLACESPACE@', '    '))
--        IF @Filter <> ''
--        BEGIN
--            INSERT INTO @ProcCode VALUES (
--'    AND ' + dbo.DoubleQuote(@Filter))
--        END

        INSERT INTO @ProcCode VALUES (
''', N''@FromSite NVARCHAR(100), @ToSite NVARCHAR(100), @SessionID uniqueidentifier''')
           INSERT INTO @ProcCode VALUES (
', @FromSite = @FromSite, @ToSite = @ToSite, @SessionID = @SessionID')
        INSERT INTO @ProcCode VALUES (
'END')

        INSERT INTO @ProcCode VALUES (
'')

        INSERT INTO @ProcCode VALUES (
'')
        IF @SkipInsert = 0
        BEGIN
           INSERT INTO @ProcCode VALUES (
'    IF @OperationType = 1')
           INSERT INTO @ProcCode VALUES (
'    BEGIN')
           INSERT INTO @ProcCode VALUES (
'        EXECUTE ' + @SitePath + 'sp_executesql
N''')

           INSERT INTO @ProcCode VALUES (
'        INSERT INTO ' + @TableName + '(')
           INSERT INTO @ProcCode (CodeLine)
           SELECT '        ' + CodeLine
           FROM @ColumnList
           Order By LineNum
-- RowPointer now handled generically with all other name/value pairs.
--           INSERT INTO @ProcCode VALUES (
--'        , RowPointer')
           INSERT INTO @ProcCode VALUES (
'        )')

           INSERT INTO @ProcCode VALUES (
'        SELECT')
           INSERT INTO @ProcCode (CodeLine)
           SELECT '        ' + CodeLine
           FROM @iiColumnList
           Order By LineNum
-- RowPointer now handled generically with all other name/value pairs.
--           INSERT INTO @ProcCode VALUES (
--'        , bt.RowPointer')
           INSERT INTO @ProcCode VALUES (
'        FROM ' + @SourcePath + @TrackRowsTableName + ' AS rws')
           INSERT INTO @ProcCode VALUES (
'        INNER JOIN ' + @SourcePath + @TableName + ' AS bt ON')

           INSERT INTO @ProcCode VALUES (
REPLACE(dbo.ReplicationTriggerWhere(@TableName, 'bt', 'rws', 1, 1),
   'REPLACESPACE@', '        '))

           INSERT INTO @ProcCode VALUES (
'        WHERE rws.SessionID = @SessionID')
           INSERT INTO @ProcCode VALUES (
'        AND NOT EXISTS (')
           INSERT INTO @ProcCode VALUES (
'        SELECT 1')
           INSERT INTO @ProcCode VALUES (
'        FROM ' + @TableName + ' AS rt')

           INSERT INTO @ProcCode VALUES (
'        WHERE ')

           INSERT INTO @ProcCode VALUES (
           REPLACE(@PrimaryKeyWhere, 'REPLACESPACE@', '        '))

           INSERT INTO @ProcCode VALUES (
'        )')

           IF @Filter <> ''
           BEGIN
              INSERT INTO @ProcCode VALUES (
'        AND ' + dbo.DoubleQuote(@Filter))
           END

           INSERT INTO @ProcCode VALUES (
''', N''@FromSite NVARCHAR(100), @ToSite NVARCHAR(100), @SessionID uniqueidentifier''')
           INSERT INTO @ProcCode VALUES (
', @FromSite = @FromSite, @ToSite = @ToSite, @SessionID = @SessionID')

           INSERT INTO @ProcCode VALUES (
'    END')
        END -- If @SkipInsert = 0

        INSERT INTO @ProcCode VALUES (
'    RETURN 0')
        INSERT INTO @ProcCode VALUES (
'GO')
        INSERT INTO @ProcCode VALUES (
' ') -- Makes ODBC happy, it does not like empty strings.

        INSERT INTO @TriggerCode VALUES (
'')

        INSERT INTO @TriggerCode VALUES (
'    EXEC @Severity = ' + @SitePath + 'ResetRemoteServerSp')
        INSERT INTO @TriggerCode VALUES (
'      @SessionID')
        INSERT INTO @TriggerCode VALUES (
'    , @Infobar')
        INSERT INTO @TriggerCode VALUES (
'    EXEC @Severity = dbo.ResetSessionIDSp @SaveSessionID')
        INSERT INTO @TriggerCode VALUES (
'END')

        INSERT INTO @TriggerCode VALUES (
'')
    END -- @SitePath IS NOT NULL

    --  If skip insert or update set, then @Delayed = 1 check gets the
    -- additional logic.  If both are set, this loop would not have fired.
    INSERT INTO @TriggerCode VALUES (
'IF @Delayed = 1' +
    CASE WHEN @SkipInsert = 1 THEN ' AND @OperationType = 2'
         WHEN @SkipUpdate = 1 THEN ' AND @OperationType = 1'
         ELSE ''
    END
    )

    INSERT INTO @TriggerCode VALUES (
'BEGIN')
    INSERT INTO @TriggerCode VALUES (
'    EXEC @Severity = dbo.GetReplicationCounterSp')
    INSERT INTO @TriggerCode VALUES (
'      @Site             = @ToSIte')
    INSERT INTO @TriggerCode VALUES (
'    , @OperationCounter = @OperationNumber OUTPUT')
    INSERT INTO @TriggerCode VALUES (
'    , @Infobar          = @Infobar         OUTPUT')

    INSERT INTO @TriggerCode VALUES (
'')

    INSERT INTO @TriggerCode VALUES (
'    INSERT INTO ReplicatedRows3 (')
    INSERT INTO @TriggerCode VALUES (
'      ObjectName')
    INSERT INTO @TriggerCode VALUES (
'    , ObjectType')
    INSERT INTO @TriggerCode VALUES (
'    , UpdateAllColumns')
    INSERT INTO @TriggerCode VALUES (
'    , RefRowPointer')
    INSERT INTO @TriggerCode VALUES (
'    , OperationType')
    INSERT INTO @TriggerCode VALUES (
'    , ProcessingPtr')
    INSERT INTO @TriggerCode VALUES (
'    , OperationNumber')
    INSERT INTO @TriggerCode VALUES (
'    , ToSite')
    INSERT INTO @TriggerCode VALUES (
'    )')
    INSERT INTO @TriggerCode VALUES (
'     SELECT')
    INSERT INTO @TriggerCode VALUES (
'    N''' + @ToObjectName + '''')
    INSERT INTO @TriggerCode VALUES (
'    , 1 -- Table ObjectType')
    INSERT INTO @TriggerCode VALUES (
'    , @UpdateAll')
    INSERT INTO @TriggerCode VALUES (
'    , bt.RowPointer')
    INSERT INTO @TriggerCode VALUES (
'    , @OperationType')
    INSERT INTO @TriggerCode VALUES (
'    , ''00000000-0000-0000-0000-000000000000''')
    INSERT INTO @TriggerCode VALUES (
'    , @OperationNumber')
    INSERT INTO @TriggerCode VALUES (
'    , @ToSite')
    INSERT INTO @TriggerCode VALUES (
'    FROM inserted AS bt')
    INSERT INTO @TriggerCode VALUES (
'    WHERE 1=1')


    INSERT INTO @TriggerCode VALUES (
'')


    INSERT INTO @TriggerCode (CodeLine)
    SELECT
       CodeLine
    FROM dbo.ReplicationShadowInsert(@TableName, @InsertView
       , @Filter, @SkipInsert, @SkipUpdate)
    ORDER BY Counter

    INSERT INTO @TriggerCode VALUES (
'END')

    --  End of skipping all logic if no columns changed from the view.
    IF @TableName <> @InsertView
    BEGIN
       INSERT INTO @TriggerCode (CodeLine) VALUES (
'SKIP_' + @Site + ':')
    END
END
CLOSE SiteCrs
DEALLOCATE SiteCrs
    INSERT INTO @TriggerCode VALUES (
'IF @TrackRowsIn = 1')
    INSERT INTO @TriggerCode VALUES (
'   DELETE ' + @TrackRowsTableName)
    INSERT INTO @TriggerCode VALUES (
'   WHERE SessionID = @SessionID')
    INSERT INTO @TriggerCode VALUES (
'GO')
    INSERT INTO @TriggerCode VALUES (
'EXEC sp_settriggerorder @triggername = ''' + @TriggerName + ''', @order = ''last'', @stmttype = ''UPDATE''')
    INSERT INTO @TriggerCode VALUES (
'GO')
    INSERT INTO @TriggerCode VALUES (
'EXEC sp_settriggerorder @triggername = ''' + @TriggerName + ''', @order = ''last'', @stmttype = ''INSERT''')
    INSERT INTO @TriggerCode VALUES (
'GO')
    INSERT INTO @TriggerCode VALUES (
' ')

--  The stored procedure code is output first so that the trigger compilation
-- won't contain a warning about the missing table site copying sps.

INSERT INTO @ProcCode (CodeLine)
  SELECT
    CodeLine
  FROM @TriggerCode
  ORDER BY LineNum

SELECT
  CodeLine
FROM @ProcCode
ORDER BY LineNum
RETURN 0
GO