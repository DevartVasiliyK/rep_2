SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncRouteOprSp.sp 18    4/10/07 2:35p mstephens $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncRouteOprSp.sp $
 *
 * SL7.04.20 18 100436 mstephens Tue Apr 10 14:35:12 2007
 * -103 ol_cadd_route and -2 ol_cadd_prt22rte RELOAD errors
 * MSF 100436. Fixed issue with effectivities for MRP parts.
 *
 * SL7.04.20 17 94401 hoffjoh Thu May 18 12:01:44 2006
 * Released jobs for MRP items are missing APS bom data after applying SL102428
 * TRK 94401 - Created a separate query helper table for PBOM and MATLPBOMS, that did not exclude jobs for MRP items.
 *
 * SL7.04 17 94401 hoffjoh Thu May 18 12:00:33 2006
 * Released jobs for MRP items are missing APS bom data after applying SL102428
 * TRK 94401 - Created a separate query helper table for PBOM and MATLPBOMS, that did not exclude jobs for MRP items.
 *
 * SL7.04 16 92873 hoffjoh Wed Mar 29 13:49:44 2006
 * TRK 92873
 *
 * SL7.04 15 92549 vanmmar Wed Feb 15 15:42:05 2006
 * 92549 - fix sync issue involving item revisions
 *
 * SL7.04 14 92065 vanmmar Wed Jan 18 14:48:06 2006
 * 92065 - use isnull in case revision is null
 *
 * SL7.04.20 13 90144 vanmmar Fri Jan 06 19:39:24 2006
 * 90144 - Delete current bom & route info from aps for old revisions
 *
 * SL7.04 12 87244 vanmmar Thu May 26 00:22:15 2005
 * 87244
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncRouteOprSp] (
   @Partition uniqueidentifier
)
as
/* This routine will stage a single Route Operation record for each Route that
 * this jobroute record may fall into.
 * It will also stage a Route record for each if one is not already staged.
 * It also stages operations and thier categories for any route operations staged.
 */

