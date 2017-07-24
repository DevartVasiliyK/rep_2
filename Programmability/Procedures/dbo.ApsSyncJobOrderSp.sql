SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncJobOrderSp.sp 26    2/27/06 2:06p Janreu $  */

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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncJobOrderSp.sp $
 *
 * SL7.04.20 26 91438 Janreu Mon Feb 27 14:06:12 2006
 * Job supply is not recognized by the planner when all operations are marked complete but the last operation doesn't show the pcs"moved"
 * 91438
 *
 * SL7.04.20 25 90422 Janreu Tue Nov 22 10:16:31 2005
 * Planned production schedules should have an order catagory of -20, but they currently are -40.
 * 90422 -  planned production schedules should have same categories as firm jobs.
 *
 * SL7.04 24 87244 vanmmar Thu May 26 00:22:12 2005
 * 87244
 *
 * SL7.04 23 79586 Grosphi Thu Apr 14 11:15:21 2005
 * made changes to avoid index scans
 *
 * SL7.04 22 82303 Janreu Thu Feb 10 14:29:21 2005
 * Job Due Date using Default Times even when Firmed from a PLN created by Planning
 * Add code to use planned date if available.
 * Issue 82303
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncJobOrderSp] (
  @Partition uniqueidentifier
)
AS
-- This routine will stage both the demand and supply orders represented by a
-- job.
--
declare
  @ApsParmDemandTime ApsTimeType
, @PlanOnSave ListYesNoType
, @PreserveProductionDates ListYesNoType
, @planplannedps ListYesNoType


SELECT @PreserveProductionDates = Preserve_Production_Dates,@planplannedps=plan_planned_ps FROM mrp_parm

set @PlanOnSave = ISNULL(dbo.DefinedValue('PlanOnSave'),1)

select
  @ApsParmDemandTime = aps_parm.demand_time
from aps_parm

declare @jobOrder table (
    OrderId nvarchar(63)
   ,job nvarchar(20)
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
   ,ProcPlanId nvarchar(36)
   ,AutoPlanFg nchar(1)
   ,Priority smallint
   ,OrderRowPointer uniqueidentifier
   ,lastJSID nvarchar(38)
   ,SupplyOrder nchar(1)
   primary key (OrderId)
)

insert into @jobOrder (
    OrderId,job, Descr, MaterialId, OrdSize, LoadSize,
    ArivDate, RelDate, DueDate, RequDate,
    Category, OrdType, Flags, PlanOnlyFg, SchedOnlyFg, ProcPlanId,
    AutoPlanFg, Priority, OrderRowPointer,LastJSID)
