SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--  This routine generates a result set containing the code lines to replicate
-- delete on the input table name.  If there are remote site link server and
-- database names available, it will generate direct transactional delete
-- statements to remote servers.  It outputs multiple object creates
-- , separated by a "GO" on a line by itself. The objects are a delete
-- replication trigger and a stored procedure for each site linked
-- transactionally, and a table containing the primary key values for the
-- input table.
/* $Header: /ApplicationDB/Stored Procedures/ReplicationTriggerDelCodeSp.sp 19    8/03/04 1:38p Grosphi $  */
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
CREATE PROCEDURE [dbo].[ReplicationTriggerDelCodeSp] (
  @TableName  SYSNAME
)
AS
DECLARE
  @TriggerCode TABLE (
    CodeLine NVARCHAR(4000) NOT NULL
  , LineNum  INT IDENTITY
  )
DECLARE
 @ProcCode TABLE (
    CodeLine NVARCHAR(4000) NOT NULL
  , LineNum  INT IDENTITY
  )
DECLARE
  @SpName             SYSNAME
, @TrackRowsTableName SYSNAME

DECLARE
  @SourceSite SiteType
SELECT
  @SourceSite = site
FROM parms

SET @TrackRowsTableName = dbo.ReplKeysTableName(@TableName, 0)

DECLARE
  @ColumnName      SYSNAME
, @ColumnID        INT
, @Severity        INT
, @PrimaryKeyWhere NVARCHAR(4000)

--  The ii. = rmt. where clause for all the primary key columns is created.
-- The REPLACESPACE@ will be used to put proper indentation into this string
-- when it is used later in this procedure.
SET @PrimaryKeyWhere = dbo.ReplicationTriggerWhere(@TableName, 'tr', 'rmt', 0, 0)

SET @Severity = 0

DECLARE
  @SQL LongListType

-- Create the table containing primary key columns for this table.
SET @SQL = dbo.ReplTriggerTemp(@TableName, 0)

INSERT INTO @ProcCode VALUES (
 @SQL)
INSERT INTO @ProcCode VALUES (
'  ') -- Keeps odbc from getting buffer errors on empty strings.
INSERT INTO @ProcCode VALUES (
'GO')


INSERT INTO @TriggerCode VALUES (
'CREATE TRIGGER ' + @TableName + 'DelReplicate ON ' + @TableName )
INSERT INTO @TriggerCode VALUES (
'AFTER DELETE')
INSERT INTO @TriggerCode VALUES (
'AS')
INSERT INTO @TriggerCode VALUES (
'IF @@ROWCOUNT = 0')
INSERT INTO @TriggerCode VALUES (
'    RETURN')

INSERT INTO @TriggerCode VALUES (
'IF dbo.SkipReplicatingTrigger() = 1')

IF @TableName LIKE '%[_]all' AND EXISTS (SELECT 1
     FROM sysobjects AS so
     WHERE so.type = 'U'
     AND so.name = SUBSTRING(@TableName, 1, LEN(@TableName) - 4))
BEGIN
   INSERT INTO @TriggerCode VALUES (
   '   IF dbo.SkipAllReplicate() = 1')
   INSERT INTO @TriggerCode VALUES (
   '      RETURN')
END
ELSE
      INSERT INTO @TriggerCode VALUES (
      '   RETURN')


INSERT INTO @TriggerCode VALUES (
'SET XACT_ABORT ON'
)
INSERT INTO @TriggerCode VALUES (
'')
INSERT INTO @TriggerCode VALUES (
'DECLARE')
INSERT INTO @TriggerCode VALUES (
'  @OperationNumber  OperationCounterType')
INSERT INTO @TriggerCode VALUES (
', @Severity         INT')
INSERT INTO @TriggerCode VALUES (
', @SourceSite       SiteType')
INSERT INTO @TriggerCode VALUES (
', @SessionID        RowPointerType')
INSERT INTO @TriggerCode VALUES (
', @SaveSessionID    RowPointerType')
INSERT INTO @TriggerCode VALUES (
', @UserName         UsernameType')
INSERT INTO @TriggerCode VALUES (
', @Infobar          InfobarType')
INSERT INTO @TriggerCode VALUES (
', @SQL              LongListType')
INSERT INTO @TriggerCode VALUES (
', @Transactional    ListYesNoType')
INSERT INTO @TriggerCode VALUES (
', @Delayed          ListYesNoType')
INSERT INTO @TriggerCode VALUES (
'')
INSERT INTO @TriggerCode VALUES (
'SELECT @SourceSite = parms.site')
INSERT INTO @TriggerCode VALUES (
'from parms')

INSERT INTO @TriggerCode VALUES (
'')

INSERT INTO @TriggerCode VALUES (
'SET @SessionID = NEWID() -- dbo.SessionIDSp()')
INSERT INTO @TriggerCode VALUES (
'SET @UserName = dbo.UserNameSp()')

INSERT INTO @TriggerCode VALUES (
'')

INSERT INTO @TriggerCode VALUES (
'')


