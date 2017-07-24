SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create procedure [dbo].[RUSBufRepos]
   @bid uniqueidentifier,
   @own sysname = 'dbo.',
   @tbl sysname,
   @flt varchar(8000),
   @ReadFields bit = 0
AS BEGIN
   create table #Pars (Par varchar(8000), Val varchar(8000))

   if @own is null or @tbl like '#%' set @own = '.'

   declare @Res int
   set @Res = 0

   delete from #RUSBuf where bid = @bid

   insert #RUSBuf (bid, typ, nam, flg)
      values (@bid, 'Owner', @own, 0)
   insert #RUSBuf (bid, typ, nam, flg)
      values (@bid, 'Table', @tbl, 0)
   insert #RUSBuf (bid, typ, nam)
      values (@bid, 'Filter', @flt)

   if @ReadFields = 1 begin
      if @tbl like '#%'
      insert into #RUSBuf (bid, typ, nam)
         select @bid, 'Field', sc.Name
         from tempdb..syscolumns sc
         where sc.id = object_id('tempdb.' + @own + @tbl)
      else insert into #RUSBuf (bid, typ, nam)
         select @bid, 'Field', sc.Name
         from syscolumns sc
         where sc.id = object_id(@own + @tbl)

      DECLARE @col varchar(8000)
      DECLARE col_crs CURSOR LOCAL FOR
      SELECT
         Nam
      FROM #RUSBuf
      WHERE bid = @bid and typ = 'Field'

      delete from #Pars
      insert #Pars (Par) values ('Val')

      OPEN col_crs
      WHILE 0 = 0
      BEGIN
         FETCH col_crs INTO @col
         IF @@FETCH_STATUS <> 0 BREAK

         EXEC('update #Pars set Val = '
             + ' (select ' + @col + ' from ' + @own + @tbl
             + ' where ' + @flt + ')')

         update #RUSBuf
            set
               Val = (select Val from #Pars)
            where current of col_crs
      END
      CLOSE      col_crs
      DEALLOCATE col_crs

      update #RUSBuf set flg = 1
      where bid = @bid and typ = 'Table'
   end

   delete from #Pars
   EXEC ('insert into #Pars (Val) '
      + ' select count(*) from ' + @own + @tbl + ' where ' + @flt)
   set @res = isnull((select Val from #Pars), 0)

   return @res
END

GO