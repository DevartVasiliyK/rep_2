SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/GenerateOrderPickListCo14sRSp.sp 5     10/14/03 7:42a Cummbry $  */
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
/*
   Procedure Overview:
      - Converted from co/co14-r.p, procedure: do-co14s-r
      - GenerateOrderPickListCo14sRSp

   Called by:
      - GenerateOrderPickList2Sp

   Notes:
      A) Only call if printing a summary.
*/

CREATE PROCEDURE [dbo].[GenerateOrderPickListCo14sRSp] (
   --Datatype @PSessionId is changed from RowPointerType to NVarchar (255)due to a limitation 
   --of Crystal Reports 9.0. Crystal Reports 9.0 does not identify the datatype RowPointerType, 
   --hence this change is required.
  @PSessionID   NVARCHAR(255)
) AS
DECLARE
   @Severity               INT,
   @TcQttTotQty            QtyUnitType,
   @TtItemloclot_QtyUsed   QtyUnitType,
   @ItemRowPointer         RowPointerType

DECLARE
   @TmpPickItemdet_CoLine             CoLineType,
   @TmpPickItemdet_CoRelease          CoReleaseType,
   @TmpPickItemdet_CoNum              CoNumType,
   @TmpPickItemdet_Item               ItemType,
   @TmpPickItemdet_QtyRequired        QtyUnitType,
   @TmpPickItemdet_UM                 UMType,
   @TmpPickItemdet_Whse               WhseType,
   @TmpPickItemdet_RowPointer         RowPointerType

DECLARE
   @TmpPickItemtot_Item               ItemType,
   @TmpPickItemtot_UM                 UMType,
   @TmpPickItemtot_QtyOnHand          QtyUnitType,
   @TmpPickItemtot_QtyRequired        QtyUnitType,
   @TmpPickItemtot_Whse               WhseType,
   @TmpPickItemtot_RowPointer         RowPointerType

DECLARE
   @TmpPickItemloclot_Whse               WhseType,
   @TmpPickItemloclot_Item               ItemType,
   @TmpPickItemloclot_Loc                LocType,
   @TmpPickItemloclot_Lot                LotType,
   @TmpPickItemloclot_QtyUsed            QtyUnitType,
   @TmpPickItemloclot_QtyOnHand          QtyUnitType,
   @TmpPickItemloclot_RowPointer         RowPointerType

-- setup tt_order_pick_list_item_info
DECLARE
   @TtOrderPickListItemInfo_TtItemtot_Whse         WhseType,
   @TtOrderPickListItemInfo_TtItemtot_Item         ItemType,
   @TtOrderPickListItemInfo_TtItemtotUM            UMType,
   @TtOrderPickListItemInfo_TtItemtot_QtyRequired  QtyUnitType,
   @TtOrderPickListItemInfo_TtItemtot_QtyOnHand    QtyUnitType,
   @TtOrderPickListItemInfo_TtItemloclot_Loc       LocType,
   @TtOrderPickListItemInfo_TtItemloclot_Lot       LotType,
   @TtOrderPickListItemInfo_TcQtuRequired          QtyUnitType,
   @TtOrderPickListItemInfo_TtItemloclot_QtyOnHand QtyUnitType,
   @TtOrderPickListItemInfo_CustaddrName           NameType,
   @TtOrderPickListItemInfo_TtItemdet_CoNum        CoNumType,
   @TtOrderPickListItemInfo_TtItemdet_CoLine       CoLineType,
   @TtOrderPickListItemInfo_TtItemdet_CoRelease    CoReleaseType,
   @TtOrderPickListItemInfo_TtItemdet_UM           UMType,
   @TtOrderPickListItemInfo_TtItemdet_QtyRequired  QtyUnitType
     
IF OBJECT_ID('tempdb..#tt_order_pick_list_item_info') IS NULL
SELECT
   @TtOrderPickListItemInfo_TtItemtot_Whse         AS tt_itemtot_whse,
   @TtOrderPickListItemInfo_TtItemtot_Item         AS tt_itemtot_item,
   @TtOrderPickListItemInfo_TtItemtotUM            AS tt_itemtot_um,
   @TtOrderPickListItemInfo_TtItemtot_QtyRequired  AS tt_itemtot_qty_req,
   @TtOrderPickListItemInfo_TtItemtot_QtyOnHand    AS tt_itemtot_qty_on_hand,
   @TtOrderPickListItemInfo_TtItemloclot_Loc       AS tt_itemloclot_loc,
   @TtOrderPickListItemInfo_TtItemloclot_Lot       AS tt_itemloclot_lot,
   @TtOrderPickListItemInfo_TcQtuRequired          AS tc_qtu_required,
   @TtOrderPickListItemInfo_TtItemloclot_QtyOnHand AS tt_itemloclot_qty_on_hand,
   @TtOrderPickListItemInfo_CustaddrName           AS custaddr_name,
   @TtOrderPickListItemInfo_TtItemdet_CoNum        AS tt_itemdet_co_num,
   @TtOrderPickListItemInfo_TtItemdet_CoLine       AS tt_itemdet_co_line,
   @TtOrderPickListItemInfo_TtItemdet_CoRelease    AS tt_itemdet_co_release,
   @TtOrderPickListItemInfo_TtItemdet_UM           AS tt_itemdet_u_m,
   @TtOrderPickListItemInfo_TtItemdet_QtyRequired  AS tt_itemdet_qty_req
