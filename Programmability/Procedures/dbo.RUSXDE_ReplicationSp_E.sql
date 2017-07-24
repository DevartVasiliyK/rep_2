SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RUSXDE_ReplicationSp_E] (
@site NVARCHAR(8) = NULL
)AS
BEGIN TRANSACTION
--В следующей строке задается размер порции на выгрузку.
--При редактировании данного параметра следует учитывать, что 
--слишком большие значения увеличивают размер выгружаемых XML и время обработки выгрузки/загрузки
--слишком маленькие значения увеличивают количество файлов и загрузку очереди фоновых задач
SELECT TOP 500 -- кол-во строк в выгружаемой порции данных
rre.ToSite AS ToSite
,rre.OperationNumber AS OperationNumber
,rre.RefRowPointer AS RefRowPointer
INTO #RES
FROM ReplicatedRows3 rre 
WHERE rre.ToSite = ISNULL(@site,rre.ToSite)
ORDER BY rre.ToSite,rre.OperationNumber

SELECT rxrv.*,rre.*,sve.*
FROM RUSXDE_ReplicationView rxrv
INNER JOIN (SELECT rre.* FROM ReplicatedRows3 rre INNER JOIN #RES res ON rre.OperationNumber=res.OperationNumber AND rre.RefRowPointer=res.RefRowPointer
)rre ON rxrv.ToSite = rre.ToSite
INNER JOIN ShadowValues sve ON rre.OperationNumber=sve.OperationNumber AND rre.RefRowPointer=sve.RowPointer 
WHERE rxrv.site = ISNULL(@site,rxrv.site)
ORDER BY rxrv.site,rre.OperationNumber,sve.LineNum
FOR XML AUTO

DECLARE @lkwoi InfobarType, @xState LongListType 
IF EXISTS(SELECT 1 
	FROM RUSXDE_ReplicationView rxrv
	INNER JOIN (SELECT rre.* FROM ReplicatedRows3 rre INNER JOIN #RES res ON rre.OperationNumber=res.OperationNumber AND rre.RefRowPointer=res.RefRowPointer
	)rre ON rxrv.ToSite = rre.ToSite
	INNER JOIN ShadowValues sve ON rre.OperationNumber=sve.OperationNumber AND rre.RefRowPointer=sve.RowPointer 
	WHERE rxrv.site = ISNULL(@site,rxrv.site))BEGIN

	EXEC SetTriggerStateSp 1,1,1,@xState OUTPUT, @lkwoi OUTPUT,1,1 
	UPDATE site SET RUSXDERepLastOutSeq = RUSXDERepLastOutSeq + 1 WHERE site.site = ISNULL(@site,site.site)
	EXEC RestoreTriggerStateSp 1, @xState, @lkwoi OUTPUT 
END

DELETE ShadowValues FROM ShadowValues sve
INNER JOIN #RES res ON res.OperationNumber=sve.OperationNumber AND res.RefRowPointer=sve.RowPointer 

DELETE ReplicatedRows3 FROM #RES res 
WHERE res.OperationNumber=ReplicatedRows3.OperationNumber AND res.RefRowPointer=ReplicatedRows3.RefRowPointer

IF EXISTS(SELECT 1 FROM ReplicatedRows3)BEGIN
	DECLARE @pFilter RUSXDEDescriptionType 
	SET @pFilter = CASE WHEN @Site IS NOT NULL THEN '@site='+ISNULL(@site,'NULL') ELSE '' END
	EXEC dbo.RUSXDEPutToQueue1Sp 'RUSXDE_ReplicationSp_E', @pFilter, 'C', NULL
END

COMMIT TRANSACTION
GO