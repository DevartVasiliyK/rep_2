SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[RUSXDEDelObjSp] AS

DECLARE 
  @ObjectId RUSXDEObjectIDType
, @SLKey RUSXDESLKeyType
  
IF OBJECT_ID('tempdb..#tt_RUSXDEDel') IS NULL
  RETURN
  
  
DECLARE tmp_curs CURSOR LOCAL STATIC FOR
SELECT
   ObjectId
 , SLKey
FROM #tt_RUSXDEDel

OPEN tmp_curs
WHILE 0 = 0
BEGIN
   FETCH tmp_curs INTO
      @ObjectId
    , @SLKey  
   IF @@FETCH_STATUS <> 0 BREAK

   EXEC dbo.RUSXDEDelObj1Sp @ObjectId, @SLKey
END
CLOSE      tmp_curs
DEALLOCATE tmp_curs

GO