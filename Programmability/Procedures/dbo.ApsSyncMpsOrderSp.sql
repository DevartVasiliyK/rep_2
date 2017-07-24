SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncMpsOrderSp.sp 6     5/26/05 12:22a vanmmar $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncMpsOrderSp.sp $
 *
 * SL7.04 6 87244 vanmmar Thu May 26 00:22:13 2005
 * 87244
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncMpsOrderSp] (
  @Partition uniqueidentifier
)
AS
-- This routine will stage an MPS order.
-- 
declare
  @ApsParmSupplyTime ApsTimeType
 ,@SfcparmsScheduleMps ListYesNoType

select
  @ApsParmSupplyTime = aps_parm.supply_time
from aps_parm 

select
  @SfcparmsScheduleMps = isnull(sfcparms.schedulemps,0)
from sfcparms

update ORDER000
set
  DESCR = 'MPS'
, PARTID = upper(rcpts.item)
, MATERIALID = upper(rcpts.item)
, ORDSIZE = rcpts.orig_qty
, LOADSIZE = dbo.MaxQty(1, rcpts.orig_qty)
, ARIVDATE = dbo.Lowdate()
, RELDATE = dbo.Lowdate()
, DUEDATE = isnull(dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(rcpts.due_date)), dbo.Lowdate())
, REQUDATE = isnull(dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(rcpts.due_date)), dbo.Lowdate())
, CATEGORY = aps_seq.priority
, ORDTYPE = 230 -- MPS Order
, FLAGS =
   64 + -- VAL_ORDFLAGS_NOFIN
   128 + -- VAL_ORDFLAGS_NOSUP
   256 + -- VAL_ORDFLAGS_REPLENISH
   1024 -- VAL_ORDFLAGS_NOLOTSIZE
, CUSTOMER = ''
, PLANONLYFG = case when @SfcparmsScheduleMps = 1 then 'N' else 'Y' end
, SCHEDONLYFG = 'N'
, PROCPLANID =
   isnull(dbo.ApsRouteId(item.job, 0), '')
-- dbo.ApsCurrentRouteId(item.job, 0,
--       isnull(
--          (select top 1 jobroute.effect_date from jobroute where 
--             jobroute.job = item.job and
--             jobroute.suffix = 0 and
--             jobroute.effect_date is not null and
--             (datediff(day, jobroute.effect_date, rcpts.due_date) >= 0) and
--             (jobroute.obs_date is null or
--              (datediff(day, jobroute.obs_date, rcpts.due_date) < 0))
--             order by jobroute.effect_date desc)
--          ,dbo.Lowdate())),'')
, OrderTable = 'rcpts'
, OrderRowPointer = rcpts.RowPointer
from TrackRows
   inner join rcpts on
      rcpts.RowPointer = TrackRows.RowPointer
   inner join item (NOLOCK) on
      item.item = rcpts.item
   inner join ORDER000 on
      ORDER000.ORDERID = dbo.ApsMpsOrderId(rcpts.item, rcpts.ref_num)
   inner join aps_seq on
      aps_seq.order_code = 5 -- MPSSupply
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync rcpts'
and rcpts.orig_qty > 0

insert into ORDER000
   (ORDERID, DESCR, PARTID, MATERIALID, ORDSIZE, LOADSIZE,
    ARIVDATE, RELDATE, DUEDATE, REQUDATE,
    CATEGORY, ORDTYPE, FLAGS, CUSTOMER,
    PLANONLYFG, SCHEDONLYFG, PROCPLANID,
    OrderTable, OrderRowPointer)
select
  dbo.ApsMpsOrderId(rcpts.item, rcpts.ref_num)
, 'MPS'
, upper(rcpts.item)
, upper(rcpts.item)
, rcpts.orig_qty
, dbo.MaxQty(1, rcpts.orig_qty)
, dbo.Lowdate()
, dbo.Lowdate()
, isnull(dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(rcpts.due_date)), dbo.Lowdate())
, isnull(dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(rcpts.due_date)), dbo.Lowdate())
, aps_seq.priority
, 230 -- MPS Order
, 64 + -- VAL_ORDFLAGS_NOFIN
 128 + -- VAL_ORDFLAGS_NOSUP
 256 + -- VAL_ORDFLAGS_REPLENISH
 1024 -- VAL_ORDFLAGS_NOLOTSIZE
, ''
, case when @SfcparmsScheduleMps = 1 then 'N' else 'Y' end
, 'N'
,isnull(dbo.ApsRouteId(item.job, 0), '')
, 'rcpts'
, rcpts.RowPointer
from TrackRows
   inner join rcpts on
      rcpts.RowPointer = TrackRows.RowPointer
   inner join item (NOLOCK) on
      item.item = rcpts.item
   left outer join ORDER000 on
      ORDER000.ORDERID = dbo.ApsMpsOrderId(rcpts.item, rcpts.ref_num)
   inner join aps_seq on
      aps_seq.order_code = 5 -- MPSSupply
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync rcpts'
and ORDER000.ORDERID is null
and rcpts.orig_qty > 0
GO