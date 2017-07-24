SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/PmtpckCustomUpdSp.sp 7     1/09/05 10:08a Hcl-chatpra $  */
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
-- Populate temp table #tt_pmtpck with "selected records" to support 
-- processing code from ar/b-pmtpck.w procedure: do-apply


/* $Archive: /ApplicationDB/Stored Procedures/PmtpckCustomUpdSp.sp $
 *
 * SL7.04 7 85291 Hcl-chatpra Sun Jan 09 10:08:02 2005
 * Unable to apply credit memo with mutliple due date invoice
 * Issue # 85291.
 * Changes made for picking up the due date in Case of Multiplre Due Date Invoice.
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[PmtpckCustomUpdSp] (
  @PBankCode       nvarchar(3)
, @PCustNum        nvarchar(7)
, @PType           nchar(1)
, @PCheckNum       int
, @PInvNum         nvarchar(12) 
, @PInvSeq         int
, @PCheckSeq       int
, @PSite           nvarchar(8)
, @PInvDate        datetime
, @PDueDate        datetime
, @PDiscDate       datetime
, @PCoNum          nvarchar(10)
, @PArtranType     nchar(1)
, @PApplyCustNum   nvarchar(7)
, @PPayType        nchar(1)
, @PTcAmtAmount    decimal(21, 8)
, @PTcAmtOrigAmt   decimal(21, 8)
, @PTcAmtTotPaid   decimal(21, 8)
, @PTcAmtAmtApplied decimal(21, 8)
, @PTcAmtDiscAmt   decimal(21, 8)
, @PTcAmtAllowAmt  decimal(21, 8)
, @PDomAmtApplied  decimal(21, 8)
, @PDomDiscAmt     decimal(21, 8)
, @PDomAllowAmt    decimal(21, 8)
, @PForAmtApplied  decimal(21, 8)
, @PForDiscAmt     decimal(21, 8)
, @PForAllowAmt    decimal(21, 8)
, @PFixedRate      tinyint
, @PExchRate       decimal(12, 7)
, @PDescription    nvarchar(40)
, @PRef            nvarchar(30)
, @PPickFlag       tinyint
, @PAcct           nvarchar(12)
, @PAcctUnit1      nvarchar(4)
, @PAcctUnit2      nvarchar(4)
, @PAcctUnit3      nvarchar(4)
, @PAcctUnit4      nvarchar(4)
, @PDiscAcct       nvarchar(12)
, @PDiscAcctUnit1  nvarchar(4)
, @PDiscAcctUnit2  nvarchar(4)
, @PDiscAcctUnit3  nvarchar(4)
, @PDiscAcctUnit4    nvarchar(4)
, @PDoNum            nvarchar(30)
, @PUseMultiDueDates tinyint
, @PCreditMemoNum  nvarchar(12)   
) AS

DECLARE
  @Severity INT
, @Msg      Infobar

SELECT 
  @Severity = 0

IF @PUseMultiDueDates = 1 
BEGIN
    SELECT @PDueDate = duedate FROM  dbo.ArTermDueGetDate (@PCustNum,@PInvNum,@PInvSeq)
END

INSERT INTO #tt_pmtpck (
  bank_code       
, cust_num        
, type            
, check_num       
, inv_num         
, inv_seq         
, check_seq       
, site            
, inv_date        
, due_date        
, disc_date       
, co_num          
, artran_type     
, apply_cust_num  
, pay_type        
, tc_amt_amount   
, tc_amt_orig_amt 
, tc_amt_tot_paid 
, tc_amt_amt_applied
, tc_amt_disc_amt 
, tc_amt_allow_amt
, dom_amt_applied 
, dom_disc_amt    
, dom_allow_amt   
, for_amt_applied 
, for_disc_amt    
, for_allow_amt   
, fixed_rate      
, exch_rate       
, description     
, ref             
, pick_flag       
, acct            
, acct_unit1      
, acct_unit2      
, acct_unit3      
, acct_unit4      
, disc_acct       
, disc_acct_unit1 
, disc_acct_unit2 
, disc_acct_unit3 
, disc_acct_unit4 
, do_num          
, RowPointer      
, Use_multi_due_dates
, credit_memo_num 
) VALUES (
  @PBankCode       
, @PCustNum        
, @PType           
, @PCheckNum       
, @PInvNum         
, @PInvSeq         
, @PCheckSeq       
, @PSite           
, @PInvDate        
, @PDueDate        
, @PDiscDate       
, @PCoNum          
, @PArtranType     
, @PApplyCustNum   
, @PPayType        
, @PTcAmtAmount    
, @PTcAmtOrigAmt   
, @PTcAmtTotPaid   
, @PTcAmtAmtApplied
, @PTcAmtDiscAmt   
, @PTcAmtAllowAmt  
, @PDomAmtApplied  
, @PDomDiscAmt     
, @PDomAllowAmt    
, @PForAmtApplied  
, @PForDiscAmt     
, @PForAllowAmt    
, @PFixedRate      
, @PExchRate       
, @PDescription    
, @PRef            
, @PPickFlag       
, @PAcct           
, @PAcctUnit1      
, @PAcctUnit2      
, @PAcctUnit3      
, @PAcctUnit4      
, @PDiscAcct       
, @PDiscAcctUnit1  
, @PDiscAcctUnit2  
, @PDiscAcctUnit3  
, @PDiscAcctUnit4  
, @PDoNum          
, newid()
, @PUseMultiDueDates
, @PCreditMemoNum     
)
SET @Severity = @@ERROR

RETURN @Severity
GO