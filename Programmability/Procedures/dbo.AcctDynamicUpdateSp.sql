SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/AcctDynamicUpdateSp.sp 4     11/09/04 4:38a Hcl-agrajai $  */
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
CREATE PROCEDURE [dbo].[AcctDynamicUpdateSp] (
 @TableName       NVARCHAR(100)
,@FieldName1      NVARCHAR(50)
,@FunctionName1   NVARCHAR(20)
,@FieldName2      NVARCHAR(50) = NULL
,@FunctionName2   NVARCHAR(20) = NULL
,@FieldName3      NVARCHAR(50) = NULL
,@FunctionName3   NVARCHAR(20) = NULL
,@FieldName4      NVARCHAR(50) = NULL
,@FunctionName4   NVARCHAR(20) = NULL
,@FieldName5      NVARCHAR(50) = NULL
,@FunctionName5   NVARCHAR(20) = NULL
,@FieldName6      NVARCHAR(50) = NULL
,@FunctionName6   NVARCHAR(20) = NULL
,@FieldName7      NVARCHAR(50) = NULL
,@FunctionName7   NVARCHAR(20) = NULL
,@FieldName8      NVARCHAR(50) = NULL
,@FunctionName8   NVARCHAR(20) = NULL
,@FieldName9      NVARCHAR(50) = NULL
,@FunctionName9   NVARCHAR(20) = NULL
,@FieldName10     NVARCHAR(50) = NULL
,@FunctionName10  NVARCHAR(20) = NULL
,@FieldName11     NVARCHAR(50) = NULL
,@FunctionName11  NVARCHAR(20) = NULL
,@FieldName12     NVARCHAR(50) = NULL
,@FunctionName12  NVARCHAR(20) = NULL
,@FieldName13     NVARCHAR(50) = NULL
,@FunctionName13  NVARCHAR(20) = NULL
,@WhereClause     NVARCHAR(100) = NULL
) AS

DECLARE
  @DynSQL           NVARCHAR(4000)
 ,@TFunctionCall    NVARCHAR(1000)
 ,@OldRawAcctLeft1  tinyint
 ,@OldRawAcctLeft2  tinyint
 ,@NewAcctLen1      tinyint
 ,@OldAcctLen1      tinyint
 ,@NewAcctLen2      tinyint
 ,@OldAcctLen2      tinyint
 ,@OldRawAcctPos1   tinyint
 ,@OldRawAcctPos2   tinyint
 ,@NewNilAcct       AcctType
 ,@NewAcctChar1     tinyint
 ,@NewAcctChar2     tinyint
 ,@NewAcctFmt1      AcctType
 ,@NewAcctFmt2      AcctType
 ,@NewRawAcctLeft1  tinyint
 ,@NewRawAcctLeft2  tinyint
 ,@NewRawAcctPos1   tinyint
 ,@NewRawAcctPos2   tinyint
 ,@NewRawAcctFlds   AcctFieldsType
 ,@OldRawAcctFlds   AcctFieldsType

 ,@NewAcctCall      NVARCHAR(1000)
 ,@NewFillFmt2      NCHAR

SELECT
    @NewRawAcctFlds    = RawAcctFlds
   ,@NewRawAcctPos1    = RawAcctPos1
   ,@NewRawAcctPos2    = RawAcctPos2
   ,@NewAcctLen1       = AcctLen1
   ,@NewAcctLen2       = AcctLen2
   ,@NewAcctChar1      = AcctChar1
   ,@NewAcctChar2      = AcctChar2
   ,@NewNilAcct        = NilAcct
   ,@NewRawAcctLeft1   = RawAcctLeft1
   ,@NewRawAcctLeft2   = RawAcctLeft2
   ,@NewAcctFmt1       = AcctFmt1
   ,@NewAcctFmt2       = AcctFmt2
   ,@NewFillFmt2       = FillFmt2
      FROM #tmp_Acct
        WHERE rec_type = 'NEW'

SELECT
    @OldRawAcctFlds   = RawAcctFlds
   ,@OldRawAcctPos1   = RawAcctPos1
   ,@OldRawAcctPos2   = RawAcctPos2
   ,@OldAcctLen1      = AcctLen1
   ,@OldAcctLen2      = AcctLen2
   ,@OldRawAcctLeft1  = RawAcctLeft1
   ,@OldRawAcctLeft2  = RawAcctLeft2
      FROM #tmp_Acct
        WHERE rec_type = 'OLD'




SET @NewAcctCall = 'dbo.NewAcctSp(<FieldName>,' + ISNULL(str(@OldRawAcctLeft1),'NULL') +
                               ',' + ISNULL(str(@OldRawAcctLeft2),'NULL') +
                               ',' + ISNULL(str(@NewAcctLen1),'NULL') +
                               ',' + ISNULL(str(@OldAcctLen1),'NULL') +
                               ',' + ISNULL(str(@NewAcctLen2),'NULL') +
                               ',' + ISNULL(str(@OldAcctLen2),'NULL') +
                               ',' + ISNULL(str(@OldRawAcctPos1),'NULL') +
                               ',' + ISNULL(str(@OldRawAcctPos2),'NULL') +
                               ',''' + ISNULL(@NewNilAcct,'') + '''' +
                               ',' + ISNULL(str(@NewAcctChar1),'NULL') +
                               ',' + ISNULL(str(@NewAcctChar2),'NULL') +
                               ',''' + ISNULL(@NewAcctFmt1,'') + '''' +
                               ',''' + ISNULL(@NewAcctFmt2,'') + '''' +
                               ',' + ISNULL(str(@NewRawAcctLeft1),'NULL') +
                               ',' + ISNULL(str(@NewRawAcctLeft2),'NULL') +
                               ',' + ISNULL(str(@NewRawAcctPos1),'NULL') +
                               ',' + ISNULL(str(@NewRawAcctPos2),'NULL') +
                               ',' + ISNULL(str(@NewRawAcctFlds),'NULL') +
                               ',' + ISNULL(str(@OldRawAcctFlds),'NULL') +
                               ',' + '''' + ISNULL(@NewFillFmt2, '') + '''' +  ')'

SET @DynSQL = 'UPDATE ' + @TableName + ' SET '
IF(@FieldName1 IS NOT NULL)
BEGIN
   SET @TFunctionCall = '<FieldName> = dbo.' + @FunctionName1
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName1)
   SET @DynSQL = @DynSQL + @TFunctionCall
END

IF(@FieldName2 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName2
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName2)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName3 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName3
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName3)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName4 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName4
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName4)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName5 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName5
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName5)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName6 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName6
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName6)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName7 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName7
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName7)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName8 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName8
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName8)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName9 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName9
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName9)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName10 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName10
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName10)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName11 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName11
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName11)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName12 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName12
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName12)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@FieldName13 IS NOT NULL)
BEGIN
   SET @TFunctionCall = ' ,<FieldName> = dbo.' + @FunctionName13
   SET @TFunctionCall = replace(@TFunctionCall,'dbo.NewAcctCall',@NewAcctCall)
   SET @TFunctionCall = replace(@TFunctionCall,'<FieldName>',@FieldName13)
   SET @DynSQL        = @DynSQL + @TFunctionCall
END

IF(@WhereClause IS NOT NULL)
   SET @DynSQL = @DynSQL + ' WHERE ' + @WhereClause

exec sp_executesql @DynSQL


Return @@Error
GO