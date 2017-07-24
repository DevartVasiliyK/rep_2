SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/CreateApsPlanDetailROPSp.sp 5     6/29/04 8:20a Hcl-sharnav $ */
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
CREATE PROCEDURE [dbo].[CreateApsPlanDetailROPSp] 
As 

declare
  @NextROPRefNumInt    Int
, @NextROPRefNumStr    NVarChar(20)
, @HrsPerDay           GenericDecimalType 
, @Item                ItemType  
, @OnHand              QtyTotlType
, @PhysicalOnHand      QtyTotlType
, @POOnHand            QtyTotlType
, @PreqOnHand          QtyTotlType
, @ShrinkFlag          ListYesNoType
, @PreqChk             ListYesNoType
, @ReorderQty          QtyTotlType
, @ReorderPoint        QtyUnitType
, @FixedOrderQty       QtyUnitType
, @OrderMultiple       QtyUnitType
, @LeadTime            LeadTimeType
, @VarLead             VarLeadTimeType
, @EarliestPlannedPOReceipt DateType
, @ReorderDueDate      DateType
, @StartDate           DateType
, @MDayNum             MdayNumType
, @Infobar             InfobarType
, @Severity            Int
, @TDate               CurrentDateType   

Set @Infobar = NULL
Set @Severity = 0
Set @NextROPRefNumInt = 1000
Set @TDate = dbo.MidnightOf(dbo.GetSiteDate(getdate()))
Exec @Severity = HrsDaySp   @PShiftID  = 'DSC' 
                           , @PDate     = @TDate
                           , @HrsPerDay = @HrsPerDay OUTPUT
                           , @Infobar   = @Infobar   OUTPUT

Select @ShrinkFlag = shrink_flag, @PreqChk = preq_chk from mrp_parm  

DECLARE ItemCrs CURSOR LOCAL STATIC
FOR SELECT
  item
 , reorder_point
 , fixed_order_qty
 , order_mult
 , lead_time
 , var_lead
 , earliest_planned_po_receipt

FROM item 
WHERE item.use_reorder_point = 1

OPEN ItemCrs
WHILE 1 = 1
BEGIN -- cursor loop
    FETCH ItemCrs INTO
     @Item
    , @ReorderPoint
    , @FixedOrderQty
    , @OrderMultiple
    , @LeadTime
    , @VarLead 
    , @EarliestPlannedPOReceipt
    
    If @@FETCH_STATUS <> 0 
          Break
    Exec @Severity = WhseQtySp    
                    @PItem    = @Item
                  , @PReorder = NULL
                  , @POnHand  = @PhysicalOnHand OUTPUT
                  , @Infobar  = @Infobar OUTPUT

    Select @POOnHand = dbo.MaxQty(0.0,Sum (poitem.qty_ordered - poitem.qty_received - 
                       (poitem.qty_ordered * (case when @ShrinkFlag = 1 then item.shrink_fact else 0.0 end))))
                        from poitem inner join item on poitem.item = item.item
                        left join whse on poitem.whse = whse.whse
                        where poitem.item = @item
                        and poitem.stat in ('P','O')
                        and (whse.whse is null or whse.dedicated_inventory <> 1)
    if @PreqChk = 1
      Select @PreqOnHand = Sum(preqitem.qty_ordered - 
                          (preqitem.qty_ordered * (Case When @ShrinkFlag = 1 then item.shrink_fact else 0.0 end)))
                           from preqitem inner join item on preqitem.item = item.item 
                           left join whse on preqitem.whse = whse.whse
                           where preqitem.item = @Item
                           and preqitem.stat in ('R', 'A', 'S')
                           and (whse.whse is null or whse.dedicated_inventory <> 1)
    Set @OnHand = Isnull(@PhysicalOnHand, 0) + Isnull(@POOnHand, 0) + Isnull(@PreqOnHand, 0)
    Set @ReorderPoint = Isnull(@ReorderPoint, 0)

    If @OnHand < @ReorderPoint
      Begin
        Set @ReorderQty = Isnull(@FixedOrderQty,0)
        If @OrderMultiple is null or @OrderMultiple = 0
          Set @OrderMultiple = @FixedOrderQty
        While (@OnHand + @ReorderQty <= @ReorderPoint)
          Begin
                 Set @ReorderQty = @ReorderQty + @OrderMultiple
          End
        Set @NextROPRefNumStr = 'ROP' + Convert(nvarchar(20),@NextROPRefNumInt)
        Set @NextROPRefNumInt = @NextROPRefNumInt + 1
        Set @LeadTime = Isnull(@LeadTime,0) + Round(((@VarLead * @ReorderQty/@HrsPerDay) + 0.499), 0)

        Select Top 1 @MDayNum = mday_num from mcal where m_date > @TDate order by m_date asc   -- get first Mcal after today
        Select @StartDate = m_date from mcal where mday_num = @MDayNum
        Select @ReorderDueDate = m_date from mcal where mday_num = @MDayNum + @LeadTime

        If @EarliestPlannedPOReceipt is not null 
          Set  @ReorderDueDate = dbo.MaxDate(@ReorderDueDate, @EarliestPlannedPOReceipt)

        Insert into apsplandetail (is_demand, ref_type, ref_num 
                                   , item, top_orderid, start_date, due_date, qty, matltag)
                            values(0, 'N', @NextROPRefNumStr, @Item, @NextROPRefNumStr
                                   , dbo.MidNightOf(@StartDate), @ReorderDueDate, @ReorderQty, 0)
      End
END -- End of cursor loop

CLOSE ItemCrs
DEALLOCATE ItemCrs

Return @Severity
GO