select
   OrderId = dbo.ApsJobOrderId(job.job, job.suffix)
  ,job = job.job
  ,DESCR =
    CASE
       WHEN job.type != 'R'
       THEN 'Job'
       ELSE 'Production Schedule'
    END
  ,MATERIALID = upper(job.item)
  ,ORDSIZE = dbo.MaxQty(0, job.qty_released - job.qty_complete - job.qty_scrapped)
  ,LOADSIZE = dbo.MaxQty(1, job.qty_released - job.qty_complete - job.qty_scrapped)
   ,ARIVDATE = isnull(dbo.MidnightOf(job.job_date), dbo.Lowdate())

   ,RELDATE = case when mrp_parm.use_sched_times_in_planning = 1 AND dbo.IsScheduled(job.job, job.suffix) = 1 and  (ORDPERF000.STARTDATE is not null)
   THEN
    ORDPERF000.STARTDATE
   ELSE
    isnull(job_sch.start_date, dbo.Lowdate())
   END
   ,DUEDATE = case when mrp_parm.use_sched_times_in_planning = 1 AND dbo.IsScheduled(job.job, job.suffix) = 1  and (ORDPERF000.COMPDATE is not null)
   THEN
     ORDPERF000.COMPDATE
   WHEN (datepart (hh,job_sch.end_date) = 0) and (datepart (mi,job_sch.end_date) = 0) and (datepart (ss,job_sch.end_date) = 0)
   THEN
     isnull(dateadd(second,@ApsParmDemandTime,dbo.MidnightOf(job_sch.end_date)),dbo.Lowdate())
   ELSE
     isnull(job_sch.end_date,dbo.Lowdate())
   END
   ,REQUDATE = case when mrp_parm.use_sched_times_in_planning = 1 AND dbo.IsScheduled(job.job, job.suffix) = 1  and (ORDPERF000.COMPDATE is not null)
   THEN
    ORDPERF000.COMPDATE
   WHEN (datepart (hh,job_sch.end_date) = 0) and (datepart (mi,job_sch.end_date) = 0) and (datepart (ss,job_sch.end_date) = 0)
   THEN
    isnull(dateadd(second,@ApsParmDemandTime,dbo.MidnightOf(job_sch.end_date)),dbo.Lowdate())
   ELSE
     isnull(job_sch.end_date,dbo.Lowdate())
   END

  ,CATEGORY =
    CASE
       when (job.stat = 'F' OR (job.type = 'R' AND job.stat = 'P'))
            AND @PreserveProductionDates = 0
       THEN -20 -- CriticalDemandOrders
       ELSE -40 -- UnscheduledJobDemand
    END
  ,ORDTYPE =
    CASE
       WHEN job.stat = 'P'
       THEN 260 -- Planned PS Work Order
       WHEN job.stat = 'F'
       THEN 240 -- Firmed Work Order
       WHEN job.stat = 'R' AND dbo.IsScheduled(job.job, job.suffix) = 0
       THEN 250 -- Released and UnScheduled Work Order
       WHEN job.stat = 'R' AND dbo.IsScheduled(job.job, job.suffix) = 1
       THEN 100 -- Released and UnScheduled Work Order
       ELSE 0
    END
  ,FLAGS =
    64 + -- VAL_ORDFLAGS_NOFIN
    128 + -- VAL_ORDFLAGS_NOSUP
    512 + -- VAL_ORDFLAGS_NOSCRAP
    1024 + --  VAL_ORDFLAGS_NOLOTSIZE
    CASE
       WHEN (job.stat = 'F' OR job.type = 'R' AND job.stat = 'P' ) AND
            (mrp_parm.preserve_production_dates = 0) AND
            (whse.whse is null or whse.dedicated_inventory <> 1)
       THEN 256 -- VAL_ORDFLAGS_REPLENISH
       ELSE 0

    END +
    CASE
       WHEN (dbo.ApsFixedJobSupply(job.job, job.suffix) = 1) AND
            (whse.whse is null or whse.dedicated_inventory <> 1)
       THEN 1048576
       ELSE 0
     END +  -- VAL_ORDFLAGS_FIXEDSUPPLY
     CASE
       WHEN dbo.ApsFixedJobSupply(job.job, job.suffix) = 1
       THEN 2097152
       ELSE 0
     END +  -- VAL_ORDFLAGS_FIXEDDEMANDS
     CASE
       WHEN dbo.ApsIsJobFrozen(job.job, job.suffix) = 1
       THEN 4096
       ELSE 0
     END +  -- VAL_ORDFLAGS_FROZEN
     CASE
       WHEN ((job.stat = 'F' or job.stat = 'R') AND
             dbo.ApsSetXREFFlag(
                 'J',
                 job.job,
                 job.suffix,
                 NULL,
                 case when job.ref_job is not null then 'J'else job.ord_type end,
                 case when job.ref_job is not null then job.ref_job else job.ord_num end,
                 case when job.ref_job is not null then job.ref_suf else job.ord_line end,
                 case when job.ref_job is not null then job.ref_oper else job.ord_release end,
                 case when job.ref_job is not null then job.ref_seq else NULL end,
                 job.item
                 ) = 1 )
       THEN 524288
       ELSE 0
     END
  ,PLANONLYFG =
   CASE
       WHEN dbo.ApsSchedulerNeedsJob(job.job, job.suffix) = 1
       THEN 'N'
       ELSE 'Y'
   END
  ,SCHEDONLYFG =
    case
       when dbo.ApsPlannerNeedsJob(job.job, job.suffix) = 1
       then 'N'
       else 'Y'
    end
  ,PROCPLANID =
    case
       when exists(select * from jobroute
                   where jobroute.job = job.job and jobroute.suffix = job.suffix)
       then dbo.ApsRouteId(job.job, job.suffix)
       when item.job is not null
       then
   -- Select the  current route
           dbo.ApsRouteId(item.job, 0)
       else ''
    end
  ,AutoPlanFg =
    case
       when dbo.ApsPlannerNeedsJob(job.job, job.suffix) = 1 AND
            dbo.ApsSetXREFFlag(
                 'J',
                 job.job,
                 job.suffix,
                 NULL,
                 case when job.ref_job is not null then 'J'else job.ord_type end,
                 case when job.ref_job is not null then job.ref_job else job.ord_num end,
                 case when job.ref_job is not null then job.ref_suf else job.ord_line end,
                 case when job.ref_job is not null then job.ref_oper else job.ord_release end,
                 case when job.ref_job is not null then job.ref_seq else NULL end,
                 job.item
                 ) = 0 AND
            @PlanOnSave = 1
       then 'Y'
       else 'N'
    end
  ,Priority =
    case
       when job.type = 'R'
       then dbo.ApsSetPrioritySp (260)  -- set priority of PS orders
       else isnull(job_sch.priority,0)
    end
  ,OrderRowPointer = job.RowPointer
  ,lastJSID =
      dbo.ApsOperationId(job.job, job.suffix,
         (select top 1 jobroute.oper_num
          from jobroute
          where
            jobroute.job = job.job
            and jobroute.suffix = job.suffix
          order by jobroute.oper_num desc))