/* 
 * Planner:
 *
 *    JOBSTEP000.STEPTMRL: Operation time rule (0/fixed 1/PerPiece)
 *    JOBSTEP000.STEPTIME: Operation time value
 *
 *    JS19VR000.SETUPTIME: Setup time (fixed setup time)
 *
 * Scheduler:
 *
 *    JOBSTEP000.STEPEXPRL: Operation time rule (0/fixed 1/PerPiece)
 *    JOBSTEP000.STEPEXP: Operation time value
 *
 *    JS19VR000.STIMEXPRL: Setup time rule (0/fixed 1/PerPiece)
 *    JS19VR000.STIMEXP: Setup time value
 *
 * Both:
 *
 *    JS19VR000.OLTYPE: Overlap Type
 *       0/No Overlap
 *       4/Next operation may start once there is no more than
 *         OLVALUE hours remaining in this operation
 *    JS19VR000.OLVALUE: Overlap time in hours
 *
 */

   declare @CalledFromSchedStart ListYesNoType
   set @CalledFromSchedStart = ISNULL(dbo.DefinedValue('CalledFromSchedStart'),0)

   -- Sequence the resources to facilitate denormalization
   declare @jrtresourcegroup table (
      job nvarchar(20)
     ,suffix smallint
     ,oper_num int
     ,rgid nvarchar(30)
     ,seq integer
     ,resactn nchar(1) Null
     ,qty_resources smallint Null
      primary key (job, suffix, oper_num, seq)
   )

   DECLARE @JOBSTEP000 TABLE (     
      PROCPLANID nvarchar(36)
      , JSID nvarchar(38)
      , DESCR nvarchar(40)
      --, TYPE smallint
      --, ALTJSID nvarchar(38)
      , NEXTJSID nvarchar(38)
      --, ALOCRL smallint
      --, SELECTRL smallint
      , STEPTIME float(53)
      , STEPTMRL smallint
      , STEPEXP nvarchar(250)
      , STEPEXPRL smallint
      --, FREECHCKFG nchar(1)
      --, HOLDTEMPFG nchar(1)
      , RESACTN1 nchar(1)
      , RESACTN2 nchar(1)
      , RESACTN3 nchar(1)
      , RESACTN4 nchar(1)
      , RESACTN5 nchar(1)
      , RESACTN6 nchar(1)
      , RESID1 nvarchar(30)
      , RESID2 nvarchar(30)
      , RESID3 nvarchar(30)
      , RESID4 nvarchar(30)
      , RESID5 nvarchar(30)
      , RESID6 nvarchar(30)
      , RESNMBR1 smallint
      , RESNMBR2 smallint
      , RESNMBR3 smallint
      , RESNMBR4 smallint
      , RESNMBR5 smallint
      , RESNMBR6 smallint
      --, RESSCHDFG nchar(1)
      , RefRowPointer uniqueidentifier
      PRIMARY KEY (PROCPLANID, JSID)
      ,EFFDATE DateTime
      ,OBSDATE DateTime
      )

   DECLARE @JS19VR000 TABLE (     
      PROCPLANID nvarchar(36)
      , JSID nvarchar(38)
      --, RSETUPID nvarchar(30)
      , SETUPTIME float(53)
      , MOVETIME float(53)
      , QTIME float(53)
      , COOLTIME float(53)
      , OLTYPE smallint
      , OLVALUE float(53)
      , WHENRL smallint
      , BASEDCD nchar(1)
      , TABID nvarchar(30)
      , RGID nvarchar(30)
      --, START smallint
      --, LENGTH smallint
      , STIMEXP nvarchar(250)
      , STIMEXPRL smallint
      , CRSBRKRL smallint
      --, INVENTORY float(53)
      --, HORIZON float(53)
      , SPLITSIZE float(53)
      , NextJrtSchOffsetHrs decimal(7,2)
      , SetOLsToZero bit
      PRIMARY KEY (PROCPLANID, JSID)
      )

   DECLARE @PROCPLN000 TABLE (    
      PROCPLANID nvarchar(36)
      , DESCR nvarchar(40)
      , EFFECTID nvarchar(39)
      , SCHEDONLYFG nchar(1)
      , FIRSTJS nvarchar(38)
      --, RefRowPointer uniqueidentifier
      PRIMARY KEY (PROCPLANID)
      )

   declare @QPHelp table (   
      job nvarchar(20)
     ,suffix smallint
     ,ApsPlannerNeedsRoute int
     ,ApsSchedulerNeedsJob int
     Primary key (job, suffix)
   )

   declare @PBOM000 table (   
      job nvarchar(20)
     ,suffix smallint
     ,job_type nchar(1)
     ,job_item nvarchar(30) null
     ,ApsPlannerNeedsBom int
     ,BOMID nvarchar(36) null
     Primary key (job, suffix)
   )

   DECLARE @NullRowPointer RowPointerType   
   SET @NullRowPointer = NEWID()

   insert into @jrtresourcegroup (
      job, suffix, oper_num, rgid, seq, resactn, qty_resources)
   select
      jobroute.job
     ,jobroute.suffix
     ,jobroute.oper_num
     ,jrtresourcegroup.rgid
     ,(select
          count(*)
       from jrtresourcegroup as jrtrg
       where
          jrtrg.job = jrtresourcegroup.job and
          jrtrg.suffix = jrtresourcegroup.suffix and
          jrtrg.oper_num = jrtresourcegroup.oper_num and
          jrtrg.rgid <= jrtresourcegroup.rgid and
          jrtrg.resactn <> ''
       )
     ,case
         when jrtresourcegroup.resactn = 'H'
         then 'O' 
         else jrtresourcegroup.resactn
      end
     ,jrtresourcegroup.qty_resources
   from TrackRows
   join jobroute (NOLOCK) on jobroute.rowpointer = TrackRows.rowpointer
   join job (NOLOCK) on job.job = jobroute.job and job.suffix = jobroute.suffix
   join item (NOLOCK) on item.item = job.item and (item.mrp_part = 0 or @CalledFromSchedStart = 1)
   join jrtresourcegroup (NOLOCK) on
      jrtresourcegroup.job = jobroute.job and
      -- select the production schedule
      jrtresourcegroup.suffix = jobroute.suffix and
      jrtresourcegroup.oper_num = jobroute.oper_num
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync jobroute' and
      jrtresourcegroup.resactn <> '' and
      (job.type <> 'S' or job.job = item.job) -- exclude old revisions
