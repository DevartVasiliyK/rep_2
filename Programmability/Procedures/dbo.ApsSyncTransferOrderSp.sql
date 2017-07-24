SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncTransferOrderSp.sp 8     5/26/05 12:22a vanmmar $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncTransferOrderSp.sp $
 *
 * SL7.04 8 87244 vanmmar Thu May 26 00:22:16 2005
 * 87244
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncTransferOrderSp] (
  @Partition uniqueidentifier
)
AS
-- This routine will stage a transfer order whether incomming or outgoing.
-- 
declare
  @ParmsSite SiteType
, @ApsParmDemandTime ApsTimeType
, @ApsParmSupplyTime ApsTimeType
, @PlanOnSave ListYesNoType

set @PlanOnSave = ISNULL(dbo.DefinedValue('PlanOnSave'),1)

select
  @ParmsSite = parms.site
from parms 

select
  @ApsParmDemandTime = aps_parm.demand_time
, @ApsParmSupplyTime = aps_parm.supply_time
from aps_parm 

update ORDER000
set
  DESCR = ''
, PARTID = upper(trnitem.item)
, MATERIALID = upper(trnitem.item)
, ORDSIZE = trnitem.qty_req - trnitem.qty_shipped
, LOADSIZE = dbo.MaxQty(1, trnitem.qty_req - trnitem.qty_shipped)
, ARIVDATE = dbo.Lowdate()
, RELDATE = dbo.Lowdate()
, DUEDATE = isnull( dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(trnitem.sch_ship_date)), dbo.Lowdate())
, REQUDATE = isnull( dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(trnitem.sch_ship_date)), dbo.Lowdate())
, CATEGORY = aps_seq.priority
, ORDTYPE = 270 -- Transfer Order
, FLAGS = 0
, CUSTOMER = ''
, PLANONLYFG = 'Y'
, SCHEDONLYFG = 'N'
, PROCPLANID = ''
, OrderTable = 'trnitem'
, OrderRowPointer = trnitem.RowPointer
, REFORDERID = Dbo.ApsGetXRefOrderID (
              Trnitem.frm_ref_type,      
              Trnitem.frm_ref_num,       
              Trnitem.frm_ref_line_suf,  
              Trnitem.frm_ref_release,   
              'T',                       
              Trnitem.trn_num,           
              Trnitem.trn_line,         
              NULL,                     
              NULL,                      
              Trnitem.item              
              )

from TrackRows
   inner join trnitem on
      trnitem.RowPointer = TrackRows.RowPointer
   inner join item (NOLOCK) on
      item.item = trnitem.item
   inner join ORDER000 on
      ORDER000.ORDERID = dbo.ApsTransferOutOrderId(trnitem.trn_num, trnitem.trn_line) 
   inner join aps_seq on
      aps_seq.order_code = 3 -- TransferOrderDemand
   inner join whse fromwhse
     on trnitem.from_whse = fromwhse.whse
   inner join whse towhse
     on trnitem.to_whse = towhse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync trnitem'
and trnitem.stat != 'C' -- Only consider OPEN orders
and trnitem.qty_req - trnitem.qty_shipped > 0
and trnitem.from_site = @ParmsSite
and fromwhse.dedicated_inventory <> 1
and (trnitem.to_site <> @ParmsSite or towhse.dedicated_inventory = 1)


insert into ORDER000
   (ORDERID, DESCR, PARTID, MATERIALID, ORDSIZE, LOADSIZE,
    ARIVDATE, RELDATE, DUEDATE, REQUDATE,
    CATEGORY, ORDTYPE, FLAGS, CUSTOMER,
    PLANONLYFG, SCHEDONLYFG, PROCPLANID, AUTOPLANFG,
    OrderTable, OrderRowPointer,REFORDERID )
select
  dbo.ApsTransferOutOrderId(trnitem.trn_num, trnitem.trn_line) 
, ''
, upper(trnitem.item)
, upper(trnitem.item)
, trnitem.qty_req - trnitem.qty_shipped
, dbo.MaxQty(1, trnitem.qty_req - trnitem.qty_shipped)
, dbo.Lowdate()
, dbo.Lowdate()
, isnull( dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(trnitem.sch_ship_date)), dbo.Lowdate())
, isnull( dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(trnitem.sch_ship_date)), dbo.Lowdate())
, aps_seq.priority
, 270 -- Transfer Order
, 0
, ''
, 'Y'
, 'N'
, ''
, CASE when @PlanOnSave = 1 then 'Y' else 'N' end 
, 'trnitem'
, trnitem.RowPointer
, Dbo.ApsGetXRefOrderID (
      Trnitem.frm_ref_type,       
      Trnitem.frm_ref_num,        
      Trnitem.frm_ref_line_suf,   
      Trnitem.frm_ref_release,    
      'T',                        
      Trnitem.trn_num,            
      Trnitem.trn_line,           
      NULL,                       
      NULL,                       
      Trnitem.item                
      )
