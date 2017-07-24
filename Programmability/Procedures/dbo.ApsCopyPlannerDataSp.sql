SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ApsCopyPlannerDataSp.sp 1     9/06/05 10:44a Janreu $  */
/*
Copyright © MAPICS, Inc. 2004 - All Rights Reserved

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

/* Infinite Backwards Scheduling

   This feature is not enabled by default. At the end of a full planning run,
   the ApsPlannerCompletedSp stored procedure calls the ApsIsInfBackSchedEnabled()
   function.  If infinite backwards scheduling is enabled, then this procedure is
   executed.  
   
   This procedure copies Planner output data to the scheduler output tables, 
   which allows users to use certain Scheduler forms and reports - without running
   the scheduler.
*/


/* $Archive: /ApplicationDB/Stored Procedures/ApsCopyPlannerDataSp.sp $
 *
 * SL7.04 1 88579 Janreu Tue Sep 06 10:44:44 2005
 * Need Infinite Backward Scheduling Mod ported to SL 7.04
 * Issue 88579 - port Infinite Backward Scheduling Mod to 7.04
 *
 * SL7.03 3 86695 vanmmar Wed Mar 30 22:20:50 2005
 * Infinite backward scheduling fails with PLN quantities < 1
 * 86695
 *
 * $NoKeywords: $
 */
CREATE  PROCEDURE [dbo].[ApsCopyPlannerDataSp] 
AS

SET NOCOUNT ON

DECLARE
 @Severity	    int
,@StartDate     datetime
,@SchedPLNs     int

/* Initialize */

SET @Severity = 0
SELECT @StartDate = dbo.MidnightOf(LASTSYNCH) FROM ALTPLAN WHERE ALTNO = 0
SELECT @SchedPLNs = ISNULL(schedpln, 0) FROM sfcparms


/* Delete old scheduler data */

DELETE FROM ORDIND000
DELETE FROM JOB000
DELETE FROM RESSCHD000
DELETE FROM DOWN000
DELETE FROM ORDPERF000
DELETE FROM LOADPERF000
DELETE FROM ORDER000 WHERE ORDTYPE = 10


/* Copy planner data to ORDIND000

    ORDIND000    Planner mapping
    --------------------------------------------
    ORDERID      MATLPLAN000.ORDERID
    ORDERTAG     MATLPLAN000.MATLTAG
    PROCPLANID   MATLPLAN000.PROCPLANID
    RELDATE      ORDER000.RELDATE
    DUEDATE      ORDER000.DUEDATE

    Conditions:
      •  Only copy rows where:
           - ORDER000.PLANONLYFG = ‘N’ or
           - order is tied to a job that needs scheduled
      •  ORDER000.ORDERID = MATLPLAN000.ORDERID
      •  MATLPLAN000.LOADID = 1 AND MATLPLAN.PMATLTAG = 0
*/

INSERT ORDIND000 (
  ORDERID
, ORDERTAG
, PROCPLANID
, RELDATE
, DUEDATE
)
SELECT 
  MATLPLAN000.ORDERID
, MATLPLAN000.MATLTAG
, CASE
	WHEN (MATLPLAN000.PROCPLANID <> '') THEN MATLPLAN000.PROCPLANID
	ELSE ORDER000.PROCPLANID
  END
, ORDER000.RELDATE
, ORDER000.DUEDATE 
FROM ORDER000 
	JOIN MATLPLAN000 ON MATLPLAN000.ORDERID = ORDER000.ORDERID
	LEFT JOIN job on ORDER000.OrderRowPointer = job.RowPointer
WHERE
	MATLPLAN000.LOADID = 1 AND MATLPLAN000.PMATLTAG = 0
	AND (ORDER000.PLANONLYFG = 'N' OR
          (job.job is not null AND dbo.ApsSchedulerNeedsJob(job.job, job.suffix) = 1))