DECLARE
SiteCrs CURSOR LOCAL STATIC FOR
  SELECT DISTINCT
  rr.target_site
, CASE WHEN sll.linked_server_name IS NOT NULL AND site.app_db_name IS NOT NULL
THEN '[' + sll.linked_server_name + '].[' + site.app_db_name + '].dbo.'
ELSE NULL END
, dbo.ReplicationFilters(@SourceSite, rr.target_site, @TableName)
, roc.to_object_name
  FROM rep_rule AS rr
  INNER JOIN rep_object_category AS roc ON
    roc.category = rr.category
  AND roc.object_name =  @TableName
  AND roc.object_type = 1 -- table
  AND roc.object_name = roc.to_object_name
  AND roc.skip_delete = 0
INNER JOIN site ON
  site.site = rr.target_site
LEFT OUTER JOIN site_live_link AS sll ON
  sll.from_site = @SourceSite
AND sll.to_site = rr.target_site
  WHERE rr.source_site = @SourceSite
UNION
  SELECT DISTINCT
  rr.target_site
, NULL -- transactional replication for different to_object_name not supported.
, dbo.ReplicationFilters(@SourceSite, rr.target_site, @TableName)
, roc.to_object_name
  FROM rep_rule AS rr
  INNER JOIN rep_object_category AS roc ON
    roc.category = rr.category
  AND roc.object_name =  @TableName
  AND roc.object_type = 1 -- table
  AND roc.object_name != roc.to_object_name
  AND roc.skip_delete = 0
INNER JOIN site ON
  site.site = rr.target_site
LEFT OUTER JOIN site_live_link AS sll ON
  sll.from_site = @SourceSite
AND sll.to_site = rr.target_site
  WHERE rr.source_site = @SourceSite

DECLARE
  @Site         SiteType
, @SitePath     SYSNAME
, @Filter       LongListType
, @SourcePath   LongListType
, @ToObjectName SYSNAME

