SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/AcctDecConvertSp.sp 11    7/27/04 10:29a Chebru $  */
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
CREATE PROCEDURE [dbo].[AcctDecConvertSp] (
    @pRecTypeDest    NVARCHAR(10)
   ,@pRecTypeSource  NVARCHAR(10)
) AS

DECLARE
  @Template          AcctType
, @AcctLen1          AcctLenType
, @AcctLen2          AcctLenType
, @AcctType1         AcctTypeType
, @AcctType2         AcctTypeType
, @AcctChar1         ListCharIntType
, @AcctChar2         ListCharIntType
, @AcctPos1          AcctPosType
, @AcctPos2          AcctPosType
, @AcctUseLeadingBlanks ListYesNoType


SELECT
     @Template   = Template
   , @AcctLen1   = AcctLen1
   , @AcctLen2   = AcctLen2
   , @AcctType1  = AcctType1
   , @AcctType2  = AcctType2
   , @AcctChar1  = AcctChar1
   , @AcctChar2  = AcctChar2
   , @AcctPos1   = AcctPos1
   , @AcctPos2   = AcctPos2
   , @AcctUseLeadingBlanks = AcctUseLeadingBlanks
     FROM #tmp_Acct
        WHERE rec_type = @pRecTypeSource

UPDATE #tmp_Acct SET
          RawAcctFlds = 1
         ,RawAcctPos1 = 1
         ,AcctLen1    = @AcctLen1
         ,AcctType1   = @AcctType1
         ,AcctChar1   = @AcctChar1
         ,AcctUseLeadingBlanks = @AcctUseLeadingBlanks 
         ,AcctFmt1    = SUBSTRING(@Template,@AcctPos1,@AcctLen1)
         ,NilAcct     = ISNUll(NilAcct,'') + CASE @AcctChar1  
                                             WHEN 0 THEN 
						CASE WHEN  @AcctUseLeadingBlanks = 1   AND CHARINDEX('Z',@Template) > 0 
                                                                 THEN REPLICATE(' ',LEN(AcctFmt1)) 
                                                      WHEN  @AcctUseLeadingBlanks = 0   AND CHARINDEX('Z',@Template) > 0
                                                                 THEN REPLICATE('0',LEN(AcctFmt1))
                                                      ELSE ''    
                                                      END --STRING("", {1}acct-fmt[{1}raw-acct-flds])  
                                             ELSE 
                                                      '' --STRING(+0, {1}acct-fmt[{1}raw-acct-flds])  
                                             END  
        WHERE rec_type = @pRecTypeDest  

IF(@AcctType2 <> '') or (@AcctType2 IS NOT NULL)

UPDATE #tmp_Acct SET
         RawAcctFlds = 2
         ,RawAcctPos2 = 1 + @AcctLen1
         ,AcctLen2    = @AcctLen2
         ,AcctType2   = @AcctType2
         ,AcctChar2   = @AcctChar2
         ,AcctFmt2     = SUBSTRING(@Template,@AcctPos2,@AcctLen2)
         ,NilAcct     = NilAcct + CASE AcctChar2
                                             WHEN 0 THEN '' --STRING("", {1}acct-fmt[{1}raw-acct-flds])
                                                     ELSE '' --STRING(+0, {1}acct-fmt[{1}raw-acct-flds])
                                             END
                  WHERE rec_type = @pRecTypeDest

UPDATE #tmp_Acct SET
        NilAcctOnly = NilAcct
       ,NilSub      = NilAcct
         WHERE rec_type = @pRecTypeDest
GO