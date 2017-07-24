SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncJobitemOrderSp.sp 11    11/22/05 10:16a Janreu $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncJobitemOrderSp.sp $
 *
 * SL7.04.20 11 90422 Janreu Tue Nov 22 10:16:11 2005
 * Planned production schedules should have an order catagory of -20, but they currently are -40.
 * 90422 -  planned production schedules should have same categories as firm jobs.
 *
 * SL7.04 10 87244 vanmmar Thu May 26 00:22:12 2005
 * 87244
 *
 * SL7.04 9 82303 Janreu Thu Feb 10 14:27:32 2005
 * Job Due Date using Default Times even when Firmed from a PLN created by Planning
 * Add code to use planned date if available.
 * Issue 82303
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncJobitemOrderSp] (
  @Partition uniqueidentifier
)
AS
-- This routine will stage both the demand and supply orders represented by a
-- coproduct job.
-- 
declare
  @ApsParmDemandTime ApsTimeType
, @PlanOnSave ListYesNoType
, @PreserveProductionDates ListYesNoType 

set @PlanOnSave = ISNULL(dbo.DefinedValue('PlanOnSave'),1)

select
  @ApsParmDemandTime = aps_parm.demand_time
from aps_parm 


SELECT @PreserveProductionDates = Preserve_Production_Dates FROM mrp_parm

declare @jobOrder table (
    OrderId nvarchar(63)
   ,Descr nvarchar(40)
   ,MaterialId nvarchar(31)
   ,OrdSize float
   ,LoadSize int
   ,ArivDate datetime
   ,RelDate datetime
   ,DueDate datetime
   ,RequDate datetime
   ,Category int
   ,OrdType int
   ,Flags int
   ,PlanOnlyFg nchar(1)
   ,SchedOnlyFg nchar(1)
   ,AutoPlanFg nchar(1)
   ,Priority smallint
   ,OrderRowPointer uniqueidentifier
   ,lastJSID nvarchar(38)
   ,SupplyOrder nchar(1)
   primary key (OrderId)
)

-- CoProduct Supply Order ------------------------------------------------------

insert into @jobOrder (
    OrderId, Descr, MaterialId, OrdSize, LoadSize,
    ArivDate, RelDate, DueDate, RequDate,
    Category, OrdType, Flags, PlanOnlyFg, SchedOnlyFg,
    AutoPlanFg, Priority, OrderRowPointer)
select
  dbo.ApsCoProductJobOrderId(job.job, job.suffix, jobitem.item)
, case
    when job.type = 'R'
    then 'Supply: Production Schedule'
    else 'Supply: Co-product Job'
  end
, upper(jobitem.item)
, dbo.MaxQty(0, jobitem.qty_released - jobitem.qty_complete - jobitem.qty_scrapped)
, dbo.MaxQty(1, jobitem.qty_released - jobitem.qty_complete - jobitem.qty_scrapped)
, dbo.Lowdate()
, case when mrp_parm.use_sched_times_in_planning = 1 AND dbo.IsScheduled(job.job, job.suffix) = 1 and (ORDPERF000.STARTDATE is not null)
  THEN
   ORDPERF000.STARTDATE
  ELSE
   isnull(job_sch.start_date, dbo.Lowdate())
  END
, case when mrp_parm.use_sched_times_in_planning = 1 AND dbo.IsScheduled(job.job, job.suffix) = 1  and (ORDPERF000.COMPDATE is not null)
  THEN
   ORDPERF000.COMPDATE
  WHEN (datepart (hh,job_sch.end_date) = 0) and (datepart (mi,job_sch.end_date) = 0) and (datepart (ss,job_sch.end_date) = 0)
  THEN
     isnull(dateadd(second,@ApsParmDemandTime,dbo.MidnightOf(job_sch.end_date)),dbo.Lowdate())
  ELSE
     isnull(job_sch.end_date,dbo.Lowdate())
  End
, case when mrp_parm.use_sched_times_in_planning = 1 AND dbo.IsScheduled(job.job, job.suffix) = 1 and (ORDPERF000.COMPDATE is not null)
  THEN
     ORDPERF000.COMPDATE
  WHEN (datepart (hh,job_sch.end_date) = 0) and (datepart (mi,job_sch.end_date) = 0) and (datepart (ss,job_sch.end_date) = 0)
  THEN
     isnull(dateadd(second,@ApsParmDemandTime,dbo.MidnightOf(job_sch.end_date)),dbo.Lowdate())
  ELSE
     isnull(job_sch.end_date,dbo.Lowdate())
  End
, case    
    when (job.stat = 'F' OR (job.type = 'R' AND job.stat = 'P'))
         AND dbo.IsScheduled(job.job, job.suffix) = 0
         AND @PreserveProductionDates = 0
    then -5 -- CriticalSupplyOrders
    else -30 -- JobSupplyNotXRefToCos
  end
, case
    when job.type = 'R'
    then 260 -- Production Order
    else 100 -- Scheduled Work Order
  end