/* Copy planner data to JOB000

    JOB000        Planner mapping
---------------------------------------
    ORDERTAG      X.MATLTAG (see below)
    JOBTAG        JOBPLAN000.JOBTAG
    LOADID        MATLPLAN000.LOADID
    JSID          JOBPLAN000.JSID
    ARIVDATE      JOBPLAN000.STARTDATE
    MOVEEND       JOBPLAN000.STARTDATE
    STARTCD       ‘S’
    STARTDATE     JOBPLAN000.STARTDATE
    SETUPEND      JOBPLAN000.STARTDATE
    ENDCD         ‘E’
    ENDDATE       JOBPLAN000.ENDDATE
    COOLEND       JOBPLAN000.ENDDATE
    PROCTIME      JOBPLAN000.DURATION
    SETUPTIME     0.0
    LOADSIZE      JOBPLAN000.QUANTITY
    BATCHID       0
    STATUSCD      ‘N’
    SEQNUM        See below
	
    Conditions:
      • ORDIND000.ORDERID = MATLPLAN000.ORDERID
      • JOBPLAN000.MATLTAG = MATLPLAN000.MATLTAG
      • MATLPLAN000.PMATLTAG = 0 (no subcomponent plans are copied)
      • X = 2nd join to MATLPLAN000 where MATLPLAN000.ORDERID = X.ORDERID AND X.LOADID = 1
         (so that all loads have that same ORDERTAG)
      • SEQNUM must be generated by ordering JOBPLAN000 records by STARTDATE, SEQNO
*/

INSERT INTO JOB000 (
  ORDERTAG
, JOBTAG
, LOADID
, JSID
, ARIVDATE
, MOVEEND
, STARTCD
, STARTDATE
, SETUPEND
, ENDCD
, ENDDATE
, COOLEND
, PROCTIME
, SETUPTIME
, LOADSIZE
, BATCHID
, STATUSCD
, SEQNUM
)
SELECT
  X.MATLTAG
, JOBPLAN000.JOBTAG
, MATLPLAN000.LOADID
, JOBPLAN000.JSID
, JOBPLAN000.STARTDATE
, JOBPLAN000.STARTDATE
, 'S'
, JOBPLAN000.STARTDATE
, JOBPLAN000.STARTDATE
, 'E'
, JOBPLAN000.ENDDATE
, JOBPLAN000.ENDDATE
, JOBPLAN000.DURATION
, 0.0
, JOBPLAN000.QUANTITY
, 0
, 'N'
, 0
FROM ORDIND000
	JOIN MATLPLAN000 ON MATLPLAN000.ORDERID = ORDIND000.ORDERID
	JOIN JOBPLAN000 ON JOBPLAN000.MATLTAG = MATLPLAN000.MATLTAG
	JOIN MATLPLAN000 X ON X.ORDERID = MATLPLAN000.ORDERID
WHERE
    MATLPLAN000.PMATLTAG = 0 AND
    X.PMATLTAG = 0 AND X.LOADID = 1


/* Copy jobs belonging to PLNs and create temp PLN orders */

