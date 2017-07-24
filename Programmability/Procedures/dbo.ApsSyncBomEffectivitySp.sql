SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsSyncBomEffectivitySp.sp 15    4/24/06 1:42p Janreu $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsSyncBomEffectivitySp.sp $
 *
 * SL7.04.20 15 92873 Janreu Mon Apr 24 13:42:12 2006
 * Job materials are being planned after they have been removed from the job.
 * TRK 92873
 *
 * SL7.04 15 92873 hoffjoh Wed Mar 29 13:49:41 2006
 * TRK 92873
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsSyncBomEffectivitySp] (
   @Partition uniqueidentifier
)
AS

  --Effectivity data is not created for Current BOMs

   declare @NeedJobs table (
     job nvarchar(20) not null
   , suffix int not null
   , NeedsBom int not null
   , jobtype nchar(1)   
   , primary key (job, suffix)
   )

   insert into @NeedJobs (job, suffix, NeedsBom,jobtype)
   select distinct jobroute.job, jobroute.suffix, 0,job.type
   from TrackRows
   inner join jobroute on   
     jobroute.RowPointer = TrackRows.RowPointer
   inner join job on
     job.job = jobroute.job and
     job.suffix = jobroute.suffix and
     job.type <> 'S'    
   where
      TrackRows.SessionId = @Partition and
      TrackRows.TrackedOperType = 'Sync jobroute'
OPTION (KEEPFIXED PLAN)

   update @NeedJobs
   set NeedsBom = dbo.ApsPlannerNeedsBom(job, suffix)

   -- Actual Jobs
   declare @Effect table (
      job nvarchar(20)
     ,suffix smallint
     ,ApsBomEffectivityId nvarchar(39) null
     ,newVALUE nvarchar(63)
     ,jobtype nchar(1)
     Primary key (job, suffix)
   )

   insert into @Effect
   select -- distinct , not needed when jobroute table removed from join.
      nj.job
     ,nj.suffix
     ,dbo.ApsBomEffectivityId(nj.job, nj.suffix)
     ,Case when nj.jobtype = 'P' then 'PS=' + dbo.ApsPSAttribId(nj.job,0) else isnull(dbo.ApsJobOrderId(nj.job, nj.suffix),'') end
     ,nj.jobtype
   from @NeedJobs nj
   where
      nj.NeedsBom = 1 
      -- dbo.ApsPlannerNeedsBom(jobroute.job, jobroute.suffix) = 1

   update EFFECT000
   set
      VALUE = newVALUE
   from @Effect effect
   join EFFECT000 on EFFECT000.EFFECTID = effect.ApsBomEffectivityId
      -- dbo.ApsBomEffectivityId(effect.job, effect.suffix)
   WHERE VALUE <> newVALUE


   insert into EFFECT000
      (EFFECTID, DESCR, STARTDATE, ENDDATE, DATETYPE, CONDITION, VALUE)
   select distinct
    effect.ApsBomEffectivityId
        -- dbo.ApsBomEffectivityId(effect.job, effect.suffix)
   ,'Job BOM'
   ,dbo.Lowdate()
   ,dbo.Highdate()
   ,2
   ,Case when effect.jobtype = 'P' then 2 else 0 end
   ,newValue
   from @Effect effect
   where
      not exists(select * from EFFECT000 
        where EFFECT000.EFFECTID = effect.ApsBomEffectivityId)
         -- dbo.ApsBomEffectivityId(effect.job, effect.suffix))

GO