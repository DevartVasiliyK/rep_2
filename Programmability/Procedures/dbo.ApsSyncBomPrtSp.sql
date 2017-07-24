SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncBomPrtSp.sp 27    4/24/06 1:42p Janreu $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncBomPrtSp.sp $
 *
 * SL7.04.20 27 92873 Janreu Mon Apr 24 13:42:21 2006
 * Job materials are being planned after they have been removed from the job.
 * TRK 92873
 *
 * SL7.04 27 92873 hoffjoh Wed Mar 29 13:49:42 2006
 * TRK 92873
 *
 * SL7.04 26 92549 vanmmar Wed Feb 15 15:41:50 2006
 * After applying SL100632 - no current bom sent to planner for Items with no rev
 * 92549 - fix sync issue involving item revisions
 *
 * SL7.04 25 92065 vanmmar Wed Jan 18 14:47:52 2006
 * Change Item Revision sends two Current BOMS to APS tables
 * 92065 - use isnull in case revision is null
 *
 * SL7.04.20 24 90144 vanmmar Fri Jan 06 19:39:13 2006
 * Change Item Revision sends two Current BOMS to APS tables
 * 90144 - Delete current bom & route info from aps for old revisions
 *
 * SL7.04.20 23 90499 vanmmar Sun Nov 13 22:28:56 2005
 * Companion APAR to 100522 to enable more alt groups
 * TRK 90499 - move logic for sync of pbommatl.seqno to separate function
 *
 * SL7.04 22 87244 vanmmar Thu May 26 00:22:10 2005
 * 87244
 *
 * SL7.04 21 87115 Hcl-manobhe Wed May 04 02:27:22 2005
 * ApsResyncAllSp fails with Violation of Constraint
 * Issue 87115
 *
 * Rolled back the changes done in issue 86862
 *
 * SL7.04 20 83981 Grosphi Tue Apr 26 17:49:21 2005
 * made changes to avoid index scans when multiple suffixes exist for a job
 *
 * SL7.04 19 86862 Hcl-manobhe Fri Apr 15 06:55:14 2005
 * Error message adding current materials.
 * Issue 86862
 *
 * Increased the width of the alt_group field
 *
 * SL7.04 18 79586 Grosphi Thu Apr 14 11:15:19 2005
 * SLPERF - Blocking of Job Material Transations caused by Post Engineering change Notice
 * made changes to avoid index scans
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncBomPrtSp] (
    @Partition uniqueidentifier
)
as
declare
 @MrpParmScrapFlag ListYesNoType

   select
    @MrpParmScrapFlag = mrp_parm.scrap_flag
   from mrp_parm

   declare @pbommatls table (
      bomid nvarchar(36)
     ,jobType nchar(1)
     ,jobMaterialid nvarchar(31)
     ,materialid nvarchar(31)
     ,seqno int
     ,altid int
     ,BOMFLAGS int
     ,QUANTITY float
     ,MERGETO int
     ,SCRAP float
     ,SHRINK float
     ,RefRowPointer uniqueidentifier
     ,RefOrderId nvarchar(80)
      primary key (bomid, seqno)
     ,EFFDATE datetime
     ,OBSDATE datetime
   )

   declare @NeedJobs table (
     job nvarchar(20) not null
   , suffix int not null
   , NeedsBom int not null
   , NeedsJob int not null
   , ApsBomId nvarchar(36) null
   , primary key (job, suffix)
   )

   -- Do not sync current bom info for old item revisions
   insert into @NeedJobs (job, suffix, NeedsBom, NeedsJob)
   select distinct jobmatl.job, jobmatl.suffix, 0, 0
   from TrackRows
   inner join jobmatl on
     jobmatl.RowPointer = TrackRows.RowPointer
   inner join job on job.job = jobmatl.job and job.suffix = jobmatl.suffix
   inner join item (NOLOCK) on job.item = item.item
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync jobmatl' and
      (job.type <> 'S' or job.job = item.job)
   OPTION (KEEPFIXED PLAN) -- prevent recompiles because of throughput on TrackRows

   update @NeedJobs
   set NeedsBom = dbo.ApsPlannerNeedsBom(nj.job, nj.suffix)
   , NeedsJob = dbo.ApsSchedulerNeedsJob(nj.job, nj.suffix)
   , ApsBomId = dbo.ApsBomId(nj.job, nj.suffix)
   from @NeedJobs nj inner join job on job.job = nj.job and job.suffix = nj.suffix

   insert into PBOM000
      (BOMID, DESCR, EFFECTID)
   select distinct
      BOMID = nj.ApsBomId
     ,DESCR = 'Current BOM'
     ,EFFECTID = ''
   from @NeedJobs nj
   join job on job.job = nj.job and job.suffix = nj.suffix
   where
      not exists(select * from PBOM000 where PBOM000.BOMID = nj.ApsBomId)
      and (job.type = 'S' and job.suffix= 0)
 
   insert into MATLPBOMS000 (
      MATERIALID, PBOMID)
   select distinct
      MATERIALID = upper(job.item)
     ,PBOMID = nj.ApsBomId
   from @NeedJobs nj
   join job on job.job = nj.job and job.suffix = nj.suffix
   where
      not exists(select * from MATLPBOMS000 where
      MATLPBOMS000.MATERIALID = job.item and
      MATLPBOMS000.PBOMID = nj.ApsBomId)
      and (job.type = 'S' and job.suffix= 0)

   insert into @pbommatls (
      bomid, jobType, jobMaterialid, 
      materialid, seqno, altid, BOMFLAGS, QUANTITY, MERGETO, SCRAP, SHRINK,
      RefRowPointer,refOrderId,EFFDATE,OBSDATE)
   select distinct
      BOMID = nj.ApsBomId -- dbo.ApsBomId(job.job, job.suffix)
     ,jobType = job.type
     ,jobMaterialid = upper(job.item)
     ,materialid = upper(jobmatl.item)
     ,seqno = dbo.ApsBomPartSeq(jobmatl.oper_num, jobmatl.alt_group, jobmatl.alt_group_rank)
     ,altid = convert(integer,
        str(jobmatl.oper_num,4) +
--        replace(str(jobmatl.alt_group,3),' ','0')) Modify by Shvez M. 05.06.2008 19:17
        replace(str(jobmatl.alt_group,4),' ','0'))
     ,BOMFLAGS = case when jobmatl.units = 'L' OR (CHARINDEX(job.type, 'JR') > 0 AND CHARINDEX(job.stat, 'RSCH') > 0 )  then 1 else 0 end
     ,QUANTITY = case when (CHARINDEX(job.type, 'JR') > 0 AND CHARINDEX(job.stat, 'RSCH') > 0 ) then
                 dbo.MaxQty((dbo.ReqQty (job.qty_released, jobmatl.units, jobmatl.matl_qty, @MrpParmScrapFlag, jobmatl.scrap_fact) - jobmatl.qty_issued),0)
           else
              jobmatl.matl_qty *
                 case
                     when xitem.plan_flag <> 0 and job.type = 'S'
                     then jobmatl.probable
                     else 1
                 end
           end

     ,MERGETO =
       (
        select
           count(oper_num)
        from jobroute where
        jobroute.job = job.job and
        jobroute.suffix = job.suffix and
        jobroute.oper_num <= jobmatl.oper_num and
        jobroute.complete = 0
        )
     ,SCRAP = 0
     ,SHRINK =
        100 *
        case
           when @MrpParmScrapFlag <> 0
           then jobmatl.scrap_fact
           else 0
        end
     ,RefRowPointer = jobmatl.rowpointer
     ,REFORDERID =
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
     ,EFFDATE = Case
                    When job.type = 'S'
                    Then dbo.MidnightOf(ISNULL(dbo.ApsJobmatlEffDate(Primaryjobmatl.effect_date,jobmatl.effect_date),
                         dbo.lowdate()))
                    Else dbo.MidnightOf(dbo.lowdate())
                End
     ,OBSDATE = Case
                    When job.type = 'S'
                    Then dbo.MidnightOf(ISNULL(dbo.ApsJobmatlObsDate(Primaryjobmatl.obs_date,jobmatl.obs_date),
                         dbo.highdate()))
                    Else dbo.MidnightOf(dbo.highdate())
                End
   from TrackRows
   join jobmatl on jobmatl.rowpointer = TrackRows.RowPointer
   join jobroute on
      jobroute.job = jobmatl.job and jobroute.suffix = jobmatl.suffix
      and jobroute.oper_num = jobmatl.oper_num
      and jobroute.complete = 0
   join job on job.job = jobmatl.job and job.suffix = jobmatl.suffix
   join @NeedJobs nj on nj.job = jobmatl.job and nj.suffix = jobmatl.suffix
   --skip non-inventoried items
   join item xitem (NOLOCK) on xitem.item = job.item
   join jobmatl Primaryjobmatl on
      jobmatl.job = Primaryjobmatl.job and
      jobmatl.suffix = Primaryjobmatl.suffix and
      jobmatl.oper_num = Primaryjobmatl.oper_num and
      jobmatl.alt_group = Primaryjobmatl.alt_group and
      Primaryjobmatl.alt_group_rank = 0
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync Jobmatl' and
      -- Do not pass fixtures on the BOM
      jobmatl.matl_type <> 'F' and
      -- Skip "other" materials
      jobmatl.matl_type <> 'O' and
      (nj.NeedsBom = 1 -- dbo.ApsPlannerNeedsBom(job.job, job.suffix) = 1
          or (job.type = 'S' and job.suffix = 0))
   option(force order)

   delete PBOMMATLS000
   from PBOMMATLS000
   join @pbommatls pbommatls on
      PBOMMATLS000.BOMID = pbommatls.bomid and
      PBOMMATLS000.SEQNO = pbommatls.seqno
   where pbommatls.quantity = 0

   update PBOMMATLS000
   set
      MATERIALID = pbommatls.materialid
     ,ALTID = pbommatls.altid
     ,BOMFLAGS = pbommatls.bomflags
     ,QUANTITY = pbommatls.quantity
     ,MERGETO = pbommatls.mergeto
     ,SCRAP = pbommatls.scrap
     ,SHRINK = pbommatls.shrink
     ,REFORDERID = pbommatls.RefOrderId
     ,EFFDATE = pbommatls.EFFDATE
     ,OBSDATE = pbommatls.OBSDATE
   from @pbommatls pbommatls
   join PBOMMATLS000 on
      PBOMMATLS000.BOMID = pbommatls.bomid and
      PBOMMATLS000.SEQNO = pbommatls.seqno
   where pbommatls.quantity <> 0

   insert into PBOMMATLS000 (
      BOMID, MATERIALID, SEQNO, ALTID, BOMFLAGS, QUANTITY, MERGETO,
      SCRAP, SHRINK, RefRowPointer,REFORDERID,EFFDATE,OBSDATE)
   select distinct
      BOMID = pbommatls.bomid
     ,MATERIALID = pbommatls.materialid
     ,SEQNO = pbommatls.seqno
     ,ALTID = pbommatls.altid
     ,BOMFLAGS = pbommatls.bomflags
     ,QUANTITY = pbommatls.quantity
     ,MERGETO = pbommatls.mergeto
     ,SCRAP = pbommatls.scrap
     ,SHRINK = pbommatls.shrink
     ,RefRowPointer = pbommatls.RefRowpointer
     ,REFORDERID = pbommatls.RefOrderId
     ,EFFDATE = pbommatls.EFFDATE
     ,OBSDATE = pbommatls.OBSDATE
   from @pbommatls pbommatls
   left join PBOMMATLS000 on
      PBOMMATLS000.BOMID = pbommatls.bomid and
      PBOMMATLS000.SEQNO = pbommatls.seqno
   where
      PBOMMATLS000.BOMID is null
      and pbommatls.quantity <> 0

   ---------------------------------------------------------------
   -- Create a BOM entry for the scheduler

   declare @bom table (
      PROCPLANID nvarchar(36)
     ,JSID nvarchar(38)
     ,MATERIALID nvarchar(31)
     ,QUANTITY float
     primary key (PROCPLANID, JSID, MATERIALID)
     )

   insert into @bom (
      PROCPLANID, JSID, MATERIALID, QUANTITY)
   select distinct
    PROCPLANID = dbo.ApsRouteId(job.job, job.suffix)
   ,JSID = dbo.ApsOperationId(job.job, job.suffix, jobmatl.oper_num)
   ,MATERIALID = dbo.ApsJobOrderId(jobmatl.ref_num, jobmatl.ref_line_suf)
   ,QUANTITY = jobmatl.matl_qty
   from TrackRows
   join jobmatl on jobmatl.RowPointer = TrackRows.RowPointer
   join @NeedJobs nj on nj.job = jobmatl.job and nj.suffix = jobmatl.suffix and
   nj.NeedsJob = 1
   join jobroute on
      jobroute.job = jobmatl.job and jobroute.suffix = jobmatl.suffix
      and jobroute.complete = 0
   join job on job.job = jobmatl.job and job.suffix = jobmatl.suffix
   join item as xitem (NOLOCK) on xitem.item = jobmatl.item
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync Jobmatl' and
      -- Do not pass fixtures on the BOM
      jobmatl.matl_type <> 'F' and
      -- Skip "other" materials
      jobmatl.matl_type <> 'O' and
      jobmatl.matl_qty > 0 and
      nj.NeedsJob = 1 and -- dbo.ApsSchedulerNeedsJob(job.job, job.suffix) = 1
      jobmatl.ref_type = 'J' and
      exists(select * from job where
         job.job = jobmatl.ref_num
         and job.suffix = jobmatl.ref_line_suf
         and dbo.ApsSchedulerNeedsJob(job.job, job.suffix) = 1
         )

   update BOM000 set
      QUANTITY = bom.quantity,
      EFFDATE = dbo.MidnightOf(dbo.LowDate()),
      OBSDATE = dbo.MidnightOf(dbo.HighDate())
   from @bom bom
   join BOM000 on
      BOM000.PROCPLANID = bom.procplanid and
      BOM000.JSID = bom.jsid and
      BOM000.MATERIALID = bom.materialid and
      BOM000.QUANCD = 'L'
   option(force order)

   insert into BOM000 (
      PROCPLANID, JSID, MATERIALID, QUANCD, QUANTITY, EFFDATE, OBSDATE )
   select distinct
      PROCPLANID = bom.procplanid
     ,JSID = bom.jsid
     ,MATERIALID = bom.materialid
     ,'L'
     ,QUANTITY = bom.quantity
     ,dbo.MidnightOf(dbo.LowDate())
     ,dbo.MidnightOf(dbo.HighDate())
   from @bom bom
   left join BOM000 on
      BOM000.PROCPLANID = bom.procplanid and
      BOM000.JSID = bom.jsid and
      BOM000.MATERIALID = bom.materialid and
      BOM000.QUANCD = 'L'
   where
      BOM000.PROCPLANID is null

return 0

GO