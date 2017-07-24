SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Code extracted from po/lcap2.p (selection = "GENERATE") 
--
-- Handled in client:
--   Initial prompt for proceeding
--   Check for no records selected
--   Check for pochange records of stat <> 'P' (Actual code in
--   GenerateLCVouchersPocWarnSp .)
--

/* $Header: /ApplicationDB/Stored Procedures/GenerateLCVouchersPostUpdSp.sp 10    6/02/04 4:31a Hcl-dubeami $  */
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
CREATE PROCEDURE [dbo].[GenerateLCVouchersPostUpdSp] 
AS

DECLARE
  @Severity        INT
, @TmpSeverity     INT
, @Infobar         InfobarType
, @CleanUpMsg      InfobarType
, @ActiveForPurch1 FlagNyType
, @ActiveForPurch2 FlagNyType
, @VendNum         VendNumType
, @CurPoNum        PoNumType
, @CurTrnNum       PoTrnNumType
, @RefNum          PoTrnNumType
, @BrokerageAcct   AcctType
, @DutyAcct        AcctType
, @FreightAcct     AcctType
, @LocFrtAcct      AcctType
, @InsuranceAcct   AcctType
, @RefType         RefTypePTType
, @LcType          LcTypeType
, @AmtApplied      AmountType
, @AmtDuty         AmountType
, @AmtFreight      AmountType
, @AmtBrokerage    AmountType
, @AmtLocFreight   AmountType
, @AmtInsurance    AmountType
, @TmpFreight      AmountType
, @TmpBrokerage    AmountType
, @TmpDuty         AmountType 
, @TmpLocFreight   AmountType
, @TmpInsurance    AmountType
, @SumFreight      AmountType
, @TSalesTax1      AmountType
, @TSalesTax2      AmountType
, @InvoiceDate     GenericDateType
, @GLDistDate      GenericDateType
, @VendorInvoice   VendInvNumType
, @SumBrokerage    AmountType
, @SumDuty         AmountType
, @SumLocFreight   AmountType
, @SumInsurance    AmountType
, @AmtTax1         AmountType
, @AmtTax2         AmountType 
, @TaxDistRecordsExist INT
, @BufferJournal RowPointerType
 
SELECT 
  @Severity = 0
, @Infobar = NULL
, @CleanUpMsg = NULL
, @CurPoNum = NULL
, @TmpFreight = 0
, @TmpBrokerage = 0
, @TmpDuty = 0
, @TmpLocFreight = 0          
, @TmpInsurance = 0           
, @SumFreight = 0
, @SumBrokerage = 0
, @SumDuty = 0
, @SumLocFreight = 0          
, @SumInsurance  = 0          
, @ActiveForPurch1 = 0
, @ActiveForPurch2 = 0
, @BrokerageAcct = NULL
, @DutyAcct = NULL
, @FreightAcct = NULL
, @LocFrtAcct = NULL     
, @InsuranceAcct = NULL      
, @TaxDistRecordsExist = 0

exec dbo.JournalDeferSp
  @Partition = @BufferJournal output
, @Infobar = @Infobar output

-- If Session variable VendNum is not defined, then this is not
-- from activity Generate Landed Cost Vouchers

IF dbo.VariableIsDefined('VendNum') = 0
BEGIN
  EXEC @Severity = dbo.MsgAppSp 
       @Infobar OUTPUT, 
       'E=VariableNotDefined'
      ,'@!VendNum'

END
ELSE
BEGIN
   SELECT 
     @VendNum = dbo.DefinedValue('VendNum')
   , @AmtDuty = CONVERT(decimal(18,8), ISNULL(dbo.DefinedValue('AmtDuty'), 0))
   , @AmtFreight = CONVERT(decimal(18,8), ISNULL(dbo.DefinedValue('AmtFreight'), 0)) 
   , @AmtBrokerage = CONVERT(decimal(18,8), ISNULL(dbo.DefinedValue('AmtBrokerage'), 0))
   , @AmtLocFreight = CONVERT(decimal(18,8), ISNULL(dbo.DefinedValue('AmtLocFreight'), 0))
   , @AmtInsurance = CONVERT(decimal(18,8), ISNULL(dbo.DefinedValue('AmtInsurance'), 0)) 
   , @InvoiceDate = CONVERT(datetime, dbo.DefinedValue('InvoiceDate'))
   , @GLDistDate = CONVERT(datetime, dbo.DefinedValue('GLDistDate'))
   , @VendorInvoice  = dbo.DefinedValue('VendorInvoice')
   , @AmtTax1 = CONVERT(decimal(18,8), ISNULL(dbo.DefinedValue('AmtTax1'), 0))
   , @AmtTax2 = CONVERT(decimal(18,8), ISNULL(dbo.DefinedValue('AmtTax2'), 0))

