SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/TableScriptSp.sp 6     2/18/04 9:26a Doujoh $  */
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

--  The RETURN result SET is a table creation script for the input table name.
-- All check constraints are created as table constraints currently AND all
-- default constraints are created as column constraints.
CREATE PROCEDURE [dbo].[TableScriptSp] (
  @TableName SYSNAME
, @GetForeignKeys INT = 1
)
AS
DECLARE
  @TableText TABLE (
  CodeLine   NVARCHAR(4000) NOT NULL
, RowPointer INT IDENTITY  NOT NULL
)
DECLARE
  @Columns TABLE (
  ColumnName   SYSNAME   NOT NULL
, Colid        INT       NOT NULL
, DefaultName  SYSNAME       NULL
, DefaultValue NVARCHAR(3000) NULL
, DataType     SYSNAME       NULL
, ISNULLable   SYSNAME       NULL
)

DECLARE
  @CheckConstraints TABLE (
  ConstraintName  SYSNAME       NOT NULL
, ConstraintValue NVARCHAR(3000) NOT NULL
)

INSERT INTO @Columns (
  ColumnName
, ColId
, DataType
, ISNULLable
, DefaultName
, DefaultValue
) SELECT
  sc.name
, sc.colid
, dbo.DataTypeString(isc.DOMAIN_NAME, isc.DATA_TYPE
   , isc.CHARACTER_MAXIMUM_LENGTH, isc.NUMERIC_PRECISION, isc.NUMERIC_SCALE)
, isc.is_NULLable
, CASE WHEN ISNULL(scn.status, 0) & 5 = 5 THEN
    OBJECT_NAME(scn.constid)
    ELSE NULL
  END
, CASE WHEN ISNULL(scn.status, 0) & 5 = 5 THEN
    sc1.text
    ELSE NULL
  END
FROM syscolumns AS sc
INNER JOIN INFORMATION_SCHEMA.COLUMNS AS isc ON
  isc.TABLE_SCHEMA = 'dbo'
AND isc.TABLE_NAME = @TableName
AND isc.COLUMN_NAME = sc.name
LEFT OUTER JOIN sysconstraints AS scn ON
  scn.id = sc.id
AND scn.colid = sc.colid
AND scn.status & 5 = 5 -- Check constraints handled separately, just defaults
LEFT OUTER JOIN syscomments AS sc1 ON
  sc1.id = scn.constid
WHERE OBJECT_NAME(sc.id) = @TableName

INSERT INTO @CheckConstraints (
  ConstraintName
, ConstraintValue
) SELECT
  OBJECT_NAME(scn.constid)
, sc.text
FROM sysconstraints AS scn
INNER JOIN syscomments AS sc ON
  sc.id = scn.constid
WHERE scn.id = OBJECT_ID(@TableName)
AND scn.status & 4 = 4   -- Check constraint
AND scn.status & 5 <> 5  -- Not a default

INSERT INTO @TableText (
  CodeLine
) VALUES (
  'CREATE TABLE ' + @TableName + ' (')

INSERT INTO @TableText (
  CodeLine
) SELECT
 CASE WHEN ColId = 1
  THEN '  '
  ELSE ', '
  END + ColumnName + ' ' +  DataType +
  CASE WHEN ISNULLable = 'Yes'
   THEN ' NULL '
   ELSE ' NOT NULL '
  END
 + CASE WHEN DefaultName IS NULL
    THEN ''
    ELSE ' DEFAULT ' + DefaultValue
  END
FROM @Columns
ORDER BY colid

INSERT INTO @TableText (
  CodeLine)
SELECT
    ', CHECK ' + ConstraintValue
FROM @CheckConstraints

INSERT INTO @TableText (
  CodeLine)
SELECT
   ', CONSTRAINT ' + ist.constraint_name +  ' ' +
   CONSTRAINT_TYPE +
   CASE WHEN si.indid = 1
     THEN ' CLUSTERED '
     ELSE ' NONCLUSTERED '
   END
  + '('
 + dbo.PrimaryOrUniqueKeyString(ist.constraint_name) + ')'
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS ist
INNER JOIN sysindexes AS si ON
  si.id = OBJECT_ID(@TableName)
AND si.name = ist.CONSTRAINT_NAME
WHERE ist.TABLE_SCHEMA    = 'dbo'
AND   ist.TABLE_NAME      = @TableName
AND   ist.CONSTRAINT_TYPE IN ('PRIMARY KEY', 'UNIQUE')

INSERT INTO @TableText (
  CodeLine)
VALUES (')')

INSERT INTO @TableText (
  CodeLine)
SELECT
  'CREATE ' + 
  CASE WHEN INDEXPROPERTY(OBJECT_ID(@TableName), si.name, 'IsUnique') = 1
  THEN 'UNIQUE ' ELSE '' END +
  CASE WHEN si.indid = 1
    THEN 'CLUSTERED'
    ELSE 'NONCLUSTERED'
  END +
' INDEX ' + si.name + ' ON ' + @TableName + ' (' + dbo.IndexKeyString(si.name,
  @TableName) + ')'
FROM sysindexes AS si
WHERE si.id = OBJECT_ID(@TableName)
AND si.status & 64 = 0 -- Ignores statistics
AND si.indid > 0 -- If no clustered indexes, table itself must be ignored.
AND si.indid <> 255 -- table contains ntext columns
AND NOT EXISTS (
  SELECT 1
  FROM sysconstraints AS sc
  WHERE si.id = sc.id
  AND OBJECT_NAME(sc.constid) = si.name)

IF @GetForeignKeys = 1
BEGIN
  INSERT INTO @TableText (
    CodeLine)
  SELECT
    CodeLine
  FROM dbo.ForeignKeyString (
    @TableName
  , 0   -- Drop
  , 1 ) -- Create
  ORDER BY RowPointer
END

SELECT
  CodeLine
FROM @TableText
ORDER BY RowPointer

RETURN 0
GO