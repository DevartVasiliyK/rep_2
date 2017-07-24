SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/AcctChgSp.sp 4     7/21/04 7:45a Hcl-pandamb $  */
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
Inc. ("; MAPICS; "), (ii) the source code may only be used for so long as customer
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
customer 's termination of software support, customer's license to the source
code will immediately terminate and customer shall return the source code to
MAPICS or prepare and send to MAPICS a written affidavit certifying destruction
of the source code within ten (10) days following the expiration or termination
of customer 's license right to the source code;
(vi) customer may not copy the source code and may only disclose the source code
to its employees or the employees of a MAPICS affiliate or business partner with
which customer contracts for modifications services, but only for so long as
such employees remain employed by customer or a MAPICS affiliate or business
partner and/or only for so long as there is an agreement in effect between
MAPICS and such affiliate or business partner authorizing them to provide
modification services for the source code ("; Authorized; Partner; " a current list
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
CREATE PROCEDURE [dbo].[AcctChgSp] 

AS

Declare
  @Result as int
 ,@NewRawAcctFlds   AcctFieldsType
 ,@OldRawAcctFlds   AcctFieldsType
 ,@NewRawAcctPos1   tinyint
 ,@OldRawAcctPos1   tinyint
 ,@OldRawAcctPos2   tinyint
 ,@NewRawAcctPos2   tinyint 
 ,@NewAcctLen1      tinyint
 ,@OldAcctLen1      tinyint
 ,@NewAcctLen2      tinyint
 ,@OldAcctLen2      tinyint
 ,@NewAcctChar1     tinyint
 ,@NewAcctChar2     tinyint
 ,@OldAcctChar1     tinyint
 ,@OldAcctChar2     tinyint
 ,@NewNilAcct       AcctType
 ,@OldNilAcct       AcctType
 ,@OldFillFmt2      NCHAR
 ,@NewFillFmt2      NCHAR
 ,@NewAcctUseLeadingBlanks NCHAR(1)
 ,@OldAcctUseLeadingBlanks NCHAR(1)

/* Get the new record */
SELECT
    @NewRawAcctFlds   = RawAcctFlds
   ,@NewRawAcctPos1   = RawAcctPos1
   ,@NewRawAcctPos2   = RawAcctPos2
   ,@NewAcctLen1      = AcctLen1
   ,@NewAcctLen2      = AcctLen2
   ,@NewAcctChar1     = AcctChar1
   ,@NewAcctChar2     = AcctChar2
   ,@NewNilAcct       = NilAcct
   ,@NewFillFmt2      = FillFmt2
   ,@NewAcctUseLeadingBlanks = AcctUseLeadingBlanks
      FROM #tmp_Acct
        WHERE rec_type = 'NEW1'


/* Get the old record */
SELECT
    @OldRawAcctFlds   = RawAcctFlds
   ,@OldRawAcctPos1   = RawAcctPos1
   ,@OldRawAcctPos2   = RawAcctPos2
   ,@OldAcctLen1      = AcctLen1
   ,@OldAcctLen2      = AcctLen2
   ,@OldAcctChar1     = AcctChar1
   ,@OldAcctChar2     = AcctChar2
   ,@OldNilAcct       = NilAcct
   ,@OldFillFmt2      = FillFmt2
   ,@OldAcctUseLeadingBlanks = AcctUseLeadingBlanks
      FROM #tmp_Acct
        WHERE rec_type = 'OLD1'

IF(@NewRawAcctFlds <> @OldRawAcctFlds) OR (@NewRawAcctPos1 <> @OldRawAcctPos1)
   OR (@NewRawAcctPos2 <> @OldRawAcctPos2) OR (@NewAcctLen1 <> @OldAcctLen1)
   OR (@NewAcctLen2 <> @OldAcctLen2) OR (@NewAcctChar1 <> @OldAcctChar1)
   OR (@NewAcctChar2 <> @OldAcctChar2) OR (@NewNilAcct <> @OldNilAcct)
   OR (@NewFillFmt2 <> @OldFillFmt2) OR (@NewAcctUseLeadingBlanks <> @OldAcctUseLeadingBlanks)
   RETURN 1
ELSE
   RETURN 0
GO