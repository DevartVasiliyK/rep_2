SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[U-58-Different User] (@parameter_name [int])
RETURNS TABLE (
  [title] [nvarchar](256) NULL,
  [link] [nvarchar](256) NULL,
  [pubdate] [datetime] NULL,
  [description] [nvarchar](max) NULL
)
WITH EXECUTE AS N'U-58-USER2'
AS
EXTERNAL NAME [table_function4].[Clr_function4.APress.Samples.Sql].[GetYahooNews]
GO