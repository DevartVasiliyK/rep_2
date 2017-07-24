SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/CreateApsExceptionsSp.sp 26    7/12/05 1:21p vanmmar $  */
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

--  Adapted from mrp/aps-load.p and as/rules\aps-back.p


/* $Archive: /ApplicationDB/Stored Procedures/CreateApsExceptionsSp.sp $
 *
 * SL7.04 26 88084 vanmmar Tue Jul 12 13:21:04 2005
 * Current logic should be changed so that existing Jobs never get a receipt not needed message because of a future planned order.
 * 88084
 *
 * SL7.04 25 85503 vanmmar Fri Feb 11 12:13:14 2005
 * Missing late order exception message
 * 85503
 *
 * SL7.04 24 85893 vanmmar Fri Feb 11 09:16:05 2005
 * Planning replication allows SQL deadlock
 * Undid previous check-in
 *
 * SL7.04 22 85447 vanmmar Wed Feb 09 16:40:10 2005
 * APS safety stock order due dates should be better
 * 85447
 *
 * $NoKeywords: $
 */
CREATE  PROCEDURE [dbo].[CreateApsExceptionsSp]
AS

DECLARE
  @Severity                INT
, @Infobar                 InfobarType
, @Item                    ApsMaterialType
, @LastItem                ApsMaterialType
, @Date                    DATETIME
, @IsSupply                INT
, @Order                   ApsOrderType
, @Supply                  QtyUnitType
, @Demand                  QtyUnitType
, @FixedSupply             INT
, @SaveItem                ApsMaterialType
, @SaveOrder               ApsOrderType
, @SaveDate                DATETIME
, @SaveQty                 QtyUnitType
, @SaveExists              INT
, @SaveMinCap              QtyUnitType
, @Level                   QtyUnitType
, @Safe                    INT
, @SaveRefOrderType        MrpOrderTypeType
, @SaveRefOrderNum         MrpOrderType
, @SaveRefOrdLineSuf       MrpOrderLineType
, @SaveRefOrderRel         MrpOrderReleaseType
, @SaveRefSequence         JobmatlSequenceType
, @RefOrderType            MrpOrderTypeType
, @RefOrderNum             MrpOrderType
, @RefOrdLineSuf           MrpOrderLineType
, @RefOrderRel             MrpOrderReleaseType
, @RefSequence             JobmatlSequenceType
, @RefItem                 ItemType
, @RefExceptCode           MrpExceptCodeType
, @RefDate                 DateType
, @RefQty                  QtyUnitType
, @ExcCode                 INT
, @DueDate                 DATETIME
, @OrdSize                 QtyUnitType
, @OrdType                 INT
, @QtyOnHand               QtyUnitType
, @MinCap                  QtyUnitType
, @OrderTable              TableNameType
, @OrderRowPointer         RowPointerType
, @MatlTag                 INT
, @ParentMatlTag           INT
, @PPMatlTag               INT
, @OrderFlags              INT
, @Count                   INT
, @SupplyOrder             ApsOrderType
, @MsgType                 SMALLINT
, @ExpediteDays            FLOAT
, @MrpParmPreqChk          ListYesNoType
, @CurrentDate             DateType
, @PCALExists              INT
, @CalcDate                DateType
, @UseRePoint              QtyUnitType
, @SaveUseRePoint          QtyUnitType


DECLARE @Exceptions TABLE (
    order_num    NVARCHAR(80)        NULL
  , order_type   NCHAR(1)            NULL
  , ord_line_suf SMALLINT            NULL
  , order_rel    SMALLINT            NULL
  , sequence     SMALLINT            NULL
  , item         NVARCHAR(80)        NOT NULL
  , except_code  TINYINT             NULL
  , date_req     DATETIME            NULL
  , qty          DECIMAL(19,8)       NULL -- QtyUnitType
)

SET @Severity = 0

select @MrpParmPreqChk = mrp_parm.preq_chk from mrp_parm

---------------------------------------------------------------------
declare @ItemQtyOnHand table (
   Item nvarchar(30)
  ,qty_on_hand decimal(20,8) -- QtyTotlType
   primary key (item)
   )

