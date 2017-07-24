SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--  Loads up the background task links for tree.
CREATE PROCEDURE [dbo].[ODTBGTasksSp]
AS
INSERT INTO ODTObjects (ObjectName)
SELECT DISTINCT REPLACE(TaskExecutable, 'SL.', '') 
FROM BGTaskDefinitions AS bgt
WHERE NOT EXISTS (SELECT 1
  FROM ODTObjects AS odt
  WHERE REPLACE(bgt.TaskExecutable, 'SL.', '') = odt.ObjectName
)

INSERT INTO ODTObjects (ObjectName)
SELECT TaskName FROM BGTaskDefinitions AS bgt
WHERE NOT EXISTS (SELECT 1
  FROM ODTObjects AS odt
  WHERE bgt.TaskName = odt.ObjectName
)

INSERT INTO ODTObjectDepends (ParentObjectID, ParentType
  , ChildObjectID, ChildType)
SELECT
  odo1.ObjectID
, 'BGT'
, odo2.ObjectID
, CASE bgt.TaskTypeCode WHEN 'SP' THEN 'SPR'
  WHEN 'IDOMTH' THEN 'OBM'
 ELSE bgt.TaskTypeCode
  END
FROM BGTaskDefinitions AS bgt
INNER JOIN ODTObjects AS odo1 ON
  odo1.ObjectName = bgt.TaskName
INNER JOIN ODTObjects AS odo2 ON
  odo2.ObjectName = REPLACE(bgt.TaskExecutable, 'SL.', '')
WHERE NOT EXISTS (SELECT 1
  FROM ODTObjectDepends as ood
  WHERE ood.ParentObjectID = odo1.ObjectID
  AND ood.ChildObjectID = odo2.ObjectID
  AND ood.ParentType = 'BGT'
  AND ood.ChildType = CASE bgt.TaskTypeCode WHEN 'SP' THEN 'SPR' 
    WHEN 'IDOMTH' THEN 'OBM'
    ELSE bgt.TaskTypeCode END
)
RETURN
GO