IF @SchedPLNs = 1
BEGIN
  INSERT INTO JOB000 (
    ORDERTAG
  , JOBTAG
  , LOADID
  , JSID
  , ARIVDATE
  , MOVEEND
  , STARTCD
  , STARTDATE
  , SETUPEND
  , ENDCD
  , ENDDATE
  , COOLEND
  , PROCTIME
  , SETUPTIME
  , LOADSIZE
  , BATCHID
  , STATUSCD
  , SEQNUM
  )
  SELECT
    JOBPLAN000.MATLTAG
  , JOBPLAN000.JOBTAG
  , MATLPLAN000.LOADID
  , JOBPLAN000.JSID
  , JOBPLAN000.STARTDATE
  , JOBPLAN000.STARTDATE
  , 'S'
  , JOBPLAN000.STARTDATE
  , JOBPLAN000.STARTDATE
  , 'E'
  , JOBPLAN000.ENDDATE
  , JOBPLAN000.ENDDATE
  , JOBPLAN000.DURATION
  , 0.0
  , JOBPLAN000.QUANTITY
  , 0
  , 'N'
  , 0
  FROM JOBPLAN000
    JOIN MATLPLAN000 ON JOBPLAN000.MATLTAG = MATLPLAN000.MATLTAG
    JOIN ORDER000 ON MATLPLAN000.ORDERID = ORDER000.ORDERID
  WHERE
    (MATLPLAN000.PMATLTAG <> 0) OR 
    ((ORDER000.OrderTable <> 'job') AND (ORDER000.OrderTable <> 'jobmatl'))

  INSERT INTO ORDER000 (
    ORDERID
  , DESCR
  , PARTID
  , MATERIALID
  , ORDSIZE
  , LOADSIZE
  , ARIVDATE
  , RELDATE
  , DUEDATE
  , REQUDATE
  , CATEGORY
  , ORDTYPE
  , FLAGS
  , CUSTOMER
  , PLANONLYFG
  , SCHEDONLYFG
  , PRIORITY
  , PROCPLANID
  )
  SELECT 
    'PLN' + cast(mp.MATLTAG as nvarchar) + '.PJOS'
  , 'Planned Supply'
  , mp.MATERIALID
  , mp.MATERIALID
  , 1
  , 1
  , dbo.Lowdate()
  , mp.STARTDATE
  , mp.ENDDATE
  , dbo.Lowdate()
  , -5 -- first-supply-cat-code
  , 10 -- OrdType
  , 1  -- VAL_ORDFLAGS_SUPPLY
  , ''
  , 'N'
  , 'Y'
  , dbo.ApsSetPrioritySp (10)
  , mp.PROCPLANID
  FROM MATLPLAN000 mp JOIN ORDER000 ord on mp.ORDERID = ord.ORDERID
  WHERE 
    ((mp.PMATLTAG <> 0) OR 
    ((ord.OrderTable <> 'job') AND (ord.OrderTable <> 'jobmatl'))) AND
    EXISTS (SELECT * FROM JOBPLAN000 jp WHERE jp.MATLTAG = mp.MATLTAG)
  
  UPDATE ORDER000 SET
    ORDSIZE = QTY,
    LOADSIZE = QTY
  FROM (
    SELECT ord.ORDERID, SUM(ip.SUPPLY) as QTY
    FROM INVPLAN000 ip 
      JOIN MATLPLAN000 mp ON ip.MATLTAG = mp.MATLTAG
      JOIN ORDER000 ord ON ord.ORDERID = 'PLN' + cast(mp.MATLTAG as nvarchar) + '.PJOS' 
    WHERE ord.ORDTYPE = 10
      AND ip.SCHFLAGS & 8192 <> 0 -- MFG flag
    GROUP BY ord.ORDERID) ord2
  WHERE ord2.ORDERID = ORDER000.ORDERID AND QTY >= 1

  INSERT ORDIND000 (
    ORDERID
  , ORDERTAG
  , PROCPLANID
  , RELDATE
  , DUEDATE
  )
  SELECT 
    'PLN' + cast(mp.MATLTAG as nvarchar) + '.PJOS'
  , mp.MATLTAG
  , mp.PROCPLANID
  , mp.STARTDATE
  , mp.ENDDATE
  FROM MATLPLAN000 mp JOIN ORDER000 ord on mp.ORDERID = ord.ORDERID
  WHERE 
    ((mp.PMATLTAG <> 0) OR 
    ((ord.OrderTable <> 'job') AND (ord.OrderTable <> 'jobmatl'))) AND
    EXISTS (SELECT * FROM JOBPLAN000 jp WHERE jp.MATLTAG = mp.MATLTAG)

  INSERT ORDPERF000 (
    ORDERID
  , REPNO
  , ORDTYP
  , PARTID
  , NUMPARTS
  , STARTCD
  , STARTDATE
  , COMPCD
  , COMPDATE
  , LATENESS
  , MAKESPAN
  , WAITTIME
  , PROCTIME
  )
  SELECT
    ORDER000.ORDERID
  , 1
  , 'S'
  , ORDER000.MATERIALID
  , ORDER000.ORDSIZE
  , 'S'
  , ORDER000.RELDATE
  , 'C'
  , ORDER000.DUEDATE
  , 0.0
  , (DATEDIFF(minute, ORDER000.DUEDATE, ORDER000.RELDATE)) / 60.0
  , 0.0
  , 0.0
  FROM ORDER000
  WHERE ORDER000.ORDTYPE = 10    

END


/* Update sequence numbers */

DECLARE @JobSeq table (
   refrow uniqueidentifier
  ,seqnum int identity(1,1)
)

INSERT INTO @JobSeq (refrow)
SELECT RowPointer
FROM JOB000
ORDER BY STARTDATE, JOBTAG