insert into @ItemQtyOnHand
select
   item.item
  ,isnull((select sum(qty_on_hand - qty_rsvd_co)
           from itemwhse join whse on itemwhse.whse = whse.whse
           where itemwhse.item = item.item and whse.dedicated_inventory <> 1),0)
from item

-- Make Initial On Hand Negative Exceptions
INSERT INTO @Exceptions (
   item, order_type, order_num, ord_line_suf, order_rel, except_code)
select
   item.item
  ,''
  ,'INIT'
  ,0
  ,0
  ,8 -- @ExcCode
from @ItemQtyOnHand item
where item.qty_on_hand < 0

-- Make Initial On Hand Below Safety Stock
INSERT INTO @Exceptions (
   item, order_type, order_num, ord_line_suf, order_rel, except_code)
select
   item.item
  ,''
  ,'INIT'
  ,0
  ,0
  ,1 -- @ExcCode
from @ItemQtyOnHand item
JOIN MATL000 on MATL000.MATERIALID = item.item
where item.qty_on_hand < MATL000.MINCAP

INSERT INTO @Exceptions (
order_type, order_num,except_code,item,date_req,qty, ord_line_suf, order_rel)
SELECT 
   'N',MATLPLAN000.MATLTAG,5,MATLPLAN000.MATERIALID,
   POEXCEPT000.NEWDATE,DATEDIFF(DAY, POEXCEPT000.NEWDATE, MATLPLAN000.ENDDATE),0,0
FROM POEXCEPT000 
JOIN MATLPLAN000 ON 
MATLPLAN000.ORDERID = POEXCEPT000.ORDERID 
JOIN apsplan ON 
apsplan.item = MATLPLAN000.MATERIALID AND ISNUMERIC(apsplan.ref_num) = 1 AND apsplan.ref_num = MATLPLAN000.MATLTAG
WHERE MSGTYPE = 4 AND MATLPLAN000.PMATLTAG = 0 AND
MATLPLAN000.ENDDATE > POEXCEPT000.NEWDATE AND
apsplan.is_demand = 0 AND
Apsplan.ref_type = 'N'   

-- Make supply exceptions
--
-- Get list of supply and demand events by item and date.
-- Walk through the events and create exceptions for inventory below
-- minimum or unecessary reciepts.

DECLARE CreateApsExceptionsCrs1 CURSOR FOR
select
    SupDem.item
   ,SupDem.DueDateDay
   ,case when SupDem.RcptRqmt = 'C' then 1 else 0 end
   ,SupDem.QtyReq
   ,SupDem.QtyRecv
   ,case when SupDem.PlannedOrder = 0 and SupDem.RcptRqmt = 'C' then 1 else 0 end
   ,MATL000.MINCAP
   ,SupDem.OrdType, SupDem.RefNum, SupDem.RefLineSuf, SupDem.RefRelease, SupDem.Sequence,SupDem.use_reorder_point
from dbo.MrpSupDem(1) SupDem
JOIN MATL000 on MATL000.MATERIALID = SupDem.item
where SupDem.RcptRqmt in ('Q', 'C')
-- Same Order as PlanningDetail display
order by SupDem.Item, SupDem.DueDateDay, SupDem.RcptRqmt, SupDem.RowPointer
FOR READ ONLY

OPEN CreateApsExceptionsCrs1

SET @LastItem = ''
SET @SaveExists = 0

