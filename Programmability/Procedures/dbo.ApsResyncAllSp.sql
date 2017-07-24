SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsResyncAllSp.sp 12    4/24/06 1:54p Janreu $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ApsResyncAllSp.sp $
 *
 * SL7.04.20 12 92873 Janreu Mon Apr 24 13:54:32 2006
 * Job materials are being planned after they have been removed from the job.
 * 92873 - Changed ApsSyncBomEffectivitySp, and calls to it, to be based off of changes to jobroute now, instead of jobmatl.
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ApsResyncAllSp]
as
SET nocount ON

if object_id('sync_xxx') is not null
   drop table sync_xxx
create table sync_xxx (
  text_data sysname
, xdate datetime
, idx int identity primary key
)

set transaction isolation level read uncommitted
alter table EFFECT000 disable trigger EFFECT000Iup
alter table JOBSTEP000 disable trigger JOBSTEP000Iup
alter table JS19VR000 disable trigger JS19VR000Iup
alter table PROCPLN000 disable trigger PROCPLN000Iup
alter table MATLPPS000 disable trigger MATLPPS000Iup
alter table PBOM000 disable trigger PBOM000Iup
alter table MATLPBOMS000 disable trigger MATLPBOMS000Iup
alter table PBOMMATLS000 disable trigger PBOMMATLS000Iup
alter table BOM000 disable trigger BOM000IUp

   declare
      @Partition uniqueidentifier
     ,@Infobar InfobarType
     ,@ContextHandling int

   --  There are OPTION KEEPFIXED PLAN statements in these routines.
   -- The are recompiled to get the best plan for a mass change.
   exec sp_recompile 'ApsSyncRouteOprSp'
   exec sp_recompile 'ApsSyncBomPrtSp'
   exec sp_recompile 'ApsSyncBomEffectivitySp'
   
   set @ContextHandling = 0
   set @Partition = newid()

   if dbo.SessionIdSp() = '00000000-0000-0000-0000-000000000000'
   begin
      exec InitSessionContextSp 'ApsResyncAllSp', @Partition output
      set @ContextHandling = 1
   end

   exec DefineVariableSp 'ApsDisableGateway000', 'Yes', @infobar output

   ---------------------------------------

   -- Parts
   TRUNCATE TABLE MATL000
   TRUNCATE TABLE MATLRULE000
   TRUNCATE TABLE PART000
   TRUNCATE TABLE MATLATTR000

   -- Effectivities
   TRUNCATE TABLE EFFECT000

   -- BOMs
   TRUNCATE TABLE PBOM000
   TRUNCATE TABLE MATLPBOMS000
   TRUNCATE TABLE PBOMMATLS000
  
   -- Routes
   TRUNCATE TABLE PROCPLN000
   TRUNCATE TABLE MATLPPS000
   TRUNCATE TABLE JOBSTEP000
   TRUNCATE TABLE JS19VR000

   -- Orders
   TRUNCATE TABLE MATLDELV000
   TRUNCATE TABLE ORDER000
   TRUNCATE TABLE ORDATTR000
   TRUNCATE TABLE BOM000

   -- Order Categories
   TRUNCATE TABLE OPRULE000

   ---------------------------------------

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,item.rowpointer
      ,'Sync item'
   from item

insert into sync_xxx values ( 'Before ApsSyncPartSp', getdate())
   exec ApsSyncPartSp @Partition
insert into sync_xxx values ( 'After ApsSyncPartSp', getdate())

   delete TrackRows where SessionId = @Partition

   ---------------------------------------

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,jobroute.rowpointer
      ,'Sync jobroute'
   from jobroute
   join job on 
      job.job = jobroute.job
      and job.suffix = jobroute.suffix
      and job.stat not in ('H','C')

insert into sync_xxx values ( 'Before ApsSyncRouteEffectivitySp', getdate())
   exec ApsSyncRouteEffectivitySp @Partition
insert into sync_xxx values ( 'After ApsSyncRouteEffectivitySp', getdate())
insert into sync_xxx values ( 'Before ApsSyncBomEffectivitySp', getdate()) 
   exec ApsSyncBomEffectivitySp @Partition   
insert into sync_xxx values ( 'After ApsSyncBomEffectivitySp', getdate()) 
insert into sync_xxx values ( 'Before ApsSyncRouteOprSp', getdate())
   exec ApsSyncRouteOprSp @Partition
