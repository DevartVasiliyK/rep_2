SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/Rpt_JobCostVariance1Sp.sp 3     9/24/04 5:55a Hcl-kannvai $  */
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
(v) upon any expiration or termination of the license agreement, customer's
license to the source code will immediately terminate and customer shall return
the source code to MAPICS or prepare and send to MAPICS a written affidavit
certifying destruction of the source code within ten (10) days following the
expiration or termination of customer's license right to the source code;
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
CREATE PROCEDURE [dbo].[Rpt_JobCostVariance1Sp] (
   @JobBuffer           NVARCHAR(10) /* = #job/ #est_job/ #std_job/ #frz_job */
   ,@JobType            NVARCHAR(10) /* = plan/ est/ std/ frz */
)
AS
/******************************************************************************
 *
 *  File Name       :   Rpt_JobCostVariance1Sp.sp: converted from job\job03a-r.i
 *
 *  Extended Name   :   Job Cost Variance Report
 *                      Calculates costs for standard/estimate jobs
 *  Converted by    :   Nam Ngo
 *  Date            :   04/16/2002
 *
 ******************************************************************************
 * Parameter            Description
 * -------------------  ------------------------------------------------------
 *
 ******************************************************************************
 * ************* ORIGINAL SINGLESOURCE COMMENTS *******************************
 *                        Modification Table
 *
 * Code  Init Date     Description
 * ----- ---- -------- -------------------------------------------------------

 ******************************************************************************/

   declare
      @JobrouteRowPointer  RowPointerType
      ,@JobrouteEffectDate DateType
      ,@JobrouteObsDate    DateType
      ,@JobrouteOperNum    OperNumType

      ,@JobmatlRowPointer  RowPointerType
      ,@JobmatlEffectDate  DateType
      ,@JobmatlObsDate     DateType
      ,@JobmatlMatlType    MatlTypeType
      ,@JobmatlUnits       JobmatlUnitsType
      ,@JobmatlMatlQty     QtyPerType
      ,@JobmatlScrapFact   ScrapFactorType
      ,@JobmatlCost        CostPrcType
      ,@JobmatlItem        ItemType
      ,@JobmatlFmatlovhd   OverheadRateType
      ,@JobmatlVmatlovhd   OverheadRateType

      ,@WcOverhead         OverheadBasisType
      ,@WcOutside          ListYesNoType

   declare
      @Severity int
      ,@i int
      ,@TcAmt AmountType
      ,@TcAmt1 AmountType
      ,@TcAmt2 AmountType
      ,@TcAmt3 AmountType

      ,@TcAmt4 AmountType
      ,@TcAmt41 AmountType
      ,@TcAmt42 AmountType

      ,@TcAmt9 AmountType
      ,@TcAmt91 AmountType
      ,@TcAmt92 AmountType
      ,@TcAmt93 AmountType
      ,@TcAmt94 AmountType
      ,@TcAmt95 AmountType
      ,@TcAmt96 AmountType


   set @Severity = 0

   -- Loop on jobroute
   if @JobBuffer = '#job'
   begin
      declare Job03bCrs cursor local static for
         select jobroute.RowPointer, jobroute.effect_date, jobroute.obs_date, jobroute.oper_num
         from jobroute join #job on #job.job = jobroute.job and #job.suffix = jobroute.suffix
   end
   else if @JobBuffer = '#est_job'
   begin
      declare Job03bCrs cursor local static for
         select jobroute.RowPointer, jobroute.effect_date, jobroute.obs_date, jobroute.oper_num
         from jobroute join #est_job on #est_job.job = jobroute.job and #est_job.suffix = jobroute.suffix
   end
   else if @JobBuffer = '#std_job'
   begin
      declare Job03bCrs cursor local static for
         select jobroute.RowPointer, jobroute.effect_date, jobroute.obs_date, jobroute.oper_num
         from jobroute join #std_job on #std_job.job = jobroute.job and #std_job.suffix = jobroute.suffix
   end
   else /*if @JobBuffer = '#frz_job'*/
   begin
      declare Job03bCrs cursor local static for
         select jobroute.RowPointer, jobroute.effect_date, jobroute.obs_date, jobroute.oper_num
         from jobroute join #frz_job on #frz_job.job = jobroute.job and #frz_job.suffix = jobroute.suffix
   end

   open Job03bCrs
   while @Severity = 0
   begin
      fetch Job03bCrs into @JobrouteRowPointer, @JobrouteEffectDate, @JobrouteObsDate, @JobrouteOperNum
      if @@FETCH_STATUS = -1 break

      if (@JobrouteEffectDate > dbo.GetSiteDate(getdate())) or (@JobrouteObsDate <= dbo.GetSiteDate(getdate())) continue

      -- Update tt-amt-(job-type)
      if @JobType = 'plan'
      begin
         select @TcAmt1 = amt_plan  from #tc_amt where idx = 1
         select @TcAmt2 = amt_plan  from #tc_amt where idx = 2
         select @TcAmt3 = amt_plan  from #tc_amt where idx = 3
         select @TcAmt4 = amt_plan  from #tc_amt where idx = 4
         select @TcAmt9 = amt_plan  from #tc_amt where idx = 9
      end
      else if @JobType = 'est'
      begin
         select @TcAmt1 = amt_est  from #tc_amt where idx = 1
         select @TcAmt2 = amt_est  from #tc_amt where idx = 2
         select @TcAmt3 = amt_est  from #tc_amt where idx = 3
         select @TcAmt4 = amt_est  from #tc_amt where idx = 4
         select @TcAmt9 = amt_est  from #tc_amt where idx = 9
      end
      else if @JobType = 'std'
      begin
         select @TcAmt1 = amt_std  from #tc_amt where idx = 1
         select @TcAmt2 = amt_std  from #tc_amt where idx = 2
         select @TcAmt3 = amt_std  from #tc_amt where idx = 3
         select @TcAmt4 = amt_std  from #tc_amt where idx = 4
         select @TcAmt9 = amt_std  from #tc_amt where idx = 9
      end
      else /*if @JobType = 'frz'*/
      begin
         select @TcAmt1 = amt_frz  from #tc_amt where idx = 1
         select @TcAmt2 = amt_frz  from #tc_amt where idx = 2
         select @TcAmt3 = amt_frz  from #tc_amt where idx = 3
         select @TcAmt4 = amt_frz  from #tc_amt where idx = 4
         select @TcAmt9 = amt_frz  from #tc_amt where idx = 9
      end

      set @TcAmt41 = 0
      set @TcAmt42 = 0
      set @TcAmt91 = 0
      set @TcAmt92 = 0
      set @TcAmt93 = 0
      set @TcAmt94 = 0
      set @TcAmt95 = 0
      set @TcAmt96 = 0

      exec CostOperSp
         @zero_args             =0
         ,@JobrouteRowPointer   =@JobrouteRowPointer
         ,@u_qty                =@TcAmt1 output
         ,@l_qty                =1
         ,@u_outside            =@TcAmt41 output
         ,@l_outside            =@TcAmt42 output
         ,@u_run                =@TcAmt3 output
         ,@l_setup              =@TcAmt2 output
         ,@u_fovhd_lbr          =@TcAmt91 output
         ,@l_fovhd_lbr          =@TcAmt92 output
         ,@u_vovhd_lbr          =@TcAmt93 output
         ,@l_vovhd_lbr          =@TcAmt94 output
         ,@u_fovhd_mch          =@TcAmt95 output
         ,@u_vovhd_mch          =@TcAmt96 output
         ,@WcOverhead           =@WcOverhead output
         ,@WcOutside            =@WcOutside output

      set @TcAmt4 = @TcAmt4 + @TcAmt41 + @TcAmt42
      set @TcAmt9 = @TcAmt9 + @TcAmt91 + @TcAmt92 + @TcAmt93 + @TcAmt94 + @TcAmt95 + @TcAmt96

      if @JobType = 'plan'
      begin
         update #tc_amt set amt_plan = @TcAmt1 where idx = 1
         update #tc_amt set amt_plan = @TcAmt2 where idx = 2
         update #tc_amt set amt_plan = @TcAmt3 where idx = 3
         update #tc_amt set amt_plan = @TcAmt4 where idx = 4
         update #tc_amt set amt_plan = @TcAmt9 where idx = 9
      end
      else if @JobType = 'est'
      begin
         update #tc_amt set amt_est = @TcAmt1 where idx = 1
         update #tc_amt set amt_est = @TcAmt2 where idx = 2
         update #tc_amt set amt_est = @TcAmt3 where idx = 3
         update #tc_amt set amt_est = @TcAmt4 where idx = 4
         update #tc_amt set amt_est = @TcAmt9 where idx = 9
      end
      else if @JobType = 'std'
      begin
         update #tc_amt set amt_std = @TcAmt1 where idx = 1
         update #tc_amt set amt_std = @TcAmt2 where idx = 2
         update #tc_amt set amt_std = @TcAmt3 where idx = 3
         update #tc_amt set amt_std = @TcAmt4 where idx = 4
         update #tc_amt set amt_std = @TcAmt9 where idx = 9
      end
      else /*if @JobType = 'frz'*/
      begin
         update #tc_amt set amt_frz = @TcAmt1 where idx = 1
         update #tc_amt set amt_frz = @TcAmt2 where idx = 2
         update #tc_amt set amt_frz = @TcAmt3 where idx = 3
         update #tc_amt set amt_frz = @TcAmt4 where idx = 4
         update #tc_amt set amt_frz = @TcAmt9 where idx = 9
      end

      --
      -- loop for each jobmatl
      --
      declare Job03bCrs2 cursor local static for
         select
            jobmatl.RowPointer ,jobmatl.effect_date ,jobmatl.obs_date ,jobmatl.matl_type
            ,jobmatl.units ,jobmatl.matl_qty ,jobmatl.scrap_fact ,jobmatl.cost
            ,jobmatl.item ,jobmatl.fmatlovhd ,jobmatl.vmatlovhd
         from jobmatl join jobroute on
            jobroute.job = jobmatl.job
            and jobroute.suffix = jobmatl.suffix
            and jobroute.oper_num = jobmatl.oper_num
            and jobroute.RowPointer = @JobrouteRowPointer
      open Job03bCrs2
      while @Severity = 0
      begin
         fetch Job03bCrs2 into
            @JobmatlRowPointer, @JobmatlEffectDate, @JobmatlObsDate, @JobmatlMatlType
            ,@JobmatlUnits, @JobmatlMatlQty, @JobmatlScrapFact, @JobmatlCost
            ,@JobmatlItem, @JobmatlFmatlovhd, @JobmatlVmatlovhd
         if @@FETCH_STATUS = -1 break

         if (@JobmatlEffectDate > dbo.GetSiteDate(getdate())) or (@JobmatlObsDate <= dbo.GetSiteDate(getdate())) continue

	 if @JobmatlMatlType = 'M' set @i = 5
         else if @JobmatlMatlType = 'F' set @i = 6
         else if @JobmatlMatlType = 'T' set @i = 7
         else if @JobmatlMatlType ='O' and @WcOutside = 1 set @i = 4
	 else /* if @JobmatlMatlType = 'O' */ set @i = 8

         set @TcAmt = 0
         set @TcAmt = dbo.ReqQty (@TcAmt1, @JobmatlUnits ,@JobmatlMatlQty, 1, @JobmatlScrapFact)
         set @TcAmt = @TcAmt *  @JobmatlCost

         if @JobType = 'plan'
            update #tc_amt set amt_plan = amt_plan + case when @TcAmt is not null then @TcAmt else 0 end where idx = @i
         else if @JobType = 'est'
            update #tc_amt set amt_est = amt_est + case when @TcAmt is not null then @TcAmt else 0 end where idx = @i
         else if @JobType = 'std'
           update #tc_amt set amt_std = amt_std + case when @TcAmt is not null then @TcAmt else 0 end where idx = @i
         else /*if @JobType = 'frz'*/
           update #tc_amt set amt_frz = amt_frz + case when @TcAmt is not null then @TcAmt else 0 end where idx = @i

         --
         -- determine matl overhead based on units per unit or per lot
         --
         if exists (select 1 from item where item.item = @JobmatlItem) and charindex('M', @WcOverhead) > 0
         begin
            set @TcAmt = 0
            set @TcAmt = dbo.ReqQty (@TcAmt1, @JobmatlUnits ,@JobmatlMatlQty, 1, @JobmatlScrapFact)
            set @TcAmt = @TcAmt *  @JobmatlCost * (@JobmatlFmatlovhd + @JobmatlVmatlovhd)

            if @JobType = 'plan'
               update #tc_amt set amt_plan = amt_plan + case when @TcAmt is not null then @TcAmt else 0 end where idx = 9
            else if @JobType = 'est'
               update #tc_amt set amt_est = amt_est + case when @TcAmt is not null then @TcAmt else 0 end where idx = 9
            else if @JobType = 'std'
              update #tc_amt set amt_std = amt_std + case when @TcAmt is not null then @TcAmt else 0 end where idx = 9
            else /*if @JobType = 'frz'*/
              update #tc_amt set amt_frz = amt_frz + case when @TcAmt is not null then @TcAmt else 0 end where idx = 9
         end

      -- end of loop for each jobmatl
      end
      close Job03bCrs2
      deallocate Job03bCrs2

   -- End of jobroute loop
   end
   close      Job03bCrs
   deallocate Job03bCrs
GO