WHILE 1=1
BEGIN

  FETCH CreateApsExceptionsCrs1 INTO
    @Item, @Date, @IsSupply, @Demand, @Supply, @FixedSupply, @MinCap,
    @RefOrderType, @RefOrderNum, @RefOrdLineSuf, @RefOrderRel, @RefSequence, @UseRePoint

  IF @@FETCH_STATUS = -1
    BREAK
  ELSE IF @@FETCH_STATUS = -2
    CONTINUE

  IF @LastItem <> @Item
  BEGIN

    -- check for unnecessary part receipt
    IF @SaveExists = 1 AND (@Level - @SaveQty) >= @SaveMinCap AND @SaveUseRePoint=0
    BEGIN
      -- we didn't need that last supply
      SET @ExcCode = 15 -- unnecessary part receipts

      INSERT INTO @Exceptions (
         order_type, order_num, ord_line_suf, order_rel,
         sequence, except_code, item, date_req, qty)
      VALUES (
         @SaveRefOrderType, 
         @SaveRefOrderNum, @SaveRefOrdLineSuf, @SaveRefOrderRel, @SaveRefSequence,
         @ExcCode, @SaveItem, @SaveDate, @SaveQty)

      SELECT @Severity = @@ERROR
      IF @Severity <> 0 BREAK
    END

    SET @QtyOnHand = (select qty_on_hand from @ItemQtyOnHand where item = @Item)
    SET @LastItem   = @Item
    SET @Level      = @QtyOnHand
    SET @Safe  = case when @QtyOnHand >= @MinCap then 1 else 0 end
    SET @SaveExists = 0
  END

  IF @IsSupply = 1
  BEGIN
     IF @FixedSupply = 1
     BEGIN
        -- This might be the last supply so we save it for later
        -- We only want the exception on fixed supplies
        -- Planned supplies shouldn't get an unneccesary part recpt excpetion
        SET @SaveItem   = @Item
        SET @SaveDate   = @Date
        SET @SaveQty    = @Supply
        SET @SaveMinCap = @MinCap
        set @SaveRefOrderType = @RefOrderType
        set @SaveRefOrderNum = @RefOrderNum
        set @SaveRefOrdLineSuf = @RefOrdLineSuf
        set @SaveRefOrderRel = @RefOrderRel
        set @SaveRefSequence = @RefSequence
        SET @SaveExists = 1
        SET @SaveUseRePoint= @UseRePoint
     END
     ELSE
        SET @SaveExists = 0
  END

  set @Level = @Level + case when @IsSupply = 1 then @Supply else -@Demand end

  IF @Safe = 1 AND @Level < @MinCap
  BEGIN
    -- We used to be above safety stock

    SET @ExcCode = 1 -- below safety stock

    INSERT INTO @Exceptions (
       order_type, order_num, ord_line_suf, order_rel,
       sequence, except_code, item, date_req, qty)
    VALUES (
       @RefOrderType, @RefOrderNum, @RefOrdLineSuf, @RefOrderRel, 
       @RefSequence, @ExcCode, @Item, @Date, @Demand)

    SELECT @Severity = @@ERROR
    IF @Severity <> 0 BREAK

    SET @Safe = 0
  END

  IF @Safe = 0 AND @Level >= @MinCap
     SET @Safe = 1
END

CLOSE CreateApsExceptionsCrs1
DEALLOCATE CreateApsExceptionsCrs1

IF @Severity <> 0
  RETURN @Severity

-- check for unnecessary part receipt
IF @SaveExists = 1 AND (@Level - @SaveQty) >= @MinCap
BEGIN
  -- we didn't need that last supply
  SET @ExcCode = 15 -- unnecessary part receipts

  INSERT INTO @Exceptions (
     order_type, order_num, ord_line_suf, order_rel,
     sequence, except_code, item, date_req, qty)
  VALUES (
     @SaveRefOrderType, 
     @SaveRefOrderNum, @SaveRefOrdLineSuf, @SaveRefOrderRel, @SaveRefSequence,
     @ExcCode, @SaveItem, @SaveDate, @SaveQty)

  SELECT @Severity = @@ERROR
  IF @Severity <> 0
     RETURN @Severity
END

---------------------------------------------------------------------

/* make late order exceptions */

DECLARE CreateApsExceptionsCrs2 CURSOR FOR
SELECT a.ORDERID, a.DUEDATE, a.ORDSIZE, a.MATERIALID, a.ORDTYPE,
       a.OrderTable, a.OrderRowPointer, b.CALCDATE, 
       0 AS MATLTAG, 0 AS PMATLTAG, 0 AS PPMATLTAG, 0 AS EXCTYPE
