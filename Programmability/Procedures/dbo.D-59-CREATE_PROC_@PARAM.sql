﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[D-59-CREATE_PROC_@PARAM]
@param1 nvarchar(50) = opaopaopapapa
AS 
BEGIN
PRINT @param1
END;

GO