INTO #tt_order_pick_list_item_info
WHERE 1=2

DECLARE 
  @OldWhse WhseType
, @OldItem ItemType

SET @Severity                                      = 0
SET @TcQttTotQty                                   = 0
SET @TtItemloclot_QtyUsed                          = 0
SET @TtOrderPickListItemInfo_TtItemtot_Item        = NULL
SET @TtOrderPickListItemInfo_TtItemtot_QtyOnHand   = 0
SET @TtOrderPickListItemInfo_TtItemtot_QtyRequired = 0
SET @TtOrderPickListItemInfo_TtItemtot_Whse        = NULL
SET @TtOrderPickListItemInfo_TtItemtotUM           = NULL
SET @OldWhse                                       = NULL
SET @OldItem                                       = NULL

-- Create Summary Records for Whse, Item, Location, Lot
DECLARE tmppick_itemtotCrs CURSOR LOCAL STATIC FOR
SELECT
  tmp_pick_itemtot.qty_on_hand
, tmp_pick_itemtot.whse
, tmp_pick_itemtot.item
, tmp_pick_itemtot.qty_required
, tmp_pick_itemloclot.loc
, tmp_pick_itemloclot.lot
, item.u_m
FROM tmp_pick_itemtot
LEFT OUTER JOIN tmp_pick_itemloclot
ON  tmp_pick_itemloclot.SessionID = tmp_pick_itemtot.SessionID
AND tmp_pick_itemloclot.whse      = tmp_pick_itemtot.whse
AND tmp_pick_itemloclot.item      = tmp_pick_itemtot.item
LEFT OUTER JOIN item
ON item.item = tmp_pick_itemtot.item
WHERE CONVERT(NVARCHAR(255),tmp_pick_itemtot.SessionID) = @PSessionID
ORDER BY tmp_pick_itemtot.whse, tmp_pick_itemtot.item