FROM ORDER000 a
  INNER JOIN ORDPLAN000 b ON a.ORDERID = b.ORDERID
WHERE (a.ORDTYPE = 100 OR -- Scheduled Workorder
       a.ORDTYPE = 200 OR -- customer order
       a.ORDTYPE = 250 OR -- released jobs
       a.ORDTYPE = 240 OR -- firm jobs
       a.ORDTYPE = 300 OR -- forecasts
       a.ORDTYPE = 245)   -- firm jobmatl requirements
       AND b.CALCDATE > a.DUEDATE
UNION
SELECT a.ORDERID, d.SCHDATE AS DUEDATE, a.ORDSIZE, a.MATERIALID, a.ORDTYPE,
       a.OrderTable, a.OrderRowPointer, b.CALCDATE, 
       c.MATLTAG, c.PMATLTAG, 0 AS PPMATLTAG, 1 AS EXCTYPE
FROM ORDER000 a
  INNER JOIN ORDPLAN000 b ON a.ORDERID = b.ORDERID
  INNER JOIN MATLPLAN000 c ON a.ORDERID = c.ORDERID AND c.PMATLTAG = 0
  INNER JOIN INVPLAN000 d ON c.MATLTAG = d.MATLTAG AND (d.SCHFLAGS & 8) <> 0
WHERE (a.ORDTYPE = 310)   -- safety stock
       AND b.CALCDATE > d.SCHDATE
UNION     
SELECT a.ORDERID, d.SCHDATE AS DUEDATE, a.ORDSIZE, c1.MATERIALID, a.ORDTYPE,
       a.OrderTable, a.OrderRowPointer, c1.ENDDATE AS CALCDATE, 
       c1.MATLTAG, c1.PMATLTAG, c2.PMATLTAG AS PPMATLTAG, 2 AS EXCTYPE
FROM ORDER000 a
  INNER JOIN ORDPLAN000 b ON a.ORDERID = b.ORDERID
  INNER JOIN MATLPLAN000 c1 ON a.ORDERID = c1.ORDERID
  INNER JOIN MATLPLAN000 c2 ON c2.MATLTAG = c1.PMATLTAG
  INNER JOIN INVPLAN000 d ON c1.MATLTAG = d.MATLTAG AND (d.SCHFLAGS & 8) <> 0
WHERE c1.ENDDATE > d.SCHDATE
FOR READ ONLY

OPEN CreateApsExceptionsCrs2

WHILE 1=1
BEGIN

  FETCH CreateApsExceptionsCrs2 INTO
    @Order, @DueDate, @OrdSize, @Item, @OrdType, @OrderTable, @OrderRowPointer, 
    @CalcDate, @MatlTag, @ParentMatlTag, @PPMatlTag, @MsgType

  IF @@FETCH_STATUS = -1
    BREAK
  ELSE IF @@FETCH_STATUS = -2
    CONTINUE

  IF (@MsgType = 0) OR (@MsgType = 2 AND @PPMatlTag = 0)
  BEGIN
    EXECUTE GetApsRefFieldsSp @Order
                            , @RefOrderType  OUTPUT
                            , @RefOrderNum   OUTPUT
                            , @RefOrdLineSuf OUTPUT
                            , @RefOrderRel   OUTPUT
                            , @RefSequence   OUTPUT
    SET @ExcCode = CASE 
                     WHEN (@MsgType = 0) AND @OrdType IN (240, 250) THEN 5 /* Rcpt Past Due */
                     ELSE 6                                                /* Rqmnt Past Due */ 
                   END
  END
  ELSE
  BEGIN
    SET @RefOrderType  = 'N'
    IF @MsgType = 1
      SET @RefOrderNum = ltrim(str(@MatlTag))
    ELSE
      SET @RefOrderNum = ltrim(str(@ParentMatlTag))
    SET @RefOrdLineSuf = NULL
    SET @RefOrderRel   = NULL
    SET @RefSequence   = NULL
    IF @MsgType = 1
      SET @ExcCode     = 5
    ELSE
      SET @ExcCode     = 6    
  END

  INSERT INTO @Exceptions (order_type, order_num, ord_line_suf, order_rel,
                           sequence, except_code, item, date_req, qty)
  VALUES (@RefOrderType, @RefOrderNum, @RefOrdLineSuf, @RefOrderRel, 
          @RefSequence, @ExcCode, @Item, @DueDate, DATEDIFF(DAY, @CalcDate, @DueDate))

  SELECT @Severity = @@ERROR
  IF @Severity <> 0 BREAK

