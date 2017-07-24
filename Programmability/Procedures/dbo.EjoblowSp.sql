SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/EjoblowSp.sp 2     6/17/03 1:17p Matagl $  */
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
CREATE PROCEDURE [dbo].[EjoblowSp] (
  @PList      NCHAR(1)
) AS

DECLARE
  @Severity       INT
, @Success        ListYesNoType
, @JobRowPointer  RowPointerType
, @JobLowLevel    LowLevelType
, @XJobJob        JobType
, @XJobSuffix     SuffixType
, @XJobItem       ItemType
, @PLowLevel      LowLevelType
, @PJobItem       ItemType
, @PReleased      QtyUnitType
, @PQty           QtyUnitType
, @PRef           RefTypeIJKPRTType
, @PJob           JobType
, @PSuffix        SuffixType
, @PUnits         JobmatlUnitsType
, @Infobar        InfobarType
, @PMTCode        PMTCodeType

SET @Severity = 0
SET @Success = 1

SELECT
   @PLowLevel AS low_level,
   @PJobItem AS item,
   @PReleased AS released,
   @PQty AS qty,
   @PUnits AS units,
   @PRef AS ref,
   @PJob AS job,
   @PSuffix AS suffix,
   @PMTCode AS pmt_code,
   @Infobar AS message
INTO #tt_joblow WHERE 1=2

create table #job (
  job nvarchar(40) not null
, suffix int not null
, item nvarchar(80)
, old_low_level int
, new_low_level int
, qty_released decimal(25,10)
, RowPointer uniqueidentifier
)

insert into #job
select job, suffix, item, low_level, 0, qty_released, RowPointer
FROM job
WHERE job.type = 'E' 
  AND job.stat IN ('W', 'P')

alter table #job
   add primary key(job, suffix)

DECLARE EjoblowSp2Crs CURSOR LOCAL STATIC FOR
SELECT
  job
, suffix
, item
FROM #job

OPEN EjoblowSp2Crs

WHILE @Severity = 0
BEGIN
   FETCH EjoblowSp2Crs INTO
     @XJobJob
   , @XJobSuffix
   , @XJobItem
   IF @@FETCH_STATUS = -1
      BREAK

   EXEC @Severity = dbo.JoblowSetSubJobSp @PList, @XJobJob, @XJobSuffix, 0, 0, '', '', 0, @XJobItem

   IF @Severity <> 0
   BEGIN
      SET @Success = 0
      BREAK
   END
END
CLOSE      EjoblowSp2Crs
DEALLOCATE EjoblowSp2Crs

-- avoid a lot of unnecessary jobIup processing
exec dbo.DefineVariableSp 'JobUtil', 1, @Infobar output

update job
set low_level = new_low_level
from #job
where #job.RowPointer = job.RowPointer
and (#job.new_low_level != #job.old_low_level or #job.old_low_level is null)

SET @Infobar = NULL
IF @Success = 1
   EXEC dbo.MsgAppSp @Infobar OUTPUT, 'I=CmdSucceeded', '@!EstimateJobBillofMaterialProcessor'
ELSE
   EXEC dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed', '@!EstimateJobBillofMaterialProcessor'

INSERT INTO #tt_joblow (message) VALUES (@Infobar)
SELECT * FROM #tt_joblow
RETURN @Severity
GO