from TrackRows
join job (NOLOCK) on job.RowPointer = TrackRows.RowPointer
join job_sch (NOLOCK) on
   job_sch.job = job.job and
   job_sch.suffix = job.suffix
join item (NOLOCK) on
   item.item = job.item
join mrp_parm (NOLOCK) on mrp_parm.parm_key = 0
left join jobitem (NOLOCK) on
   jobitem.job = job.job
   and jobitem.suffix = job.suffix
   and jobitem.item = job.item
LEFT JOIN ORDER000 (NOLOCK) ON ORDER000.OrderRowPointer = job.RowPointer
LEFT JOIN ORDPERF000 (NOLOCK) ON ORDPERF000.ORDERID = ORDER000.ORDERID
left join whse on job.whse = whse.whse
where TrackRows.SessionId = @Partition
and TrackRows.TrackedOperType = 'Sync job'
and (job.co_product_mix = 0 or jobitem.job is not null)
and job.type not in ('S', 'P')
and job.stat not in ('C', 'H')

-- Create a Simulated part for the scheduler
insert into MATL000 (
   MATERIALID, CAPACITY, SCHEDONLYFG)
select
  jobOrder.OrderId
, 999999999
, 'Y'
from @jobOrder joborder
left join MATL000 (NOLOCK) on
   MATL000.MATERIALID = jobOrder.ORDERID
where
   MATL000.MATERIALID is null
   and jobOrder.PlanOnlyFg != 'Y'

-- Create a negative (supply) BOM entry for the scheduler
update BOM000 set
   QUANTITY = - jobOrder.OrdSize
from @jobOrder jobOrder
join BOM000 (NOLOCK) on
   BOM000.PROCPLANID = jobOrder.procplanid and
--   BOM000.JSID = jobOrder.lastJSID and
   BOM000.MATERIALID = jobOrder.OrderId and
   BOM000.QUANCD = 'L'
