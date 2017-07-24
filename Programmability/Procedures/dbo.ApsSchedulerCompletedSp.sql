SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 
/*
** Stub stored procedure that is automatically called
** after the APS Scheduler has completed.
*/

/* $Header: /ApplicationDB/Stored Procedures/ApsSchedulerCompletedSp.sp 16    4/24/06 1:58p Janreu $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSchedulerCompletedSp.sp $
 *
 * SL7.04.20 16 92873 Janreu Mon Apr 24 13:58:48 2006
 * Job materials are being planned after they have been removed from the job.
 * 92873 - Changed ApsSyncBomEffectivitySp, and calls to it, to be based off of changes to jobroute now, instead of jobmatl.
 *
 * SL7.04.20 15 92835 Hcl-jainami Tue Apr 18 13:15:12 2006
 * Backport RS 3020 from 7.05 back to 7.04
 * Checked-in for issue 92835.
 *
 * SL7.04.11 14 92338 Janreu Wed Mar 15 09:09:27 2006
 * Job operation start and end times are misleading when offset hours are used in Scheduling.
 * TRK 92338
 *
 * SL7.04 14 92338 hoffjoh Tue Mar 14 14:31:14 2006
 * Job operation start and end times are misleading when offset hours are used in Scheduling.
 * TRK 92338
 *
 * SL7.04 13 89230 hoffjoh Wed Sep 14 10:59:01 2005
 * TRK 89230 - Limited these procedures to only run on AltNo = 0.  Also, updated ApsPlannerStartSp to correctly handle incremental planning.
 *
 * SL7.04 12 86374 Hcl-haldsub Tue Mar 15 05:34:57 2005
 * Traditional MRP
 * ISSUE 86734
 * RS2405
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSchedulerCompletedSp] (
  @AltNo SMALLINT
) AS

DECLARE
  @Severity   INT
, @PlanningMode  ApsModeType

SET @Severity = 0

if @AltNo <> 0 return @Severity

-- Update orders for change in scheduledness
UPDATE ORDER000 SET 
   FLAGS = ORDER000.FLAGS | 4096 -- VAL_ORDFLAGS_FROZEN
FROM RESSCHD000 AS res
JOIN JOB000 ON res.JOBTAG = JOB000.JOBTAG
JOIN ORDIND000 AS oi ON JOB000.ORDERTAG = oi.ORDERTAG
JOIN ORDER000 AS supplyord ON oi.ORDERID = supplyord.ORDERID
join job on job.rowpointer = supplyord.orderrowpointer
join ORDER000 on
 ORDER000.ORDERID = dbo.ApsJobOrderId(job.job, job.suffix)
where ORDER000.SchedOnlyFg = 'N'
and dbo.ApsFixedJobSupply(job.job, job.suffix) = 0

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

UPDATE ORDER000 SET 
   FLAGS = ORDER000.FLAGS | 4096 -- VAL_ORDFLAGS_FROZEN
FROM RESSCHD000 AS res
JOIN JOB000 ON res.JOBTAG = JOB000.JOBTAG
JOIN ORDIND000 AS oi ON JOB000.ORDERTAG = oi.ORDERTAG
JOIN ORDER000 AS supplyord ON oi.ORDERID = supplyord.ORDERID
join jobitem on jobitem.rowpointer = supplyord.orderrowpointer
join job on job.job = jobitem.job and job.suffix = jobitem.suffix
join ORDER000 on
 ORDER000.ORDERID = dbo.ApsJobOrderId(job.job, job.suffix)
where ORDER000.SchedOnlyFg = 'N'
and dbo.ApsFixedJobSupply(job.job, job.suffix) = 0

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

declare @Partition uniqueidentifier
set @Partition = isnull(dbo.DefinedValue('ApsSyncDeferred'),newid())

-- Update bills and routes for change in scheduledness
declare @PlanJob table (
   job nvarchar(20)
  ,suffix smallint
  ,item nvarchar(30)
  ,Bom int
  ,Route int
   primary key (job, suffix)
   )

insert into @PlanJob
select job, suffix, item,
dbo.ApsPlannerNeedsBom(job,suffix),
dbo.ApsPlannerNeedsRoute(job,suffix)
from job
where 
   job.stat not in ('H','C')
   and job.type not in ('S','P')

delete PBOM000
from @PlanJob PlanJob
join PBOM000 on PBOM000.BOMID = dbo.ApsBomId(planjob.job, planjob.suffix)
where PlanJob.Bom = 0

delete MATLPBOMS000
from @PlanJob PlanJob
join MATLPBOMS000 on
   MATLPBOMS000.MATERIALID = planjob.item
   and MATLPBOMS000.PBOMID = dbo.ApsBomId(planjob.job, planjob.suffix)
where PlanJob.Bom = 0

delete PBOMMATLS000
from @PlanJob PlanJob
join PBOMMATLS000 on
   PBOMMATLS000.BOMID = dbo.ApsBomId(planjob.job, planjob.suffix)
where PlanJob.Bom = 0

update PROCPLN000 set
   SchedOnlyFg = 'Y'
from @PlanJob PlanJob
join PROCPLN000 on PROCPLN000.PROCPLANID = dbo.ApsRouteId(planjob.job, planjob.suffix)
where planjob.route = 0
   and PROCPLN000.SchedOnlyFg <> 'Y'

delete MATLPPS000
from @PlanJob PlanJob
join MATLPPS000 on
   MATLPPS000.PROCPLANID = dbo.ApsRouteId(planjob.job, planjob.suffix)
   and MATLPPS000.MATERIALID = planjob.item
where planjob.route = 0

insert into TrackRows (
   SessionId, RowPointer, TrackedOperType)
select
   @Partition
   ,jobmatl.rowpointer
   ,'Sync jobmatl'      
from jobmatl
join @PlanJob planjob on 
   planjob.job = jobmatl.job
   and planjob.suffix = jobmatl.suffix
   and planjob.bom = 1
where not exists( select * from TrackRows where SessionId = @Partition and RowPointer = jobmatl.RowPointer)

if dbo.VariableIsDefined('ApsSyncDeferred') = 0
begin
   exec ApsSyncBomPrtSp @Partition
   delete TrackRows where SessionId = @Partition
end

insert into TrackRows (
   SessionId, RowPointer, TrackedOperType)
select
   @Partition
   ,jobroute.rowpointer
   ,'Sync jobroute'
from jobroute
join @PlanJob planjob on 
   planjob.job = jobroute.job
   and planjob.suffix = jobroute.suffix
   and planjob.route = 1
join job on job.job = jobroute.job and job.suffix = jobroute.suffix
join item on item.item = job.item and item.mrp_part = 0
where not exists( select * from TrackRows where SessionId = @Partition and RowPointer = jobroute.RowPointer)

if dbo.VariableIsDefined('ApsSyncDeferred') = 0
begin
   exec ApsSyncRouteEffectivitySp @Partition
   exec ApsSyncBomEffectivitySp @Partition
   exec ApsSyncRouteOprSp @Partition
   delete TrackRows where SessionId = @Partition
end

insert into TrackRows (
   SessionId, RowPointer, TrackedOperType)
select
   @Partition
   ,job.rowpointer
   ,'Sync job'
from job
where not exists( select * from TrackRows where SessionId = @Partition and RowPointer = job.RowPointer)
and job.type not in ('S', 'P')
and job.stat in ('F', 'R', 'S')

if dbo.VariableIsDefined('ApsSyncDeferred') = 0
begin
   exec ApsSyncJobOrderSp @Partition
   delete TrackRows where SessionId = @Partition
end

Insert into TrackRows (
   SessionId, RowPointer, TrackedOperType)
select
   @Partition
   ,jobitem.rowpointer
   ,'Sync jobitem'
from jobitem 
join job on 
   job.job = jobitem.job
   and job.suffix = jobitem.suffix
where not exists( select * from TrackRows where SessionId = @Partition and RowPointer = jobitem.RowPointer)
and job.type not in ('S', 'P')
and job.stat not in ('C', 'H')

if dbo.VariableIsDefined('ApsSyncDeferred') = 0
begin
   exec ApsSyncJobitemOrderSp @Partition
   delete TrackRows where SessionId = @Partition
end

--  Show scheduler results for the jobs
--  Only set start and end date values if running Traditional MRP, and the 
--  job's dates are NULL, and Job was fully scheduled

SELECT @PlanningMode  = apsmode from aps_parm

UPDATE job_sch set
compdate = ORDPERF000.COMPDATE
from ORDPERF000
join ORDER000 on ORDER000.ORDERID = ORDPERF000.ORDERID
join job on job.rowpointer = ORDER000.OrderRowPointer
join job_sch on
   job_sch.job = job.job and
   job_sch.suffix = job.suffix

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

update job_sch set
   compdate = ORDPERF000.COMPDATE
from ORDPERF000
join ORDER000 on ORDER000.ORDERID = ORDPERF000.ORDERID
join jobitem on jobitem.rowpointer = ORDER000.orderrowpointer
join job on job.job = jobitem.job and job.suffix = jobitem.suffix
join job_sch on
   job_sch.job = job.job and
   job_sch.suffix = job.suffix

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

-- Show scheduler results for the operations
--the start_tick and end_tick calculations must remain '19900101' and not dbo.Lowdate()
update jrt_sch set
   start_tick = datediff(second,'19900101',J.STARTDATE) / 36
  ,start_date = J.STARTDATE
  ,end_tick = datediff(second,'19900101',J.ENDDATE) / 36
  ,end_date = J.ENDDATE
from (SELECT MIN(JOB000.STARTDATE) AS STARTDATE,
  MAX(JOB000.ENDDATE) AS ENDDATE,
  jobroute.job, jobroute.suffix, jobroute.oper_num
from JOB000
join ORDIND000 on ORDIND000.ORDERTAG = JOB000.ORDERTAG
join JOBSTEP000 on
   JOBSTEP000.JSID = JOB000.JSID and
   JOBSTEP000.PROCPLANID = ORDIND000.PROCPLANID
join jobroute on jobroute.rowpointer = JOBSTEP000.RefRowPointer
join job on
   job.job = jobroute.job and
   job.suffix = jobroute.suffix
where job.type <> 'S'
group by JOB000.JSID, jobroute.job, jobroute.suffix, jobroute.oper_num
) J
join jrt_sch on
   jrt_sch.job = J.job and
   jrt_sch.suffix = J.suffix and
   jrt_sch.oper_num = J.oper_num

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

RETURN @Severity

GO