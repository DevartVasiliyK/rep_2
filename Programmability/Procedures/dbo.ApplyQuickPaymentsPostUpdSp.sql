SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApplyQuickPaymentsPostUpdSp.sp 3     4/07/04 11:18p Hcl-samujob $  */
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
CREATE PROCEDURE [dbo].[ApplyQuickPaymentsPostUpdSp] 
AS

DECLARE
  @Severity                 INT
, @Infobar                  InfobarType
, @Error               INT
, @Error1               INT
, @amount               AmountType
, @AmountPosted            AmountType   
, @AppmtBankCode         BankCodeType
, @AppmtCheckDate         DateType
, @AppmtCheckSeq         ApCheckSeqType
, @AppmtDueDate            DateType
, @AppmtExchRate         ExchRateType
, @AppmtPayType            AppmtPayTypeType
, @AppmtRowPointer         RowPointerType
, @AppmtVendNum            VendNumType
, @AptrxpAmtPaid         AmountType
, @AptrxpType            AptrxpTypeType
, @AptrxpVoucher         VoucherType
, @BankHdrCurrCode         CurrCodeType
, @CurrparmsCurrCode      CurrCodeType 
, @DomPaidAmount         AmountType
, @DomPaidAmountNeg         AmountType
, @ExchangeRate            ExchRateType
, @ForPaidAmount         AmountType
, @ForPaidAmountNeg         AmountType
, @ottvchpckApplyVendNum   VendNumType
, @ottvchpckAptrxpType      AptrxpTypeType
, @ottvchpckCheckNum      ApCheckNumType
, @ottvchpckRowPointer      RowPointerType
, @ottvchpckSite         SiteType
, @ottvchpckVendNum         VendNumType
, @ottvchpckVoucher         VoucherType
, @ottvchpckVouchSeq      VouchSeqType
, @Success               ListYesNoType
, @tAcct               AcctType
, @tAcctUnit1            UnitCode1Type
, @tAcctUnit2            UnitCode2Type
, @tAcctUnit3            UnitCode3Type
, @tAcctUnit4            UnitCode4Type
, @tAppmtRef            ReferenceType
, @tAptrxpRowid            RowPointerType
, @tAptrxpVend            VendNumType
, @tCreated                GenericNoType
, @tDeleted                GenericNoType
, @tDomBank               ListYesNoType
, @tUpdated                GenericNoType
, @Text                  DescriptionType
, @tmpDate               DateType
, @TmpInfobar            InfobarType
, @TmpSeverity            Int
, @tOpenCheckNum         ApCheckNumType
, @tOpenIsDone            ListYesNoType
, @ToSite               SiteType
, @ToVoucher            VoucherType
, @tPayType               DescriptionType
, @tvsite               SiteType
, @tvvoucher            VoucherType
, @VendcatRowPointer      RowPointerType
, @VendorCategory         CategoryType
, @vttvchpckExchRate      ExchRateType
, @vttvchpckRowPointer      RowPointerType
, @vttvchpckSite         SiteType
, @vttvchpckVoucher         VoucherType
, @xttvchpckAppmtRowPointer   RowPointerType
, @xttvchpckSite         SiteType
, @xttvchpckVoucher         VoucherType
, @VendorCurrCode         CurrCodeType

declare
  @ControlPrefix JourControlPrefixType
, @ControlSite SiteType
, @ControlYear FiscalYearType
, @ControlPeriod FinPeriodType
, @ControlNumber LastTranType

SET @Severity = 0
SET @Infobar = NULL
SET @Error = 0
SET @Error1 = 0

SELECT TOP 1
   @CurrparmsCurrCode = currparms.curr_code
FROM currparms

IF OBJECT_ID('tempdb..#ApplyAPQuickPayments') IS NULL
BEGIN
   SET @Infobar = 'Temp table #ApplyAPQuickPayments Not Found'
   SET @Severity = 16
   SET @Error = 1
END

select top 1 @AppmtRowPointer = DerAppmtRowPointer
from #ApplyAPQuickPayments

