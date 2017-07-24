SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncPurchaseOrderSp.sp 7     7/07/06 1:58p hoffjoh $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncPurchaseOrderSp.sp $
 *
 * SL7.04.20 7 94129 hoffjoh Fri Jul 07 13:58:06 2006
 * Modifying warehouse on co line to 'dedicated' warehouse - order is still planned
 * TRK 94129 - added delete of records in trackrows that do not get inserted/updated, to catch things such as changing a warehouse to dedicated inventory.
 *
 * SL7.04 6 87244 vanmmar Thu May 26 00:22:14 2005
 * 87244
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncPurchaseOrderSp] (
  @Partition uniqueidentifier
)
AS
-- This routine will stage a purchase order.
-- 
declare
  @ApsParmSupplyTime ApsTimeType
, @PlanOnSave ListYesNoType

set @PlanOnSave = ISNULL(dbo.DefinedValue('PlanOnSave'),1)

select
  @ApsParmSupplyTime = aps_parm.supply_time
from aps_parm 

delete MATLDELV000
from TrackRows
   inner join poitem on poitem.RowPointer = TrackRows.RowPointer
   inner join po WITH (READUNCOMMITTED) on po.po_num = poitem.po_num
   inner join item (NOLOCK) on item.item = poitem.item
   inner join MATLDELV000 on MATLDELV000.ORDERID = dbo.ApsPurchaseOrderId(poitem.po_num, poitem.po_line, poitem.po_release)
   left join whse on poitem.whse = whse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync poitem'
and not (CHARINDEX( poitem.stat, 'PO') != 0
         and dbo.ApsPurchaseOrderQty(poitem.po_num, poitem.po_line, poitem.po_release) > 0
         and (whse.whse is null or whse.dedicated_inventory <> 1))

update MATLDELV000
set
  CATEGORY = -30 -- JobSupplyNotXRefToCos
, CUSTOMER = ''
, DELVDATE = isnull(dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(isnull(
    (select mcal.m_date
     from (
        select top 1 mcali.mday_num
        from mcal mcali
        where mcali.m_date >= poitem.due_date
        order by mcali.m_date
       ) as m1
     join mcal on mcal.mday_num = m1.mday_num + isnull(item.dock_time,0)
    ), poitem.due_date))), dbo.Lowdate())
, DESCR = ''
, ORDTYPE = 50 -- Incomming supply
, MATERIALID = upper(poitem.item)
, AMOUNT = dbo.ApsPurchaseOrderQty(poitem.po_num, poitem.po_line, poitem.po_release)
, OrderTable = 'poitem'
, OrderRowPointer = poitem.RowPointer
, FLAGS =  1 + --default
           case when Dbo.ApsSetXREFFlag (
                     'P',                    
                     poitem.po_num,          
                     poitem.po_line,         
                     poitem.po_release,      
                     poitem.ref_type,        
                     poitem.ref_num,         
                     poitem.ref_line_suf,    
                     poitem.ref_release,     
                     NULL,                   
                     poitem.item
                     )=1 
                then 524288 -- VAL_ORDFLAG_XREF
                else 0
           end
from TrackRows
   inner join poitem on
      poitem.RowPointer = TrackRows.RowPointer
   inner join po on
      po.po_num = poitem.po_num
   -- Skip non-inventoried items
   inner join item (NOLOCK) on
      item.item = poitem.item
   inner join MATLDELV000 on
      MATLDELV000.ORDERID = dbo.ApsPurchaseOrderId(poitem.po_num, poitem.po_line, poitem.po_release)
   left join whse on poitem.whse = whse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync poitem'
and CHARINDEX( poitem.stat, 'PO') != 0
and dbo.ApsPurchaseOrderQty(poitem.po_num, poitem.po_line, poitem.po_release) > 0
and (whse.whse is null or whse.dedicated_inventory <> 1)

insert into MATLDELV000
   (ORDERID, CATEGORY, CUSTOMER, DELVDATE, DESCR, ORDTYPE,
    MATERIALID, AMOUNT, --AUTOPLANFG,
    OrderTable, OrderRowPointer,FLAGS)
select
  dbo.ApsPurchaseOrderId(poitem.po_num, poitem.po_line, poitem.po_release)
, -30 -- JobSupplyNotXRefToCos
, ''
, isnull(dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(isnull(
    (select mcal.m_date
     from (
        select top 1 mcali.mday_num
        from mcal mcali
        where mcali.m_date >= poitem.due_date
        order by mcali.m_date
       ) as m1
     join mcal on mcal.mday_num = m1.mday_num + isnull(item.dock_time,0)
    ), poitem.due_date))), dbo.Lowdate())
, ''
, 50 -- Incomming supply
, upper(poitem.item)
, dbo.ApsPurchaseOrderQty(poitem.po_num, poitem.po_line, poitem.po_release)
--, case
--   when @Firming = 0
--   then 'Y'
--   else 'N'
--  end
, 'poitem'
, poitem.RowPointer
,1 + --default
           case when Dbo.ApsSetXREFFlag (
                     'P',                    
                     poitem.po_num,          
                     poitem.po_line,         
                     poitem.po_release,      
                     poitem.ref_type,        
                     poitem.ref_num,         
                     poitem.ref_line_suf,    
                     poitem.ref_release,     
                     NULL,                   
                     poitem.item
                     )=1 
                then 524288 -- VAL_ORDFLAG_XREF
                else 0
           end
from TrackRows
   inner join poitem on
      poitem.RowPointer = TrackRows.RowPointer
   inner join po on
      po.po_num = poitem.po_num
   -- Skip non-inventoried items
   inner join item (NOLOCK) on
      item.item = poitem.item
   left outer join MATLDELV000 on
      MATLDELV000.ORDERID = dbo.ApsPurchaseOrderId(poitem.po_num, poitem.po_line, poitem.po_release)
   left join whse on poitem.whse = whse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync poitem'
and MATLDELV000.ORDERID is null
and CHARINDEX( poitem.stat, 'PO') != 0
and dbo.ApsPurchaseOrderQty(poitem.po_num, poitem.po_line, poitem.po_release) > 0
and (whse.whse is null or whse.dedicated_inventory <> 1)
GO