END

CLOSE CreateApsExceptionsCrs2
DEALLOCATE CreateApsExceptionsCrs2

IF @Severity <> 0
  RETURN @Severity

---------------------------------------------------------------------


---------------------------------------------------------------------

/* make late PO and PO Req exceptions */
/* These are done separately since there are not APS "ORDER" records for these */

set @CurrentDate = dbo.MidnightOf(dbo.GetSiteDate(getdate()))
insert @Exceptions
   select 
    poitem.po_num
  , 'P'
  , poitem.po_line
  , poitem.po_release
  , 0
  , poitem.item
  , 5  -- Rcpt Past Due
  , poitem.due_date
  , DATEDIFF(DAY, poitem.due_date, @CurrentDate)
   from poitem 
   inner join item on item.item = poitem.item
   where poitem.due_date < @CurrentDate and 
         poitem.stat IN ('P', 'O')

if @MrpParmPreqChk = 1 
   insert @Exceptions
      select 
       preqitem.req_num
     , 'R'
     , preqitem.req_line
     , 0
     , 0
     , preqitem.item
     , 5  -- Rcpt Past Due
     , preqitem.due_date
     , DATEDIFF(DAY, preqitem.due_date, @CurrentDate)
      from preqitem 
      inner join item on item.item = preqitem.item
      where preqitem.due_date < @CurrentDate and
            preqitem.stat in ('R', 'A', 'S')

---------------------------------------------------------------------

/* make out of range order exceptions */

DECLARE CreateApsExceptionsCrs3 CURSOR FOR
SELECT a.ORDERID, a.DUEDATE, a.ORDSIZE, a.MATERIALID,
       a.OrderTable, a.OrderRowPointer
FROM ORDER000 a, ALTPLAN b
WHERE b.ALTNO = 0
  AND a.SCHEDONLYFG = 'N'
  AND DATEDIFF(HOUR, dbo.GetSiteDate(getdate()), a.DUEDATE) > b.PLANHORIZ
FOR READ ONLY

OPEN CreateApsExceptionsCrs3

WHILE 1=1
BEGIN

  FETCH CreateApsExceptionsCrs3 INTO
      @Order, @DueDate, @OrdSize, @Item, @OrderTable, @OrderRowPointer

  IF @@FETCH_STATUS = -1
    BREAK
  ELSE IF @@FETCH_STATUS = -2
    CONTINUE

  IF @OrderTable = 'jobmatl'
  BEGIN
    SELECT @Order = dbo.ApsJobOrderId(jobmatl.job, jobmatl.suffix)
    FROM jobmatl
    WHERE jobmatl.RowPointer = @OrderRowPointer
  END

  EXECUTE GetApsRefFieldsSp @Order
                          , @RefOrderType  OUTPUT
                          , @RefOrderNum   OUTPUT
                          , @RefOrdLineSuf OUTPUT
                          , @RefOrderRel   OUTPUT
                          , @RefSequence   OUTPUT

  SET @ExcCode = 7 /* Orders out of planning horizon */

  INSERT INTO @Exceptions (order_type, order_num, ord_line_suf, order_rel,
                           sequence, except_code, item, date_req, qty)
  VALUES (@RefOrderType, @RefOrderNum, @RefOrdLineSuf, @RefOrderRel, 
          @RefSequence, @ExcCode, @Item, @DueDate, @OrdSize)

  SELECT @Severity = @@ERROR
  IF @Severity <> 0 BREAK

END

CLOSE CreateApsExceptionsCrs3
DEALLOCATE CreateApsExceptionsCrs3