-- Main processing code block 
WHILE @Error = 0
BEGIN
   --Find oldest Open payment

   SET   @xttvchpckAppmtRowPointer = NULL
   
   SELECT Top 1
      @xttvchpckVoucher = trxp.Voucher,
      @xttvchpckSite = trxp.SiteRef,
      @xttvchpckAppmtRowPointer = trxp.DerAppmtRowPointer
   FROM #ApplyAPQuickPayments as trxp
   WHERE DerSelected = 1
     and trxp.DerAptrxpTypeDesc = 'O'
     and trxp.DerDomAmtPaid <> 0
   ORDER BY trxp.DueDate

   SET @Severity = @@ERROR

   IF @Severity <> 0 Or @xttvchpckAppmtRowPointer IS NULL
      BREAK

   SELECT
      @AppmtRowPointer = appmt.RowPointer,
      @AppmtPayType = appmt.pay_type,
      @AppmtVendNum = appmt.vend_num,
      @AppmtBankCode = appmt.bank_code,
      @AppmtCheckSeq = appmt.check_seq,
      @AppmtCheckDate = appmt.check_date,
      @AppmtDueDate = appmt.due_date,
      @AppmtExchRate = appmt.exch_rate
   FROM appmt
   WHERE
      appmt.RowPointer =    @xttvchpckAppmtRowPointer
            
   SELECT 
      @BankHdrCurrCode = bank_hdr.curr_code
   FROM bank_hdr
   WHERE
      bank_hdr.bank_code = @AppmtBankCode      
         
   IF @CurrparmsCurrCode = @BankHdrCurrCode
      SET @tDomBank = 1
   ELSE
      SET @tDomBank = 0

   SELECT 
      @VendorCategory = vendor.category
   FROM vendor
   WHERE
      vendor.vend_num = @AppmtVendNum
      
   SET @ToVoucher = @xttvchpckVoucher
   SET @ToSite = @xttvchpckSite
   SET @Error1 = 0

   WHILE @Error1 = 0
   BEGIN
      -- Find vouchers to be re-applied

      -- Get the oldest one
      SET @vttvchpckRowPointer = NULL

      SELECT Top 1
         @vttvchpckVoucher = trxp.Voucher,
         @vttvchpckSite = trxp.SiteRef,
         @vttvchpckExchRate = trxp.ExchRate,
         @vttvchpckRowPointer = trxp.DerAppmtRowPointer
      FROM #ApplyAPQuickPayments as trxp
      WHERE
         trxp.DerSelected = 1
         and trxp.DerAptrxpTypeDesc = 'V'
         and trxp.DerDomAmtPaid <> 0
      ORDER BY trxp.DueDate

      SET @Severity = @@ERROR
         
      IF @Severity = 0 And @vttvchpckRowPointer IS NOT NULL
      BEGIN
         SET @tvvoucher = @vttvchpckVoucher
         SET @tvsite = @vttvchpckSite
         
         -- apply the open payment to the voucher
         SET @ottvchpckRowPointer = NULL

         SELECT
            @ottvchpckApplyVendNum = trxp.DerApplyVendNum,
            @ottvchpckVendNum = trxp.VendNum,
            @ottvchpckVoucher = trxp.Voucher,
            @ottvchpckVouchSeq = trxp.VouchSeq,
            @ottvchpckCheckNum = trxp.CheckNum,
            @ottvchpckAptrxpType = trxp.DerAptrxpTypeDesc,
            @ottvchpckRowPointer = trxp.DerAppmtRowPointer,
            @ottvchpckSite = trxp.SiteRef
         FROM #ApplyAPQuickPayments as trxp
         WHERE
            trxp.DerBankCode = @AppmtBankCode
            and trxp.VendNum = @AppmtVendNum
            and trxp.DerCheckSeq = @AppmtCheckSeq
            and trxp.Voucher = @ToVoucher
            and trxp.SiteRef = @ToSite
               
         SET @Severity = @@ERROR
            
         IF @Severity <> 0 Or @ottvchpckRowPointer IS NULL
         BEGIN
            SET @Error1 = 1   
            BREAK
         END
            
         IF not EXISTS(SELECT 1
                     FROM #ApplyAPQuickPayments as trxp
                     WHERE
                        trxp.DerBankCode = @AppmtBankCode
                        and trxp.VendNum = @AppmtVendNum
                        and trxp.DerCheckSeq = @AppmtCheckSeq
                        and trxp.Voucher = @tvvoucher
                        and trxp.SiteRef = @tvsite)
         BEGIN
            SET @Error1 = 1   
            BREAK
         END
            
         IF @ottvchpckApplyVendNum IS NOT NULL And @ottvchpckApplyVendNum is not null
            SET @tAptrxpVend = @ottvchpckApplyVendNum
         ELSE
            SET @tAptrxpVend = @ottvchpckVendNum

         SET @tAptrxpRowid = NULL
            
         SELECT TOP 1
            @tAptrxpRowid = aptrxp.RowPointer
            ,@AptrxpType = aptrxp.type
            ,@AptrxpVoucher = aptrxp.voucher
            ,@tAcct = aptrxp.ap_acct
            ,@tAcctUnit1 = aptrxp.ap_acct_unit1
            ,@tAcctUnit2 = aptrxp.ap_acct_unit2
            ,@tAcctUnit3 = aptrxp.ap_acct_unit3
            ,@tAcctUnit4 = aptrxp.ap_acct_unit4
         FROM aptrxp
         WHERE
            aptrxp.vend_num = @tAptrxpVend
            and aptrxp.voucher = @ottvchpckVoucher

         IF @tAptrxpRowid IS NOT NULL -- And @AptrxpType = 'O'
         BEGIN
            SET @tAppmtRef = 'APPR ' + @ottvchpckVendNum
            SET @tOpenCheckNum = @ottvchpckCheckNum
            SET @ExchangeRate = @vttvchpckExchRate
         END
         ELSE
         BEGIN
            SET @Infobar = NULL

            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT   , 'E=NoExist4'
                                                , '@aptrxp'
                                                , '@aptrxp.vend_num'
                                                , @tAptrxpVend
                                                , '@aptrxp.voucher'
                                                , @ottvchpckVoucher
                                                , '@aptrxp.vouch_seq'
                                                , @ottvchpckVouchSeq
                                                , '@aptrxp.check_num'
                                                , @ottvchpckCheckNum
                                 
            SET @Error1 = 1
            BREAK
         END
            
         IF @AppmtPayType = 'T' Or @AppmtPayType = 'N'
            SET @tPayType = 'draft'
         ELSE
            SET @tPayType = ''
               
         IF @tPayType = 'draft'
            IF @VendorCategory IS NOT NULL And @VendorCategory is not null
            BEGIN
               SET @VendcatRowPointer = NULL
                  
               SELECT TOP 1
                  @VendcatRowPointer = vendcat.RowPointer
                  ,@tAcct = vendcat.draft_payable_acct
                  ,@tAcctUnit1 = vendcat.draft_payable_acct_unit1
                  ,@tAcctUnit2 = vendcat.draft_payable_acct_unit2
                  ,@tAcctUnit3 = vendcat.draft_payable_acct_unit3
                  ,@tAcctUnit4 = vendcat.draft_payable_acct_unit4
               FROM vendcat
               WHERE
                  vendcat.category = @VendorCategory

               IF @VendcatRowPointer IS NULL
               BEGIN
                  SET @Infobar = NULL

                  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT   , 'E=NoExist1'
                                                      , '@vendcat'
                                                      , '@vendcat.category'
                                                      , @VendorCategory
                                       
                  SET @Error1 = 1
                  BREAK
               END

               IF @tAcct IS NULL Or @tAcct = ''
               BEGIN
                  SET @Infobar = NULL

                  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT   , 'E=NoCompare'
                                                      , '@vendcat.draft_payable_acct'
                                                      , @tAcct
                                       
                  SET @Error1 = 1
                  BREAK
               END
            END
            ELSE
            BEGIN
               SELECT TOP 1
                  @tAcct = apparms.draft_payable_acct
                  ,@tAcctUnit1 = apparms.draft_payable_acct_unit1
                  ,@tAcctUnit2 = apparms.draft_payable_acct_unit2
                  ,@tAcctUnit3 = apparms.draft_payable_acct_unit3
                  ,@tAcctUnit4 = apparms.draft_payable_acct_unit4
               FROM apparms

               IF @tAcct IS NULL Or @tAcct = ''
               BEGIN
                  SET @Infobar = NULL

                  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT   , 'E=NoCompare'
                                                      , '@apparms.draft_payable_acct'
                                                      , @tAcct
                                       
                  SET @Error1 = 1
                  BREAK
               END
            END
            
         IF @tAcct is null Or NOT EXISTS (SELECT 1
                                 FROM chart
                                 WHERE
                                    chart.acct = @tAcct)
         BEGIN
            SET @Infobar = NULL
            SET @Text = '@:AptrxpType:' + @ottvchpckAptrxpType

            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT   , 'E=NoExistForIs4'
                                                , '@chart'
                                                , '@chart.acct'
                                                , @tAcct
                                                , '@aptrxp'
                                                , '@aptrxp.vend_num'
                                                , @AppmtVendNum
                                                , '@aptrxp.voucher'
                                                , @AptrxpVoucher
                                                , '@aptrxp.type'
                                                , @Text
                                                 , '@aptrxp.check_num'
                                                , @ottvchpckCheckNum
                                       
            SET @Error1 = 1
            BREAK
         END
         
         IF @tPayType = 'draft'
            SET @tmpDate = @AppmtDueDate
         ELSE
            SET @tmpDate = @AppmtCheckDate

         EXEC @Severity = dbo.ChkAcctSp @tAcct , @tmpDate
                                    , @Infobar OUTPUT

         IF @Severity <> 0
         BEGIN
            SET @Error1 = 1
            BREAK
         END
            
         EXEC @Severity = dbo.ChkUnitSp @tAcct , @tAcctUnit1
                                    , @tAcctUnit2
                                    , @tAcctUnit3
                                    , @tAcctUnit4
                                    , @Infobar OUTPUT

         IF @Severity <> 0
         BEGIN
            SET @Error1 = 1
            BREAK
         END

            SET @AmountPosted = 0
            SET @DomPaidAmount = 0
            SET @ForPaidAmount = 0

         SET @Success = 0
         SET @tOpenIsDone = 0

         exec @Severity = dbo.NextControlNumberSp
           @JournalId = 'AP Dist'
         , @TransDate = @AppmtCheckDate
         , @ControlPrefix = @ControlPrefix output
         , @ControlSite = @ControlSite output
         , @ControlYear = @ControlYear output
         , @ControlPeriod = @ControlPeriod output
         , @ControlNumber = @ControlNumber output
         , @Infobar = @Infobar OUTPUT

         EXEC @Severity = dbo.Sitpmtp2Sp
           @TVVchpckSite = @vttvchpckSite
         , @TVVchpckVoucher = @vttvchpckVoucher
         , @TOVchpckSite = @ottvchpckSite
         , @TOVchpckVoucher = @ottvchpckVoucher
         , @RowidAppmt = @xttvchpckAppmtRowPointer
         , @WireExchangeRate = @ExchangeRate
         , @ControlPrefix = @ControlPrefix
         , @ControlSite = @ControlSite
         , @ControlYear = @ControlYear
         , @ControlPeriod = @ControlPeriod
         , @ControlNumber = @ControlNumber
         , @CorpAmountPosted = @AmountPosted OUTPUT
         , @DomPaidAmount = @DomPaidAmount OUTPUT
         , @ForPaidAmount = @ForPaidAmount OUTPUT
         , @Success = @Success OUTPUT
         , @TOpenIsDone = @tOpenIsDone OUTPUT
         , @Infobar = @Infobar OUTPUT

         IF @Success <> 1
            SET @Severity = 16

         IF @Severity <> 0 
         BEGIN
            SET @Error1 = 1
            BREAK
         END

         IF @AppmtExchRate = 0
            SET @ExchangeRate = 1
         ELSE
            SET @ExchangeRate = @AppmtExchRate

         -- Cash - Credit

         SET @DomPaidAmountNeg = - @DomPaidAmount
         SET @ForPaidAmountNeg = - @ForPaidAmount
            
         EXEC @Severity = dbo.JourpostISp
           @id = 'AP Dist'
         , @trans_date = @AppmtCheckDate
         , @acct = @tAcct 
         , @acct_unit1 = @tAcctUnit1
         , @acct_unit2 = @tAcctUnit2
         , @acct_unit3 = @tAcctUnit3
         , @acct_unit4 = @tAcctUnit4
         , @amount = @DomPaidAmountNeg
         , @ref = @tAppmtRef
         , @vend_num = @AppmtVendNum
         , @check_num = @tOpenCheckNum
         , @check_date = @AppmtCheckDate
         , @ref_type = 'P'
         , @curr_code = @BankHdrCurrCode
         , @for_amount = @ForPaidAmountNeg
         , @exch_rate = @ExchangeRate
         , @ControlPrefix = @ControlPrefix
         , @ControlSite = @ControlSite
         , @ControlYear = @ControlYear
         , @ControlPeriod = @ControlPeriod
         , @ControlNumber = @ControlNumber
         , @Infobar = @Infobar OUTPUT

         SELECT
            @AptrxpAmtPaid = aptrxp.amt_paid 
         FROM aptrxp
         WHERE
            aptrxp.RowPointer = @tAptrxpRowid

         select @VendorCurrCode=curr_code from vendor where vend_num=@AppmtVendNum

         IF @tDomBank = 1 AND @VendorCurrCode=@BankHdrCurrCode
            SET @AptrxpAmtPaid = @AptrxpAmtPaid - @DomPaidAmount
         ELSE
            SET @AptrxpAmtPaid = @AptrxpAmtPaid - @ForPaidAmount

         IF @AptrxpAmtPaid = 0
           BEGIN
              DELETE 
              FROM aptrxp
            WHERE
               aptrxp.RowPointer = @tAptrxpRowid
         END
         ELSE
          BEGIN
             UPDATE aptrxp
                SET aptrxp.amt_paid = @AptrxpAmtPaid
            WHERE
               aptrxp.RowPointer = @tAptrxpRowid
         END

         IF @tOpenIsDone = 1
            BREAK
      END
      ELSE
      BEGIN
         SET @Error1 = 1
         BREAK
      END
   END

   IF @Error1 <> 0
   BEGIN
      Set @Error = 1
      BREAK
   END