insert into sync_xxx values ( 'After ApsSyncRouteOprSp', getdate())

   delete TrackRows where SessionId = @Partition

   insert into TrackRows (          
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,jobmatl.rowpointer
      ,'Sync jobmatl'
   from jobmatl (NOLOCK)
   join job (NOLOCK) on 
      job.job = jobmatl.job
      and job.suffix = jobmatl.suffix
      and job.stat not in ('H','C')

insert into sync_xxx values ( 'Before ApsSyncBomPrtSp', getdate()) 
   exec ApsSyncBomPrtSp @Partition        
insert into sync_xxx values ( 'After ApsSyncBomPrtSp', getdate())  

   delete TrackRows where SessionId = @Partition       

   --------------------------------------------
   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,forecast.rowpointer
      ,'Sync forecast'
   from forecast (NOLOCK)

insert into sync_xxx values ( 'Before ApsSyncForecastOrderSp', getdate())
   exec ApsSyncForecastOrderSp @Partition
insert into sync_xxx values ( 'After ApsSyncForecastOrderSp', getdate())

   delete TrackRows where SessionId = @Partition

   --------------------------------------------

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,job.rowpointer
      ,'Sync job'
   from job (NOLOCK)
   where job.stat not in ('H','C')

insert into sync_xxx values ( 'Before ApsSyncJobOrderSp', getdate())
   exec ApsSyncJobOrderSp @Partition
insert into sync_xxx values ( 'After ApsSyncJobOrderSp', getdate())
   delete TrackRows where SessionId = @Partition
   --------------------------------------------

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,jobitem.rowpointer
      ,'Sync jobitem'
   from jobitem (NOLOCK)
   join job (NOLOCK) on 
      job.job = jobitem.job
      and job.suffix = jobitem.suffix
      and job.stat not in ('H','C')

insert into sync_xxx values ( 'Before ApsSyncJobitemOrderSp', getdate())
   exec ApsSyncJobitemOrderSp @Partition
insert into sync_xxx values ( 'After ApsSyncJobitemOrderSp', getdate())

   delete TrackRows where SessionId = @Partition
   --------------------------------------------
   
   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,coitem.rowpointer
      ,'Sync coitem'
   from coitem (NOLOCK)

insert into sync_xxx values ( 'Before ApsSyncCustomerOrderSp', getdate())
   exec ApsSyncCustomerOrderSp @Partition
insert into sync_xxx values ( 'After ApsSyncCustomerOrderSp', getdate())

   delete TrackRows where SessionId = @Partition
   --------------------------------------------

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,trnitem.rowpointer
      ,'Sync trnitem'
   from trnitem (NOLOCK)

insert into sync_xxx values ( 'Before ApsSyncTransferOrderSp', getdate())
   exec ApsSyncTransferOrderSp @Partition
insert into sync_xxx values ( 'After ApsSyncTransferOrderSp', getdate())

   delete TrackRows where SessionId = @Partition
   --------------------------------------------

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,rcpts.rowpointer
      ,'Sync rcpts'
   from rcpts (NOLOCK)

insert into sync_xxx values ( 'Before ApsSyncMpsOrderSp', getdate())
   exec ApsSyncMpsOrderSp @Partition
insert into sync_xxx values ( 'After ApsSyncMpsOrderSp', getdate())

   delete TrackRows where SessionId = @Partition

   -------------------------------------
   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,preqitem.rowpointer
      ,'Sync preqitem'
   from preqitem (NOLOCK)

insert into sync_xxx values ( 'Before ApsSyncPreqOrderSp', getdate())
   exec ApsSyncPreqOrderSp @Partition
insert into sync_xxx values ( 'After ApsSyncPreqOrderSp', getdate())

   delete TrackRows where SessionId = @Partition

   ---------------------------------------

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,poitem.rowpointer
      ,'Sync poitem'
   from poitem (NOLOCK)

insert into sync_xxx values ( 'Before ApsSyncPurchaseOrderSp', getdate())
   exec ApsSyncPurchaseOrderSp @Partition
insert into sync_xxx values ( 'After ApsSyncPurchaseOrderSp', getdate())

   delete TrackRows where SessionId = @Partition

   ---------------------------------------

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,projmatl.rowpointer
      ,'Sync projmatl'
   from projmatl (NOLOCK)

insert into sync_xxx values ( 'Before ApsSyncProjectOrderSp', getdate())
   exec ApsSyncProjectOrderSp @Partition
insert into sync_xxx values ( 'After ApsSyncProjectOrderSp', getdate())

   delete TrackRows where SessionId = @Partition

   ---------------------------------------

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select distinct
      @Partition
      ,aps_seq.rowpointer
      ,'Sync aps_seq'
   from aps_seq (NOLOCK)
  
insert into sync_xxx values ( 'Before ApsSyncApsSeqSp', getdate()  )
   exec ApsSyncApsSeqSp @Partition
insert into sync_xxx values ( 'After ApsSyncApsSeqSp', getdate()  )

   delete TrackRows where SessionId = @Partition

   IF OBJECT_ID('EXTSSSFSApsResyncAllSp') IS NOT NULL
   BEGIN
      declare @SpName sysname
      set @SpName = 'EXTSSSFSApsResyncAllSp'
      EXEC @SpName
   END


   ---------------------------------------

   exec UndefineVariableSp 'ApsDisableGateway000', @infobar output
   
   if @ContextHandling = 1
      exec CloseSessionContextSp @Partition

   --  There are OPTION KEEPFIXED PLAN statements in these routines.
   -- The are recompiled to get the best plan for a non-mass change.
   exec sp_recompile 'ApsSyncRouteOprSp'
   exec sp_recompile 'ApsSyncBomPrtSp'
   exec sp_recompile 'ApsSyncBomEffectivitySp'

alter table EFFECT000 enable trigger EFFECT000Iup
alter table JOBSTEP000 enable trigger JOBSTEP000Iup
alter table JS19VR000 enable trigger JS19VR000Iup
alter table PROCPLN000 enable trigger PROCPLN000Iup
alter table MATLPPS000 enable trigger MATLPPS000Iup
alter table PBOM000 enable trigger PBOM000Iup
alter table MATLPBOMS000 enable trigger MATLPBOMS000Iup
alter table PBOMMATLS000 enable trigger PBOMMATLS000Iup
alter table BOM000 enable trigger BOM000IUp

   return 0

GO