IF @Severity <> 0
  RETURN @Severity

---------------------------------------------------------------------

/* make move-in/move-out/not-used supply exceptions */

DECLARE CreateApsExceptionsCrs4 CURSOR FOR
SELECT a.ORDERID, dbo.MidnightOf(a.NEWDATE), a.MSGTYPE, CONVERT(FLOAT, b.AMOUNT) AS ORDSIZE,
       dbo.MidnightOf(b.DELVDATE), b.MATERIALID, b.OrderTable, b.OrderRowPointer
FROM POEXCEPT000 a
  INNER JOIN MATLDELV000 b ON a.ORDERID = b.ORDERID
WHERE a.MSGTYPE IN (1,2,3) 
FOR READ ONLY

OPEN CreateApsExceptionsCrs4

WHILE 1=1
BEGIN

  FETCH CreateApsExceptionsCrs4 INTO
    @Order, @Date, @MsgType, @OrdSize, @DueDate, @Item, @OrderTable, @OrderRowPointer

  IF @@FETCH_STATUS = -1
    BREAK
  ELSE IF @@FETCH_STATUS = -2
    CONTINUE

  IF @OrderTable = 'jobmatl'
  BEGIN
    SELECT @Order = dbo.ApsJobOrderId(jobmatl.job, jobmatl.suffix)
    FROM jobmatl
    WHERE jobmatl.RowPointer = @OrderRowPointer
  END

  EXECUTE GetApsRefFieldsSp @Order
                          , @RefOrderType  OUTPUT
                          , @RefOrderNum   OUTPUT
                          , @RefOrdLineSuf OUTPUT
                          , @RefOrderRel   OUTPUT
                          , @RefSequence   OUTPUT

  SET @Date = CASE
                WHEN @MsgType = 3 THEN @DueDate
                ELSE @Date
              END

  if @MsgType in (1, 2)
  begin
     -- Push date up by dock to stock
     select @Date = dbo.MidnightOf(mcal.m_date)
     from (
        select top 1 mcali.mday_num
        from mcal mcali
        where mcali.m_date <= @Date
        order by mcali.m_date desc
       ) as m1
     join item on item.item = @Item
     join mcal on mcal.mday_num = m1.mday_num - isnull(item.dock_time,0)

     if @DueDate = @Date
        continue
  end

  SET @ExcCode = CASE 
                   WHEN @MsgType = 1 THEN 13 /* Move In    */
                   WHEN @MsgType = 2 THEN 14 /* Move Out   */
                   WHEN @MsgType = 3 THEN 15 /* Not Needed */
                 END

  INSERT INTO @Exceptions (order_type, order_num, ord_line_suf, order_rel,
                           sequence, except_code, item, date_req, qty)
  VALUES (@RefOrderType, @RefOrderNum, @RefOrdLineSuf, @RefOrderRel, 
          @RefSequence, @ExcCode, @Item, @Date, @OrdSize)

  SELECT @Severity = @@ERROR
  IF @Severity <> 0 BREAK

END

CLOSE CreateApsExceptionsCrs4
DEALLOCATE CreateApsExceptionsCrs4

IF @Severity <> 0
  RETURN @Severity

---------------------------------------------------------------------

/* Move In Receipt (Tolerance) exceptions */

DECLARE CreateApsExceptionsCrs5 CURSOR FOR
SELECT c.ORDERID, min(a.SCHDATE), c.MATERIALID, c.ENDDATE, c.MATLTAG, c.PMATLTAG, d.SUPPLY,
    ISNULL(e.OrderTable, f.OrderTable), ISNULL(e.OrderRowPointer, f.OrderRowPointer)
FROM INVPLAN000 a
    INNER JOIN MATLPLAN000 b ON a.MATLTAG = b.MATLTAG
    INNER JOIN MATLPLAN000 c ON b.MATERIALID = c.MATERIALID AND c.ORDERID = a.SUPORDER
    INNER JOIN INVPLAN000 d ON c.MATLTAG = d.MATLTAG AND d.SUPPLY > 0 AND d.SCHDATE = c.ENDDATE
    LEFT JOIN ORDER000 e ON c.ORDERID = e.ORDERID 
    LEFT JOIN MATLDELV000 f ON c.ORDERID = f.ORDERID
