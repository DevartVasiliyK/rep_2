SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create procedure [dbo].[RUSCFG_FindSameDocSp]
   @rp uniqueidentifier,            -- RUSCFG_Document RowPointer
   @rp2 uniqueidentifier output     -- RowPointer of equal RUSCFG_Document found
AS BEGIN
   declare @lt sysname, @trp uniqueidentifier, @nid uniqueidentifier
   set @rp2 = null
   set @nid = newid()

   select @lt = LinkedTable from dbo.RUSCFG_Document where RowPointer = @rp

   DECLARE crs_cfgdoc CURSOR LOCAL STATIC FOR
   SELECT
      doc.RowPointer
   FROM dbo.RUSCFG_Document doc
   WHERE doc.RowPointer <> @rp and doc.LinkedTable = @lt and
      exists(select top 1 1 from dbo.RUSCFG_Option opt where opt.CFGDocID = doc.RowPointer)

   OPEN crs_cfgdoc
   WHILE 0 = 0
   BEGIN
      FETCH crs_cfgdoc INTO @trp
      IF @@FETCH_STATUS <> 0 BREAK

      if not exists (select top 1 1
         from dbo.RUSCFG_Document doc1
         join dbo.RUSCFG_Document doc2 on doc2.RowPointer = @trp
      	join dbo.RUSCFG_Option opt1 on opt1.CFGDocID = doc1.RowPointer
         full outer join dbo.RUSCFG_Option opt2 on opt2.CFGDocID = doc2.RowPointer and
      		opt2.Name = opt1.Name and isnull(opt2.Value, @nid) = isnull(opt1.Value, @nid)
         where doc1.RowPointer = @rp and opt1.RowPointer is null or opt2.RowPointer is null)
      begin
         set @rp2 = @trp
         RETURN 0       -- Found matched doc
      end
   END
   CLOSE      crs_cfgdoc
   DEALLOCATE crs_cfgdoc

   RETURN 1    -- Nothing found
END
GO