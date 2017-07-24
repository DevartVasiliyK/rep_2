SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncProjectOrderSp.sp 6     7/07/06 1:58p hoffjoh $  */
/*
Copyright c MAPICS, Inc. 2003 - All Rights Reserved

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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncProjectOrderSp.sp $
 *
 * SL7.04.20 6 94129 hoffjoh Fri Jul 07 13:58:03 2006
 * Modifying warehouse on co line to 'dedicated' warehouse - order is still planned
 * TRK 94129 - added delete of records in trackrows that do not get inserted/updated, to catch things such as changing a warehouse to dedicated inventory.
 *
 * SL7.04 5 87244 vanmmar Thu May 26 00:22:13 2005
 * 87244
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncProjectOrderSp] (
  @Partition uniqueidentifier
)
AS
-- This routine will stage a project order.
-- 
declare
  @ApsParmDemandTime ApsTimeType
, @PlanOnSave ListYesNoType

set @PlanOnSave = ISNULL(dbo.DefinedValue('PlanOnSave'),1)

select
  @ApsParmDemandTime = aps_parm.demand_time
from aps_parm 

delete ORDER000
from TrackRows
inner join projmatl on projmatl.RowPointer = TrackRows.RowPointer
inner join proj on proj.proj_num = projmatl.proj_num
inner join projtask on projtask.proj_num = projmatl.proj_num and projtask.task_num = projmatl.task_num
inner join item (NOLOCK) on item.item = projmatl.item
inner join ORDER000 on ORDER000.ORDERID = dbo.ApsProjectOrderId(projtask.proj_num, projtask.task_num, projmatl.seq)
left join whse on projmatl.whse = whse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync projmatl'
and not (proj.type = 'P'
         and projtask.stat = 'A'
         and projmatl.matl_qty - projmatl.qty_issued > 0
         and (whse.whse is null or whse.dedicated_inventory <> 1))

update ORDER000
set
  DESCR = 'Project'
, PARTID = upper(projmatl.item)
, MATERIALID = upper(projmatl.item)
, ORDSIZE = projmatl.matl_qty - projmatl.qty_issued
, LOADSIZE = dbo.MaxQty(1, projmatl.matl_qty - projmatl.qty_issued)
, ARIVDATE = isnull(dbo.MidnightOf(projtask.task_date), dbo.Lowdate())
, RELDATE =  dbo.Lowdate()
, DUEDATE = isnull(dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(projtask.eff_date)),  dbo.Lowdate())
, REQUDATE = isnull(dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(projtask.eff_date)),  dbo.Lowdate())
, CATEGORY = aps_seq.priority
, ORDTYPE = 200 -- Customer Order
, FLAGS = 0
, CUSTOMER = isnull(dbo.ApsCustNumId(proj.cust_num), ' ')
, PLANONLYFG = 'Y'
, SCHEDONLYFG = 'N'
, PROCPLANID = ''
, OrderTable = 'projmatl'
, OrderRowPointer = projmatl.RowPointer
, REFORDERID = dbo.ApsGetXRefOrderID (
                      projmatl.ref_type,       
                      projmatl.ref_num,        
                      projmatl.ref_line_suf,   
                      projmatl.ref_release,    
                      'K',                     
                      projmatl.proj_num,       
                      projmatl.task_num,       
                      projmatl.seq,            
                      NULL,                    
                      projmatl.item            
                      )

from TrackRows
   inner join projmatl on
      projmatl.RowPointer = TrackRows.RowPointer
   inner join proj on
      proj.proj_num = projmatl.proj_num
   inner join projtask on
      projtask.proj_num = projmatl.proj_num
      and projtask.task_num = projmatl.task_num
   -- exclude non-item master parts
   inner join item (NOLOCK) on
      item.item = projmatl.item
   inner join ORDER000 on
      ORDER000.ORDERID = dbo.ApsProjectOrderId(projtask.proj_num, projtask.task_num, projmatl.seq)
   inner join aps_seq on
      aps_seq.order_code = 4 -- ProjectDemand
   left join whse on projmatl.whse = whse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync projmatl'
and proj.type = 'P'
AND projtask.stat = 'A'
and projmatl.matl_qty - projmatl.qty_issued > 0
and (whse.whse is null or whse.dedicated_inventory <> 1)

insert into ORDER000
   (ORDERID, DESCR, PARTID, MATERIALID, ORDSIZE, LOADSIZE,
    ARIVDATE, RELDATE, DUEDATE, REQUDATE,
    CATEGORY, ORDTYPE, FLAGS, CUSTOMER,
    PLANONLYFG, SCHEDONLYFG, PROCPLANID, AUTOPLANFG,
    OrderTable, OrderRowPointer,REFORDERID)
select
  dbo.ApsProjectOrderId(projtask.proj_num, projtask.task_num, projmatl.seq)
, 'Project'
, upper(projmatl.item)
, upper(projmatl.item)
, projmatl.matl_qty - projmatl.qty_issued
, dbo.MaxQty(1, projmatl.matl_qty - projmatl.qty_issued)
, isnull(dbo.MidnightOf(projtask.task_date),  dbo.Lowdate())
, dbo.Lowdate()
, isnull(dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(projtask.eff_date)), dbo.Lowdate())
, isnull(dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(projtask.eff_date)), dbo.Lowdate())
, aps_seq.priority
, 200 -- Customer Order
, 0
, isnull(dbo.ApsCustNumId(proj.cust_num), ' ')
, 'Y'
, 'N'
, ''
, CASE when @PlanOnSave = 1 then 'Y' else 'N' end 
, 'projmatl'
, projmatl.RowPointer
, Dbo.ApsGetXRefOrderID (
       projmatl.ref_type,       
       projmatl.ref_num,        
       projmatl.ref_line_suf,   
       projmatl.ref_release,    
       'K',                     
       projmatl.proj_num,       
       projmatl.task_num,       
       projmatl.seq,            
       NULL,                    
       projmatl.item            
                      )
from TrackRows
   inner join projmatl on
      projmatl.RowPointer = TrackRows.RowPointer
   inner join proj on
      proj.proj_num = projmatl.proj_num
   inner join projtask on
      projtask.proj_num = projmatl.proj_num and projtask.task_num = projmatl.task_num
   -- exclude non-item master parts
   inner join item (NOLOCK) on
      item.item = projmatl.item
   left outer join ORDER000 on
      ORDER000.ORDERID = dbo.ApsProjectOrderId(projtask.proj_num, projtask.task_num, projmatl.seq)
   inner join aps_seq on
      aps_seq.order_code = 4 -- ProjectDemand
   left join whse on projmatl.whse = whse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync projmatl'
and ORDER000.ORDERID is null
and proj.type = 'P'
AND projtask.stat = 'A'
and projmatl.matl_qty - projmatl.qty_issued > 0
and (whse.whse is null or whse.dedicated_inventory <> 1)

GO