OPEN SiteCrs
WHILE @Severity = 0
BEGIN
    FETCH SiteCrs INTO
      @Site
    , @SitePath
    , @Filter
    , @ToObjectName

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
'EXEC @Severity = dbo.GetReplicationOnSp')
    INSERT INTO @TriggerCode VALUES (
'  @SourceSite = @SourceSite')
    INSERT INTO @TriggerCode VALUES (
', @TargetSite = N''' + dbo.DoubleQuote(@Site) + '''')
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

    IF @SitePath IS NOT NULL
    BEGIN
        INSERT INTO @TriggerCode VALUES (
'IF @Transactional = 1')
        INSERT INTO @TriggerCode VALUES (
'BEGIN')
INSERT INTO @TriggerCode VALUES (
'   INSERT INTO ' + @TrackRowsTableName + '(')

SET @SQL = ''
SELECT
  @SQL = @SQL + ', ' + pkc.column_name
FROM dbo.PrimaryKeyColumns(@TableName) AS pkc
ORDER by pkc.ordinal_position

INSERT INTO @TriggerCode VALUES (
'  SessionID' + @SQL  )
INSERT INTO @TriggerCode VALUES (
  ') SELECT @SessionID' + @SQL + '
')
INSERT INTO @TriggerCode VALUES (
'    FROM deleted AS bt')
IF @FILTER <> ''
BEGIN
   INSERT INTO @TriggerCode VALUES (
'    WHERE ' + @Filter)
END

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

        SET @SpName = dbo.ReplTriggerProcName (@TableName, @Site, 'Del')

        INSERT INTO @ProcCode VALUES (
'CREATE PROCEDURE dbo.' + @SpName + '(
  @SessionID RowPointerType
)
AS
')

        INSERT INTO @ProcCode VALUES (
'    EXECUTE ' + @SitePath + 'sp_executesql
N''')
        INSERT INTO @ProcCode VALUES (
'DECLARE
  @FromSite SiteType
, @ToSite   SiteType
SET @FromSite = N''''' + dbo.DoubleQuote(@SourceSite) + '''''
SET @ToSite = N''''' + dbo.DoubleQuote(@Site) + '''''')

        INSERT INTO @ProcCode VALUES (
'    DELETE rmt')

        INSERT INTO @ProcCode VALUES (
'    FROM ' + @TableName + ' AS rmt')
        INSERT INTO @ProcCode VALUES (
'    INNER JOIN ' + @SourcePath + @TrackRowsTableName + ' AS tr ON')

        INSERT INTO @ProcCode VALUES (
      REPLACE(@PrimaryKeyWhere, 'REPLACESPACE@', '      '))
        INSERT INTO @ProcCode VALUES (
'      AND tr.SessionID = @SessionID')

        INSERT INTO @ProcCode VALUES (
''', N''@SessionID uniqueidentifier''')
        INSERT INTO @ProcCode VALUES (
', @SessionID = @SessionID')

        INSERT INTO @ProcCode VALUES (
'RETURN 0')
        INSERT INTO @ProcCode VALUES (
'GO')
        INSERT INTO @ProcCode VALUES (
'  ') -- Keeps odbc from getting buffer errors on empty strings.

        INSERT INTO @TriggerCode VALUES (
'    EXEC @Severity = ' + @SpName + ' @SessionID')
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
'   DELETE ' + @TrackRowsTableName)
        INSERT INTO @TriggerCode VALUES (
'   WHERE SessionID = @SessionID')
        INSERT INTO @TriggerCode VALUES (
'END')

        INSERT INTO @TriggerCode VALUES (
'')
    END -- @SitePath IS NOT NULL

    INSERT INTO @TriggerCode VALUES (
'IF @Delayed = 1')
    INSERT INTO @TriggerCode VALUES (
'BEGIN')

    INSERT INTO @TriggerCode VALUES (
'    EXEC @Severity = dbo.GetReplicationCounterSp')
    INSERT INTO @TriggerCode VALUES (
'    @Site             = N''' + dbo.DoubleQuote(@Site) + '''')
    INSERT INTO @TriggerCode VALUES (
'  , @OperationCounter = @OperationNumber OUTPUT')
    INSERT INTO @TriggerCode VALUES (
'  , @Infobar          = @Infobar         OUTPUT')

INSERT INTO @TriggerCode VALUES (
'')

    INSERT INTO @TriggerCode VALUES (
'    INSERT INTO ReplicatedRows3 (')
    INSERT INTO @TriggerCode VALUES (
'      ObjectName')
    INSERT INTO @TriggerCode VALUES (
'    , ObjectType')
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
'    , 1 -- table')
    INSERT INTO @TriggerCode VALUES (
'    , bt.RowPointer')
    INSERT INTO @TriggerCode VALUES (
'    , 3 -- Delete')
    INSERT INTO @TriggerCode VALUES (
'    , ''00000000-0000-0000-0000-000000000000''')
    INSERT INTO @TriggerCode VALUES (
'    , @OperationNumber')
    INSERT INTO @TriggerCode VALUES (
'    , N''' + dbo.DoubleQuote(@Site) + '''')
    INSERT INTO @TriggerCode VALUES (
'    FROM deleted AS bt')

    IF @Filter <> ''
    BEGIN
        INSERT INTO @TriggerCode VALUES (
'    WHERE ' + @Filter)
    END


    INSERT INTO @TriggerCode VALUES (
'')
    INSERT INTO @TriggerCode VALUES (
'    INSERT INTO ShadowValues (')

    INSERT INTO @TriggerCode VALUES (
'      OperationNumber')
    INSERT INTO @TriggerCode VALUES (
'    , OldNew')
    INSERT INTO @TriggerCode VALUES (
'    , LineNum')
    INSERT INTO @TriggerCode VALUES (
'    , RowPointer')

    INSERT INTO @TriggerCode (CodeLine)
    SELECT '    , ' + 'Name' + CAST(pkc.ordinal_position AS NVARCHAR(10)) + '
    , Value' + CAST(pkc.ordinal_position AS NVARCHAR(10))
   FROM dbo.PrimaryKeyColumns(@TableName) AS pkc
   WHERE pkc.column_name <> 'RowPointer'
   ORDER BY pkc.ordinal_position

    INSERT INTO @TriggerCode VALUES (
'    ) SELECT ')
    INSERT INTO @TriggerCode VALUES (
'      @OperationNumber')
    INSERT INTO @TriggerCode VALUES (
'    ,  ''Old'' -- OldNew')
    INSERT INTO @TriggerCode VALUES (
'    , 1 -- LineNum')
    INSERT INTO @TriggerCode VALUES (
'    , bt.RowPointer')

--  The :N indicates that the primary key columns should not be marked for
-- updated, since this is a delete operation.
    INSERT INTO @TriggerCode (CodeLine)
    SELECT '    , N''' + pkc.column_name + ':N''
    , ' +
      CASE WHEN isc.DATA_TYPE NOT IN ('nvarchar', 'NVARCHAR', 'ntext', 'text')
      THEN 'CAST(' ELSE '' END + ' bt.' + pkc.column_name +
      CASE WHEN isc.DATA_TYPE NOT IN ('nvarchar', 'NVARCHAR', 'ntext', 'text')
      THEN ' AS NVARCHAR(4000))' ELSE '' END
   FROM dbo.PrimaryKeyColumns(@TableName) AS pkc
   INNER JOIN INFORMATION_SCHEMA.COLUMNS AS isc ON
       isc.TABLE_NAME = @TableName
   AND isc.COLUMN_NAME = pkc.column_name
   WHERE pkc.column_name <> 'RowPointer'
   ORDER BY pkc.ordinal_position

    INSERT INTO @TriggerCode VALUES (
'    FROM deleted AS bt')
    IF @Filter <> ''
    BEGIN
        INSERT INTO @TriggerCode VALUES (
'    WHERE ' + @Filter)
    END
    INSERT INTO @TriggerCode VALUES (
'END')
END
CLOSE SiteCrs
DEALLOCATE SiteCrs

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