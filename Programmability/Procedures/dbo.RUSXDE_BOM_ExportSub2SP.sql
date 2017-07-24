SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RUSXDE_BOM_ExportSub2SP]
AS BEGIN
   declare @flt nvarchar(4000), @t_out uniqueidentifier
   declare @tItem nvarchar(4000), @tOperNum nvarchar(4000), @tSeq nvarchar(4000),
      @tMatl nvarchar(4000), @tRGID nvarchar(4000)

   set @t_out = newid()

   declare @rpItem uniqueidentifier, @rpJbr uniqueidentifier, @rpJbrSch uniqueidentifier,
      @rpJmtl uniqueidentifier, @rpRes uniqueidentifier
   declare @oldItem uniqueidentifier, @oldJbr uniqueidentifier, @oldJbrSch uniqueidentifier,
      @oldJmtl uniqueidentifier, @oldRes uniqueidentifier

   declare @nid uniqueidentifier set @nid = newid()
   declare @cnt int, @isnewoper bit

   set @isnewoper = 0

   DECLARE crs_bom CURSOR LOCAL STATIC FOR
   SELECT
      i.RowPointer, jbr.RowPointer, jbrsch.RowPointer, jmtl.RowPointer, res.RowPointer,
      i.item, jbr.oper_num, jmtl.sequence, jmtl.item, res.rgid
   FROM dbo.item i
   join #XDEBOMExport_item xi on xi.item = i.item
   left outer join dbo.jobroute jbr on
      jbr.job    = i.job and
      jbr.suffix = i.suffix
   left outer join dbo.jrt_sch jbrsch on
      jbrsch.job      = jbr.job and
      jbrsch.suffix   = jbr.suffix and
      jbrsch.oper_num = jbr.oper_num
   left outer join dbo.jobmatl jmtl on
      jmtl.job      = jbr.job and
      jmtl.suffix   = jbr.suffix and
      jmtl.oper_num = jbr.oper_num
   left outer join dbo.jrtresourcegroup res on
      res.job      = jbr.job and
      res.suffix   = jbr.suffix and
      res.oper_num = jbr.oper_num
   WHERE not exists(select 1 from #XDEBOMExport_jbr xjbr where xjbr.root_item = xi.item)

   OPEN crs_bom
   WHILE 0 = 0
   BEGIN
      FETCH crs_bom INTO
         @rpItem, @rpJbr, @rpJbrSch, @rpJmtl, @rpRes,
         @tItem, @tOperNum, @tSeq, @tMatl, @tRGID
      IF @@FETCH_STATUS <> 0 BREAK

      -- Add OPERATION
      if isnull(@oldJbr, @nid) <> @rpJbr and not @rpJbr is null begin
         set @isnewoper = 1
         set @flt = 'RowPointer = ' + dbo.RUSToStr(@rpJbr)
         EXEC @cnt = dbo.RUSBufRepos @rpJbr, 'dbo.', 'jobroute', @flt, 1

         if @cnt = 1 begin
            set @flt = 'RowPointer = ' + dbo.RUSToStr(@rpJbrSch)
            EXEC dbo.RUSBufRepos @rpJbrSch, 'dbo.', 'jrt_sch', @flt, 1

            set @flt = 'root_item = ' + dbo.RUSToStr(@tItem) + ' and oper_num = ' + dbo.RUSToStr(@tOperNum)
            EXEC dbo.RUSBufRepos @t_out, '.', '#XDEBOMExport_jbr', @flt, 0

            EXEC dbo.RUSBufCopy @rpJbr, '', @t_out, ''
            EXEC dbo.RUSBufCopy @rpJbrSch, '', @t_out, ''
            EXEC dbo.RUSBufSet @t_out, 'root_item', @tItem
            EXEC dbo.RUSBufSave @t_out, 1
         end

         set @oldJbr = @rpJbr
      end

      -- Add MATERIAL
      if (@isnewoper = 1 or isnull(@oldJmtl, @nid) <> @rpJmtl) and not @rpJmtl is null begin
         set @flt = 'RowPointer = ' + dbo.RUSToStr(@rpJmtl)
         EXEC @cnt = dbo.RUSBufRepos @rpJmtl, 'dbo.', 'jobmatl', @flt, 1

         if @cnt = 1 begin
            set @flt = 'root_item = ' + dbo.RUSToStr(@tItem)
               + ' and oper_num = ' + dbo.RUSToStr(@tOperNum)
               + ' and sequence =' + dbo.RUSToStr(@tSeq)
            EXEC dbo.RUSBufRepos @t_out, '.', '#XDEBOMExport_jmtl', @flt, 0

            EXEC dbo.RUSBufCopy @rpJmtl, '', @t_out, ''
            EXEC dbo.RUSBufSet @t_out, 'root_item', @tItem
            EXEC dbo.RUSBufSave @t_out, 1

            -- Add next level ITEM
            EXEC dbo.RUSXDE_BOM_ExportSub1SP @tMatl
         end

         set @oldJmtl = @rpJmtl
      end

      -- Add RESOURCEGROUP
      if (@isnewoper = 1 or isnull(@oldRes, @nid) <> @rpRes) and not @rpRes is null begin
         set @flt = 'RowPointer = ' + dbo.RUSToStr(@rpRes)
         EXEC @cnt = dbo.RUSBufRepos @rpRes, 'dbo.', 'jrtresourcegroup', @flt, 1

         if @cnt = 1 begin
            set @flt = 'root_item = ' + dbo.RUSToStr(@tItem)
               + ' and oper_num = ' + dbo.RUSToStr(@tOperNum)
               + ' and rgid = ' + dbo.RUSToStr(@tRGID)
            EXEC dbo.RUSBufRepos @t_out, '.', '#XDEBOMExport_res', @flt, 0

            EXEC dbo.RUSBufCopy @rpRes, '', @t_out, ''
            EXEC dbo.RUSBufSet @t_out, 'root_item', @tItem
            EXEC dbo.RUSBufSave @t_out, 1
         end

         set @oldRes = @rpRes
      end

      set @isnewoper = 0
   END
   CLOSE      crs_bom
   DEALLOCATE crs_bom
END
GO