WHERE datepart(dy, a.SCHDATE) <> datepart(dy, c.ENDDATE) 
    AND (a.SCHFLAGS & 33554432) <> 0 
GROUP BY c.ORDERID, c.MATLTAG, c.PMATLTAG, c.ENDDATE, c.PMATLTAG, c.MATERIALID, d.SUPPLY,
    e.OrderTable, e.OrderRowPointer, f.OrderTable, f.OrderRowPointer
FOR READ ONLY

OPEN CreateApsExceptionsCrs5

WHILE 1=1
BEGIN

  FETCH CreateApsExceptionsCrs5 INTO
    @Order, @Date, @Item, @DueDate, @MatlTag, @ParentMatlTag, @OrdSize, @OrderTable, @OrderRowPointer

  IF @@FETCH_STATUS = -1
    BREAK
  ELSE IF @@FETCH_STATUS = -2
    CONTINUE

  SET @ExcCode = 16 /* Move In Receipt */

  IF @ParentMatlTag <> 0
  BEGIN
    SET @RefOrderType  = 'N'
    SET @RefOrderNum   = @MatlTag
    SET @RefOrdLineSuf = 0
    SET @RefOrderRel   = 0
    SET @RefSequence   = 0
  END
  ELSE
  BEGIN
    IF @OrderTable = 'jobmatl'
    BEGIN
      SELECT @Order = dbo.ApsJobOrderId(jobmatl.job, jobmatl.suffix)
      FROM jobmatl
      WHERE jobmatl.RowPointer = @OrderRowPointer
    END

    EXECUTE GetApsRefFieldsSp @Order
                            , @RefOrderType  OUTPUT
                            , @RefOrderNum   OUTPUT
                            , @RefOrdLineSuf OUTPUT
                            , @RefOrderRel   OUTPUT
                            , @RefSequence   OUTPUT
  END

  INSERT INTO @Exceptions (order_type, order_num, ord_line_suf, order_rel,
                           sequence, except_code, item, date_req, qty)
  VALUES (@RefOrderType, @RefOrderNum, @RefOrdLineSuf, @RefOrderRel, 
          @RefSequence, @ExcCode, @Item, @Date, @OrdSize)

  SELECT @Severity = @@ERROR
  IF @Severity <> 0 BREAK

END

CLOSE CreateApsExceptionsCrs5
DEALLOCATE CreateApsExceptionsCrs5

IF @Severity <> 0
  RETURN @Severity

---------------------------------------------------------------------

/* Used Expedited Lead Time exception */

if exists(select * from shift000 where shiftid = 'PCAL')
   set @PCALExists = 1
else
   set @PCALExists = 0
      
DECLARE CreateApsExceptionsCrs6 CURSOR FOR
SELECT DATEDIFF(day, f.DUEDATE, e.CALCDATE), b.MATERIALID, b.MATLTAG, 
    dbo.ApsCalcExpTime(@PCALExists, d.USETNFG, a.SCHDATE, c.FLEADTIME, c.VLEADTIME, a.DEMAND, d.TIMENOW, d.LASTSYNCH)
FROM INVPLAN000 a
    INNER JOIN MATLPLAN000 b ON a.MATLTAG = b.MATLTAG
    INNER JOIN MATL000 c ON b.MATERIALID = c.MATERIALID
    INNER JOIN ALTPLAN d ON d.ALTNO = 0
    INNER JOIN ORDPLAN000 e ON b.ORDERID = e.ORDERID
    INNER JOIN ORDER000 f ON e.ORDERID = f.ORDERID
WHERE (a.SCHFLAGS & 16777216) <> 0
FOR READ ONLY

OPEN CreateApsExceptionsCrs6

