SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create procedure [dbo].[RUSBufRelease]
   @bid uniqueidentifier = null
AS BEGIN
   delete from #RUSBuf where (@bid is null or bid = @bid)
END

GO