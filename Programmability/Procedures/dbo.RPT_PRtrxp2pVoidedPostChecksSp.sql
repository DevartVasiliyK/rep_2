SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/RPT_PRtrxp2pVoidedPostChecksSp.sp 3     4/06/04 10:38a Wilala $  */
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
CREATE PROCEDURE [dbo].[RPT_PRtrxp2pVoidedPostChecksSp] (
  @pEmpType             NCHAR(5)
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
     @ContextName = 'RPT_PRtrxp2pVoidedPostChecksSp'
   , @SessionID   = @RptSessionID OUTPUT


DECLARE
  @CheckLabel    	LongListType
, @DirDepLabel   	LongListType
, @FormVoidLabel 	LongListType
, @Severity     	INT
, @TVoid         	GenericNoType
, @TAmt          	PrAmountType
, @UnkEmpLabel   	LongListType


DECLARE
  @EmployeeRowPointer 	RowPointerType
, @EmployeeEmpType    	EmpTypeType
, @EmployeeEmpNum     	EmpNumType
, @EmployeeName      	EmpNameType
, @GlbankRowPointer   	RowPointerType
, @GlbankRefNum       	CustEmpVendNumType
, @GlbankCheckAmt     	AmountType
, @GlbankCheckNum     	GlCheckNumType
, @GlbankType         	GlbankTypeType
, @GlbankCheckDate    	DateType


DECLARE
  @RptTxType            	TINYINT
, @RptPrtrxType			PrtrxTypeType
, @RptPrtrxTypeLabel		LongListType
, @RptCheckNum		        PrCheckNumType
, @RptCheckDate		        DateType
, @RptPrtrxDept			DeptType
, @RptPrtrxEmpNum		EmpNumType
, @RptEmployeeName		EmpNameType
, @RptPrtrxBankCode		BankCodeType
, @RptBankHdrAcct		AcctType
, @RptBankHdrAcctUnit1		UnitCode1Type
, @RptBankHdrAcctUnit2		UnitCode2Type
, @RptBankHdrAcctUnit3		UnitCode3Type
, @RptBankHdrAcctUnit4		UnitCode4Type
, @RptPrtrxNetPay 		PrAmountType
, @RptPrtrxDepAmt    		PrAmountType
, @RptGlbankRefNum		CustEmpVendNumType
, @RptGlbankCheckAmt		AmountType
, @RptGlBankTypeLabel		LongListType
, @RptVoidRefLabel		LongListType



-- Note: TxType below has been added for reporting 1 = Posted Payroll, 2 = Voided Checks, 3= Unposted Payroll

IF OBJECT_ID('tempdb..#RptVoidedPayroll') IS NULL
   SELECT
      @RptTxType AS TxType,
      @RptPrtrxType AS PayType,
      @RptPrtrxTypeLabel AS PayTypeLabel,
      @RptCheckNum AS CheckNum,
      @RptCheckDate AS CheckDate,
      @RptPrtrxDept AS Dept,
      @RptPrtrxEmpNum AS EmpNum,
      @RptEmployeeName AS EmpName,
      @RptPrtrxBankCode AS BankCode,
      @RptBankHdrAcct AS BankHdrAcct,
      @RptBankHdrAcctUnit1 AS BankHdrAcctUnit1,
      @RptBankHdrAcctUnit2 AS BankHdrAcctUnit2,
      @RptBankHdrAcctUnit3 AS BankHdrAcctUnit3,
      @RptBankHdrAcctUnit4 AS BankHdrAcctUnit4,
      @RptPrtrxNetPay AS NetPay,
      @RptPrtrxDepAmt AS DepAmt,
      @RptGlbankRefNum AS BankRefNum,
      @RptGlbankCheckAmt AS CheckAmt,
      @RptGlBankTypeLabel AS GlbankTypeLabel,
      @RptVoidRefLabel AS VoidRefLabel
   INTO
      #RptVoidedPayroll
   WHERE
      1=2

SET @Severity = 0
SET @TVoid    = 0
SET @TAmt     = 0

SET @CheckLabel = dbo.GetLabel ('@!Check')
SET @DirDepLabel = dbo.GetLabel ('@!DirectDeposit')
SET @FormVoidLabel = dbo.GetLabel ('@!FormVoided')
SET @UnkEmpLabel = dbo.GetLabel ('@!Unknown Employee')


-- Check for Voided Checks

DECLARE SelGlbankCrs CURSOR LOCAL STATIC FOR
SELECT
  glbank.RowPointer
, glbank.ref_num
, glbank.check_amt
, glbank.check_num
, glbank.type
, glbank.check_date
FROM glbank
WHERE DATEDIFF(DAY, glbank.post_date, dbo.GetSiteDate(getdate())) = 0
   AND glbank.voided = 1
   AND glbank.ref_type = 'P/R'
   AND CHARINDEX( glbank.type, 'CR') > 0
ORDER BY glbank.post_date, glbank.check_num

OPEN SelGlbankCrs
WHILE @Severity = 0
BEGIN
   FETCH SelGlbankCrs INTO
     @GlbankRowPointer
   , @GlbankRefNum
   , @GlbankCheckAmt
   , @GlbankCheckNum
   , @GlbankType
   , @GlbankCheckDate

   IF @@FETCH_STATUS = -1
       BREAK

   SET @EmployeeRowPointer = NULL
   SET @EmployeeEmpType    = NULL
   SET @EmployeeEmpNum     = NULL
   SET @EmployeeName       = NULL

   SELECT
     @EmployeeRowPointer = employee.RowPointer
   , @EmployeeEmpType    = employee.emp_type
   , @EmployeeEmpNum     = employee.emp_num
   , @EmployeeName       = employee.name
   FROM employee
   WHERE employee.emp_num = @GlbankRefNum

   IF @EmployeeRowPointer IS NOT NULL AND
      CHARINDEX( @EmployeeEmpType, @pEmpType) = 0 AND
      @EmployeeEmpNum <> ''
      CONTINUE


   SET @TVoid = @TVoid + 1
   SET @TAmt = @TAmt - @GlbankCheckAmt

   -- Init Report Values

   SET @RptTxType = 0
   SET @RptPrtrxType = NULL
   SET @RptPrtrxTypeLabel = NULL
   SET @RptCheckNum = 0
   SET @RptCheckDate = NULL
   SET @RptPrtrxDept = NULL
   SET @RptPrtrxEmpNum = 0
   SET @RptEmployeeName = NULL
   SET @RptPrtrxBankCode = NULL
   SET @RptBankHdrAcct = NULL
   SET @RptBankHdrAcctUnit1 = NULL
   SET @RptBankHdrAcctUnit2 = NULL
   SET @RptBankHdrAcctUnit3 = NULL
   SET @RptBankHdrAcctUnit4 = NULL
   SET @RptPrtrxNetPay = 0
   SET @RptPrtrxDepAmt = 0
   SET @RptGlbankRefNum = NULL
   SET @RptGlbankCheckAmt = 0
   SET @RptGlBankTypeLabel = NULL
   SET @RptVoidRefLabel = NULL


   SET @RptTxType = 2	-- Void Checks
   SET @RptCheckNum = @GlbankCheckNum
   IF (@GlbankType = 'C' OR @GlbankType = 'R')
      SET @RptGlBankTypeLabel = @CheckLabel + ',' + @DirDepLabel

   SET @RptCheckDate = @GlbankCheckDate
   SET @RptGlbankCheckAmt = (@GlbankCheckAmt * -1)
   SET @RptGlbankRefNum = @GlbankRefNum

   IF @GlbankRefNum IS NULL
      SET @RptVoidRefLabel = @FormVoidLabel
   ELSE
      IF @EmployeeRowPointer IS NOT NULL
         SET @RptVoidRefLabel = @EmployeeName
      ELSE
         SET @RptVoidRefLabel = @UnkEmpLabel


   INSERT INTO #RptVoidedPayroll
      ( TxType,
        GlbankTypeLabel,
        CheckNum,
        CheckDate,
        CheckAmt,
        BankRefNum,
        VoidRefLabel )
   VALUES
      ( @RptTxType,
        @RptGlbankTypeLabel,
        @RptCheckNum,
        @RptCheckDate,
        @RptGlbankCheckAmt,
        @RptGlbankRefNum,
        @RptVoidRefLabel )

END
CLOSE      SelGlbankCrs
DEALLOCATE SelGlbankCrs /* for each glbank */

-- Load the resultset
SELECT * FROM #RptVoidedPayroll

END_OF_POST:

COMMIT TRANSACTION
EXEC CloseSessionContextSp @SessionID = @RptSessionID
RETURN @Severity
GO