WHILE 1=1
BEGIN

  FETCH CreateApsExceptionsCrs6 INTO
    @Date, @Item, @MatlTag, @ExpediteDays

  IF @@FETCH_STATUS = -1
    BREAK
  ELSE IF @@FETCH_STATUS = -2
    CONTINUE
  ELSE IF @ExpediteDays < 1
    CONTINUE

  SET @ExcCode       = 17 /* Used Expedited Lead Time */
  SET @RefOrderType  = 'N'
  SET @RefOrderNum   = @MatlTag
  SET @RefOrdLineSuf = 0
  SET @RefOrderRel   = 0
  SET @RefSequence   = 0

  
  INSERT INTO @Exceptions (order_type, order_num, ord_line_suf, order_rel,
                           sequence, except_code, item, date_req, qty)
  VALUES (@RefOrderType, @RefOrderNum, @RefOrdLineSuf, @RefOrderRel, 
          @RefSequence, @ExcCode, @Item, @Date, @ExpediteDays)

  SELECT @Severity = @@ERROR
  IF @Severity <> 0 BREAK

END

CLOSE CreateApsExceptionsCrs6
DEALLOCATE CreateApsExceptionsCrs6

IF @Severity <> 0
  RETURN @Severity

---------------------------------------------------------------------

/* Used Lead Time due to multisite recursion exception */

DECLARE CreateApsExceptionsCrs7 CURSOR FOR
SELECT a.SCHDATE, b.MATERIALID, b.MATLTAG, a.DEMAND 
FROM INVPLAN000 a
    INNER JOIN MATLPLAN000 b ON a.MATLTAG = b.MATLTAG
WHERE (a.SCHFLAGS & 268435456) <> 0
FOR READ ONLY

OPEN CreateApsExceptionsCrs7

WHILE 1=1
BEGIN

  FETCH CreateApsExceptionsCrs7 INTO
    @Date, @Item, @MatlTag, @OrdSize

  IF @@FETCH_STATUS = -1
    BREAK
  ELSE IF @@FETCH_STATUS = -2
    CONTINUE

  SET @ExcCode       = 18 /* Multisite recursion - use default leadtime */
  SET @RefOrderType  = 'N'
  SET @RefOrderNum   = @MatlTag
  SET @RefOrdLineSuf = 0
  SET @RefOrderRel   = 0
  SET @RefSequence   = 0

  
  INSERT INTO @Exceptions (order_type, order_num, ord_line_suf, order_rel,
                           sequence, except_code, item, date_req, qty)
  VALUES (@RefOrderType, @RefOrderNum, @RefOrdLineSuf, @RefOrderRel, 
          @RefSequence, @ExcCode, @Item, @Date, @OrdSize)

  SELECT @Severity = @@ERROR
  IF @Severity <> 0 BREAK

END

CLOSE CreateApsExceptionsCrs7
DEALLOCATE CreateApsExceptionsCrs7

IF @Severity <> 0
  RETURN @Severity

---------------------------------------------------------------------

/* load exceptions */

DECLARE CreateApsExceptionsCrsX CURSOR FOR
SELECT order_num, order_type, ord_line_suf, order_rel, sequence,
  item, except_code, date_req, qty
FROM @Exceptions
FOR READ ONLY

OPEN CreateApsExceptionsCrsX

WHILE 1=1
BEGIN

  FETCH CreateApsExceptionsCrsX INTO
      @RefOrderNum, @RefOrderType, @RefOrdLineSuf, @RefOrderRel, @RefSequence,
      @RefItem, @RefExceptCode, @RefDate, @RefQty

  IF @@FETCH_STATUS = -1
    BREAK
  ELSE IF @@FETCH_STATUS = -2
    CONTINUE

  EXECUTE @Severity = MrpExcSp @RefOrderNum, @RefOrderType, @RefItem, 
                               @RefDate, @RefExceptCode, @RefQty, 
                               @RefOrdLineSuf, @RefOrderRel, @Infobar OUTPUT
  IF @Severity <> 0 BREAK

END

CLOSE CreateApsExceptionsCrsX
DEALLOCATE CreateApsExceptionsCrsX

IF @Severity <> 0
  RETURN @Severity

---------------------------------------------------------------------

RETURN @Severity
GO