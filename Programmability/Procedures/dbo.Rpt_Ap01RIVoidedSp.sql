﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/Rpt_Ap01RIVoidedSp.sp 8     4/06/04 10:37a Wilala $  */
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
CREATE PROCEDURE [dbo].[Rpt_Ap01RIVoidedSp] (
  @PPayType NVARCHAR(2) = NULL
) AS
--  Crystal reports has the habit of setting the isolation level to dirty
-- read, so we'll correct that for this routine now.  Transaction management
-- is also not being provided by Crystal, so a transaction is started here.
BEGIN TRANSACTION
SET XACT_ABORT ON

IF dbo.GetIsolationLevel(N'') = N'COMMITTED'
   SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
ELSE 
   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- A session context is created so session variables can be used.
DECLARE
  @RptSessionID RowPointerType

   EXEC InitSessionContextSp
     @ContextName = 'Rpt_Ap01RIVoidedSp'
   , @SessionID   = @RptSessionID OUTPUT

SET @PPayType = ISNULL(@PPayType,'SM')

DECLARE
  @Severity            INT
, @VendaddrName        NameType
, @XVendaddrName       NameType
, @BankHdrRowPointer   RowPointerType
, @BankHdrCurrCode     CurrCodeType
, @BankHdrAcct         AcctType
, @RecordType          GenericMedCodeType
, @GlbankRowPointer    RowPointerType
, @GlbankCheckNum      GlCheckNumType
, @GlbankCheckDate     DateType
, @GlbankCheckAmt      AmountType
, @GlbankBankCode      BankCodeType
, @GlbankRefNum        CustEmpVendNumType
, @GlbankDomCheckAmt   AmountType
, @FormVoided          NameType
, @TVendName           NameType
, @TVendRemitName      NameType
, @TcTotAmt            AmountType
, @TVoidChkCnt         GenericNoType
, @TPayType            NVARCHAR(2)
, @CurrencyFormat          InputMaskType
, @CurrencyPlaces          DecimalPlacesType
, @TotalCurrencyFormat     InputMaskType
, @TotalCurrencyPlaces     DecimalPlacesType
, @DecimalPlaces           TINYINT
, @IntPosition             TINYINT


-- Create Result Table
SELECT
  @RecordType AS RecordType
, @BankHdrCurrCode AS BankHdrCurrCode
, @GlbankCheckNum AS GlbankCheckNum
, @GlbankCheckDate AS GlbankCheckDate
, @GlbankCheckAmt AS GlbankCheckAmt
, @GlbankBankCode AS GlbankBankCode
, @GlbankRefNum AS GlbankRefNum
, @FormVoided AS FormVoided
, @TVoidChkCnt AS VoidChecks
, @TVendName AS TVendName
, @TVendRemitName AS TVendRemitName
, @TcTotAmt AS TcTotAmt
, @CurrencyFormat         As CurrencyFormat
, @CurrencyPlaces         As CurrencyPlaces
, @TotalCurrencyFormat    As TotalCurrencyFormat
, @TotalCurrencyPlaces    As TotalCurrencyPlaces
INTO #tt_post WHERE 1=2

SET @Severity  = 0
SET @FormVoided = dbo.GetLabel('@!FormVoided') -- "(Form Voided)"
SET @TPayType = REPLACE(@PPayType, 'S', 'C')
SET @TVoidChkCnt = 0
SET @TcTotAmt = 0

SELECT TOP 1 @CurrencyPlaces = places, @CurrencyFormat = amt_format,
@TotalCurrencyFormat = amt_tot_format
FROM currency where curr_code = (SELECT TOP 1 curr_code FROM currparms)

SET @CurrencyFormat = dbo.FixMaskForCrystal( @CurrencyFormat, dbo.GetWinRegDecGroup() )

SET @TotalCurrencyFormat = dbo.FixMaskForCrystal( @TotalCurrencyFormat, dbo.GetWinRegDecGroup() )