UPDATE JOB000
SET SEQNUM = jobseq.seqnum
FROM @JobSeq jobseq join JOB000 on jobseq.refrow = JOB000.RowPointer

 
/* Copy planner data to RESCHED000

    RESSCHD000    Planner mapping
-----------------------------------------
    RESID         RESPLAN000.RESID
    GROUPID       RESPLAN000.GROUPID
    JOBTAG        RESPLAN000.JOBTAG
    STARTCD       RESPLAN000.FLAGS (see below)
    STARTDATE     RESPLAN000.STARTDATE
    ENDCD         RESPLAN000.FLAGS (see below)
    ENDDATE       RESPLAN000.ENDDATE
    STATUSCD      ‘O’
    SEQNUM        See below
 
    Conditions:
      • RESPLAN000.JOBTAG = JOB000.JOBTAG
      • SEQNUM must be generated by ordering RESPLAN000 records by STARTDATE
*/

INSERT RESSCHD000 (
  RESID
, GROUPID
, JOBTAG
, STARTCD
, STARTDATE
, ENDCD
, ENDDATE
, STATUSCD
, SEQNUM
)
SELECT
  RESPLAN000.RESID
, RESPLAN000.GROUPID
, RESPLAN000.JOBTAG
, CASE
	WHEN ((RESPLAN000.FLAGS & 1) = 1) THEN 'A'
	ELSE 'R'
  END 
, RESPLAN000.STARTDATE
, CASE
	WHEN ((RESPLAN000.FLAGS & 2) = 2) THEN 'F'
	ELSE 'I'
  END 
, RESPLAN000.ENDDATE
, 'O'
, 0 
FROM JOB000
	JOIN RESPLAN000 ON RESPLAN000.JOBTAG = JOB000.JOBTAG


/* Update sequence numbers */

DECLARE @ResSeq table (
   refrow uniqueidentifier
  ,seqnum int identity(1,1)
)

INSERT INTO @ResSeq (refrow)
SELECT RowPointer
FROM RESSCHD000
ORDER BY STARTDATE, JOBTAG

UPDATE RESSCHD000
SET SEQNUM = resseq.seqnum
FROM @ResSeq resseq join RESSCHD000 on resseq.refrow = RESSCHD000.RowPointer


/* Copy planner data to DOWN000 
 
 DOWN000    Planner mapping
 ------------------------------
 RESID      DOWNPLAN000.RESID
 STARTDATE  DOWNPLAN000.STARTDATE
 ENDDATE    DOWNPLAN000.ENDDATE
 DOWNCD     DOWNPLAN000.DOWNCD
*/
 
INSERT DOWN000 (
  RESID
, STARTDATE
, ENDDATE
, DOWNCD
)
SELECT
  DOWNPLAN000.RESID
, DOWNPLAN000.STARTDATE
, DOWNPLAN000.ENDDATE
, DOWNPLAN000.DOWNCD
FROM DOWNPLAN000


/* Copy planner data to ORDPERF000 / LOADPERF000

    ORDPERF000    Planner mapping
    -----------------------------------
    ORDERID       ORDPLAN000.ORDERID
    REPNO         1
    ORDTYP        ‘S’
    PARTID        MATLPLAN000.MATERIALID
    NUMPARTS      See below
    STARTCD       ‘S’
    STARTDATE     MATLPLAN000.STARTDATE
    COMPCD        ‘C’
    COMPDATE      ORDPLAN000.CALCDATE
    LATENESS      ORDPLAN000.CALCDATE – ORDER000.DUEDATE (in hours)
    MAKESPAN      ORDPLAN000.CALCDATE – MATLPLAN000.STARTDATE (in hours)
    WAITTIME      0
	
    Conditions:
      •  ORDIND000.ORDERID = ORDER000.ORDERID
      •  ORDER000.ORDERID = MATLPLAN000.ORDERID
      •  MATLPLAN000.LOADID = 1 AND MATLPLAN000.PMATLTAG = 0
      •  ORDPLAN000.ORDERID = ORDER000.ORDERID
      •  NUMPARTS will be set to the quantity of the end item actually planned 
*/

INSERT ORDPERF000 (
  ORDERID
, REPNO
, ORDTYP
, PARTID
, NUMPARTS
, STARTCD
, STARTDATE
, COMPCD
, COMPDATE
, LATENESS
, MAKESPAN
, WAITTIME
, PROCTIME
)
SELECT
  ORDPLAN000.ORDERID
