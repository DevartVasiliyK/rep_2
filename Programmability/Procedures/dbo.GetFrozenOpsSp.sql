SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
** As part of the APS Regen processing, load the
** SCHEDOP table with the frozen operations.
*/

/* $Header: /ApplicationDB/Stored Procedures/GetFrozenOpsSp.sp 7     9/06/05 10:51a Janreu $  */
/*
Copyright c MAPICS, Inc. 2003 - All Rights Reserved

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

/* $Archive: /ApplicationDB/Stored Procedures/GetFrozenOpsSp.sp $
 *
 * SL7.04 7 88579 Janreu Tue Sep 06 10:51:17 2005
 * Need Infinite Backward Scheduling Mod ported to SL 7.04
 * Issue 88579 - port Infinite Backward Scheduling Mod to 7.04
 *
 * SL7.04 6 88117 Janreu Wed Aug 31 18:10:09 2005
 * RESSCHD records are not all transferrred to Planning when multiple resources are allocated.
 * RK 88117 - needed to consolidate rows split for end of setup event
 *
 * $NoKeywords: $
 */
CREATE  PROCEDURE [dbo].[GetFrozenOpsSp]
AS

DECLARE
  @Severity           INT

DECLARE @SchedOp1 TABLE (
    ORDERID     NVARCHAR(80)     NOT NULL
  , JSID        NVARCHAR(80)     NOT NULL
  , GROUPID     NVARCHAR(80)     NOT NULL
  , RESID       NVARCHAR(80)     NOT NULL
  , STARTDATE   DATETIME         NOT NULL
  , ENDDATE     DATETIME         NOT NULL
  , STARTFG     NCHAR(1)         NOT NULL
  , ENDFG       NCHAR(1)         NOT NULL
  , JOBTAG      INTEGER          NOT NULL
  , STARTCD     NCHAR(1)         NOT NULL
  , ENDCD       NCHAR(1)         NOT NULL
)

DECLARE @SchedOp2 TABLE (
    ORDERID     NVARCHAR(80)     NOT NULL
  , RESID       NVARCHAR(80)     NOT NULL
  , STARTDATE   DATETIME         NOT NULL
)

DECLARE @SchedOp3 TABLE (
    ORDERID     NVARCHAR(80)     NOT NULL
  , RESID       NVARCHAR(80)     NOT NULL
  , ENDDATE     DATETIME         NOT NULL
)

SELECT
  @Severity = 0

/*
** Remove existing records from the SCHEDOP000 table.
*/

TRUNCATE TABLE SCHEDOP000

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity


/*
 * Short circuit this stored procedure if the infinite backward scheduling mode is enabled
 */

IF dbo.ApsIsInfBackSchedEnabled() = 1           
  RETURN @Severity


/*
** Select resource load.
*/

INSERT INTO @SchedOp1
SELECT DISTINCT
    supplyOrd.ORDERID
  , MAX(JOB000.JSID)
  , MAX(res.GROUPID)
  , res.RESID
  , res.STARTDATE
  , MAX(res.ENDDATE)
  , 'N'
  , 'N'
  , MAX(res.JOBTAG)
  , MAX(res.STARTCD)
  , MAX(res.ENDCD)
FROM RESSCHD000 AS res
JOIN JOB000 ON res.JOBTAG = JOB000.JOBTAG
JOIN ORDIND000 AS oi ON JOB000.ORDERTAG = oi.ORDERTAG
JOIN ORDER000 AS supplyord ON oi.ORDERID = supplyord.ORDERID
join job on job.rowpointer = supplyord.orderrowpointer
WHERE
   DATEDIFF(minute, res.STARTDATE, res.ENDDATE) > 0 AND
   -- avoid estimate jobs as the the planner wont be planning them
   job.type <> 'E' and
   -- Only load orders the planner will be using
   (supplyOrd.SchedOnlyFg = 'N' and 
   (supplyord.flags & 4096) = 4096 )-- CHECK FROZEN FLAG 
group by supplyOrd.ORDERID , res.RESID , res.STARTDATE

INSERT INTO @SchedOp1
SELECT distinct 
    supplyOrd.ORDERID
  , MAX(JOB000.JSID)
  , MAX(res.GROUPID)
  , res.RESID
  , res.STARTDATE
  , MAX(res.ENDDATE)
  , 'N'
  , 'N'
  , MAX(res.JOBTAG)
  , MAX(res.STARTCD)
  , MAX(res.ENDCD)
FROM RESSCHD000 AS res
JOIN JOB000 ON res.JOBTAG = JOB000.JOBTAG
JOIN ORDIND000 AS oi ON JOB000.ORDERTAG = oi.ORDERTAG
JOIN ORDER000 AS supplyord ON oi.ORDERID = supplyord.ORDERID
join jobitem on jobitem.rowpointer = supplyord.orderrowpointer
join job on job.job = jobitem.job and job.suffix = jobitem.suffix
WHERE
   DATEDIFF(minute, res.STARTDATE, res.ENDDATE) > 0 AND
   -- avoid estimate jobs as the the planner wont be planning them
   job.type <> 'E' and
   -- Only load orders the planner will be using
   (supplyOrd.SchedOnlyFg = 'N' AND
   (supplyOrd.FLAGS & 4096) = 4096 ) -- CHECK FROZEN FLAG 
group by supplyOrd.ORDERID , res.RESID , res.STARTDATE


SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

/*
** Consolidate rows split for change from setup to operate status
*/

UPDATE so1
  SET ENDDATE = so2.ENDDATE
FROM @SchedOp1 AS so1
INNER JOIN @SchedOp1 AS so2
ON so1.JOBTAG = so2.JOBTAG
  AND so1.ENDCD   = 'U'
  AND so2.STARTCD = 'U' 

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

DELETE FROM @SchedOp1
WHERE STARTCD = 'U'

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

/*
** Set STARTFG field.
*/

INSERT INTO @SchedOp2
SELECT
    ORDERID
  , RESID
  , MIN(STARTDATE)
FROM @SchedOp1
GROUP BY ORDERID, JSID, RESID

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

UPDATE @SchedOp1
  SET STARTFG = 'Y'
FROM @SchedOp1 AS so1
   , @SchedOp2 AS so2
WHERE so1.ORDERID   = so2.ORDERID
  AND so1.RESID     = so2.RESID
  AND so1.STARTDATE = so2.STARTDATE

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

/*
** Set ENDFG field.
*/

INSERT INTO @SchedOp3
SELECT
    ORDERID
  , RESID
  , MAX(ENDDATE)
FROM @SchedOp1
GROUP BY ORDERID, JSID, RESID

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

UPDATE @SchedOp1
  SET ENDFG = 'Y'
FROM @SchedOp1 AS so1
   , @SchedOp3 AS so3
WHERE so1.ORDERID   = so3.ORDERID
  AND so1.RESID     = so3.RESID
  AND so1.ENDDATE   = so3.ENDDATE

SELECT
  @Severity = @@ERROR

IF @Severity <> 0
  RETURN @Severity

/*
** Add data to the SCHEDOP table.
*/

INSERT INTO SCHEDOP000 (
  ORDERID, JSID , GROUPID, RESID, STARTDATE, ENDDATE, STARTFG, ENDFG
)
SELECT
  ORDERID, MAX(JSID), MAX(GROUPID), RESID, STARTDATE, MAX(ENDDATE), MAX(STARTFG), MAX(ENDFG)
FROM @SchedOp1 as ff
group by ff.ORDERID , ff.RESID , ff.STARTDATE

SELECT
  @Severity = @@ERROR

RETURN @Severity

GO