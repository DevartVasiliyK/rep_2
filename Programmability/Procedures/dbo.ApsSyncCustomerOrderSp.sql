SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncCustomerOrderSp.sp 9     7/07/06 2:00p hoffjoh $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncCustomerOrderSp.sp $
 *
 * SL7.04.20 9 94129 hoffjoh Fri Jul 07 14:00:10 2006
 * Modifying warehouse on co line to 'dedicated' warehouse - order is still planned
 * TRK 94129 - added delete of records in trackrows that do not get inserted/updated, to catch things such as changing a warehouse to dedicated inventory.
 *
 * SL7.04.20 8 90917 vanmmar Mon Jan 30 11:16:17 2006
 * Planned orders are created after entering a customer order line with plan on save unchecked.
 * 90917 - sync "plan on save" correctly during syncdefer
 *
 * SL7.04 6 87244 vanmmar Thu May 26 00:22:10 2005
 * 87244
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncCustomerOrderSp] (
  @Partition uniqueidentifier
)
AS
-- This routine will stage a customer order for APS if applicable.
-- 
declare
  @ApsParmDemandTime ApsTimeType
, @ParmsSite SiteType

-- Only pass customer orders to APS if so specified
if exists(select * from mrp_parm where mrp_parm.req_src = 'F')
   return

select
  @ParmsSite = parms.site
from parms 

select
  @ApsParmDemandTime = aps_parm.demand_time
from aps_parm 

declare @custOrder table (
       OrderId nvarchar(80)
      ,Item nvarchar(40)
      ,OrdSize float(8)
      ,LoadSize int
      ,ArivDate datetime
      ,DueDate datetime
      ,RequDate datetime
      ,Category int
      ,OrdType int
      ,Flags int
      ,Customer nvarchar(30)
      ,SchedOnlyFg nchar(1)
      ,AutoPlanFg nchar(1)
      ,OrderRowPointer uniqueidentifier
      ,RefOrderId nvarchar(80)
      primary key (OrderId)
   )

insert into @custOrder (
       OrderId, Item, OrdSize, LoadSize, ArivDate, DueDate, RequDate, Category,
       OrdType, Flags, Customer, SchedOnlyFg, AutoPlanFg, OrderRowPointer,RefOrderId)
select
    OrderId = dbo.ApsOrderId(coitem.co_num, coitem.co_line, coitem.co_release)
   ,item = upper(coitem.item)
   ,ORDSIZE = coitem.qty_ordered - coitem.qty_shipped - coitem.qty_rsvd
   ,LOADSIZE = dbo.MaxQty(1, coitem.qty_ordered - coitem.qty_shipped - coitem.qty_rsvd)
   ,ARIVDATE = isnull(dbo.MidnightOf(co.order_date), dbo.Lowdate())
   ,DUEDATE = isnull(dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(coitem.due_date)), dbo.Lowdate())
   ,REQUDATE = isnull(dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(coitem.promise_date)), dbo.Lowdate())
   ,CATEGORY =
     case
        when co.order_source = 'EC'
        then dbo.ApsPriorityOf(2) -- WebOrderEntryDemand
        when co.taken_by = 'WEB'
        then dbo.ApsPriorityOf(2) -- WebOrderEntryDemand
        when co.taken_by like 'EDI%'
        then dbo.ApsPriorityOf(0) -- EDIDemand
        else dbo.ApsPriorityOf(1) -- OrderEntryDemand
     end
   ,ORDTYPE = 
     case
        when co.order_source = 'EC'
        then 220  -- Web Order
        when co.taken_by = 'WEB'
        then 220     -- Web Order
        when co.taken_by like 'EDI%'
        then 210 -- EDI Order
        else 200
     end
   ,FLAGS =
     case
        when co.aps_pull_up <> 0
        THEN 2048 -- VAL_ORDFLAGS_PULLUP
        ELSE 0 
     end
   ,CUSTOMER = dbo.ApsCustNumId(co.cust_num)
   ,SCHEDONLYFG = 'N'
   ,AUTOPLANFG = 
     case
        when tmp_aps_sync.RefRowPointer is null
        then 'Y'
        else 'N'
     end
   ,OrderRowPointer = coitem.RowPointer
   ,RefOrderId = dbo.ApsGetXRefOrderID (
                 Coitem.ref_type,      
                 coitem.ref_num,       
                 coitem.ref_line_suf,  
                 coitem.ref_release,   
                 'O',                  
                 coitem.co_num,        
                 coitem.co_line,       
                 coitem.co_release,    
                 NULL,                 
                 Coitem.item           
                 )
from TrackRows
join coitem on
   coitem.RowPointer = TrackRows.RowPointer
