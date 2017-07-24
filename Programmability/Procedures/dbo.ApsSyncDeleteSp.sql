SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncDeleteSp.sp 10    6/06/05 2:42p Janreu $  */
/*
Copyright © MAPICS, Inc. 2004 - All Rights Reserved

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


/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncDeleteSp.sp $
 *
 * SL7.04 10 87335 Janreu Mon Jun 06 14:42:13 2005
 * Non-Referenced materials are being stranded in BOM000
 * 87335 - removed condition on delete of BOM000 records.  We weren't deleting enough.
 *
 * SL7.04 9 87312 Grosphi Thu May 19 14:44:58 2005
 * performance is slow
 * improved column joins for JS19VR000 and JOBSTEP000
 *
 * SL7.04 8 79586 Grosphi Thu Apr 14 11:15:20 2005
 * made changes to avoid index scans
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncDeleteSp] (
  @Partition uniqueidentifier
)
AS
-- This routine will process deferred APS table deletions
-- 
declare @HC HighLowCharType
set @HC = dbo.HighCharacter()

   DELETE ORDER000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del order' AND
    dd.RefRowPointer = ORDER000.OrderRowPointer

   DELETE MATLPBOMS000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del matlpboms' AND
    dd.Key1 = MATLPBOMS000.MATERIALID and dd.Key2 like MATLPBOMS000.PBOMID

   DELETE PBOMMATLS000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del pbommatls' AND
    dd.Key1 = PBOMMATLS000.BOMID

   DELETE PBOMMATLS000              
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del Single Pbommatl' AND
    dd.Key1 = PBOMMATLS000.RefRowPointer

   DELETE MATLPBOMS000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del planner bom' AND
    dd.Key1 = MATLPBOMS000.MATERIALID and dd.Key2 = MATLPBOMS000.PBOMID

   DELETE PBOMMATLS000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del planner bom' AND
    dd.Key2 = PBOMMATLS000.BOMID

   DELETE PBOM000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del planner bom' AND
    dd.Key2 = PBOM000.BOMID

   DELETE MATLPBOMS000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del planner bom range' AND
    dd.Key1 = MATLPBOMS000.MATERIALID and MATLPBOMS000.PBOMID >= dd.Key2 and MATLPBOMS000.PBOMID <= dd.Key3

   DELETE PBOMMATLS000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del planner bom range' AND
    PBOMMATLS000.BOMID >= dd.Key2 and PBOMMATLS000.BOMID <= dd.Key3

   DELETE PBOM000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del planner bom range' AND
    PBOM000.BOMID >= dd.Key2 and PBOM000.BOMID <= dd.Key3

   DELETE BOM000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del bom' AND
    dd.Key1 = BOM000.PROCPLANID AND dd.Key2 = BOM000.JSID and dd.Key3 = BOM000.MATERIALID AND
    BOM000.QUANCD = 'L'

   DELETE EFFECT000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del effect' AND
    dd.Key1 = EFFECT000.EFFECTID

   --  Query plans showed that doing a LIKE when there was no wildcard scanned extra
   -- rows unnecessarily.  So the wildcard and non-wildcard Del Route were broken into
   -- separate cases.  Del route has a wildcard, and Del route1 does not and uses =.
   DELETE JS19VR000
   FROM tmp_aps_sync dd (NOLOCK)
      inner join JS19VR000 (NOLOCK) on
         JS19VR000.PROCPLANID between dd.Key1 and (dd.Key1 + @HC)
         and JS19VR000.JSID = dd.Key2
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del route'
   option(force order)

   DELETE JS19VR000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del route1' AND
    JS19VR000.PROCPLANID = dd.Key1
   and JS19VR000.JSID = dd.Key2

   DELETE JOBSTEP000
   FROM tmp_aps_sync dd (NOLOCK)
      inner join JOBSTEP000 (NOLOCK) on
         JOBSTEP000.PROCPLANID between dd.Key1 and (dd.Key1 + @HC)
         and JOBSTEP000.JSID = dd.Key2
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del route'
   option(force order)

   DELETE JOBSTEP000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del route1' AND
    JOBSTEP000.PROCPLANID = dd.Key1
   and JOBSTEP000.JSID = dd.Key2


   DELETE PROCPLN000
   FROM tmp_aps_sync dd (NOLOCK)
      inner join PROCPLN000 (NOLOCK) on
         PROCPLN000.PROCPLANID like dd.Key1
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del route'
   option(force order)

   DELETE PROCPLN000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del route1' AND
    PROCPLN000.PROCPLANID = dd.Key1

   DELETE JOBSTEP000              
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del Single Route' AND
    JOBSTEP000.PROCPLANID = dd.Key1 AND JOBSTEP000.JSID = dd.Key2

   DELETE JS19VR000              
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del Single Route' AND
    JS19VR000.PROCPLANID = dd.Key1 AND JS19VR000.JSID = dd.Key2

   DELETE PBOMMATLS000              
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del Single Route BOM' AND
    PBOMMATLS000.BOMID = dd.Key1 AND 
    Convert(integer,
            LEFT(Convert(nvarchar(12),PBOMMATLS000.SEQNO),LEN(Convert(nvarchar(12),PBOMMATLS000.SEQNO))-5)) = dd.Key2

   DELETE MATLPPS000
   FROM tmp_aps_sync dd (NOLOCK)
   WHERE dd.SessionId = @Partition AND dd.SyncType = 'Del matlpps' AND
    dd.Key1 = MATLPPS000.MATERIALID AND dd.Key2 like MATLPPS000.PROCPLANID

--  This query in a customer's database was determined to scan and
-- only totally hardwiring the query made it stop and use the indexes.
-- This prevents deadlocks.
   DELETE ORDER000
from order000 with (index=IX_ORDER000_ORDERID,NOLOCK)
join tmp_aps_sync dd with (index=IX_tmp_aps_sync_Key,NOLOCK) on
dd.SessionId = @Partition AND dd.SyncType = 'Del bomorder' AND
    dd.Key1 = ORDER000.ORDERID
option (loop join)

RETURN 0
GO