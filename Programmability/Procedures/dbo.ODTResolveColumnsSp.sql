SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ODTResolveColumnsSp] (
  @ParentObjectName    NVARCHAR(255)
, @ParentType          CHAR(3)
)
AS
-- Resolve table update alias:  UPDATE TableAlias FROM Table TableAlias ....
UPDATE ota
SET
  ota.TableName = ota2.TableName
, ota.TableAlias = ota2.TableAlias
FROM ODTTables ota, ODTTables ota2
WHERE (ota.TableAlias IS NULL OR ota.TableAlias = '')
AND   ota.TableName = ota2.TableAlias
AND   ABS( ota.TableLevel - ota2.TableLevel ) = ( SELECT MIN( ABS( ota3.TableLevel - ota4.TableLevel ) )
                                                  FROM ODTTables ota3, ODTTables ota4
                                                  WHERE (ota3.TableAlias IS NULL OR ota3.TableAlias = '')
                                                  AND   ota3.TableName = ota4.TableAlias
                                                  AND   ota.TableName = ota3.TableName
                                                  AND   ota2.TableName = ota4.TableName
                                                  AND   ota2.TableAlias = ota4.TableAlias )

-- These update routines could potentially fail because of alias conflicts, but it is rare.
-- If failure occurs, the server script should be modified to use non-ambiguous aliases.
UPDATE oco
SET ColumnAlias = ota.TableName
,   Resolved = 1
FROM ODTColumns oco, ODTTables ota
WHERE (oco.ColumnAlias = ota.TableAlias OR oco.ColumnAlias = ota.TableName)
AND   ABS( oco.ColumnLevel - ota.TableLevel ) = 
  ( SELECT MIN( ABS( oco2.ColumnLevel - ota2.TableLevel ) )
    FROM ODTColumns oco2, ODTTables ota2
    WHERE (oco2.ColumnAlias = ota2.TableAlias OR oco2.ColumnAlias = ota2.TableName)
    AND   oco2.ColumnName = oco.ColumnName
    AND   ota2.TableName = ota.TableName
    AND   EXISTS ( SELECT * FROM sysobjects sob2, syscolumns sco2
       WHERE sob2.id = sco2.id
       AND   sob2.type in ('U','V')
       AND   sob2.name = ota2.TableName
       AND   sco2.name = oco2.ColumnName ) )
AND   EXISTS ( SELECT * FROM sysobjects sob, syscolumns sco
               WHERE sob.id = sco.id
               AND   sob.type in ('U','V')
               AND   sob.name = ota.TableName
               AND   sco.name = oco.ColumnName )

UPDATE oco
SET ColumnAlias = ota.TableName
,   Resolved = 1
FROM ODTColumns oco, ODTTables ota
WHERE oco.Resolved = 0
AND   ( oco.ColumnAlias IS NULL OR oco.ColumnAlias = '' )
AND   ABS( oco.ColumnLevel - ota.TableLevel ) = ( SELECT MIN( ABS( oco2.ColumnLevel - ota2.TableLevel ) )
                                                  FROM ODTColumns oco2, ODTTables ota2
                                                  WHERE ( oco2.ColumnAlias IS NULL OR oco2.ColumnAlias = '' )
                                                  AND   oco2.ColumnName = oco.ColumnName
                                                  AND   ota2.TableName = ota.TableName
                                                  AND   EXISTS ( SELECT * FROM sysobjects sob2, syscolumns sco2
                                                                       WHERE sob2.id = sco2.id
                                                                       AND   sob2.type in ('U','V')
                                                                       AND   sob2.name = ota2.TableName
                                                                       AND   sco2.name = oco2.ColumnName ) )
AND   EXISTS ( SELECT * FROM sysobjects sob, syscolumns sco
                     WHERE sob.id = sco.id
                     AND   sob.type in ('U','V')
                     AND   sob.name = ota.TableName
                     AND   sco.name = oco.ColumnName )

-- Add unique object name
IF NOT EXISTS ( SELECT 1 FROM ODTObjects WHERE ObjectName = @ParentObjectName )
    INSERT INTO ODTObjects ( ObjectName ) VALUES ( @ParentObjectName )

-- Add unique table object name
INSERT INTO ODTObjects ( ObjectName )
SELECT DISTINCT ota.TableName
FROM ODTTables ota
WHERE NOT EXISTS ( SELECT 1 FROM ODTObjects oob WHERE oob.ObjectName = ota.TableName )

-- Add unique column object name
INSERT INTO ODTObjects ( ObjectName )
SELECT DISTINCT oco.ColumnAlias + '.' + oco.ColumnName
FROM ODTColumns oco
WHERE oco.Resolved = 1
AND   NOT EXISTS ( SELECT 1 FROM ODTObjects oob WHERE oob.ObjectName = oco.ColumnAlias + '.' + oco.ColumnName )

-- Add unique table dependency record
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT DISTINCT
  oob1.ObjectID
, @ParentType
, oob2.ObjectID
, ota.Operation
FROM ODTTables ota, ODTObjects oob1, ODTObjects oob2
WHERE oob1.ObjectName = @ParentObjectName
AND   oob2.ObjectName = ota.TableName
AND   (     ota.TableName LIKE '#%'
        OR  EXISTS ( SELECT * FROM sysobjects sob
                     WHERE sob.type in ('U','V')
                     AND   sob.name = ota.TableName ) )
AND   NOT EXISTS ( SELECT 1 FROM ODTObjectDepends ood
                   WHERE ood.ParentObjectID = oob1.ObjectID
                   AND   ood.ParentType = @ParentType
                   AND   ood.ChildObjectID = oob2.ObjectID
                   AND   ood.ChildType = ota.Operation )

-- Add unique column dependency record
-- Unresolved columns are ignored
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT DISTINCT
  oob1.ObjectID
, @ParentType
, oob2.ObjectID
, oco.Operation
FROM ODTColumns oco, ODTObjects oob1, ODTObjects oob2
WHERE oco.Resolved = 1
AND   oob1.ObjectName = @ParentObjectName
AND   oob2.ObjectName = oco.ColumnAlias + '.' + oco.ColumnName
AND   NOT EXISTS ( SELECT 1 FROM ODTObjectDepends ood
                   WHERE ood.ParentObjectID = oob1.ObjectID
                   AND   ood.ParentType = @ParentType
                   AND   ood.ChildObjectID = oob2.ObjectID
                   AND   ood.ChildType = oco.Operation )

RETURN 0
GO