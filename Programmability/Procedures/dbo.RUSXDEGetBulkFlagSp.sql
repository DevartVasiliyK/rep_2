SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RUSXDEGetBulkFlagSp](
  @pFlags bigint
, @pTransaction          int OUTPUT
, @pCheckConstraints     int OUTPUT
, @pForceTableLock       int OUTPUT
, @pIgnoreDuplicateKeys  int OUTPUT
, @pKeepIdentity         int OUTPUT
, @pKeepNulls            int OUTPUT
, @pSchemaGen            int OUTPUT
, @pSGDropTables         int OUTPUT
, @pSGUseID              int OUTPUT
)
AS

SELECT
  @pTransaction         = 0
, @pCheckConstraints    = 0
, @pForceTableLock      = 0
, @pIgnoreDuplicateKeys = 0
, @pKeepIdentity        = 0
, @pKeepNulls           = 0
, @pSchemaGen           = 0
, @pSGDropTables        = 0
, @pSGUseID             = 0

if (@pFlags & 1) > 0  SET @pTransaction = 1
if (@pFlags & 2) > 0  SET @pCheckConstraints = 1
if (@pFlags & 4) > 0  SET @pForceTableLock = 1
if (@pFlags & 8) > 0  SET @pIgnoreDuplicateKeys = 1
if (@pFlags & 16) > 0 SET @pKeepIdentity = 1
if (@pFlags & 32) > 0 SET @pKeepNulls = 1
if (@pFlags & 64) > 0 SET @pSchemaGen = 1
if (@pFlags & 128) > 0 SET @pSGDropTables = 1
if (@pFlags & 256) > 0 SET @pSGUseID = 1

RETURN 0
GO