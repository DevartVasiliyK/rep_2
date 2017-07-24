SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create procedure [dbo].[RUSBufSet]
   @bid uniqueidentifier,
   @fld sysname,
   @val varchar(8000)
AS BEGIN
   update f
   set
      f.val = @val,
      f.flg = 1
   from #RUSBuf f
   where f.bid = @bid and f.typ = 'Field' and f.nam = @Fld

   if @@ROWCOUNT < 1
   insert into #RUSBuf (bid, typ, nam, val, flg)
   values (@bid, 'Field', @Fld, @val, 1)
END

GO