join co on
   co.co_num = coitem.co_num
join item (NOLOCK) on
   item.item = coitem.item
left join mrp_parm on mrp_parm.parm_key = 0
left join whse on coitem.whse = whse.whse
left join tmp_aps_sync on 
   tmp_aps_sync.SessionId = @Partition and
   tmp_aps_sync.RefRowPointer = coitem.RowPointer and
   tmp_aps_sync.SyncType = 'No plan on save'
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync coitem'
and coitem.ship_site = @ParmsSite
--and coitem.stat in ('P', 'O') -- CRM#7631 
and coitem.stat in ('O') -- CRM#7631 
and co.type != 'E'
and coitem.qty_ordered - coitem.qty_shipped - coitem.qty_rsvd > 0
and (whse.whse is null or whse.dedicated_inventory <> 1)

delete ORDER000
from TrackRows
join coitem on coitem.RowPointer = TrackRows.RowPointer
join ORDER000 on ORDER000.ORDERID = dbo.ApsOrderId(coitem.co_num, coitem.co_line, coitem.co_release)
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync coitem'
and not exists(select 1 from @custOrder custOrder where ORDER000.ORDERID = custOrder.orderid)

update ORDER000
set
    PARTID = custOrder.item
   ,MATERIALID = custOrder.item
   ,ORDSIZE = custOrder.OrdSize
   ,LOADSIZE = custOrder.LoadSize
   ,ARIVDATE = custOrder.ArivDate
   ,DUEDATE = custOrder.DueDate
   ,REQUDATE = custOrder.RequDate
   ,CATEGORY = custOrder.Category
   ,ORDTYPE = custOrder.OrdType
   ,FLAGS = custOrder.Flags
   ,CUSTOMER = custOrder.Customer
   ,SCHEDONLYFG = custOrder.SchedOnlyFg
   ,OrderRowPointer = custOrder.OrderRowPointer
   ,REFORDERID = custOrder.RefOrderId
from @custOrder custOrder
join ORDER000 on ORDER000.ORDERID = custOrder.orderid

insert into ORDER000
   (ORDERID, DESCR, PARTID, MATERIALID, ORDSIZE, LOADSIZE,
    ARIVDATE, RELDATE, DUEDATE, REQUDATE,
    CATEGORY, ORDTYPE, FLAGS, CUSTOMER,
    PLANONLYFG, SCHEDONLYFG, AUTOPLANFG,
    OrderTable, OrderRowPointer,REFORDERID)
select
    ORDERID = custOrder.orderid
   ,DESCR = ''
   ,PARTID = custOrder.item
   ,MATERIALID = custOrder.item
   ,ORDSIZE = custOrder.OrdSize
   ,LOADSIZE = custOrder.LoadSize
   ,ARIVDATE = custOrder.ArivDate
   ,RELDATE =  dbo.Lowdate()
   ,DUEDATE = custOrder.DueDate
   ,REQUDATE = custOrder.RequDate
   ,CATEGORY = custOrder.Category
   ,ORDTYPE = custOrder.OrdType
   ,FLAGS = custOrder.Flags
   ,CUSTOMER = custOrder.Customer
   ,PlanOnlyFg = 'Y'
   ,SchedOnlyFg = custOrder.schedonlyfg
   ,AutoPlanFg = custOrder.autoplanfg 
   ,OrderTable = 'coitem'
   ,OrderRowPointer = custOrder.OrderRowPointer
   ,REFORDERID = custOrder.RefOrderId
from @custOrder custOrder
left join ORDER000 on ORDER000.ORDERID = custOrder.orderid
where ORDER000.ORDERID is null

DECLARE @T TABLE(
GROUPID NVARCHAR(30)
,ORDERID NVARCHAR(63)
,SEQNO   INT IDENTITY(1,1)
)

--Удалим привязку к группам 

delete ORDGRP000 from ORDGRP000 
    inner join ORDER000 (NOLOCK) on ORDER000.ORDERID = ORDGRP000.ORDERID 
    inner join TrackRows  on TrackRows.RowPointer = ORDER000.OrderRowPointer

--Вставим

INSERT INTO @T(GROUPID,ORDERID)
SELECT coitem.RUSGROUPID,ORDER000.ORDERID
FROM coitem
INNER JOIN TrackRows (NOLOCK) ON TrackRows.RowPointer = coitem.RowPointer
inner join ORDER000 on ORDER000.OrderRowPointer = coitem.RowPointer
where not coitem.RUSGROUPID is NULL
order by coitem.RUSGROUPID


INSERT INTO ORDGRP000(GROUPID,ORDERID,SEQNO)
SELECT GROUPID,ORDERID,SEQNO FROM @T

DELETE FROM @T

GO