END      

SET @tUpdated = 0
SET @tCreated = 0
SET @tDeleted = 0

IF @Severity = 0 Or (@Severity <> 0 And @Error = 0)
BEGIN
   DELETE 
   FROM #ApplyAPQuickPayments
   WHERE 
      #ApplyAPQuickPayments.DerAptrxpTypeDesc = 'O'
      
   IF @AppmtRowPointer IS NULL
      EXEC @TmpSeverity = dbo.GetVariableSp 'ApplyQuickPaymentAccount'
                                 , NULL
                                 , 0
                                 , @AppmtRowPointer
                                 , @TmpInfobar OUTPUT 
      
   IF @AppmtRowPointer IS NOT NULL
      EXEC @Severity = dbo.GenerateAppmtdSp @AppmtRowPointer , @tCreated OUTPUT
                                             , @tUpdated   OUTPUT
                                             , @tDeleted   OUTPUT
                                             , @Infobar OUTPUT  


END

IF @Severity = 0
BEGIN
   EXEC @TmpSeverity = dbo.DefineVariableSp 'ApplyQuickPaymentUpdated'
                              , @tUpdated
                              , @TmpInfobar OUTPUT 
   EXEC @TmpSeverity = dbo.DefineVariableSp 'ApplyQuickPaymentCreated'
                              , @tCreated
                              , @TmpInfobar OUTPUT 
   EXEC @TmpSeverity = dbo.DefineVariableSp 'ApplyQuickPaymentDeleted'
                              , @tDeleted
                              , @TmpInfobar OUTPUT 
   SET @Infobar = ''
   EXEC @TmpSeverity = dbo.DefineVariableSp 'ApplyQuickPaymentMessage'
                              , @Infobar
                              , @TmpInfobar OUTPUT 
END      
ELSE
   EXEC @TmpSeverity = dbo.DefineVariableSp 'ApplyQuickPaymentMessage'
                              , @Infobar
                              , @TmpInfobar OUTPUT 

RETURN 0
GO