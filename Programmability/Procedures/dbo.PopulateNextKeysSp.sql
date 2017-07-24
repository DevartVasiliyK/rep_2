SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/PopulateNextKeysSp.sp 2     6/17/03 1:33p Matagl $  */
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

CREATE PROCEDURE [dbo].[PopulateNextKeysSp] (
  @TableName   SYSNAME
, @ColumnName  SYSNAME
, @SubKeyName  SYSNAME = NULL
, @Table2Name  SYSNAME = NULL
, @Column2Name SYSNAME = NULL
, @SubKey2Name SYSNAME = NULL
)
AS
CREATE TABLE #Keys (
  Prefix      SYSNAME NOT NULL
, SubKeyValue SYSNAME     NULL
, MaxValue    SYSNAME     NULL
)

DECLARE
  @SQL LongListType

--  The like [0-9] on the last digit makes sure we skip values that do not have
-- numeric endings and are therefore not eligible for next key processing.
SET @SQL = 'INSERT INTO #Keys (Prefix, SubKeyValue)
SELECT DISTINCT dbo.PrefixOnly(' + @ColumnName + '), ' + 
ISNULL(@SubKeyName, 'NULL') + '
FROM '  + @TableName + '
WHERE SUBSTRING(' + @ColumnName + ', LEN(' + @ColumnName + '), 1) LIKE ''[0-9]'''

IF @Table2Name IS NOT NULL
BEGIN
   SET @SQL = @SQL + ' 
UNION 
SELECT
DISTINCT dbo.PrefixOnly(' + @Column2Name + '), ' +
ISNULL(@SubKey2Name, 'NULL') + '
FROM ' + @Table2Name + '
WHERE SUBSTRING(' + @Column2Name + ', LEN(' + @Column2Name + '), 1) LIKE ''[0-9]'''
END

EXECUTE (@SQL)

--  The trick is to find the maximum integer value for each distinct prefix
-- already in theeys table.  A match on the prefix is considered to have been
-- made if
-- a) The prefix itself matches
-- b) The char after the prefix length is an integer.
-- c) The rest of the string after the prefix contains only digits or blanks.
--  Wildcard pattern matching used to be used for this, but it failed in SQL 
-- Server, running properly only some of the time.
SET @SQL = '
UPDATE #Keys
SET  MaxValue = (SELECT MAX (KeyValue) FROM (SELECT ISNULL(MAX(' + @TableName + 
'.' + @ColumnName + '), '''') AS KeyValue
  FROM ' + @TableName + '
WHERE SUBSTRING(' + @TableName + '.' + @ColumnName + ', 1, LEN(#Keys.Prefix)) =#Keys.Prefix 
AND SUBSTRING(' + @TableName + '.' + @ColumnName + ', LEN(#Keys.Prefix) + 1, 1) LIKE ''[0-9 ]''

 AND dbo.IsInteger(SUBSTRING(' + @TableName + '.' + @ColumnName + ', 
LEN(#Keys.Prefix) + 1, 255)) = 1

' + CASE WHEN @SubKeyName IS NULL THEN ''
  ELSE ' AND ' + @TableName + '.' + @SubKeyName + ' = #Keys.SubKeyValue '
END

+  CASE WHEN @Table2Name IS NULL THEN ''
ELSE
' UNION SELECT ISNULL(MAX(' + @Table2Name + 
'.' + @Column2Name + '), '''') AS KeyValue
  FROM ' + @Table2Name + '
WHERE SUBSTRING(' + @Table2Name + '.' + @Column2Name + ', 1, LEN(#Keys.Prefix)) =#Keys.Prefix 
AND SUBSTRING(' + @Table2Name + '.' + @Column2Name + ', LEN(#Keys.Prefix) + 1, 1) LIKE ''[0-9 ]''

 AND dbo.IsInteger(SUBSTRING(' + @Table2Name + '.' + @Column2Name + ', 
LEN(#Keys.Prefix) + 1, 255)) = 1
' + CASE WHEN @SubKey2Name IS NULL THEN ''
  ELSE ' AND ' + @Table2Name + '.' + @SubKey2Name + ' = #Keys.SubKeyValue ' 
END END +
') AS x)
FROM #Keys'

EXECUTE (@SQL)

INSERT INTO NextKeys (TableColumnname, KeyPrefix, KeyID, SubKey)
SELECT @TableName + '.' + @ColumnName, Prefix, 
  SUBSTRING(MaxValue, LEN(Prefix) + 1, 100), SubKeyValue
FROM #Keys

DROP TABLE #Keys 

RETURN 0
GO