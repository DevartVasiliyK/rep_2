SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create procedure [dbo].[RUSBufGet]
   @bid uniqueidentifier,
   @fld sysname,
	@res varchar(8000) output
AS BEGIN
   select @res = f.Val
   from #RUSBuf f
   join #RUSBuf t on t.bid = @bid and t.typ = 'Table' and t.flg = 1
   where f.bid = @bid and f.typ = 'Field' and f.nam = @Fld
END

GO