SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/FKOneSp.sp 2     6/17/03 12:03p Matagl $  */
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
CREATE PROCEDURE [dbo].[FKOneSp] (
  @Table SYSNAME
, @Drop INT = 1
, @Create INT = 1
, @FKDropCode  NVARCHAR(4000) OUTPUT
, @FKAddCode   NVARCHAR(4000) OUTPUT
)
AS
DECLARE
  @DropCodeLines TABLE (
  CodeLine NVARCHAR(4000)
, RowPointer INT IDENTITY)

DECLARE
  @AddCodeLines TABLE (
  CodeLine NVARCHAR(4000)
, RowPointer INT IDENTITY)

IF @Drop = 1
BEGIN
INSERT INTO @DropCodeLines (CodeLine)
select 'ALTER TABLE ' + object_name(fkeyid) + ' DROP CONSTRAINT ' + object_name(constid)
from sysreferences
where object_name(rkeyid) = @Table
END

IF @Create = 1
BEGIN
INSERT INTO @AddCodeLines (CodeLine)
select 'ALTER TABLE ' + object_name(fkeyid) + ' ADD CONSTRAINT ' + object_name(constid) + '
FOREIGN KEY (' + COL_NAME (fkeyid, fkey1) +
CASE WHEN COL_NAME(fkeyid, fkey2) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey2)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey3) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey3)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey4) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey4)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey5) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey5)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey6) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey6)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey7) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey7)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey8) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey8)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey9) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey9)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey9) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey9)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey10) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey10)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey11) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey11)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey12) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey12)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey13) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey13)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey14) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey14)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey15) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey15)
  ELSE ''
END +
CASE WHEN COL_NAME(fkeyid, fkey16) IS NOT NULL THEN
  ', ' + COL_NAME(fkeyid, fkey16)
  ELSE ''
END +
') REFERENCES ' + object_name(rkeyid) + ' (
' +
COL_NAME (rkeyid, rkey1) +
CASE WHEN COL_NAME(rkeyid, rkey2) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey2)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey3) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey3)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey4) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey4)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey5) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey5)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey6) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey6)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey7) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey7)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey8) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey8)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey9) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey9)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey10) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey10)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey11) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey11)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey12) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey12)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey13) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey13)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey14) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey14)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey15) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey15)
  ELSE ''
END +
CASE WHEN COL_NAME(rkeyid, rkey16) IS NOT NULL THEN
  ', ' + COL_NAME(rkeyid, rkey16)
  ELSE ''
END +

')' +
CASE WHEN rc.DELETE_RULE = 'CASCADE' THEN ' ON DELETE CASCADE '
ELSE ''
END + ''
from sysreferences
INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS rc ON
  rc.CONSTRAINT_NAME = OBJECT_NAME(sysreferences.constid)
where object_name(rkeyid) = @Table
END

SET @FKDropCode = ''
SELECT
  @FKDropCode = @FKDropCode + CodeLine + NCHAR(10)
FROM @DropCodeLines
ORDER BY RowPointer

SET @FKAddCode = ''
SELECT
  @FKAddCode = @FKAddCode + CodeLine + NCHAR(10)
FROM @AddCodeLines
ORDER BY RowPointer

RETURN 0
GO