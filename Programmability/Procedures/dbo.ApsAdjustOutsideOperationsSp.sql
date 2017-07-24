SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*
** Stub stored procedure that is automatically called
** before the APS Scheduler has started.
*/

/* $Header: /ApplicationDB/Stored Procedures/ApsAdjustOutsideOperationsSp.sp 4     3/30/04 11:33p Blostho $  */
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
CREATE PROCEDURE [dbo].[ApsAdjustOutsideOperationsSp]
AS

DECLARE
  @Severity INT
 ,@ApsParmSupplyTime ApsTimeType

set @Severity = 0

select
  @ApsParmSupplyTime = aps_parm.supply_time
from aps_parm 

declare @InProcOutsideOp table (
    Rowpointer uniqueidentifier
   ,StepTime decimal(15,8)
   primary key (RowPointer)
  )

insert into @InProcOutsideOp
select
   j1.rowpointer
  ,case
      when cpoitem.rowpointer is not null
           and poitem.rowpointer is null
      then 0
      when datediff(second,dbo.GetSiteDate(getdate()),dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(poitem.due_date)))/3600.0 <= 0
      then 0 
      else datediff(second,dbo.GetSiteDate(getdate()),dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(poitem.due_date)))/3600.0
   end
from jobroute
join wc on 
   wc.wc = jobroute.wc
   and wc.outside = 1
join job on
   job.job = jobroute.job
   and job.suffix = jobroute.suffix
   and job.stat = 'R' -- Released
join JOBSTEP000 j1 on j1.RefRowPointer = jobroute.rowpointer
left join poitem cpoitem on cpoitem.rowpointer = (
   -- completed outside operation
   select top 1 poitem.rowpointer
   from jobmatl
   join poitem on
      poitem.po_num = jobmatl.ref_num 
      and poitem.po_line = jobmatl.ref_line_suf
      and poitem.po_release = jobmatl.ref_release
      and poitem.stat <> 'P' -- Planned
      and (poitem.stat in ('F', 'C') -- Filled, Complete
           or jobroute.qty_complete + jobroute.qty_scrapped >= jobroute.qty_received)
   join item on
      item.item = poitem.item
      and item.matl_type = 'O' -- Other
   where jobmatl.ref_type = 'P' -- PO
   and jobmatl.job = jobroute.job
   and jobmatl.suffix = jobroute.suffix
   and jobmatl.oper_num = jobroute.oper_num
   )
left join poitem on poitem.rowpointer = (
   -- in process outside operation
   -- latest xrefed ordered po w/ a material of type other
   select top 1 poitem.rowpointer
   from jobmatl
   join poitem on
      poitem.po_num = jobmatl.ref_num 
      and poitem.po_line = jobmatl.ref_line_suf
      and poitem.po_release = jobmatl.ref_release
      and poitem.stat = 'O' -- Ordered
   join item on
      item.item = poitem.item
      and item.matl_type = 'O' -- Other
   where jobmatl.ref_type = 'P' -- PO
   and jobmatl.job = jobroute.job
   and jobmatl.suffix = jobroute.suffix
   and jobmatl.oper_num = jobroute.oper_num
   and jobroute.qty_complete + jobroute.qty_scrapped < jobroute.qty_received
   order by poitem.due_date desc
   )
where 
   -- The operation has started
   jobroute.qty_received > 0
   -- All resources are infinite
   and not exists(
      select *
      from jrtresourcegroup jrtrg
      join RGRP000 on
         RGRP000.RGID = jrtrg.rgid
         and RGRP000.INFINITEFG = 'N'
      where jrtrg.job = jobroute.job
         and jrtrg.suffix = jobroute.suffix
         and jrtrg.oper_num = jobroute.oper_num
         )
   -- There is a cross referenced PO
   and (poitem.rowpointer is not null or cpoitem.rowpointer is not null)
   -- The PO is completed or
   -- The new adjusted duration is smaller or
   -- The operation is first on the route
   and (cpoitem.rowpointer is not null and poitem.rowpointer is null
        or datediff(second,dbo.GetSiteDate(getdate()),dateadd(second, @ApsParmSupplyTime, dbo.MidnightOf(poitem.due_date)))/3600.0 <
           dbo.ApsStepTime(jobroute.job, jobroute.suffix, jobroute.oper_num, 1)
        or j1.JSID = (select MIN(JSID) from JOBSTEP000 j2 where j1.PROCPLANID = j2.PROCPLANID)
       )
   
-- Update operations steptimes for outside operations
update JOBSTEP000 set
   STEPTIME = InProcOutsideOp.StepTime
  ,STEPEXP = InProcOutsideOp.StepTime
  ,STEPTMRL = case when JOBSTEP000.STEPTMRL = 1 then 0 else JOBSTEP000.STEPTMRL end
  ,STEPEXPRL = case when JOBSTEP000.STEPEXPRL = 1 then 0 else JOBSTEP000.STEPEXPRL end
from @InProcOutsideOp InProcOutsideOp 
join JOBSTEP000 on JOBSTEP000.Rowpointer = InProcOutsideOp.rowpointer

update JS19VR000 set
   MOVETIME = 0
  ,QTIME = 0
  ,COOLTIME = 0
from @InProcOutsideOp InProcOutsideOp 
join JOBSTEP000 on JOBSTEP000.Rowpointer = InProcOutsideOp.rowpointer
join JS19VR000 on
   JS19VR000.ProcPlanId = JOBSTEP000.ProcPlanId
   and JS19VR000.JSID = JOBSTEP000.JSID

RETURN @Severity
GO