where
   jobOrder.PlanOnlyFg != 'Y'
   AND QUANTITY <> - jobOrder.OrdSize
   AND jobOrder.lastJSID IS NOT NULL
option(force order)

insert into BOM000 (
   PROCPLANID, JSID, MATERIALID, QUANCD, QUANTITY)
select
     jobOrder.procplanid
   , jobOrder.lastJSID
   , jobOrder.ORDERID
   , 'L'
   , - jobOrder.OrdSize
from @jobOrder jobOrder
left join BOM000 (NOLOCK) on
   BOM000.PROCPLANID = jobOrder.procplanid and
--   BOM000.JSID = jobOrder.lastJSID and
   BOM000.MATERIALID = jobOrder.OrderId and
   BOM000.QUANCD = 'L'
where
   BOM000.PROCPLANID is null
   AND jobOrder.PlanOnlyFg != 'Y'
   AND jobOrder.lastJSID IS NOT NULL

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
  ,PROCPLANID = jobOrder.ProcPlanId
  ,PRIORITY = jobOrder.Priority
from @jobOrder joborder
join ORDER000 (NOLOCK) on ORDER000.ORDERID = joborder.OrderId
WHERE ORDER000.DESCR <> jobOrder.descr
  OR ORDER000.PARTID <> jobOrder.MaterialId
  OR ORDER000.MATERIALID <> jobOrder.MaterialId
  OR ORDER000.ORDSIZE <> jobOrder.OrdSize
  OR ORDER000.LOADSIZE <> jobOrder.LoadSize
  OR ORDER000.ARIVDATE <> jobOrder.ArivDate
  OR ORDER000.RELDATE <> jobOrder.RelDate
  OR ORDER000.DUEDATE <> jobOrder.DueDate
  OR ORDER000.REQUDATE <> jobOrder.RequDate
  OR ORDER000.CATEGORY <> jobOrder.Category
  OR ORDER000.ORDTYPE <> jobOrder.OrdType
  OR ORDER000.FLAGS <> jobOrder.Flags
  OR ORDER000.PLANONLYFG <> jobOrder.PlanOnlyFg
  OR ORDER000.SCHEDONLYFG <> jobOrder.SchedOnlyFg
  OR ORDER000.PROCPLANID <> jobOrder.ProcPlanId
  OR ORDER000.PRIORITY <> jobOrder.Priority

insert into ORDER000
   (ORDERID, DESCR, PARTID, MATERIALID, ORDSIZE, LOADSIZE,
    ARIVDATE, RELDATE, DUEDATE, REQUDATE,
    CATEGORY, ORDTYPE, FLAGS,
    PLANONLYFG, SCHEDONLYFG, PROCPLANID, AUTOPLANFG, Priority,
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
  ,PROCPLANID = jobOrder.ProcPlanId
  ,AutoPlanFG = jobOrder.AutoPlanFg
  ,PRIORITY = jobOrder.Priority
  ,OrderTable = 'job'
  ,OrderRowPointer = jobOrder.orderrowpointer
from @jobOrder joborder
left join ORDER000 (NOLOCK) on ORDER000.ORDERID = joborder.OrderId
where
   ORDER000.ORDERID is null

insert into ORDATTR000
   ( ORDERID
    ,ATTID
    ,ATTVALUE)
select
   OrderId = jobOrder.Orderid
  ,ATTID = 'PS'
  ,ATTVALUE = dbo.ApsPSAttribid(joborder.job,0) -- Suffix = 0 is PS Item Job
from @jobOrder joborder
left join ORDATTR000 (NOLOCK) on ORDATTR000.ORDERID = joborder.OrderId
where
   ORDATTR000.ORDERID is null and
   joborder.DESCR = 'Production Schedule' and
   jobOrder.SchedOnlyFg = 'N'

RETURN 0
GO