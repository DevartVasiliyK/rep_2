SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create procedure [dbo].[RUSBufSaveTable]
   @tbl sysname = null,
   @Clr bit = 1
AS BEGIN

   declare @bid uniqueidentifier, @Severity int

   DECLARE crs_buf CURSOR LOCAL STATIC FOR
   SELECT
      distinct bid
   FROM #RUSBuf
   WHERE typ = 'Table' and
      (@tbl is null or val = @tbl)

   OPEN crs_buf
   WHILE 0 = 0
   BEGIN
      FETCH crs_buf INTO @bid
      IF @@FETCH_STATUS <> 0 BREAK

      EXEC @Severity = dbo.RUSBufSave @bid, @Clr
      if @Severity <> 0 RETURN @Severity
   END
   CLOSE      crs_buf
   DEALLOCATE crs_buf

   RETURN 0
END

GO