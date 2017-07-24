SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- This routine generates a result set containing the code lines to create
-- Audit Log records for an Insert/Update/Delete of a given table name and
-- field name. The Audit Logging Triggers are given names in the form
--   <tablename>InsAudit
--   <tablename>UpdAudit
--   <tablename>DelAudit
-- If the trigger already exists, it is removed and readded with the new requirements

/* $Header: /ApplicationDB/Stored Procedures/AuditLoggingGenCodeSp.sp 6     8/29/05 3:37p Grosphi $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/AuditLoggingGenCodeSp.sp $
 *
 * SL7.04 6 88879 Grosphi Mon Aug 29 15:37:45 2005
 * Audit Log Type for database using table Transfer and field Trn_num does not work.
 * create AuditLog records for primary key columns
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[AuditLoggingGenCodeSp] (
  @PTableName   sysname
)
AS

-- Debugging:
--Declare @PTableName sysname  SET @PTableName = N'matltrack' set nocount on

DECLARE
  @ColumnId       INT
, @ColumnName     sysname
, @CASTit bit
, @Severity       INT
, @ALTMessageType GenericTypeType
, @SafeColumnName LongList

SET @Severity = 0

DECLARE @ProcCode TABLE (
   Prefix CHAR(3)
   , CodeLine NVARCHAR(4000) NOT NULL
   , LineNum  INT IDENTITY
   )

-- IF the table is invalid, go no further
IF OBJECT_ID(@PTableName) IS NULL
BEGIN
   -- Create a Do Nothing command so that IDO procedure doesn't fail
   INSERT INTO @ProcCode VALUES ('',
   N'DECLARE @Nothing NCHAR(1)' )

   SELECT
     CodeLine
   FROM @ProcCode
   ORDER BY LineNum

   RETURN 0
END

DECLARE @Loop tinyint
DECLARE @Prefix CHAR(3)

SET @Loop = 1
WHILE @Loop <= 3
BEGIN
   IF @Loop = 3 AND @PTableName='AuditLogTypes' 
   BEGIN
      SET @Loop = @Loop + 1 
      CONTINUE 
   END

   SET @Prefix = CASE @Loop WHEN 1 THEN 'Ins' WHEN 2 THEN 'Upd' WHEN 3 THEN 'Del' END

   INSERT INTO @ProcCode VALUES (@Prefix,
   N'IF OBJECT_ID(''dbo.' + @PTableName + @Prefix + N'Audit'') IS NOT NULL ')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'    DROP TRIGGER dbo.' + @PTableName + @Prefix + N'Audit' )
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'GO' )

   SET @Loop = @Loop + 1
END


-- Verify at least one AuditLogTypes record exists for given table
-- otherwise, go no further
IF NOT EXISTS ( SELECT 1 FROM AuditLogTypes
                 WHERE Category = N'D' AND
                 MessageDesc = @PTableName)
or dbo.AuditLogOn(@PTableName) = 0
BEGIN
   SELECT
     CodeLine
   FROM @ProcCode
   ORDER BY LineNum

   RETURN 0
END

DECLARE @StandIn sysname
SET @StandIn = N'<tablename>'

-- Determine the Primary Keys and their data-types
DECLARE @pkc TABLE (column_name sysname, ordinal_position SMALLINT, data_type sysname)

INSERT INTO @pkc
SELECT pkc.column_name, pkc.ordinal_position, syst.name
FROM dbo.PrimaryKeyColumns(@PTableName) AS pkc
INNER JOIN syscolumns AS sysc ON sysc.name = pkc.column_name
INNER JOIN systypes AS syst ON syst.xusertype = sysc.xtype
WHERE sysc.id = OBJECT_ID(@PTableName)

-- Construct an expression to concatenate the Primary Keys as a string
DECLARE @KeyValue LongList
SET @KeyValue = N''

SELECT @KeyValue = @KeyValue
   + CASE WHEN @KeyValue = N'' THEN N'' ELSE N' + N''-'' + ' END
   + CASE WHEN pkc.data_type NOT IN ('nvarchar', N'varchar', N'char', N'nchar', N'ntext', N'text')
      THEN N'CAST(' ELSE N'' END
   + @StandIn + '.' + pkc.column_name
   + CASE WHEN pkc.data_type NOT IN ('nvarchar', N'varchar', N'char', N'nchar', N'ntext', N'text')
      THEN N' AS NVARCHAR(4000))' ELSE N'' END
FROM @pkc AS pkc
ORDER BY pkc.ordinal_position


SET @Loop = 1
WHILE @Loop <= 3
BEGIN
   IF @Loop = 3 AND @PTableName='AuditLogTypes' 
   BEGIN
      SET @Loop = @Loop + 1 
      CONTINUE 
   END

   SET @Prefix = CASE @Loop WHEN 1 THEN 'Ins' WHEN 2 THEN 'Upd' WHEN 3 THEN 'Del' END

   INSERT INTO @ProcCode VALUES (@Prefix,
   N'CREATE TRIGGER dbo.' + @PTableName + @Prefix + N'Audit')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'ON ' + @PTableName)
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'AFTER ' + CASE @Prefix WHEN 'Ins' THEN N'INSERT' WHEN 'Upd' THEN N'UPDATE' WHEN 'Del' THEN N'DELETE' END)
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'AS')

-- Debugging:
--INSERT INTO @ProcCode VALUES (@Prefix, N'PRINT ''' + @PTableName + @Prefix + N'Audit firing...''')

   INSERT INTO @ProcCode VALUES (@Prefix,
   N'-- Skip trigger operations as required.')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'IF dbo.SkipBaseTrigger() = 1 RETURN')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')

-- Debugging:
--INSERT INTO @ProcCode VALUES (@Prefix, N'PRINT ''' + @PTableName + @Prefix + N'Audit executing''')

   INSERT INTO @ProcCode VALUES (@Prefix,
   N'DECLARE')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'  @Severity INT')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N', @Infobar  InfobarType')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'SET @Severity = 0')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'SET @Infobar = NULL')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')

   INSERT INTO @ProcCode VALUES (@Prefix,
   N'-- This trigger creates the necessary audit records for the ' + @PTableName + N' table')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'-- NOTE: This trigger is GENERATED by AuditLoggingGenCodeSp -- Do not modify directly.')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'DECLARE')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'  @SessionID uniqueidentifier')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N', @Today DateType')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N', @UserName LongListType')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N', @FormName FormNameType')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'SET @SessionID = dbo.SessionIDSp()')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'SET @Today = dbo.GetSiteDate(GETDATE())')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'SET @UserName = dbo.UserNameSp()')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'SET @FormName = dbo.GetFormName()')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')

   SET @Loop = @Loop + 1
END


-- Create Database Insert Audit Log Inserts For Each Column Listed in
-- AuditTypes for the given table
DECLARE AuditLogTypesCrs CURSOR LOCAL STATIC
FOR SELECT DISTINCT sysc.colid, sysc.name
   , CASE WHEN syst.name NOT IN ('nvarchar', N'varchar', N'char', N'nchar', N'ntext', N'text') THEN 1 ELSE 0 END
FROM syscolumns AS sysc
INNER JOIN AuditLogTypes AS ALT
   -- All Columns if '*' record exist, otherwise just those specified
   ON (ALT.FieldName = sysc.name OR ALT.FieldName = N'*')
INNER JOIN systypes AS syst ON syst.xusertype = sysc.xtype
WHERE sysc.id = OBJECT_ID(@PTableName)
-- No System Columns
AND sysc.name NOT IN (N'CreatedBy', N'UpdatedBy', N'CreateDate', N'RecordDate')
-- No blob colums
AND syst.name NOT IN (N'text', N'ntext', N'image')
-- No computed columns
AND sysc.iscomputed = 0
AND ALT.Category = N'D'
AND ALT.MessageDesc = @PTableName
-- No Columns that are part of the primary key
--AND NOT EXISTS(SELECT 1 FROM @pkc AS pkc WHERE pkc.column_name = sysc.name)
-- Put in correct Column order
ORDER BY sysc.colid

OPEN AuditLogTypesCrs
WHILE @Severity = 0
BEGIN -- cursor loop
   FETCH AuditLogTypesCrs INTO
     @ColumnId
   , @ColumnName
   , @CASTit

   IF @@FETCH_STATUS = -1
      BREAK

   -- Get necessary info from AuditLogTypes
   SET @ALTMessageType = N''
   SELECT TOP 1
      @ALTMessageType = ALT.MessageType
   FROM AuditLogTypes AS ALT
   WHERE Category = N'D'             AND
         MessageDesc = @PTableName  AND
         (FieldName   = @ColumnName OR FieldName = N'*')

   SET @SafeColumnName =
      CASE @CASTit WHEN 1 THEN N'CAST(' ELSE N'' END
      + @StandIn + '.' + @ColumnName
      + CASE @CASTit WHEN 1 THEN N' AS NVARCHAR(4000))' ELSE N'' END

   SET @Loop = 1
   WHILE @Loop <= 3
   BEGIN
      IF @Loop = 3 AND @PTableName='AuditLogTypes' 
      BEGIN
         SET @Loop = @Loop + 1 
         CONTINUE 
      END
   
      SET @Prefix = CASE @Loop WHEN 1 THEN 'Ins' WHEN 2 THEN 'Upd' WHEN 3 THEN 'Del' END

      INSERT INTO @ProcCode VALUES (@Prefix,
      N'-- Column: ' + @PTableName + N'.' + @ColumnName)
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'INSERT INTO AuditLog (')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   MessageType')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , UserName')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , LogDesc')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , OldValue')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , NewValue')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , KeyValue')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , Category')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , MessageDesc')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , CreatedBy')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , CreateDate')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , UpdatedBy')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , RecordDate')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   )')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'SELECT')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   ' + CAST(@ALTMessageType AS NVARCHAR(15)) + N' AS MessageType')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , @UserName AS UserName')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , @FormName AS LogDesc')

      IF @Prefix = 'Ins'
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'   , NULL AS OldValue')
      ELSE
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'   , ' + replace(@SafeColumnName, @StandIn, N'deleted') + N' AS OldValue')

      IF @Prefix = 'Del'
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'   , NULL AS NewValue')
      ELSE
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'   , ' + replace(@SafeColumnName, @StandIn, N'inserted') + N' AS NewValue')

      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , '
         + replace(@KeyValue, @StandIn, CASE @Prefix WHEN 'Del' THEN N'deleted' ELSE N'inserted' END)
         + N' AS KeyValue')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , N'''
         + CASE @Prefix WHEN 'Ins' THEN 'DA' WHEN 'Upd' THEN 'DU' WHEN 'Del' THEN 'DD' END
         + ''' AS Category')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , N' + NCHAR(39) + @PTableName + N'.' + @ColumnName + NCHAR(39) + N' AS MessageDesc')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , @UserName AS CreatedBy')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , @Today AS CreateDate')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , @UserName AS UpdatedBy')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   , @Today AS RecordDate')

      IF @Prefix = 'Del'
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'FROM deleted')
      ELSE
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'FROM inserted')

      IF @Prefix = 'Upd'
      BEGIN
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'INNER JOIN deleted ON inserted.RowPointer = deleted.RowPointer')
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'   -- Create an Audit Record only if the Column data has changed')
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'   WHERE ISNULL(' + replace(@SafeColumnName, @StandIn, N'deleted') + N', NCHAR(1))')
         INSERT INTO @ProcCode VALUES (@Prefix,
         N'      <> ISNULL(' + replace(@SafeColumnName, @StandIn, N'inserted') + N', NCHAR(1))')
      END

      INSERT INTO @ProcCode VALUES (@Prefix,
      N'')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'SET @Severity = @@Error')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'IF @Severity <> 0')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'BEGIN')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   SET @Infobar = N' + NCHAR(39) + @PTableName + N'.' + @ColumnName + NCHAR(39))
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'   GOTO EOT')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'END')
      INSERT INTO @ProcCode VALUES (@Prefix,
      N'')

      SET @Loop = @Loop + 1
   END

END -- End of cursor loop

CLOSE AuditLogTypesCrs
DEALLOCATE AuditLogTypesCrs


SET @Loop = 1
WHILE @Loop <= 3
BEGIN
   IF @Loop = 3 AND @PTableName='AuditLogTypes' 
   BEGIN
      SET @Loop = @Loop + 1 
      CONTINUE 
   END

   SET @Prefix = CASE @Loop WHEN 1 THEN 'Ins' WHEN 2 THEN 'Upd' WHEN 3 THEN 'Del' END

   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'EOT:')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'IF @Severity <> 0')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'BEGIN')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'   SET @Infobar = '
      + NCHAR(39) + N'Internal error: Unable to Create Audit Log for '
      + @Prefix + ' of ' + NCHAR(39) + N' + @Infobar')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'   EXEC RaiseErrorSp @Infobar, @Severity, 3')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'   EXEC @Severity = RollbackTransactionSp @Severity')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'   IF @Severity != 0')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'   BEGIN')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'      ROLLBACK TRANSACTION')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'      RETURN')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'   END')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'END')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')

   INSERT INTO @ProcCode VALUES (@Prefix,
   N'RETURN')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')

   INSERT INTO @ProcCode VALUES (@Prefix,
   N'GO' )
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')
   INSERT INTO @ProcCode VALUES (@Prefix,
   N'')

   SET @Loop = @Loop + 1
END

-- Debugging:
--DECLARE CodeLineCursor CURSOR LOCAL STATIC FOR

SELECT
  CodeLine
FROM @ProcCode
ORDER BY Prefix, LineNum

-- Debugging:
--OPEN CodeLineCursor WHILE 1=1 BEGIN DECLARE @CodeLine nvarchar(4000) FETCH CodeLineCursor INTO @CodeLine IF @@FETCH_STATUS = -1 BREAK   PRINT @CodeLine END CLOSE CodeLineCursor DEALLOCATE CodeLineCursor


RETURN 0
GO