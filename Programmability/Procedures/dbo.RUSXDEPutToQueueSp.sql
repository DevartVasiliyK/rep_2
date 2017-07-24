SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[RUSXDEPutToQueueSp](
  @PInsertFlag int = 1 
)
AS

DECLARE
  @MasterTable as varchar(50)
, @RowID as uniqueidentifier
, @RowIDStr as varchar(40)
, @Filter as  RUSXDEDescriptionType
, @TSql as RUSXDEDescriptionType
, @Action as varchar(1)

IF OBJECT_ID('tempdb..#tt_RUSXDEIns') IS NULL
  RETURN

if @PInsertFlag = 1
  set @Action = 'C'
else 
  set @Action = 'U'  

DECLARE tmp_curs CURSOR LOCAL STATIC FOR
SELECT
   MasterTable
 , RowPointer
 , Filter
FROM #tt_RUSXDEIns

--DECLARE @tt_MasterTables TABLE (MasterTable varchar(50))
--INSERT INTO @tt_MasterTables (MasterTable)
--SELECT DISTINCT MasterTable FROM #tt_RUSXDEIns

OPEN tmp_curs
WHILE 0 = 0
BEGIN
   FETCH tmp_curs INTO
      @MasterTable
    , @RowID
    , @Filter
   IF @@FETCH_STATUS <> 0 BREAK

--   set @RowIDStr = @RowID
--   set @TSql = 'select item from ' + @MasterTable + 'where RowPointer = ' + @RowIDStr

   exec RUSXDEPutToQueue1Sp @MasterTable, @Filter, @Action


END
CLOSE      tmp_curs
DEALLOCATE tmp_curs

GO