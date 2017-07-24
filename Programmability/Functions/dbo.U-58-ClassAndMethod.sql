SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[U-58-ClassAndMethod] (@parameter_name [int])
RETURNS TABLE (
  [title] [nvarchar](256) NULL,
  [link] [nvarchar](256) NULL,
  [pubdate] [datetime] NULL,
  [description] [nvarchar](max) NULL
)
WITH EXECUTE AS N'dbo'
AS
EXTERNAL NAME [table_function5].[Clr_function5.APress.Samples.Sql].[GetYahooNews]
GO