END
-- Main processing code block (Not a real loop. Only execute block of code once)
WHILE @Severity = 0
BEGIN
   IF OBJECT_ID('tempdb..#GenerateLCVouchers') IS NULL
   BEGIN
    EXEC @Severity = dbo.MsgAppSp 
       @Infobar OUTPUT, 
       'E=Msg'
      ,'@!GenerateLcVchrNotFound'

      BREAK
   END
        
   -- LOOP THROUGH ALL SELECTED RECORDS AND PERFORM SUMMATIONS
   DECLARE
      GenerateLCVouchersCrs1 CURSOR LOCAL STATIC READ_ONLY
   FOR SELECT
     glc.RefNum
   , glc.AmtApplied
   , glc.LcType
   , glc.RefType
   FROM #GenerateLCVouchers AS glc

   OPEN GenerateLCVouchersCrs1
   WHILE @Severity = 0
   BEGIN
      FETCH GenerateLCVouchersCrs1 INTO
        @RefNum
      , @AmtApplied
      , @LcType
      , @RefType

      IF @@FETCH_STATUS <> 0
         BREAK

      IF @RefType = 'P' AND 
         EXISTS (SELECT 1
                 FROM  po
                 WHERE po.po_num = @RefNum)
      BEGIN
         SET @CurPoNum = @RefNum
      END
      ELSE
      BEGIN
         SET @CurTrnNum = @RefNum
      END

      IF @LcType = 'F'
      BEGIN
         SET @TmpFreight = @TmpFreight + @AmtApplied
         SET @SumFreight = @SumFreight + @AmtApplied
      END
      ELSE IF @LcType = 'D'
      BEGIN
         SET @TmpDuty = @TmpDuty + @AmtApplied
         SET @SumDuty = @SumDuty + @AmtApplied
      END
      ELSE IF @LcType = 'B'
      BEGIN
         SET @TmpBrokerage = @TmpBrokerage + @AmtApplied
         SET @SumBrokerage = @SumBrokerage + @AmtApplied
      END
      ELSE IF @LcType = 'L'
      BEGIN
         SET @TmpLocFreight = @TmpLocFreight + @AmtApplied
         SET @SumLocFreight = @SumLocFreight + @AmtApplied
      END
      ELSE IF @LcType = 'I'
      BEGIN
         SET @TmpInsurance = @TmpInsurance + @AmtApplied
         SET @SumInsurance = @SumInsurance + @AmtApplied
      END
   END
   CLOSE GenerateLCVouchersCrs1
   DEALLOCATE GenerateLCVouchersCrs1

   -- Check for inconsistencies
   If @TmpFreight <> @AmtFreight  
   BEGIN 
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
            
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=MustCompare='
           , '@!FreightVoucherAmount' 
           , '@!FreightInvoiceAmount' 
            
      IF @Severity <> 0 
         BREAK        
   END
   IF @TmpDuty <> @AmtDuty  
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
           
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=MustCompare='
            , '@!DutyVoucherAmount' 
            , '@!DutyInvoiceAmount' 

      IF @Severity <> 0 
         BREAK        
   END
   IF @TmpBrokerage <> @AmtBrokerage  
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
            
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=MustCompare='
            , '@!BrokerageVoucherAmount' 
            , '@!BrokerageInvoiceAmount' 

      IF @Severity <> 0 
         BREAK        
   END
   IF @TmpInsurance <> @AmtInsurance  
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
            
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=MustCompare='
            , '@!InsuranceVoucherAmount' 
            , '@!InsuranceInvoiceAmount' 

      IF @Severity <> 0 
         BREAK        
   END
   IF @TmpLocFreight <> @AmtLocFreight  
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
            
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=MustCompare='
            , '@!LocFreightVoucherAmount' 
            , '@!LocFreightInvoiceAmount' 

      IF @Severity <> 0 
         BREAK        
   END


  

   --
   -- Call Lcap2tgSp to Generate tax distributions for a Landed Cost voucher
   --

   SELECT @ActiveForPurch1 = txs.active_for_purch
   FROM   tax_system AS txs
   WHERE  txs.tax_system = 1

   SELECT @ActiveForPurch2 = txs.active_for_purch
   FROM   tax_system AS txs
   WHERE  txs.tax_system = 2

   SELECT @TaxDistRecordsExist = COUNT(*) FROM tmp_lc_tax_dist 
          WHERE SessionId = dbo.SessionIDSp()


   IF ((@ActiveForPurch1 = 1 OR @ActiveForPurch2 = 1) AND @TaxDistRecordsExist = 0)
   BEGIN
      EXEC @Severity = dbo.Lcap2tgSp 
             @CurPoNum
           , @VendNum
           , @SumFreight    
           , @SumBrokerage
           , @SumDuty
           , @SumLocFreight       
           , @SumInsurance         
           , @InvoiceDate
           , 0
           , @TSalesTax1  OUTPUT
           , @TSalesTax2  OUTPUT
           , @Infobar     OUTPUT    

      IF @Severity <> 0
         BREAK
   END

   -- Get Parm Acct info (Check where condition here)
   SELECT 
     @BrokerageAcct = pop.brokerage_acct
   , @DutyAcct = pop.duty_acct
   , @FreightAcct = pop.freight_acct
   , @LocFrtAcct  = pop.local_frt_acct      
   , @InsuranceAcct = pop.Insurance_acct       
   FROM poparms AS pop
   WHERE pop.parm_key = 0

   -- Validate acct used in second .p so KNOW it will execute completely
   SET @Infobar = NULL
   IF @AmtBrokerage <> 0.0 AND @BrokerageAcct IS NULL  
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
            
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare='
           , '@poparms.brokerage_acct' 
           , @BrokerageAcct  
   END
   ELSE IF @AmtDuty <> 0.0 AND @DutyAcct IS NULL  
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
            
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare='
           , '@poparms.duty_acct' 
           , @DutyAcct  
   END
   ELSE IF @AmtFreight <> 0.0 AND @FreightAcct IS NULL  
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
             
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare='
           , '@poparms.freight_acct' 
           , @FreightAcct  
   END
   ELSE IF @AmtLocFreight <> 0.0 AND @LocFrtAcct IS NULL  
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
             
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare='
           , '@poparms.local_frt_acct' 
           , @FreightAcct  
   END
   ELSE IF @AmtInsurance <> 0.0 AND @InsuranceAcct IS NULL  
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed'
           , '@!GenerateVoucher' 
             
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare='
           , '@poparms.insurance_acct' 
           , @FreightAcct  
   END

   IF @Severity <> 0
      BREAK
   -----------------------------------------------------
   -- Skip this section for now
   --   IF has-extfin and CAN-DO(CALL-avail,'ext-efas')  
   -----------------------------------------------------
   ----------------------
   -- Run LcapGenSp
   ----------------------
   EXEC @Severity = dbo.LcapGenSp
     @VendNum
   , @InvoiceDate
   , @GLDistDate
   , @VendorInvoice
   , @AmtDuty
   , @AmtFreight
   , @AmtBrokerage
   , @AmtLocFreight    
   , @AmtInsurance     
   , @CurPoNum
   , @Infobar OUTPUT

   BREAK -- End main control block
END -- Main processing block

-- Do Transaction Clean-up

IF OBJECT_ID('tempdb..#GenerateLCVouchers') IS NOT NULL
   DROP TABLE #GenerateLCVouchers

EXEC @TmpSeverity = dbo.UndefineVariableSp 'VendNum', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'InvoiceDate', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'GLDistDate', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'VendorInvoice', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'VendExchRate', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'AmtBrokerage', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'AmtDuty', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'AmtFreight', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'AmtLocFreight', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'AmtInsurance', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'AmtTax1', @CleanUpMsg OUTPUT
EXEC @TmpSeverity = dbo.UndefineVariableSp 'AmtTax2', @CleanUpMsg OUTPUT

exec dbo.JournalImmediateSp
  @Partition = @BufferJournal
, @Infobar = @Infobar output

IF @Severity <> 0 OR @TmpSeverity <> 0
BEGIN
   IF @Severity = 0
      SET @Severity = @TmpSeverity
   IF @Infobar IS NULL AND @CleanUpMsg IS NOT NULL
      SET @Infobar = @CleanUpMsg
   EXEC dbo.RaiseErrorSp @Infobar, @Severity, 1
END      

RETURN @Severity
GO