OPTION (KEEPFIXED PLAN)

   insert into @QPHelp (
      job, suffix, 
      ApsPlannerNeedsRoute, ApsSchedulerNeedsJob)
   select distinct
      job.job
     ,job.suffix
     ,dbo.ApsPlannerNeedsRoute(job.job, job.suffix)
     ,dbo.ApsSchedulerNeedsJob(job.job, job.suffix)
   from TrackRows
   join jobroute (NOLOCK) on jobroute.rowpointer = TrackRows.rowpointer
   join job (NOLOCK) on job.job = jobroute.job and job.suffix = jobroute.suffix
   join item (NOLOCK) on item.item = job.item and(item.mrp_part = 0 or @CalledFromSchedStart = 1)
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync jobroute' and
      (job.type <> 'S' or job.job = item.job) -- exclude old revisions
   OPTION (KEEPFIXED PLAN)


   INSERT @JOBSTEP000 (
      PROCPLANID
      , JSID
      , DESCR
      , NEXTJSID
      , STEPTIME
      , STEPTMRL
      , STEPEXPRL
      , RESACTN1
      , RESACTN2
      , RESACTN3
      , RESACTN4
      , RESACTN5
      , RESACTN6
      , RESID1
      , RESID2
      , RESID3
      , RESID4
      , RESID5
      , RESID6
      , RESNMBR1
      , RESNMBR2
      , RESNMBR3
      , RESNMBR4
      , RESNMBR5
      , RESNMBR6
      , RefRowPointer
      , EFFDATE              
      , OBSDATE              
      )
   SELECT
        /* PROCPLANID = */ dbo.ApsRouteId(job.job, job.suffix) --dbo.ApsCurrentRouteId(job.job, job.suffix, ApsRoute.start_date)
      , /* JSID = */ dbo.ApsOperationId(jobroute.job, jobroute.suffix, jobroute.oper_num)
      , /* DESCR = */ jobroute.wc
      , /* NEXTJSID = */ ''
      , /* STEPTIME = */ dbo.ApsStepTime(jobroute.job, jobroute.suffix, jobroute.oper_num, 0)
      , /* STEPTMRL = */
         case
            when jrt_sch.sched_hrs is not null and
                 isnull(jrt_sch.plannerstep,0) = 0
            then 0
            when isnull(jrt_sch.plannerstep,0) = 0
            then 1
            when jrt_sch.sched_hrs is not null
            then 2
            else 3
         end
      , /* stepexprl = */ isnull(jrt_sch.schedsteprule,0)
      , /* RESACTN1 = */ isnull(jrtresourcegroup1.resactn,'')
      , /* RESACTN2 = */ isnull(jrtresourcegroup2.resactn,'')
      , /* RESACTN3 = */ isnull(jrtresourcegroup3.resactn,'')
      , /* RESACTN4 = */ isnull(jrtresourcegroup4.resactn,'')
      , /* RESACTN5 = */ isnull(jrtresourcegroup5.resactn,'')
      , /* RESACTN6 = */ isnull(jrtresourcegroup6.resactn,'')
      , /* RESID1 = */ isnull(jrtresourcegroup1.rgid,'')
      , /* RESID2 = */ isnull(jrtresourcegroup2.rgid,'')
      , /* RESID3 = */ isnull(jrtresourcegroup3.rgid,'')
      , /* RESID4 = */ isnull(jrtresourcegroup4.rgid,'')
      , /* RESID5 = */ isnull(jrtresourcegroup5.rgid,'')
      , /* RESID6 = */ isnull(jrtresourcegroup6.rgid,'')
      , /* RESNMBR1 = */ isnull(jrtresourcegroup1.qty_resources,'')
      , /* RESNMBR2 = */ isnull(jrtresourcegroup2.qty_resources,'')
      , /* RESNMBR3 = */ isnull(jrtresourcegroup3.qty_resources,'')
      , /* RESNMBR4 = */ isnull(jrtresourcegroup4.qty_resources,'')
      , /* RESNMBR5 = */ isnull(jrtresourcegroup5.qty_resources,'')
      , /* RESNMBR6 = */ isnull(jrtresourcegroup6.qty_resources,'')
      , /* RefRowPointer = */ jobroute.rowpointer
      , /* EFFDATE = */ Case 
                             When job.type = 'S'
                             Then dbo.MidnightOf(ISNULL (jobroute.effect_date, dbo.lowdate()))
                             Else dbo.MidnightOf(dbo.lowdate())  
                        End
      , /* OBSDATE = */ Case 
                            When job.type = 'S'
                            Then dbo.MidnightOf (ISNULL (jobroute.obs_date, dbo.highdate()))    
                            Else dbo.MidnightOf(dbo.highdate())
                        End 
   from TrackRows
   join jobroute (NOLOCK) on jobroute.rowpointer = TrackRows.rowpointer
   join job (NOLOCK) on job.job = jobroute.job and job.suffix = jobroute.suffix
   join @QPHelp qph on qph.job = job.job and qph.suffix = job.suffix           
   join jrt_sch (NOLOCK) on                                                             
      jrt_sch.job = jobroute.job and 
      jrt_sch.suffix = jobroute.suffix and 
      jrt_sch.oper_num = jobroute.oper_num
   left join @jrtresourcegroup as jrtresourcegroup1 on
      jrtresourcegroup1.job = jobroute.job and
      jrtresourcegroup1.suffix = jobroute.suffix and
      jrtresourcegroup1.oper_num = jobroute.oper_num and
      jrtresourcegroup1.seq = 1
   left join @jrtresourcegroup as jrtresourcegroup2 on
      jrtresourcegroup2.job = jobroute.job and
      jrtresourcegroup2.suffix = jobroute.suffix and
      jrtresourcegroup2.oper_num = jobroute.oper_num and
      jrtresourcegroup2.seq = 2
   left join @jrtresourcegroup as jrtresourcegroup3 on
      jrtresourcegroup3.job = jobroute.job and
      jrtresourcegroup3.suffix = jobroute.suffix and
      jrtresourcegroup3.oper_num = jobroute.oper_num and
      jrtresourcegroup3.seq = 3
   left join @jrtresourcegroup as jrtresourcegroup4 on
      jrtresourcegroup4.job = jobroute.job and
      jrtresourcegroup4.suffix = jobroute.suffix and
      jrtresourcegroup4.oper_num = jobroute.oper_num and
      jrtresourcegroup4.seq = 4
   left join @jrtresourcegroup as jrtresourcegroup5 on
      jrtresourcegroup5.job = jobroute.job and
      jrtresourcegroup5.suffix = jobroute.suffix and
      jrtresourcegroup5.oper_num = jobroute.oper_num and
      jrtresourcegroup5.seq = 5
   left join @jrtresourcegroup as jrtresourcegroup6 on
      jrtresourcegroup6.job = jobroute.job and
      jrtresourcegroup6.suffix = jobroute.suffix and
      jrtresourcegroup6.oper_num = jobroute.oper_num and
      jrtresourcegroup6.seq = 6
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync jobroute' and
      jobroute.complete = 0 and                          
      (qph.ApsPlannerNeedsRoute = 1 or
       qph.ApsSchedulerNeedsJob = 1 or 
       (job.type = 'S' and job.suffix = 0)
      )
   OPTION (KEEPFIXED PLAN)

   UPDATE @JOBSTEP000
   SET
      stepexp = STEPTIME

   UPDATE JOBSTEP000
   SET
      DESCR = updated.DESCR
      , NEXTJSID = updated.NEXTJSID
      , STEPTIME = updated.STEPTIME
      , STEPTMRL = updated.STEPTMRL
      , STEPEXP = updated.STEPEXP
      , STEPEXPRL = updated.STEPEXPRL
      , RESACTN1 = updated.RESACTN1
      , RESACTN2 = updated.RESACTN2
      , RESACTN3 = updated.RESACTN3
      , RESACTN4 = updated.RESACTN4
      , RESACTN5 = updated.RESACTN5
      , RESACTN6 = updated.RESACTN6
      , RESID1 = updated.RESID1
      , RESID2 = updated.RESID2
      , RESID3 = updated.RESID3
      , RESID4 = updated.RESID4
      , RESID5 = updated.RESID5
      , RESID6 = updated.RESID6
      , RESNMBR1 = updated.RESNMBR1
      , RESNMBR2 = updated.RESNMBR2
      , RESNMBR3 = updated.RESNMBR3
      , RESNMBR4 = updated.RESNMBR4
      , RESNMBR5 = updated.RESNMBR5
      , RESNMBR6 = updated.RESNMBR6
      , RefRowPointer = updated.RefRowPointer
      , EFFDATE = updated.EFFDATE
      , OBSDATE = updated.OBSDATE 
   FROM @JOBSTEP000 updated
   WHERE JOBSTEP000.PROCPLANID = updated.PROCPLANID
   AND JOBSTEP000.JSID = updated.JSID
   AND (
      -- All of these are NOT NULLable, so we can compare them directly
      JOBSTEP000.DESCR <> updated.DESCR
      OR JOBSTEP000.NEXTJSID <> updated.NEXTJSID
      OR JOBSTEP000.STEPTIME <> updated.STEPTIME
      OR JOBSTEP000.STEPTMRL <> updated.STEPTMRL
      OR JOBSTEP000.STEPEXP <> updated.STEPEXP
      OR JOBSTEP000.STEPEXPRL <> updated.STEPEXPRL
      OR JOBSTEP000.RESACTN1 <> updated.RESACTN1
      OR JOBSTEP000.RESACTN2 <> updated.RESACTN2
      OR JOBSTEP000.RESACTN3 <> updated.RESACTN3
      OR JOBSTEP000.RESACTN4 <> updated.RESACTN4
      OR JOBSTEP000.RESACTN5 <> updated.RESACTN5
      OR JOBSTEP000.RESACTN6 <> updated.RESACTN6
      OR JOBSTEP000.RESID1 <> updated.RESID1
      OR JOBSTEP000.RESID2 <> updated.RESID2
      OR JOBSTEP000.RESID3 <> updated.RESID3
      OR JOBSTEP000.RESID4 <> updated.RESID4
      OR JOBSTEP000.RESID5 <> updated.RESID5
      OR JOBSTEP000.RESID6 <> updated.RESID6
      OR JOBSTEP000.RESNMBR1 <> updated.RESNMBR1
      OR JOBSTEP000.RESNMBR2 <> updated.RESNMBR2
      OR JOBSTEP000.RESNMBR3 <> updated.RESNMBR3
      OR JOBSTEP000.RESNMBR4 <> updated.RESNMBR4
      OR JOBSTEP000.RESNMBR5 <> updated.RESNMBR5
      OR JOBSTEP000.RESNMBR6 <> updated.RESNMBR6
      OR JOBSTEP000.EFFDATE <> updated.EFFDATE
      OR JOBSTEP000.OBSDATE <> updated.OBSDATE

      -- Except this one:
      OR isnull(JOBSTEP000.RefRowPointer, @NullRowPointer) <> isnull(updated.RefRowPointer, @NullRowPointer)
      )

   insert into JOBSTEP000
      (PROCPLANID, JSID, DESCR, NEXTJSID,
       RESACTN1, RESACTN2, RESACTN3, RESACTN4, RESACTN5, RESACTN6,
       RESID1, RESID2, RESID3, RESID4, RESID5, RESID6,
       RESNMBR1, RESNMBR2, RESNMBR3, RESNMBR4, RESNMBR5, RESNMBR6,
       STEPTIME, STEPTMRL, stepexprl, stepexp, RefRowPointer,
       EFFDATE, OBSDATE)                                         
   select
      new.PROCPLANID, new.JSID, new.DESCR, new.NEXTJSID,
       new.RESACTN1, new.RESACTN2, new.RESACTN3, new.RESACTN4, new.RESACTN5, new.RESACTN6,
       new.RESID1, new.RESID2, new.RESID3, new.RESID4, new.RESID5, new.RESID6,
       new.RESNMBR1, new.RESNMBR2, new.RESNMBR3, new.RESNMBR4, new.RESNMBR5, new.RESNMBR6,
       new.STEPTIME, new.STEPTMRL, new.stepexprl, new.stepexp, new.RefRowPointer,
       new.EFFDATE, new.OBSDATE               
   FROM @JOBSTEP000 AS new
   -- Only those that do not yet exist:
   left join JOBSTEP000 (NOLOCK) on
      JOBSTEP000.PROCPLANID = NEW.PROCPLANID
      and JOBSTEP000.JSID = NEW.JSID
   where
      JOBSTEP000.PROCPLANID is null

   INSERT @JS19VR000
      (PROCPLANID, JSID, SETUPTIME, MOVETIME, QTIME, COOLTIME,
       NextJrtSchOffsetHrs, SetOLsToZero,
       whenrl, basedcd, tabid, rgid, stimexp, stimexprl,
       crsbrkrl, splitsize
      )
   SELECT 
        /* PROCPLANID = */ dbo.ApsRouteId(job.job, job.suffix) --dbo.ApsCurrentRouteId(job.job, job.suffix, ApsRoute.start_date)
      , /* JSID = */ dbo.ApsOperationId(jobroute.job, jobroute.suffix, jobroute.oper_num)
      , /* SETUPTIME = */
          case
             when jrt_sch.sched_hrs is not null
              or jobroute.qty_complete <> 0           
              or jobroute.qty_scrapped <> 0
              or jobroute.qty_moved <> 0
              or jobroute.run_hrs_t_lbr <> 0
              or jobroute.run_hrs_t_mch <> 0
              or isnull(jrt_sch.setup_hrs * (100 / jobroute.efficiency),0)
                  <= isnull(jobroute.setup_hrs_t,0)
             then 0 
             else isnull(jrt_sch.setup_hrs *
                -- Tweak cycle time with operation efficiency
                (100 / jobroute.efficiency),0)
                - isnull(jobroute.setup_hrs_t,0)
          end
      , /* MOVETIME = */ 
          case                                   
            when jobroute.qty_complete <> 0
              or jobroute.qty_scrapped <> 0
              or jobroute.qty_moved <> 0
              or jobroute.setup_hrs_t <> 0
              or jobroute.run_hrs_t_lbr <> 0
              or jobroute.run_hrs_t_mch <> 0
            then 0
            else isnull(jrt_sch.move_hrs,0)
         end
      , /* QTIME = */ isnull(jrt_sch.queue_hrs,0)
      , /* COOLTIME = */ isnull(jrt_sch.finish_hrs,0)
      , /* NextJrtSchOffsetHrs = */
         dbo.NextJrtSchOffsetHrs(jobroute.job, jobroute.suffix, jobroute.oper_num)
      , /* SetOLsToZero = */
         case
            when isnull(jrt_sch.schedsteprule,0) = 0 and
                 dbo.ApsStepTime(jobroute.job, jobroute.suffix, jobroute.oper_num, 0) = 0
            then 1 -- Temporary workaround for Error 1461
            else 0
         end
      , /* whenrl = */ jrt_sch.whenrule
      , /* basedcd = */ jrt_sch.matrixtype
      , /* tabid = */ isnull(jrt_sch.tabid,'')
      , /* rgid = */ isnull(jrt_sch.setuprgid,'')
      , /* stimexp = */
          case
             when jrt_sch.sched_hrs is not null
              or jobroute.qty_complete <> 0
              or jobroute.qty_scrapped <> 0
              or jobroute.qty_moved <> 0
              or jobroute.run_hrs_t_lbr <> 0
              or jobroute.run_hrs_t_mch <> 0
              or isnull(jrt_sch.setup_hrs * (100 / jobroute.efficiency),0)
                    <= isnull(jobroute.setup_hrs_t,0)
             then 0
             else isnull(jrt_sch.setup_hrs *
                -- Tweak cycle time with operation efficiency
                (100 / jobroute.efficiency),0)
                - isnull(jobroute.setup_hrs_t,0)
          end
      , /* stimexprl = */
          case
             when jrt_sch.sched_hrs is not null
              or jobroute.qty_complete <> 0
              or jobroute.qty_scrapped <> 0
              or jobroute.qty_moved <> 0
              or jobroute.run_hrs_t_lbr <> 0
              or jobroute.run_hrs_t_mch <> 0
             then 0
             else isnull(jrt_sch.setuprule,0)
          end
      , /* crsbrkrl = */ isnull(jrt_sch.crsbrkrule,0)
      , /* splitsize = */ jrt_sch.splitsize
   from TrackRows
   join jobroute (NOLOCK) on jobroute.rowpointer = TrackRows.rowpointer
   join job (NOLOCK) on job.job = jobroute.job and job.suffix = jobroute.suffix
   join @QPHelp qph on qph.job = job.job and qph.suffix = job.suffix          
   join jrt_sch (NOLOCK) on 
      jrt_sch.job = jobroute.job and 
      jrt_sch.suffix = jobroute.suffix and 
      jrt_sch.oper_num = jobroute.oper_num
