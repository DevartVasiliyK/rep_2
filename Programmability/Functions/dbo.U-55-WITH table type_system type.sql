﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-55-WITH table type/system type]
(@p1 [U-55-table type1] READONLY) RETURNS TABLE
WITH ENCRYPTION
AS RETURN (select c1 from [U-55-t1]);
GO