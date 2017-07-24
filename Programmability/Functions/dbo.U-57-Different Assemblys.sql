SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[U-57-Different Assemblys] (@f [float])
RETURNS [float]
AS
EXTERNAL NAME [Clr_function].[Clr_function.APress.Samples.Sql].[Fahrenheit2Celsius]
GO