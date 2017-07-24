SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/PurgeNextKeysSp.sp 3     6/08/05 4:43p Doujoh $  */
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
--  The NextKeys table is not deleted from during normal processing.  This
-- routine cleans up all but the max value for each table.column and prefix.

/* $Archive: /ApplicationDB/Stored Procedures/PurgeNextKeysSp.sp $
 *
 * SL7.04 3 87617 Doujoh Wed Jun 08 16:43:49 2005
 * PurgeNextKeysSp while users running can cause duplicates
 * Issue #87617, lock up all the application locks and make sure NextKeys is free before doing the actual purge to prevent duplicate values during a collision with Next2SubKeySp.
 *
 * SL7.03 3 87617 Doujoh Wed Jun 08 16:41:40 2005
 * PurgeNextKeysSp while users running can cause duplicates
 * Issue #87617, lock up all the application locks and make sure NextKeys is free before doing the actual purge to prevent duplicate values during a collision with Next2SubKeySp.
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[PurgeNextKeysSp]
AS
DECLARE
  @TransNeeded INT
SET @TransNeeded = 0

--  The application locks require a transaction.
IF @@TRANCOUNT = 0
BEGIN
   SET @TransNeeded = 1
   BEGIN TRAN
END
DECLARE
  @Resource SYSNAME

--  Purging of next keys needs to be done while nobody is trying to add new
-- keys.  In order to do this, an application lock for each of the table
-- column and prefix combinations in the NextKeys table is obtained.  When the
-- commit happens, all of these application locks will be released.  The
-- TABLOCK ensures that all other processes have committed any NextKeys
-- changes first.

DECLARE
  PurgeCrs CURSOR LOCAL STATIC FOR
SELECT DISTINCT 'NextKeys:' + TableColumnName + ':' + Keyprefix
FROM NextKeys WITH (TABLOCK)
OPEN PurgeCrs
WHILE 1=1
BEGIN
   FETCH PurgeCrs INTO @Resource
   IF @@FETCH_STATUS = -1
      BREAK

   EXEC sp_getapplock 
     @Resource = @Resource
   , @LockMode = 'exclusive'
END

--  First get rid of all non-max rows.
DELETE nk1
FROM NextKeys AS nk1 WITH (TABLOCK)
WHERE KeyID <> (SELECT MAX(nk2.KeyID)
  FROM NextKeys AS nk2
  WHERE nk2.TableColumnName = nk1.TableColumnName
  AND   nk2.KeyPrefix = nk1.KeyPrefix
  AND   ISNULL(nk2.SubKey, NCHAR(1)) = ISNULL(nk1.SubKey, NCHAR(1)))

-- Next get rid of all but 1 of duplicates.
DELETE nk1
FROM NextKeys AS nk1 WITH (TABLOCK)
WHERE RowPointer <> (SELECT TOP 1 nk2.RowPointer
  FROM NextKeys AS nk2
  WHERE nk2.TableColumnName = nk1.TableColumnName
  AND   nk2.KeyPrefix = nk1.KeyPrefix
  AND   ISNULL(nk2.SubKey, NCHAR(1)) = ISNULL(nk1.SubKey, NCHAR(1)))

IF @TransNeeded = 1
   COMMIT TRAN

RETURN 0
GO