, 1 + -- VAL_ORDFLAGS_SUPPLY
  case 
    when (job.stat = 'R' or ( @PreserveProductionDates = 1 AND job.stat ='F')) AND
         dbo.ApsSetXREFFlag (
             'J',                   
             jobitem.job,           
             jobitem.suffix,        
             NULL,                 
             Jobitem.ord_type,      
             Jobitem.ord_num,       
             Jobitem.ord_line,      
             Jobitem.ord_release,   
             NULL,                  
             Jobitem.item
            ) = 1
   then 524288 -- VAL_ORDFLAG_XREF
   else 0
   end
, 'Y'
, case
    when dbo.ApsPlannerNeedsJob(job.job, job.suffix) = 1
    then 'Y'
    else 'N'
  end
, case
    when  dbo.ApsPlannerNeedsJob(job.job, job.suffix) = 1 AND 
         dbo.ApsSetXREFFlag (
             'J',                   
             jobitem.job,          
             jobitem.suffix,       
             NULL,                 
             Jobitem.ord_type,     
             Jobitem.ord_num,       
             Jobitem.ord_line,      
             Jobitem.ord_release,   
             NULL,                  
             Jobitem.item
            ) = 0 AND 
         @PlanOnSave = 1
    then 'Y'
    else 'N'
  end
, isnull(job_sch.priority,0)
, jobitem.RowPointer
from TrackRows
join jobitem on jobitem.RowPointer = TrackRows.RowPointer
join job on 
   job.job = jobitem.job
   and job.suffix = jobitem.suffix
join job_sch on
   job_sch.job = job.job and 
   job_sch.suffix = job.suffix
join mrp_parm on mrp_parm.parm_key = 0
left join item (NOLOCK) on
   item.item = job.item
LEFT JOIN ORDER000 ON ORDER000.OrderRowPointer = job.RowPointer
LEFT JOIN ORDPERF000 ON ORDPERF000.ORDERID = ORDER000.ORDERID
left join whse on job.whse = whse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync jobitem'
and job.co_product_mix = 1
and jobitem.item <> job.item -- ApsSyncJobOrderSp will handle the main item
and jobitem.qty_released - jobitem.qty_complete - jobitem.qty_scrapped > 0
and job.type not in ('S', 'P')
and job.stat not in ('C', 'H')
and (whse.whse is null or whse.dedicated_inventory <> 1)

update ORDER000
set
   DESCR = jobOrder.descr
  ,PARTID = jobOrder.MaterialId
  ,MATERIALID = jobOrder.MaterialId
  ,ORDSIZE = jobOrder.OrdSize
  ,LOADSIZE = jobOrder.LoadSize
  ,ARIVDATE = jobOrder.ArivDate
  ,RELDATE = jobOrder.RelDate
  ,DUEDATE = jobOrder.DueDate
  ,REQUDATE = jobOrder.RequDate
  ,CATEGORY = jobOrder.Category
  ,ORDTYPE = jobOrder.OrdType
  ,FLAGS = jobOrder.Flags
  ,PLANONLYFG = jobOrder.PlanOnlyFg
  ,SCHEDONLYFG = jobOrder.SchedOnlyFg
  ,PRIORITY = jobOrder.Priority
from @jobOrder joborder
join ORDER000 on ORDER000.ORDERID = joborder.OrderId

insert into ORDER000
   (ORDERID, DESCR, PARTID, MATERIALID, ORDSIZE, LOADSIZE,
    ARIVDATE, RELDATE, DUEDATE, REQUDATE,
    CATEGORY, ORDTYPE, FLAGS,
    PLANONLYFG, SCHEDONLYFG, AUTOPLANFG, Priority,
    OrderTable, OrderRowPointer)
select
   OrderId = jobOrder.Orderid
  ,DESCR = jobOrder.descr
  ,PARTID = jobOrder.MaterialId
  ,MATERIALID = jobOrder.MaterialId
  ,ORDSIZE = jobOrder.OrdSize
  ,LOADSIZE = jobOrder.LoadSize
  ,ARIVDATE = jobOrder.ArivDate
  ,RELDATE = jobOrder.RelDate
  ,DUEDATE = jobOrder.DueDate
  ,REQUDATE = jobOrder.RequDate
  ,CATEGORY = jobOrder.Category
  ,ORDTYPE = jobOrder.OrdType
  ,FLAGS = jobOrder.Flags
  ,PLANONLYFG = jobOrder.PlanOnlyFg
  ,SCHEDONLYFG = jobOrder.SchedOnlyFg
  ,AutoPlanFG = jobOrder.AutoPlanFg
  ,PRIORITY = jobOrder.Priority
  ,OrderTable = 'jobitem'
  ,OrderRowPointer = jobOrder.orderrowpointer
from @jobOrder joborder
left join ORDER000 on ORDER000.ORDERID = joborder.OrderId
where
   ORDER000.ORDERID is null

GO