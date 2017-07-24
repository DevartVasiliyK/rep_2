SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create procedure [dbo].[RUSBufCopy]
   @frid uniqueidentifier,
   @frpre sysname = '',
   @toid uniqueidentifier,
   @topre sysname = ''
AS BEGIN
   delete tof
   from #RUSBuf tof
   join #RUSBuf frf on frf.bid = @frid and frf.typ = 'Field' and
      substring(frf.nam, len(@frpre) + 1, len(frf.nam)) =
      substring(tof.nam, len(@topre) + 1, len(tof.nam))
   where tof.bid = @toid and tof.typ = 'Field'

   declare @Own sysname, @Tbl sysname
   select @Own = nam from #RUSBuf where bid = @toid and typ = 'Owner'
   select @Tbl = nam from #RUSBuf where bid = @toid and typ = 'Table'

   if @Tbl like '#%'
      insert into #RUSBuf (bid, typ, nam, val, flg)
      select @toid, 'Field', @topre + substring(fr.nam,  len(@frpre) + 1, len(fr.nam)), fr.val, 1
      from #RUSBuf fr
      join tempdb..syscolumns sc on sc.id = object_id('tempdb.' + @Own + @Tbl) and
         substring(sc.name, len(@topre) + 1, len(sc.name)) =
         substring(fr.nam,  len(@frpre) + 1, len(fr.nam))
      where fr.bid = @frid and fr.typ = 'Field' and
         (not fr.val is null or sc.isnullable = 1)
   else
      insert into #RUSBuf (bid, typ, nam, val, flg)
      select @toid, 'Field', @topre + substring(fr.nam,  len(@frpre) + 1, len(fr.nam)), fr.val, 1
      from #RUSBuf fr
      join syscolumns sc on sc.id = object_id(@Own + @Tbl) and
         substring(sc.name, len(@topre) + 1, len(sc.name)) =
         substring(fr.nam,  len(@frpre) + 1, len(fr.nam))
      where fr.bid = @frid and fr.typ = 'Field' and
         (not fr.val is null or sc.isnullable = 1)
END

GO