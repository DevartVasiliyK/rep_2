SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[U-55-Cases, spaces, comments / empty]
(@p1 int) RETURNS TABLE
AS RETURN (seLECt C1 fRom /*comment*/ [U-55-t1]);-- comment
GO