SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncBomOrderSp.sp 13    5/26/05 12:22a vanmmar $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncBomOrderSp.sp $
 *
 * SL7.04 13 87244 vanmmar Thu May 26 00:22:08 2005
 * Change Reads to Dirty Reads in Aps Sync routines
 * 87244
 *
 * SL7.04 12 83981 Grosphi Tue Apr 26 17:49:20 2005
 * Performance issues when changing job status if large number of sub-jobs
 * made changes to avoid index scans when multiple suffixes exist for a job
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncBomOrderSp] (
  @Partition uniqueidentifier
)
AS
-- This routine will stage a demand order that represents the demand of a 
-- BOM item on a job.
-- 
declare @ApsParmSupplyTime ApsTimeType
, @MrpParmPreserveProductionDates ListYesNoType

select
  @ApsParmSupplyTime = aps_parm.supply_time
from aps_parm 

select
  @MrpParmPreserveProductionDates = mrp_parm.preserve_production_dates
from mrp_parm 

update ORDER000
set
     DESCR =
      CASE
         WHEN job.type <> 'R'
         THEN 'Demand: Job'
         ELSE 'Demand: Production Schedule'
      END
   , PARTID = upper(jobmatl.item)
   , MATERIALID = upper(jobmatl.item)
   , ORDSIZE = dbo.ApsBomOrderQty(job.job, job.suffix, jobmatl.oper_num, jobmatl.sequence)
   , LOADSIZE = dbo.MaxQty(1, dbo.ApsBomOrderQty(job.job, job.suffix, jobmatl.oper_num, jobmatl.sequence))
   , ARIVDATE = isnull(dbo.MidnightOf(job.job_date), dbo.Lowdate())
   , RELDATE = dbo.Lowdate()
   , DUEDATE =
      isnull(
      case
         when jrt_sch.start_date is not null
         then dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(jrt_sch.start_date))
         else dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(job_sch.start_date))
      end, dbo.Lowdate())
   , REQUDATE =
      isnull(
      case
         when jrt_sch.start_date is not null
         then dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(jrt_sch.start_date))
         else dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(job_sch.start_date))
      end, dbo.Lowdate())
   , CATEGORY = -10 -- JobPSDemandOrders
   , ORDTYPE =
      CASE
         WHEN job.stat = 'F'
         THEN 245 -- ?
         WHEN job.stat = 'R'
         THEN 255 -- ?
         ELSE 0
      END
   , FLAGS =
      case
         when jobmatl.matl_qty < 0
         then 1 -- VAL_ORDFLAGS_SUPPLY
         else 0
      end
   , CUSTOMER = ''
   , PLANONLYFG = 'Y'
   , SCHEDONLYFG ='N'        
   , PROCPLANID = ''
   , OrderTable = 'jobmatl'
   , OrderRowPointer = jobmatl.rowpointer
   , REFORDERID = 
       dbo.ApsGetXRefOrderID (
         jobmatl.ref_type,      
         jobmatl.ref_num,      
         jobmatl.ref_line_suf,  
         jobmatl.ref_release,   
         'J',                   
         jobmatl.job,           
         jobmatl.suffix,        
         jobmatl.oper_num,      
         jobmatl.sequence,      
         jobmatl.item           
                               )

from TrackRows
inner join jobmatl on jobmatl.rowpointer = TrackRows.rowpointer
inner join item as xitem (NOLOCK) on xitem.item = jobmatl.item -- Exclude non-inventoried items
inner join job as xjob on xjob.job = jobmatl.job and xjob.suffix = jobmatl.suffix
inner join job on 
   -- select the releases if were working on a production schedule
   job.job = xjob.job and
   job.suffix = 
      case
         when xjob.type <> 'P' then xjob.suffix
         when xjob.type = 'P' and job.suffix <> 0 then job.suffix
      end
inner join job_sch on job_sch.job = job.job and job_sch.suffix = job.suffix
inner join jobroute on
   jobroute.job = job.job
   and jobroute.suffix = job.suffix
   and jobroute.oper_num = jobmatl.oper_num
   and jobroute.complete = 0
inner join jrt_sch on jrt_sch.job = jobroute.job and jrt_sch.suffix = jobroute.suffix and jrt_sch.oper_num = jobroute.oper_num
inner join item (NOLOCK) on item.item = job.item
inner join ORDER000 on ORDER000.ORDERID = dbo.ApsBomOrderId(job.job, job.suffix, jobmatl.oper_num, jobmatl.sequence)
where
   TrackRows.SessionId = @Partition
   and TrackRows.TrackedOperType = 'Sync jobmatl'
   and xjob.type <> 'R' -- dont use jobmatls off a release
   and jobmatl.matl_type not in ('O','F')
   and job.type in ('J', 'R')
   and job.stat in ('F', 'R', 'S', 'P')
   and dbo.ApsBomOrderQty(job.job, job.suffix, jobmatl.oper_num, jobmatl.sequence) > 0
   and ( dbo.IsScheduled(job.job, job.suffix) = 1 
         OR ((job.stat <> 'F' AND NOT(job.stat = 'P' AND job.type = 'R')) 
              OR @MrpParmPreserveProductionDates = 1
            ) 
       )