, 1
, 'S'
, MATLPLAN000.MATERIALID
, 0.0
, 'S'
, MATLPLAN000.STARTDATE
, 'C'
, ORDPLAN000.CALCDATE
, (DATEDIFF(minute, ORDER000.DUEDATE, ORDPLAN000.CALCDATE)) / 60.0
, (DATEDIFF(minute, MATLPLAN000.STARTDATE, ORDPLAN000.CALCDATE)) / 60.0
, 0.0
, 0.0
FROM ORDER000
  JOIN ORDIND000 ON ORDER000.ORDERID = ORDIND000.ORDERID
  JOIN ORDPLAN000 ON ORDPLAN000.ORDERID = ORDER000.ORDERID
  JOIN MATLPLAN000 ON MATLPLAN000.ORDERID = ORDER000.ORDERID
WHERE  
  MATLPLAN000.LOADID = 1 AND MATLPLAN000.PMATLTAG = 0 AND
  ORDER000.ORDTYPE <> 10    


/* Update NUMPARTS on ORDPERF to be the actual quantity planned */

DECLARE @OrdLoadStartOp table (
   orderid nvarchar(63)
  ,loadid  int
  ,seqno   int
)
INSERT INTO @OrdLoadStartOp (orderid, loadid, seqno)
SELECT oi.ORDERID, m.LOADID, min(jp.SEQNO)
FROM JOB000 jb
  JOIN JOBPLAN000 jp ON jb.JOBTAG = jp.JOBTAG AND jp.SEQNO > 0
  JOIN MATLPLAN000 m ON m.MATLTAG = jp.MATLTAG AND m.PMATLTAG = 0
  JOIN ORDIND000 oi ON oi.ORDERTAG = jb.ORDERTAG
  JOIN ORDER000 ord ON ord.ORDERID = oi.ORDERID AND ord.ORDTYPE <> 10
GROUP BY oi.ORDERID, m.LOADID

UPDATE ORDPERF000
SET NUMPARTS = QUANTITY
FROM (
    SELECT startop.ORDERID, jp.QUANTITY
    FROM @OrdLoadStartOp startop
        JOIN MATLPLAN000 m ON m.ORDERID = startop.ORDERID AND m.PMATLTAG = 0
        JOIN JOBPLAN000 jp ON m.MATLTAG = jp.MATLTAG
        JOIN JOB000 jb ON jb.JOBTAG = jp.JOBTAG
    WHERE
        jp.SEQNO = startop.seqno AND jb.LOADID = startop.loadid
) qty
WHERE ORDPERF000.ORDERID = qty.ORDERID

INSERT INTO LOADPERF000 (
  ORDERID
, LOADID
, REPNO
, ORDTYP
, PARTID
, LOADSIZE
, COMPCD
, COMPDATE
, LATENESS
, PROCTIME
, WAITTIME)
SELECT
  ORDERID
, 1
, 1
, ORDTYP
, PARTID
, NUMPARTS
, COMPCD
, COMPDATE
, LATENESS
, PROCTIME
, WAITTIME
FROM ORDPERF000


/* Update the Scheduler horizon in ALTSCHED */

UPDATE ALTSCHED
SET STARTDATE = dbo.MidnightOf(ALTPLAN.LASTSYNCH),
    ENDDATE = dateadd(hour, ALTPLAN.PLANHORIZ, dbo.MidnightOf(ALTPLAN.LASTSYNCH))
FROM ALTPLAN
WHERE ALTPLAN.ALTNO = 0 and ALTSCHED.ALTNO = 0

	
/* Update Operation Start and End dates */

update jrt_sch set
   start_tick = datediff(second,'19900101',JOB000.STARTDATE) / 36
  ,start_date = JOB000.STARTDATE
  ,end_tick = datediff(second,'19900101',JOB000.ENDDATE) / 36
  ,end_date = JOB000.ENDDATE
from JOB000
join ORDIND000 on ORDIND000.ORDERTAG = JOB000.ORDERTAG
join JOBSTEP000 on
   JOBSTEP000.JSID = JOB000.JSID and
   JOBSTEP000.PROCPLANID = ORDIND000.PROCPLANID
join jobroute on jobroute.rowpointer = JOBSTEP000.RefRowPointer
join jrt_sch on
   jrt_sch.job = jobroute.job and
   jrt_sch.suffix = jobroute.suffix and
   jrt_sch.oper_num = jobroute.oper_num
join job on
   job.job = jobroute.job and
   job.suffix = jobroute.suffix
where job.type <> 'S'


SET NOCOUNT OFF
  
RETURN @Severity
GO