SET @decimalPlaces = 0

SELECT @IntPosition = CHARINDEX( '.', @TotalCurrencyFormat)
IF @IntPosition > 0
     SET @decimalPlaces = LEN(SUBSTRING( @TotalCurrencyFormat, @IntPosition+1, LEN(@TotalCurrencyFormat)))

SET @TotalCurrencyPlaces = @decimalPlaces

-- Print Void Check/Draft List
DECLARE Appmtp2ISp1Crs CURSOR LOCAL STATIC FOR
SELECT
  glbank.RowPointer
, glbank.dom_check_amt
, glbank.ref_num
, glbank.check_num
, glbank.check_date
, glbank.check_amt
, glbank.bank_code
, vendaddr.name
, xvendaddr.name
FROM glbank
LEFT OUTER JOIN vendor on vendor.vend_num = glbank.ref_num
LEFT OUTER JOIN vendaddr on vendaddr.vend_num = vendor.vend_remit
LEFT OUTER JOIN vendaddr xvendaddr on xvendaddr.vend_num = glbank.ref_num
WHERE dbo.MidnightOfSp(glbank.post_date) = dbo.MidnightOfSp(dbo.GetSiteDate(getdate()))
  AND glbank.voided = 1
  AND glbank.ref_type = 'A/P'
  AND CHARINDEX(glbank.type, @TPayType) > 0
ORDER BY glbank.post_date, glbank.check_num

OPEN Appmtp2ISp1Crs
WHILE @Severity = 0
BEGIN
	FETCH Appmtp2ISp1Crs INTO
	  @GlbankRowPointer
	, @GlbankDomCheckAmt
	, @GlbankRefNum
	, @GlbankCheckNum
	, @GlbankCheckDate
	, @GlbankCheckAmt
	, @GlbankBankCode
	, @VendaddrName
	, @XVendaddrName
	IF @@FETCH_STATUS = -1
		BREAK

	SET @BankHdrRowPointer = NULL
	SET @BankHdrCurrCode   = NULL

	SELECT
	  @BankHdrRowPointer = bank_hdr.RowPointer
	, @BankHdrCurrCode   = bank_hdr.curr_code
	FROM bank_hdr
	WHERE bank_hdr.bank_code = @GlbankBankCode

	SET @TVendName      =  ISNULL(@VendaddrName, @XVendaddrName)
	SET @TVendRemitName = ISNULL(@VendaddrName, '')

	SET @GlbankCheckAmt = -@GlbankCheckAmt

	INSERT INTO #tt_post ( RecordType,
		BankHdrCurrCode, GlbankCheckNum, GlbankCheckDate, GlbankCheckAmt,
		GlbankBankCode, GlbankRefNum, FormVoided, VoidChecks, TVendName, TVendRemitName, TcTotAmt, 
                CurrencyFormat, CurrencyPlaces, TotalCurrencyFormat, TotalCurrencyPlaces )
	VALUES ( 'Voided',
		@BankHdrCurrCode, @GlbankCheckNum, @GlbankCheckDate, @GlbankCheckAmt,
		@GlbankBankCode, @GlbankRefNum, @FormVoided, @TVoidChkCnt, @TVendName, @TVendRemitName, @TcTotAmt, 
                @CurrencyFormat, @CurrencyPlaces, @TotalCurrencyFormat, @TotalCurrencyPlaces )
END
CLOSE      Appmtp2ISp1Crs
DEALLOCATE Appmtp2ISp1Crs

SELECT @TcTotAmt = SUM(GlbankCheckAmt), @TVoidChkCnt = COUNT(*)
FROM #tt_post

UPDATE #tt_post
SET TcTotAmt = @TcTotAmt
, VoidChecks = @TVoidChkCnt

-- Return the result set
SELECT #tt_post.*
FROM #tt_post

COMMIT TRANSACTION
EXEC CloseSessionContextSp @SessionID = @RptSessionID
RETURN @Severity
GO