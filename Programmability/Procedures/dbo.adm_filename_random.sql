SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[adm_filename_random](
  @file_name NVARCHAR(255) OUT,
  @prefix NVARCHAR(10)=NULL,
  @file_extension NVARCHAR(10)=NULL
  )
AS
SET NOCOUNT ON;

-- DECLARE @prefix NVARCHAR(10)='f_';
-- DECLARE @file_extension NVARCHAR(10)='mdf';
-- DECLARE @file_name NVARCHAR(255);

SET @prefix = LTRIM(LTRIM(@prefix));
SET @file_extension = LTRIM(LTRIM(@file_extension));

SET @file_name = LEFT(REPLACE(NEWID(),N'-',N''),10);

IF @prefix IS NOT NULL AND DATALENGTH(@prefix) > 0
  SET @file_name = @prefix + @file_name;
IF @file_extension IS NOT NULL AND DATALENGTH(@file_extension) > 0
  SET @file_name = @file_name+N'.'+@file_extension;
RETURN;
GO