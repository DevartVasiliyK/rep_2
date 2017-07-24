SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/AuditLoggingGenCodeWrapperSp.sp 2     7/18/05 4:05p Grosphi $  */
/*
Copyright © MAPICS, Inc. 2005 - All Rights Reserved

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

/* $Archive: /ApplicationDB/Stored Procedures/AuditLoggingGenCodeWrapperSp.sp $
 *
 * SL7.04 2 88119 Grosphi Mon Jul 18 16:05:26 2005
 * Deleted UET still referenced by audit log trigger
 * commit audit trail trigger changes
 *
 * SL7.03 1 88119 Grosphi Mon Jul 18 15:48:12 2005
 * Deleted UET still referenced by audit log trigger
 * commit audit trail trigger changes
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[AuditLoggingGenCodeWrapperSp] (
  @TableName sysname
) AS

DECLARE
  @Severity INT
, @SQL LongListType
, @CodeLine LongListType
, @BufNum int
, @SQLCmd LongListType
, @SQLSelect LongListType
, @SQLDeclare LongListType
, @NewLine nvarchar(2)
, @seq nvarchar(2)
, @i int
, @j int
, @CommitFrom LongListType
, @NonBlank ListYesNoType

SET @Severity = 0
set @NewLine = nchar(13) + nchar(10)

-- used to capture output from AuditLoggingGenCodeSp
if object_id('tempdb..#AuditCode') is null
   create table #AuditCode (
     seq int identity
   , code_line nvarchar(4000)
   )

insert into #AuditCode
exec dbo.AuditLoggingGenCodeSp @TableName

set @SQL = ''
set @BufNum = 1
set @NonBlank = 0

-- compressed output
if object_id('tempdb..#Segments') is null
   create table #Segments (
     seq int
   , segment nvarchar(4000)
   )

-- compress the trigger code
declare acCrs cursor local fast_forward for
select code_line
from #AuditCode
order by seq

open acCrs

while @Severity = 0
begin
   fetch acCrs into
     @CodeLine

   if @@fetch_status != 0
      break

   -- commit each segment as we go
   if @CodeLine = 'GO'
   begin
      set @CommitFrom = 'LOOP'
      goto COMMIT_CHANGES
CF_LOOP:
   end
   else
   begin
      -- avoid committing SQL code with blank lines only
      if @CodeLine is not null and @CodeLine != ''
         set @NonBlank = 1

      -- if about to exceed the variable size limit
      if len(@SQL) + len(@CodeLine) >= 3998
      begin
         insert into #Segments values(@BufNum, @SQL)

         set @SQL = @NewLine + @CodeLine
         set @BufNum = @BufNum + 1 
      end
      else if @SQL = ''
         set @SQL = @CodeLine
      else
         set @SQL = @SQL + @NewLine + @CodeLine
   end
end
close acCrs
deallocate acCrs

if @SQL != ''
and @NonBlank = 1
begin
   set @CommitFrom = 'END'
   goto COMMIT_CHANGES
CF_END:
end

RETURN @Severity


COMMIT_CHANGES:

-- add the remaining uncompressed code to the buffer
insert into #Segments values(@BufNum, @SQL)

set @SQL = ''
set @NonBlank = 0
set @SQLDeclare = 'declare @1 LongList'
set @SQLSelect = 'select @1=segment from #Segments where seq=1'
set @SQLCmd = 'execute (@1'

select @i = max(seq) from #Segments

set @j = 2
while @j <= @i
begin
   set @seq = cast(@j as int)
   set @SQLDeclare = @SQLDeclare + case when @j % 10 = 1 then @NewLine else '' end + ',@' + @seq + ' LongList'
   set @SQLSelect = @SQLSelect + @NewLine + 'select @' + @seq + '=segment from #Segments where seq=' + @seq
   set @SQLCmd = @SQLCmd + '+@' + @seq
   set @j = @j + 1
end
set @SQLCmd = @SQLCmd + ')'

-- print @SQLDeclare + @NewLine + @SQLSelect + @NewLine + @SQLCmd
execute (@SQLDeclare + @NewLine + @SQLSelect + @NewLine + @SQLCmd)

delete #Segments

set @BufNum = 1

if @CommitFrom = 'LOOP'
   goto CF_LOOP
goto CF_END
GO