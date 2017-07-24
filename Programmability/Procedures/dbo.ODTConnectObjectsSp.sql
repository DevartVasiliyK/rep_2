SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* ODT - Object Dependency Scanner
**
** This routine performs an upward explosion from the input child object.
** The resulting tree is then pruned to contain only those leaf nodes which
** match the input parent.  This results in a series of parent/child items
** being SELECTed which show all the calling paths from the child to the
** parent.
*/
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
CREATE PROCEDURE [dbo].[ODTConnectObjectsSp] (
  @ParentObjectName    NVARCHAR(255)
, @ParentType          CHAR(3)
, @ChildObjectName     NVARCHAR(255)
, @ChildType           CHAR(3)
, @QuitLevel           TINYINT = 10
)
as

DECLARE
  @Level       TINYINT
, @InsertCount INT
, @Dup         TINYINT
, @RowPointer  INT

SELECT
  @Level = 1
, @Dup   = 0

/*
**  This temp table is used to gather the information needed.  The algorithm
** explodes up from the child, and then prunes off the nodes which do not
** lead to the input parent object.  The TreeHistory column is used to
** determine whether or not a loop has been generated.  Each node contains
** a history which indicates the full path to the root for that node.  In
** this way, set operations can be used to determine whether or not a loop
** has just been found for a particular route through the tree.  Example:
** "R1" calls "R1.2" calls "R1.2.1" etc.
*/
CREATE TABLE #TraverseTmp (
  ParentObjectID     INT
, ParentType         CHAR(3)
, UParentObjectName  NVARCHAR(255)
, ChildObjectID      INT
, ChildType          CHAR(3)
, UChildObjectName   NVARCHAR(255)
, DepthLevel         TINYINT
, Duplicate          TINYINT
, ParentPointer      INT
, TreeHistory        NVARCHAR(255)
, RowPointer         INT IDENTITY
)

IF @ChildType IN ( 'OBS', 'OBI', 'OBU', 'OBD', 'OBM', 'OPS', 'OPI', 'OPU' )
BEGIN
  INSERT INTO #TraverseTmp (
    ParentObjectID
  , ParentType
  , UParentObjectName
  , ChildObjectID
  , ChildType
  , UChildObjectName
  , DepthLevel
  , Duplicate
  , ParentPointer
  , TreeHistory
  )
  SELECT
    ood.ParentObjectID
  , ood.ParentType
  , UPPER(oob1.ObjectName)
  , ood.ChildObjectID
  , @ChildType
  , UPPER(oob2.ObjectName)
  , @Level
  , @Dup
  , -1
  , 'R'
  FROM ODTObjectDepends ood
       INNER JOIN ODTObjects oob1 ON
           ood.ParentObjectID = oob1.ObjectID
       INNER JOIN ODTObjects oob2 ON
           ood.ChildObjectID = oob2.ObjectID
  WHERE UPPER( oob2.ObjectName ) = UPPER( @ChildObjectName )
  AND   ood.ChildType = @ChildType
END
ELSE
BEGIN
  INSERT INTO #TraverseTmp (
    ParentObjectID
  , ParentType
  , UParentObjectName
  , ChildObjectID
  , ChildType
  , UChildObjectName
  , DepthLevel
  , Duplicate
  , ParentPointer
  , TreeHistory
  )
  SELECT
    ood.ParentObjectID
  , ood.ParentType
  , UPPER(oob1.ObjectName)
  , ood.ChildObjectID
  , @ChildType
  , UPPER(oob2.ObjectName)
  , @Level
  , @Dup
  , -1
  , 'R'
  FROM ODTObjectDepends ood
       INNER JOIN ODTObjects oob1 ON
           ood.ParentObjectID = oob1.ObjectID
       INNER JOIN ODTObjects oob2 ON
           ood.ChildObjectID = oob2.ObjectID
  WHERE oob2.ObjectName = @ChildObjectName
  AND   ood.ChildType = @ChildType
END

