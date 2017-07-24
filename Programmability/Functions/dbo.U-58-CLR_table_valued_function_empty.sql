SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[U-58-CLR_table_valued_function/empty] (@parameter_name [int])
RETURNS TABLE (
  [title] [nvarchar](256) NULL,
  [link] [nvarchar](256) NULL,
  [pubdate] [datetime] NULL,
  [description] [nvarchar](max) NULL
)
AS
EXTERNAL NAME [table_function].[Clr_function.APress.Samples.Sql].[GetYahooNews]
GO