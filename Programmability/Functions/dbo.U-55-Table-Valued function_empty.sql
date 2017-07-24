SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-55-Table-Valued function/empty]
(@p1 int) RETURNS TABLE
AS RETURN (select c1 from [U-55-t1]);
GO