/*
**  The min rowpointer will be 1 since the table was just CREATEd, but if
** the table CREATE is changed to a SELECT into, that might not be the case.
*/
SELECT
  @RowPointer = MIN(RowPointer)
FROM #TraverseTmp

UPDATE #TraverseTmp
SET TreeHistory = 'R' + CONVERT (NVARCHAR, RowPointer - @RowPointer + 1)

CREATE INDEX #TraverseTmpIx1 on #TraverseTmp (ParentObjectID, ParentType)
CREATE INDEX #TraverseTmpIx2 on #TraverseTmp (ChildObjectID, ChildType)
CREATE INDEX #TraverseTmpIx3 on #TraverseTmp (TreeHistory)
CREATE INDEX #TraverseTmpIx4 on #TraverseTmp (UParentObjectName, ParentType)
CREATE INDEX #TraverseTmpIx5 on #TraverseTmp (UChildObjectName, ChildType)

WHILE 1=1
BEGIN
    SELECT
      @Level = @Level + 1

    INSERT INTO #TraverseTmp (
      ParentObjectID
    , ParentType
    , UParentObjectName
    , ChildObjectID
    , ChildType
    , UChildObjectName
    , DepthLevel
    , Duplicate
    , ParentPointer
    , TreeHistory
    )
    SELECT DISTINCT
      ood.ParentObjectID
    , ood.ParentType
    , UPPER(oob1.ObjectName)
    , ood.ChildObjectID
    , ood.ChildType
    , UPPER(oob2.ObjectName)
    , @Level
    , 0
    , tmp.RowPointer
    , tmp.TreeHistory
    FROM ODTObjectDepends ood
         INNER JOIN ODTObjects oob1 ON
             ood.ParentObjectID = oob1.ObjectID
         INNER JOIN ODTObjects oob2 ON
             ood.ChildObjectID = oob2.ObjectID
         INNER JOIN #TraverseTmp tmp ON
             ood.ChildObjectID = tmp.ParentObjectID
         AND ood.ChildType     = tmp.ParentType
    WHERE tmp.DepthLevel = @Level - 1
    AND   tmp.Duplicate  = 0
    AND   tmp.ParentType NOT IN ( 'OBS', 'OBI', 'OBU', 'OBD', 'OBM', 'OPS', 'OPI', 'OPU' )
    AND   NOT ( oob2.ObjectName = @ParentObjectName
            AND tmp.ParentType = @ParentType )

    SELECT  @InsertCount = @@ROWCOUNT

    INSERT INTO #TraverseTmp (
      ParentObjectID
    , ParentType
    , UParentObjectName
    , ChildObjectID
    , ChildType
    , UChildObjectName
    , DepthLevel
    , Duplicate
    , ParentPointer
    , TreeHistory
    )
    SELECT DISTINCT
      ood.ParentObjectID
    , ood.ParentType
    , UPPER(oob1.ObjectName)
    , ood.ChildObjectID
    , ood.ChildType
    , UPPER(oob2.ObjectName)
    , @Level
    , 0
    , tmp.RowPointer
    , tmp.TreeHistory
    FROM ODTObjectDepends ood
         INNER JOIN ODTObjects oob1 ON
             ood.ParentObjectID = oob1.ObjectID
         INNER JOIN ODTObjects oob2 ON
             ood.ChildObjectID = oob2.ObjectID
         INNER JOIN #TraverseTmp tmp ON
             UPPER( oob2.ObjectName ) = tmp.UParentObjectName
         AND ood.ChildType     = tmp.ParentType
    WHERE tmp.DepthLevel = @Level - 1
    AND   tmp.Duplicate  = 0
    AND   tmp.ParentType IN ( 'OBS', 'OBI', 'OBU', 'OBD', 'OBM', 'OPS', 'OPI', 'OPU' )
    AND   NOT ( UPPER( oob2.ObjectName ) = UPPER( @ParentObjectName )
            AND tmp.ParentType IN ( 'OBS', 'OBI', 'OBU', 'OBD', 'OBM', 'OPS', 'OPI', 'OPU' )
            AND tmp.ParentType = @ParentType )

    SELECT  @InsertCount = @InsertCount + @@ROWCOUNT

    /*
    **  The rowpointer is used to CREATE the history and the rowpointer is
    ** not known until the insert is done, hence the need for a separate
    ** update just to get history.
    */
    UPDATE #TraverseTmp
    SET TreeHistory = TreeHistory + '.' + CONVERT (NVARCHAR, RowPointer - ParentPointer + 1)
    WHERE DepthLevel = @Level

    UPDATE #TraverseTmp
    SET Duplicate = 1
    FROM #TraverseTmp tmp1
    WHERE tmp1.DepthLevel = @Level
    AND   ( EXISTS ( SELECT 1
                    FROM #TraverseTmp tmp2
                    WHERE tmp1.ParentObjectID = tmp2.ParentObjectID
                    AND   tmp1.ParentType     = tmp2.ParentType
                    AND   tmp2.DepthLevel     < @Level
                    AND   tmp1.TreeHistory    LIKE tmp2.TreeHistory + '.%' )
      OR    EXISTS ( SELECT 1
                     FROM #TraverseTmp tmp2
                     WHERE tmp1.UParentObjectName = tmp2.UParentObjectName
                     AND   tmp1.ParentType IN ( 'OBS', 'OBI', 'OBU', 'OBD', 'OBM', 'OPS', 'OPI', 'OPU' )
                     AND   tmp1.ParentType     = tmp2.ParentType
                     AND   tmp2.DepthLevel     < @Level
                     AND   tmp1.TreeHistory    LIKE tmp2.TreeHistory + '.%' ) )

    IF @InsertCount = 0 OR ( @QuitLevel <> 0 AND @Level >= @QuitLevel)
        BREAK
