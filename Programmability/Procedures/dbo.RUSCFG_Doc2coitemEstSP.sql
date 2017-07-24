SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create procedure [dbo].[RUSCFG_Doc2coitemEstSP]
   @QueSeq int
AS BEGIN
   declare @Infobar InfobarType, @Severity int

   if object_id('tempdb..#RUSBuf') is null
      create table #RUSBuf (bid uniqueidentifier, typ sysname, nam sysname, val nvarchar(4000), flg bit)

   declare @x_coitem uniqueidentifier set @x_coitem = newid()
   declare @x_cfgdoc uniqueidentifier set @x_cfgdoc = newid()

   declare @co_num CoNumType, @co_line CoLineType
   declare @item ItemType, @u_m UMType, @description DescriptionType
   declare @tmp varchar(8000), @rp uniqueidentifier

   declare @CurrCode CurrCodeType, @IncPrice CostPrcType

   if exists(select 1 from dbo.RUSCFG_Document d
      left outer join dbo.RUSCFG_DocField df on df.CFGDocID = d.RowPointer and df.Name = 'coitem__co_num'
      where d.QueSeq = @QueSeq and df.Value is null)
   RETURN

   delete from dbo.RUSXDE_coitem where QueSeq = @QueSeq

   DECLARE crs_docum CURSOR LOCAL STATIC FOR
   SELECT
      d.RowPointer, coitem__co_num.value, coitem__co_line.value, co.curr_code
   FROM dbo.RUSCFG_Document d
   JOIN dbo.RUSCFG_DocField coitem__co_num on coitem__co_num.CFGDocID = d.RowPointer and coitem__co_num.Name = 'coitem__co_num'
   JOIN dbo.RUSCFG_DocField coitem__co_line on coitem__co_line.CFGDocID = d.RowPointer and coitem__co_line.Name = 'coitem__co_line'
   JOIN dbo.co co on co.co_num = coitem__co_num.value
   WHERE d.QueSeq = @QueSeq
   ORDER BY coitem__co_num.value, coitem__co_line.value, d.name

   OPEN crs_docum
   WHILE 0 = 0
   BEGIN
      FETCH crs_docum INTO
         @rp, @co_num, @co_line, @CurrCode
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


      set @co_line = 0
      select @co_line = max(co_line) from dbo.RUSXDE_coitem
      where QueSeq = @QueSeq and co_num = @co_num
      set @co_line = isnull(@co_line, 0)

      EXEC dbo.RUSBufGet @x_cfgdoc, 'coitem__price_conv', @IncPrice output
      EXEC dbo.RUSBufGet @x_cfgdoc, 'item__item', @item output
      EXEC dbo.RUSBufGet @x_cfgdoc, 'item__u_m', @u_m output
      EXEC dbo.RUSBufGet @x_cfgdoc, 'item__description', @description output

      if @item is null or @item = '' CONTINUE

      -- Find ITEM (already configured) or create it (if new configuration)
      declare @rp2 uniqueidentifier, @x_item uniqueidentifier
      EXEC dbo.RUSCFG_FindSameDoc @rp, @rp2 output
      if not @rp2 is null
         select @item = item.item, @u_m = item.u_m, @description = item.description
            from dbo.RUSCFG_Document doc
            join dbo.item item on item.RowPointer = doc.LinkedOID
            where doc.RowPointer = @rp2
      else begin  -- Create new ITEM
         if @u_m is null or @u_m = ''
            select @u_m = u_m from dbo.item where item = @item
         if @description is null or @description = ''
            select @description = description from dbo.item where item = @item

         EXEC @Severity = dbo.ItemCreateFromFeatStrSp
            @FeatStr       = null,        /* Using only unfeatured BOM! */
            @Item          = @item,
            @CurrCode      = @CurrCode,
            @ContractPrice = null,        /* dumb parameter! */
            @CoNum         = @co_num,
            @CoLine        = @co_line,
            @IncPrice      = @IncPrice,
            @NewItem       = @item OUTPUT,
            @Infobar       = @Infobar OUTPUT
         if @Severity <> 0 RETURN @Severity

         set @tmp = 'item = ' + dbo.RUSToStr(@item)
         set @x_item = newid()
         EXEC dbo.RUSBufRepos @x_item, 'dbo.', 'item', @tmp
         EXEC dbo.RUSBufCopy @x_cfgdoc, 'item__', @x_item, ''
         EXEC dbo.RUSBufSet @x_item, 'item', @item    /* Restore ITEM to new value */
         EXEC dbo.RUSBufSave @x_item, 1

         select @rp2 = RowPointer from dbo.item where item = @item
         update RUSCFG_Document
            set LinkedTable = 'item', LinkedOID = @rp2
            where RowPointer = @rp

         EXEC @Severity = dbo.RUSUSER_ConstructItemSp @rp, @item
         if @Severity <> 0 RETURN @Severity
      end

      -- Prepare RUSXDE_coitem record
      set @co_line = @co_line + 1
      set @tmp = 'QueSeq = ' + dbo.RUSToStr(@QueSeq)
         + ' and co_num =' + dbo.RUSToStr(@co_num)
         + ' and co_line = ' + dbo.RUSToStr(@co_line)
      EXEC dbo.RUSBufRepos @x_coitem, 'dbo.', 'RUSXDE_coitem', @tmp
      EXEC dbo.RUSBufCopy @x_cfgdoc, 'coitem__', @x_coitem, ''

      EXEC dbo.RUSBufSet @x_coitem, 'item', @item
      EXEC dbo.RUSBufSet @x_coitem, 'u_m', @u_m
      EXEC dbo.RUSBufSet @x_coitem, 'description', @description
      EXEC dbo.RUSBufSet @x_coitem, 'co_line', @co_line
      EXEC dbo.RUSBufSet @x_coitem, 'QueSeq', @QueSeq

      -- Save COITEM record
      EXEC dbo.RUSBufSave @x_coitem, 1

      delete dbo.RUSCFG_Document where RowPointer = @rp and LinkedOID is null
   END
   CLOSE      crs_docum
   DEALLOCATE crs_docum

   EXEC @Severity = dbo.RUSXDE_coitemSP @QueSeq
   RETURN @Severity
END
GO