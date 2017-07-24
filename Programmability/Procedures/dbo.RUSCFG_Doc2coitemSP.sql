SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create procedure [dbo].[RUSCFG_Doc2coitemSP]
   @QueSeq int
AS BEGIN

   if object_id('tempdb..#RUSBuf') is null
      create table #RUSBuf (bid uniqueidentifier, typ sysname, nam sysname, val nvarchar(4000), flg bit)

   declare @x_coitem uniqueidentifier set @x_coitem = newid()
   declare @x_cfgdoc uniqueidentifier set @x_cfgdoc = newid()

   declare @OptString nvarchar(4000)

   declare @co_num CoNumType, @co_line CoLineType, @co_release CoReleaseType
   declare @item ItemType, @u_m UMType, @description DescriptionType
   declare @tmp varchar(8000), @rp uniqueidentifier, @cnt int
   declare @Severity int

   if exists(select 1 from dbo.RUSCFG_Document d
      left outer join dbo.RUSCFG_DocField df on df.CFGDocID = d.RowPointer and df.Name = 'coitem__co_num'
      where d.QueSeq = @QueSeq and df.Value is null)
   RETURN

   delete from dbo.RUSXDE_coitem where QueSeq = @QueSeq

   DECLARE crs_docum CURSOR LOCAL STATIC FOR
   SELECT
      d.RowPointer, coitem__co_num.value, coitem__co_line.value, isnull(coitem__co_release.value, 0)
   FROM dbo.RUSCFG_Document d
   JOIN dbo.RUSCFG_DocField coitem__co_num on coitem__co_num.CFGDocID = d.RowPointer and coitem__co_num.Name = 'coitem__co_num'
   JOIN dbo.RUSCFG_DocField coitem__co_line on coitem__co_line.CFGDocID = d.RowPointer and coitem__co_line.Name = 'coitem__co_line'
   JOIN dbo.RUSCFG_DocField coitem__co_release on coitem__co_release.CFGDocID = d.RowPointer and coitem__co_release.Name = 'coitem__co_release'
   WHERE d.QueSeq = @QueSeq
   ORDER BY coitem__co_num.value, coitem__co_line.value, coitem__co_release.value, d.name

   OPEN crs_docum
   WHILE 0 = 0
   BEGIN
      FETCH crs_docum INTO
         @rp, @co_num, @co_line, @co_release
      IF @@FETCH_STATUS <> 0 BREAK

      set @tmp = 'RowPointer =' + dbo.RUSToStr(@rp)
      EXEC dbo.RUSBufRepos @x_cfgdoc, 'dbo.', 'RUSCFG_Document', @tmp, 1

      -- Add extended Document fields
      delete #RUSBuf from #RUSBuf
         join dbo.RUSCFG_DocField df on df.CFGDocID = @rp and df.Name = #RUSBuf.nam
         where #RUSBuf.bid = @x_cfgdoc and #RUSBuf.typ = 'Field'
      insert into #RUSBuf (bid, typ, nam, val)
         select @x_cfgdoc, 'Field', Name, Value
         from dbo.RUSCFG_DocField
         where CFGDocID = @rp



      set @OptString = ''

      select @OptString = @OptString + ' ' + opt.value
      from dbo.RUSCFG_Document doc
      join dbo.RUSCFG_Option opt on opt.CFGDocID = doc.RowPointer
      where doc.RowPointer = @rp and opt.value <> '' and not opt.value is null
      order by opt.Name

      set @OptString = (select Description from dbo.RUSCFG_Document where RowPointer = @rp)
         + ' ' + substring(@OptString, 2, len(@OptString))
      set @co_line = 0
      select @co_line = max(co_line) from dbo.RUSXDE_coitem
      where QueSeq = @QueSeq and co_num = @co_num
      set @co_line = isnull(@co_line, 0)

      DECLARE crs_cfgitem CURSOR LOCAL STATIC FOR
      SELECT distinct itm.item, itm.u_m, itm.description
      FROM dbo.RUSCFG_OptGroups grp
      join dbo.item itm on itm.item = grp.item
      WHERE @OptString like grp.OptCode

      set @cnt = 0

      OPEN crs_cfgitem
      WHILE 0 = 0
      BEGIN
         FETCH crs_cfgitem INTO @item, @u_m, @description
         IF @@FETCH_STATUS <> 0 BREAK

         set @co_line = @co_line + 1
         set @cnt = @cnt + 1
         set @tmp = 'QueSeq = ' + dbo.RUSToStr(@QueSeq)
            + ' and co_num =' + dbo.RUSToStr(@co_num)
            + ' and co_line = ' + dbo.RUSToStr(@co_line)
            + ' and co_release = ' + dbo.RUSToStr(@co_release)
         EXEC dbo.RUSBufRepos @x_coitem, 'dbo.', 'RUSXDE_coitem', @tmp
         EXEC dbo.RUSBufCopy @x_cfgdoc, 'coitem__', @x_coitem, ''

         EXEC dbo.RUSBufSet @x_coitem, 'item', @item
         EXEC dbo.RUSBufSet @x_coitem, 'u_m', @u_m
         EXEC dbo.RUSBufSet @x_coitem, 'description', @description
         EXEC dbo.RUSBufSet @x_coitem, 'co_line', @co_line
         EXEC dbo.RUSBufSet @x_coitem, 'QueSeq', @QueSeq

         EXEC dbo.RUSBufSave @x_coitem, 1
      END
      CLOSE      crs_cfgitem
      DEALLOCATE crs_cfgitem

      /* if @cnt > 0 */
      delete dbo.RUSCFG_Document where RowPointer = @rp and LinkedOID is null
   END
   CLOSE      crs_docum
   DEALLOCATE crs_docum

   EXEC @Severity = dbo.RUSXDE_coitemSP @QueSeq
   RETURN @Severity
END

GO