from TrackRows
   inner join trnitem on
      trnitem.RowPointer = TrackRows.RowPointer
   inner join item (NOLOCK) on
      item.item = trnitem.item
   left outer join ORDER000 on
      ORDER000.ORDERID = dbo.ApsTransferOutOrderId(trnitem.trn_num, trnitem.trn_line) 
   inner join aps_seq on
      aps_seq.order_code = 3 -- TransferOrderDemand
   inner join whse fromwhse
     on trnitem.from_whse = fromwhse.whse
   inner join whse towhse
     on trnitem.to_whse = towhse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync trnitem'
and ORDER000.ORDERID is null
and trnitem.stat != 'C' -- Only consider OPEN orders
and trnitem.qty_req - trnitem.qty_shipped > 0
and trnitem.from_site = @ParmsSite
and fromwhse.dedicated_inventory <> 1
and (trnitem.to_site <> @ParmsSite or towhse.dedicated_inventory = 1)

update MATLDELV000
set
  CATEGORY = -30 -- JobSupplyNotXRefToCos
, CUSTOMER = ''
, DELVDATE = isnull( dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(trnitem.sch_rcv_date)), dbo.Lowdate())
, DESCR = ''
, ORDTYPE = 50 -- Incomming supply
, MATERIALID = upper(trnitem.item)
, AMOUNT = trnitem.qty_req - trnitem.qty_received
, OrderTable = 'trnitem'
, OrderRowPointer = trnitem.RowPointer
, FLAGS =  1 + --default
           case when Dbo.ApsSetXREFFlag (
                     'T',                      
                     trnitem.trn_num,          
                     trnitem.trn_line,         
                     NULL,                     
                     trnitem.to_ref_type,      
                     trnitem.to_ref_num,       
                     trnitem.to_ref_line_suf,  
                     trnitem.to_ref_release,   
                     NULL,                     
                     trnitem.item
                     )=1 
                then 524288 -- VAL_ORDFLAG_XREF
                else 0
           end
from TrackRows
   inner join trnitem on
      trnitem.RowPointer = TrackRows.RowPointer
   inner join item (NOLOCK) on
      item.item = trnitem.item
   inner join MATLDELV000 on
      MATLDELV000.ORDERID = dbo.ApsTransferInOrderId(trnitem.trn_num, trnitem.trn_line)
   inner join whse fromwhse
     on trnitem.from_whse = fromwhse.whse
   inner join whse towhse
     on trnitem.to_whse = towhse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync trnitem'
and trnitem.stat != 'C' -- Only consider OPEN orders
and trnitem.qty_req - trnitem.qty_received > 0
and trnitem.to_site = @ParmsSite
and towhse.dedicated_inventory <> 1
and (trnitem.from_site <> @ParmsSite or fromwhse.dedicated_inventory = 1)


insert into MATLDELV000
   (ORDERID, CATEGORY, CUSTOMER, DELVDATE, DESCR, ORDTYPE,
    MATERIALID, AMOUNT, --AUTOPLANFG,
    OrderTable, OrderRowPointer,FLAGS)
select
  dbo.ApsTransferInOrderId(trnitem.trn_num, trnitem.trn_line)
, -30 -- JobSupplyNotXRefToCos
, ''
, isnull( dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(trnitem.sch_rcv_date)), dbo.Lowdate())
, ''
, 50 -- Incomming supply
, upper(trnitem.item)
, trnitem.qty_req - trnitem.qty_received
--, case
--   when @Firming = 0
--   then 'Y'
--   else 'N'
--  end
, 'trnitem'
, trnitem.RowPointer
, 1 + --default
           case when Dbo.ApsSetXREFFlag (
                     'T',                      
                     trnitem.trn_num,          
                     trnitem.trn_line,         
                     NULL,                     
                     trnitem.to_ref_type,      
                     trnitem.to_ref_num,       
                     trnitem.to_ref_line_suf,  
                     trnitem.to_ref_release,   
                     NULL,                     
                     trnitem.item
                     )=1 
                then 524288 -- VAL_ORDFLAG_XREF
                else 0
                end 
from TrackRows
   inner join trnitem on
      trnitem.RowPointer = TrackRows.RowPointer
   inner join item (NOLOCK) on
      item.item = trnitem.item
   left outer join MATLDELV000 on
      MATLDELV000.ORDERID = dbo.ApsTransferInOrderId(trnitem.trn_num, trnitem.trn_line)
   inner join whse fromwhse
     on trnitem.from_whse = fromwhse.whse
   inner join whse towhse
     on trnitem.to_whse = towhse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync trnitem'
and MATLDELV000.ORDERID is null
and trnitem.stat != 'C' -- Only consider OPEN orders
and trnitem.qty_req - trnitem.qty_received > 0
and trnitem.to_site = @ParmsSite
and towhse.dedicated_inventory <> 1
and (trnitem.from_site <> @ParmsSite or fromwhse.dedicated_inventory = 1)
GO