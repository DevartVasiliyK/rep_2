SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncForecastOrderSp.sp 3     5/26/05 12:22a vanmmar $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncForecastOrderSp.sp $
 *
 * SL7.04 3 87244 vanmmar Thu May 26 00:22:11 2005
 * 87244
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncForecastOrderSp] (
  @Partition uniqueidentifier
)
AS
declare
  @ApsParmDemandTime ApsTimeType

-- Only pass forecasts to APS if so specified
if exists(select * from mrp_parm where mrp_parm.req_src = 'C')
   return

declare @Forecast table (
  Item nvarchar(40)
, OrdSize float(8)
, LoadSize int
, DueDate datetime
, OrderId nvarchar(80)
, Flags int
, OrderRowPointer uniqueidentifier
primary key (OrderId)
)

select
  @ApsParmDemandTime = aps_parm.demand_time
from aps_parm 

insert into @Forecast (
   OrderId, Item, OrdSize, LoadSize, DueDate, Flags, OrderRowPointer)
select
    dbo.ApsForecastOrderId(forecast.item, forecast.fcst_date)
   ,upper(forecast.item)
   ,forecast.avail_qty
   ,dbo.MaxQty(1, forecast.avail_qty)
   ,isnull(dateadd(second, @ApsParmDemandTime, dbo.MidnightOf(forecast.fcst_date)), dbo.Lowdate())
   ,dbo.ApsForecastOrderFlags()
   ,forecast.rowpointer
from TrackRows
join forecast on forecast.RowPointer = TrackRows.RowPointer
join item (NOLOCK) on item.item = forecast.item
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync forecast'
and item.mps_flag = 0
and forecast.avail_qty > 0

update ORDER000
set
    PARTID = forecast.item
   ,MATERIALID = forecast.item
   ,ORDSIZE = forecast.OrdSize
   ,LOADSIZE = forecast.LoadSize
   ,DUEDATE = forecast.DueDate
   ,REQUDATE = forecast.DueDate
   ,CATEGORY = dbo.ApsPriorityOf(6) -- ForecastDemand
   ,FLAGS = forecast.flags
from @Forecast forecast
join ORDER000 on ORDER000.ORDERID = forecast.OrderId

insert into ORDER000
   (ORDERID, DESCR, PARTID, MATERIALID, ORDSIZE, LOADSIZE,
    ARIVDATE, RELDATE, DUEDATE, REQUDATE,
    CATEGORY, ORDTYPE, FLAGS, CUSTOMER,
    PLANONLYFG, SCHEDONLYFG, PROCPLANID,
    OrderTable, OrderRowPointer)
select
    ORDERID = forecast.OrderId
   ,DESCR = 'Forecast'
   ,PARTID = forecast.item
   ,MATERIALID = forecast.item
   ,ORDSIZE = forecast.OrdSize
   ,LOADSIZE = forecast.LoadSize
   ,ARIVDATE = dbo.Lowdate()
   ,RELDATE = dbo.Lowdate()
   ,DUEDATE = forecast.DueDate
   ,REQUDATE = forecast.DueDate
   ,CATEGORY = dbo.ApsPriorityOf(6) -- ForecastDemand
   ,ORDTYPE = 300 -- Forecast Order
   ,FLAGS = forecast.flags
   ,CUSTOMER = ''
   ,PLANONLYFG = 'Y'
   ,SCHEDONLYFG = 'N'
   ,PROCPLANID = ''
   ,OrderTable = 'forecast'
   ,OrderRowPointer = forecast.OrderRowPointer
from @Forecast forecast
left join ORDER000 on ORDER000.ORDERID = forecast.OrderId
where ORDER000.ORDERID is null
GO