OPEN tmppick_itemtotCrs
WHILE @Severity = 0
BEGIN
   FETCH tmppick_itemtotCrs INTO
      @TtOrderPickListItemInfo_TtItemtot_QtyOnHand,
      @TtOrderPickListItemInfo_TtItemtot_Whse,
      @TtOrderPickListItemInfo_TtItemtot_Item,
      @TtOrderPickListItemInfo_TtItemtot_QtyRequired,
      @TtOrderPickListItemInfo_TtItemloclot_Loc,
      @TtOrderPickListItemInfo_TtItemloclot_Lot,
      @TtOrderPickListItemInfo_TtItemtotUM
   
   IF @@FETCH_STATUS = -1
      BREAK
   
   INSERT INTO #tt_order_pick_list_item_info (
     tt_itemtot_whse
   , tt_itemtot_item
   , tt_itemtot_um
   , tt_itemtot_qty_req
   , tt_itemtot_qty_on_hand
   , tt_itemloclot_loc          
   , tt_itemloclot_lot 
   )
   VALUES (
     @TtOrderPickListItemInfo_TtItemtot_Whse
   , @TtOrderPickListItemInfo_TtItemtot_Item
   , @TtOrderPickListItemInfo_TtItemtotUM
   , @TtOrderPickListItemInfo_TtItemtot_QtyRequired
   , @TtOrderPickListItemInfo_TtItemtot_QtyOnHand 
   , @TtOrderPickListItemInfo_TtItemloclot_Loc
   , @TtOrderPickListItemInfo_TtItemloclot_Lot
   )
   
   -- IF Working on a new whse or item, reset variables
   IF @OldWhse IS NULL 
   OR @OldItem IS NULL
   OR @OldWhse <> @TtOrderPickListItemInfo_TtItemtot_Whse
   OR @OldItem <> @TtOrderPickListItemInfo_TtItemtot_Item
   BEGIN
      SET @TcQttTotQty          = 0
      SET @TtItemloclot_QtyUsed = 0
      SET @OldWhse              = @TtOrderPickListItemInfo_TtItemtot_Whse
      SET @OldItem              = @TtOrderPickListItemInfo_TtItemtot_Item
   END

   SET @TtOrderPickListItemInfo_TtItemloclot_QtyOnHand = 0
   
   DECLARE tmppick_itemloclotCrs CURSOR LOCAL STATIC FOR
      SELECT
         tmp_pick_itemloclot.qty_used,
         tmp_pick_itemloclot.qty_on_hand
      FROM tmp_pick_itemloclot
      WHERE CONVERT(NVARCHAR(255),tmp_pick_itemloclot.SessionID) = @PSessionID
      AND   tmp_pick_itemloclot.whse = @TtOrderPickListItemInfo_TtItemtot_Whse 
      AND   tmp_pick_itemloclot.item = @TtOrderPickListItemInfo_TtItemtot_Item
      AND   tmp_pick_itemloclot.loc  = @TtOrderPickListItemInfo_TtItemloclot_Loc
      AND   tmp_pick_itemloclot.lot  = @TtOrderPickListItemInfo_TtItemloclot_Lot
   
   OPEN tmppick_itemloclotCrs
   WHILE @Severity = 0
   BEGIN
      FETCH tmppick_itemloclotCrs INTO
         @TtItemloclot_QtyUsed,
         @TtOrderPickListItemInfo_TtItemloclot_QtyOnHand
      
      IF @@FETCH_STATUS = -1
         BREAK
      
      IF @TcQttTotQty >= @TtOrderPickListItemInfo_TtItemtot_QtyRequired
         BREAK
      
      SET @TcQttTotQty = @TcQttTotQty + @TtItemloclot_QtyUsed
      
      IF @TcQttTotQty > @TtOrderPickListItemInfo_TtItemtot_QtyRequired
         SET @TtOrderPickListItemInfo_TcQtuRequired = @TtItemloclot_QtyUsed -
                                                      (@TcQttTotQty -
                                                       @TtOrderPickListItemInfo_TtItemtot_QtyRequired)
      ELSE
      BEGIN
         SET @TtOrderPickListItemInfo_TcQtuRequired = @TtItemloclot_QtyUsed
         
         IF @TtOrderPickListItemInfo_TcQtuRequired > @TtOrderPickListItemInfo_TtItemloclot_QtyOnHand
            SET @TtOrderPickListItemInfo_TcQtuRequired = @TtOrderPickListItemInfo_TtItemloclot_QtyOnHand
      END
      
      -- Since the selection criteria was based off of
      -- @TtOrderPickListItemInfo_TtItemtot_Whse and @TtOrderPickListItemInfo_TtItemtot_Item, the record
      -- can be found and inserted using those two
      -- instead of #tt_itemloclot's
      UPDATE #tt_order_pick_list_item_info
      SET #tt_order_pick_list_item_info.tt_itemloclot_loc          = @TtOrderPickListItemInfo_TtItemloclot_Loc,
          #tt_order_pick_list_item_info.tt_itemloclot_lot          = @TtOrderPickListItemInfo_TtItemloclot_Lot,
          #tt_order_pick_list_item_info.tc_qtu_required            = @TtOrderPickListItemInfo_TcQtuRequired,
          #tt_order_pick_list_item_info.tt_itemloclot_qty_on_hand  = @TtOrderPickListItemInfo_TtItemloclot_QtyOnHand
      WHERE #tt_order_pick_list_item_info.tt_itemtot_whse   = @TtOrderPickListItemInfo_TtItemtot_Whse 
      AND   #tt_order_pick_list_item_info.tt_itemtot_item   = @TtOrderPickListItemInfo_TtItemtot_Item
      AND   #tt_order_pick_list_item_info.tt_itemloclot_loc = @TtOrderPickListItemInfo_TtItemloclot_Loc
      AND   #tt_order_pick_list_item_info.tt_itemloclot_lot = @TtOrderPickListItemInfo_TtItemloclot_Lot
   END
   CLOSE      tmppick_itemloclotCrs
   DEALLOCATE tmppick_itemloclotCrs
      
END
CLOSE      tmppick_itemtotCrs
DEALLOCATE tmppick_itemtotCrs

-- Create Summary Records for Whse, Item, Order, Line, Release
INSERT INTO #tt_order_pick_list_item_info (
  tt_itemtot_whse
, tt_itemtot_item
, tt_itemtot_um
, tt_itemtot_qty_req
, tt_itemtot_qty_on_hand
, custaddr_name
, tt_itemdet_co_num   
, tt_itemdet_co_line 
, tt_itemdet_co_release 
, tt_itemdet_u_m          
, tt_itemdet_qty_req
)
SELECT
  tmp_pick_itemtot.whse
, tmp_pick_itemtot.item
, item.u_m
, tmp_pick_itemtot.qty_required
, tmp_pick_itemtot.qty_on_hand
, custaddr.name
, tmp_pick_itemdet.co_num
, tmp_pick_itemdet.co_line
, tmp_pick_itemdet.co_release
, tmp_pick_itemdet.u_m
, tmp_pick_itemdet.qty_required
FROM tmp_pick_itemtot
LEFT OUTER JOIN tmp_pick_itemdet
ON  tmp_pick_itemdet.SessionID = tmp_pick_itemtot.SessionID
AND tmp_pick_itemdet.whse      = tmp_pick_itemtot.whse
AND tmp_pick_itemdet.item      = tmp_pick_itemtot.item
LEFT OUTER JOIN item
ON item.item = tmp_pick_itemtot.item
LEFT OUTER JOIN co
ON co.co_num = tmp_pick_itemdet.co_num 
LEFT OUTER JOIN custaddr
ON  custaddr.cust_num = co.cust_num 
AND custaddr.cust_seq = co.cust_seq
WHERE CONVERT(NVARCHAR(255),tmp_pick_itemtot.SessionID )= @PSessionID
ORDER BY tmp_pick_itemtot.whse, tmp_pick_itemtot.item

RETURN @Severity
GO