--   join item (NOLOCK) on item.item = job.item
--   join jrt_sch on jrt_sch.job = jobroute.job and jrt_sch.suffix = jobroute.suffix and jrt_sch.oper_num = jobroute.oper_num
 --  join @ApsRoute as ApsRoute on ApsRoute.job = job.job and ApsRoute.suffix = job.suffix
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync jobroute' and
      jobroute.complete = 0 and
      (qph.ApsPlannerNeedsRoute = 1 or
       qph.ApsSchedulerNeedsJob = 1 or
       (job.type = 'S' and job.suffix = 0)
      )
  OPTION (KEEPFIXED PLAN)

   UPDATE @JS19VR000
   SET
      OLTYPE =
         case
            when SetOLsToZero = 1
            then 0 -- Temporary workaround for Error 1461
            when NextJrtSchOffsetHrs is null or
                 NextJrtSchOffsetHrs <= 0
            then 0
            else 4
         end
      , OLVALUE =
         case
            when SetOLsToZero = 1
            then 0 -- Temporary workaround for Error 1461
            when NextJrtSchOffsetHrs is null or
                 NextJrtSchOffsetHrs <= 0
            then 0
            else NextJrtSchOffsetHrs
         end
   

   UPDATE JS19VR000
   SET
      SETUPTIME = updated.SETUPTIME
      , MOVETIME = updated.MOVETIME
      , QTIME = updated.QTIME
      , COOLTIME = updated.COOLTIME
      , OLTYPE = updated.OLTYPE
      , OLVALUE = updated.OLVALUE
      , WHENRL = updated.WHENRL
      , BASEDCD = updated.BASEDCD
      , TABID = updated.TABID
      , RGID = updated.RGID
      , STIMEXP = updated.STIMEXP
      , STIMEXPRL = updated.STIMEXPRL
      , CRSBRKRL = updated.CRSBRKRL
      , SPLITSIZE = updated.SPLITSIZE
   FROM @JS19VR000 updated
   WHERE JS19VR000.PROCPLANID = updated.PROCPLANID
   AND JS19VR000.JSID = updated.JSID
   AND (
      -- All of these are NOT NULLable, so we can compare them directly
      JS19VR000.SETUPTIME <> updated.SETUPTIME
      OR JS19VR000.MOVETIME <> updated.MOVETIME
      OR JS19VR000.QTIME <> updated.QTIME
      OR JS19VR000.COOLTIME <> updated.COOLTIME
      OR JS19VR000.OLTYPE <> updated.OLTYPE
      OR JS19VR000.OLVALUE <> updated.OLVALUE
      OR JS19VR000.WHENRL <> updated.WHENRL
      OR JS19VR000.BASEDCD <> updated.BASEDCD
      OR JS19VR000.TABID <> updated.TABID
      OR JS19VR000.RGID <> updated.RGID
      OR JS19VR000.STIMEXP <> updated.STIMEXP
      OR JS19VR000.STIMEXPRL <> updated.STIMEXPRL
      OR JS19VR000.CRSBRKRL <> updated.CRSBRKRL
      OR JS19VR000.SPLITSIZE <> updated.SPLITSIZE
      )


   insert into JS19VR000
      (PROCPLANID, JSID, SETUPTIME, MOVETIME, QTIME, COOLTIME, 
       OLTYPE, OLVALUE, whenrl, basedcd, tabid, rgid, stimexp, stimexprl,
       crsbrkrl, splitsize
      )
   select
      new.PROCPLANID, new.JSID, new.SETUPTIME, new.MOVETIME, new.QTIME, new.COOLTIME,
       new.OLTYPE, new.OLVALUE, new.whenrl, new.basedcd, new.tabid, new.rgid, new.stimexp, new.stimexprl,
       new.crsbrkrl, new.splitsize
   FROM @JS19VR000 AS new
   -- Only those that do not yet exist:
   left join JS19VR000 (NOLOCK) on
      JS19VR000.PROCPLANID = new.PROCPLANID
      and JS19VR000.JSID = new.JSID
   where
      JS19VR000.PROCPLANID is null

   INSERT @PROCPLN000 (PROCPLANID, DESCR, EFFECTID, SCHEDONLYFG, FIRSTJS) 
   SELECT DISTINCT
      /* PROCPLANID = */ dbo.ApsRouteId(job.job, job.suffix) 
      , /* DESCR = */ 
         case
            when job.type = 'E'                       
            then 'Estimate Route'
            when job.type = 'J'
            then 'Job Route'
            when job.type = 'R'
            then 'Production Schedule Route'
            when job.type = 'S'
            then 'Current Route'
            else ''
         end
      , /* EFFECTID = */          
         case 
            when item.mrp_part = 1
            then ''
            when job.type <>  'S' 
            then dbo.ApsRouteEffectivityId(job.job, job.suffix)          
            else ''
         end
      , /* SCHEDONLYFG = */
         case
            when qph.ApsPlannerNeedsRoute = 0 and job.type <> 'S'
            then 'Y'
            else 'N'
         end
      , /* FIRSTJS = */ ''
   from TrackRows
   join jobroute (NOLOCK) on jobroute.rowpointer = TrackRows.rowpointer
   join job (NOLOCK) on job.job = jobroute.job and job.suffix = jobroute.suffix
   join item (NOLOCK) on item.item = job.item
   join @QPHelp qph on qph.job = job.job and qph.suffix = job.suffix
   join jrt_sch (NOLOCK) on 
      jrt_sch.job = jobroute.job and 
      jrt_sch.suffix = jobroute.suffix and 
      jrt_sch.oper_num = jobroute.oper_num
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync jobroute' and
      (qph.ApsPlannerNeedsRoute = 1 or                    
       qph.ApsSchedulerNeedsJob = 1 or
       (job.type = 'S' and job.suffix = 0)
       )
   OPTION (KEEPFIXED PLAN)

   UPDATE PROCPLN000
   SET
      DESCR = updated.DESCR
      , EFFECTID = updated.EFFECTID
      , SCHEDONLYFG = updated.SCHEDONLYFG       
      , FIRSTJS = updated.FIRSTJS
   FROM @PROCPLN000 AS updated
   WHERE PROCPLN000.PROCPLANID = updated.PROCPLANID
   AND (
      -- All of these are NOT NULLable, so we can compare them directly
      PROCPLN000.DESCR <> updated.DESCR
      OR PROCPLN000.EFFECTID <> updated.EFFECTID
      OR PROCPLN000.SCHEDONLYFG <> updated.SCHEDONLYFG
      OR PROCPLN000.FIRSTJS <> updated.FIRSTJS
      )


   insert into PROCPLN000
      (PROCPLANID, DESCR, FIRSTJS, EFFECTID, SCHEDONLYFG)           
   select new.PROCPLANID, new.DESCR, new.FIRSTJS, new.EFFECTID, new.SCHEDONLYFG   
   FROM @PROCPLN000 AS new
   -- Only those that do not yet exist:
   left join PROCPLN000 (NOLOCK) on PROCPLN000.PROCPLANID = new.PROCPLANID
   where
      PROCPLN000.PROCPLANID is null

   insert into @PBOM000 (
      job, suffix, job_type, job_item,
      ApsPlannerNeedsBom, BOMID)
   select distinct
      job.job
     ,job.suffix
     ,job.type
     ,job.item
     ,dbo.ApsPlannerNeedsBom(job.job, job.suffix)
     ,dbo.ApsBomId(job.job, job.suffix)
   from TrackRows
   join jobroute (NOLOCK) on jobroute.rowpointer = TrackRows.rowpointer
   join job (NOLOCK) on job.job = jobroute.job and job.suffix = jobroute.suffix
   join item (NOLOCK) on item.item = job.item
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync jobroute' and
      (job.type <> 'S' or job.job = item.job) -- exclude old revisions
   OPTION (KEEPFIXED PLAN)

   insert into PBOM000
      (BOMID, DESCR, EFFECTID)
   select distinct
      BOMID = qph.BOMID
     ,DESCR =
        case
           when qph.job_type = 'E'
           then 'Estimate BOM'
           when qph.job_type = 'J'
           then 'Job BOM'
           when qph.job_type = 'P'
           then 'Production Schedule BOM'
           when qph.job_type = 'R'
           then 'Production Schedule Release BOM'
           else ''
        end
     ,EFFECTID = dbo.ApsBomEffectivityId(qph.job, qph.suffix)
   from @PBOM000 qph
   left join PBOM000 (NOLOCK) on PBOM000.BOMID = qph.BOMID
   where
      PBOM000.BOMID is null
      and qph.job_type <> 'S'
      and qph.ApsPlannerNeedsBom = 1

   insert into MATLPBOMS000
      (MATERIALID, PBOMID)
   select distinct
      MATERIALID = upper(qph.job_item)
     ,PBOMID = qph.BOMID
   from @PBOM000 qph
   left join MATLPBOMS000 (NOLOCK) on MATLPBOMS000.MATERIALID = qph.job_item
      and MATLPBOMS000.PBOMID = qph.BOMID
   where
      MATLPBOMS000.MATERIALID is null
      and qph.job_type <> 'S'
      and qph.ApsPlannerNeedsBom = 1
 
   insert into MATLPPS000
      (MATERIALID, PROCPLANID)
   select distinct
    upper(job.item)
   ,dbo.ApsRouteId(job.job, job.suffix)  
   from TrackRows
   join jobroute (NOLOCK) on jobroute.rowpointer = TrackRows.rowpointer
   join job (NOLOCK) on job.job = jobroute.job and job.suffix = jobroute.suffix
   join @QPHelp qph on qph.job = job.job and qph.suffix = job.suffix
   join jrt_sch (NOLOCK) on 
      jrt_sch.job = jobroute.job and 
      jrt_sch.suffix = jobroute.suffix and 
      jrt_sch.oper_num = jobroute.oper_num
   left join MATLPPS000 (NOLOCK) on 
      MATLPPS000.MATERIALID = job.item and
      MATLPPS000.PROCPLANID = dbo.ApsRouteId(job.job, job.suffix)  
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync jobroute' and
      MATLPPS000.MATERIALID is null and
      (qph.ApsPlannerNeedsRoute = 1 or (job.type = 'S' and job.suffix = 0))
OPTION (KEEPFIXED PLAN)

GO