END

/*
**  This loop prunes the tree back down to only show the routes from the
** child to the parent leaf node.
*/
WHILE 1=1
BEGIN
    DELETE #TraverseTmp
    FROM #TraverseTmp tmp1
         INNER JOIN ODTObjects oob ON
             tmp1.ParentObjectID = oob.ObjectID
    WHERE tmp1.DepthLevel = @Level
    AND   NOT EXISTS ( SELECT 1
                       FROM #TraverseTmp tmp2
                       WHERE tmp2.DepthLevel = @Level + 1
                       AND   tmp2.ChildObjectID = tmp1.ParentObjectID
                       AND   tmp2.ChildType     = tmp1.ParentType
                       AND   tmp2.TreeHistory LIKE tmp1.TreeHistory + '.%')
    AND   NOT EXISTS ( SELECT 1
                       FROM #TraverseTmp tmp2
                       WHERE tmp2.DepthLevel = @Level + 1
                       AND   tmp2.UChildObjectName = tmp1.UParentObjectName
                       AND   tmp2.ChildType IN ( 'OBS', 'OBI', 'OBU', 'OBD', 'OBM', 'OPS', 'OPI', 'OPU' )
                       AND   tmp2.ChildType     = tmp1.ParentType
                       AND   tmp2.TreeHistory LIKE tmp1.TreeHistory + '.%')
    AND   NOT ( oob.ObjectName = @ParentObjectName
            AND tmp1.ParentType = @ParentType )
    AND   NOT ( UPPER( oob.ObjectName ) = UPPER( @ParentObjectName )
            AND tmp1.ParentType IN ( 'OBS', 'OBI', 'OBU', 'OBD', 'OBM', 'OPS', 'OPI', 'OPU' )
            AND tmp1.ParentType = @ParentType )

    SELECT
      @Level = @Level - 1

    IF @Level <= 0
        BREAK
END

SELECT oob.ObjectName, tmp.ParentType, tmp.TreeHistory
FROM #TraverseTmp tmp
     INNER JOIN ODTObjects oob ON
         tmp.ParentObjectID = oob.ObjectID
ORDER BY TreeHistory

DROP TABLE #TraverseTmp
RETURN 0
GO