OPTION (KEEPFIXED PLAN, force order)

insert into ORDER000
   (ORDERID, DESCR, PARTID, MATERIALID, ORDSIZE, LOADSIZE,
    ARIVDATE, RELDATE, DUEDATE, REQUDATE,
    CATEGORY, ORDTYPE, FLAGS, CUSTOMER,
    PLANONLYFG, SCHEDONLYFG, PROCPLANID,
    OrderTable, OrderRowPointer,REFORDERID)
select
  dbo.ApsBomOrderId(job.job, job.suffix, jobmatl.oper_num, jobmatl.sequence)
, CASE
    WHEN job.type <> 'R'
    THEN 'Demand: Job'
    ELSE 'Demand: Production Schedule'
  END
, upper(jobmatl.item)
, upper(jobmatl.item)
, dbo.ApsBomOrderQty(job.job, job.suffix, jobmatl.oper_num, jobmatl.sequence)
, dbo.MaxQty(1, dbo.ApsBomOrderQty(job.job, job.suffix, jobmatl.oper_num, jobmatl.sequence))
, isnull(dbo.MidnightOf(job.job_date), dbo.Lowdate())
, dbo.Lowdate()
, isnull(
  case
    when jrt_sch.start_date is not null
    then dateadd(second,@ApsParmSupplyTime, dbo.MidnightOf(jrt_sch.start_date))
    else dateadd(second,@ApsParmSupplyTime, dbo.MidnightOf(job_sch.start_date))
  end, dbo.Lowdate())
, isnull(
  case
    when jrt_sch.start_date is not null
    then dateadd(second,@ApsParmSupplyTime, dbo.MidnightOf(jrt_sch.start_date))
    else dateadd(second,@ApsParmSupplyTime, dbo.MidnightOf(job_sch.start_date))
  end, dbo.Lowdate())
, -10 -- JobPSDemandOrders
, CASE
    WHEN job.stat = 'F'
    THEN 245 -- ?
    WHEN job.stat = 'R'
    THEN 255 -- ?
    ELSE 0
  END
, case
     when jobmatl.matl_qty < 0
     then 1 -- VAL_ORDFLAGS_SUPPLY
     else 0
  end
, ''
, 'Y'
, 'N'
, ''
, 'jobmatl'
, jobmatl.rowpointer
, dbo.ApsGetXRefOrderID (
    jobmatl.ref_type,      
    jobmatl.ref_num,       
    jobmatl.ref_line_suf,  
    jobmatl.ref_release,   
    'J',                   
    jobmatl.job,           
    jobmatl.suffix,        
    jobmatl.oper_num,      
    jobmatl.sequence,      
    jobmatl.item           
                       )
from TrackRows
inner join jobmatl on jobmatl.rowpointer = TrackRows.rowpointer
inner join item as xitem (NOLOCK) on xitem.item = jobmatl.item -- Exclude non-inventoried items
inner join job as xjob on xjob.job = jobmatl.job and xjob.suffix = jobmatl.suffix
inner join job on 
   -- select the releases if were working on a production schedule
   job.job = xjob.job and
   job.suffix = 
      case
         when xjob.type <> 'P' then xjob.suffix
         when xjob.type = 'P' and job.suffix <> 0 then job.suffix
      end
inner join job_sch on job_sch.job = job.job and job_sch.suffix = job.suffix
inner join jobroute on
   jobroute.job = job.job
   and jobroute.suffix = job.suffix
   and jobroute.oper_num = jobmatl.oper_num
   and jobroute.complete = 0
inner join jrt_sch on jrt_sch.job = jobroute.job and jrt_sch.suffix = jobroute.suffix and jrt_sch.oper_num = jobroute.oper_num
inner join item (NOLOCK) on item.item = job.item
where
   TrackRows.SessionId = @Partition
   and TrackRows.TrackedOperType = 'Sync jobmatl'
   and not exists(select * from ORDER000
      where ORDER000.ORDERID = dbo.ApsBomOrderId(job.job, job.suffix, jobmatl.oper_num, jobmatl.sequence))
   and xjob.type <> 'R' -- dont use jobmatls off a release
   and jobmatl.matl_type not in ('O','F')
   and job.type in ('J', 'R')
   and job.stat in ('F', 'R', 'S', 'P')
   and dbo.ApsBomOrderQty(job.job, job.suffix, jobmatl.oper_num, jobmatl.sequence) > 0
   and ( dbo.IsScheduled(job.job, job.suffix) = 1 
         OR ((job.stat <> 'F' AND NOT(job.stat = 'P' AND job.type = 'R')) 
              OR @MrpParmPreserveProductionDates = 1
            ) 
       )
OPTION (KEEPFIXED PLAN, force order)
RETURN 0
GO