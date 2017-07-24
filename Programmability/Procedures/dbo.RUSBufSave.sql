SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE procedure [dbo].[RUSBufSave]
   @bid uniqueidentifier,
   @Clr bit = 1
AS BEGIN
   declare @FldsU varchar(8000), @FldsIf varchar(8000), @FldsIv varchar(8000)
   declare @Own sysname, @Tbl sysname, @Flt varchar(8000), @Severity int
   select @FldsU = '', @FldsIf = '', @FldsIv = ''

   select
      @Own = o.nam, @Tbl = t.nam, @Flt = f.nam
   from #RUSBuf t
   join #RUSBuf o on o.bid = t.bid and o.typ = 'Owner'
   join #RUSBuf f on f.bid = t.bid and f.typ = 'Filter'
   where t.bid = @bid and t.typ = 'Table'

   if @Tbl like '#%'
      select
         @FldsU  = @FldsU  + ', ' + c.nam + ' = ' + dbo.RUSToStr(c.val),
         @FldsIf = @FldsIf + ', ' + c.nam,
         @FldsIv = @FldsIv + ', ' + dbo.RUSToStr(c.val)
      from #RUSBuf c
      join tempdb..syscolumns sc on sc.id = object_id('tempdb.' + @Own + @Tbl) and sc.name = c.nam
      where c.bid = @bid and c.typ = 'Field' and c.flg = 1
   else
      select
         @FldsU  = @FldsU  + ', ' + c.nam + ' = ' + dbo.RUSToStr(c.val),
         @FldsIf = @FldsIf + ', ' + c.nam,
         @FldsIv = @FldsIv + ', ' + dbo.RUSToStr(c.val)
      from #RUSBuf c
      join syscolumns sc on sc.id = object_id(@Own + @Tbl) and sc.name = c.nam
      where c.bid = @bid and c.typ = 'Field' and c.flg = 1

   select
      @Tbl    = @Own + @Tbl,
      @FldsU  = rtrim(substring(@FldsU, 2, len(@FldsU))),
      @FldsIf = rtrim(substring(@FldsIf, 2, len(@FldsIf))),
      @FldsIv = rtrim(substring(@FldsIv, 2, len(@FldsIv)))

   if @FldsU <> '' begin
      EXEC ('update ' + @Tbl + ' set ' + @FldsU + ' where ' + @Flt
         + ' if @@ROWCOUNT = 0'
         + ' insert ' + @Tbl + ' (' + @FldsIf + ') values (' + @FldsIv + ')')
      set @Severity = @@ERROR
      if @Severity <> 0 return @Severity
   end

   if @Clr = 1 delete from #RUSBuf where bid = @bid

   RETURN 0
END
GO