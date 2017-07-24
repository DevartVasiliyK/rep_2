SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




create procedure [dbo].[RUSXDE_coitemSP]
   @QueSeq int = null
AS BEGIN
   if object_id('tempdb..#RUSBuf') is null
      create table #RUSBuf (bid uniqueidentifier, typ sysname, nam sysname, val nvarchar(4000), flg bit)

   declare @x_coitem uniqueidentifier set @x_coitem = newid()
   declare @x_import uniqueidentifier set @x_import = newid()

	declare @co_num     CoNumType
	declare @co_line    CoLineType
	declare @co_release CoReleaseType
	declare @RowPointer uniqueidentifier
	declare @tmp        varchar(8000)
	declare @Severity   int

	set @Severity = 0

   declare
        @Item           ItemType
      , @CustNum        CustNumType
      , @QtyOrderedConv QtyUnitType
      , @ItemPriceCode  PriceCodeType
      , @CurrCode       CurrCodeType
      , @ShipSite       SiteType
      , @ItemItem       ItemType
      , @ItemUM         UMType
      , @ItemDesc       DescriptionType
      , @CustItem       CustItemType
      , @Price          AmountType
      , @FeatStr        FeatStrType
      , @ItemPlanFlag   Flag
      , @ItemFeatTempl  FeatTemplateType
      , @ItemCommCode   CommodityCodeType
      , @ItemUnitWeight ItemWeightType
      , @ItemOrigin     EcCodeType
      , @DueDate        DateType
      , @RefType        RefTypeIJOType
      , @RefNum         CoNumJobType
      , @RefLineSuf     CoLineSuffixType
      , @RefRelease     CoReleaseOperNumType
      , @TaxCode1       TaxCodeType
      , @TaxCode1Desc   DescriptionType
      , @TaxCode2       TaxCodeType
      , @TaxCode2Desc   DescriptionType
      , @DiscPct        LineDiscType
      , @Infobar        Infobar
      , @RUSGROUPID     ApsOrdgrpType
      , @OrderDate      GenericDateType
      , @PriceConv      AmountType
      , @Whse           WhseType
      , @QtyReady       QtyUnitNoNegType


   delete coitem
   from dbo.coitem coitem
   join dbo.RUSXDE_coitem xci on xci.co_num = coitem.co_num
   where (@QueSeq is null or xci.QueSeq = @QueSeq)
   if @@error <> 0 RETURN 1

   DECLARE crs_coitem_im CURSOR LOCAL FOR
   SELECT
      xci.RowPointer, xci.co_num, xci.co_line, xci.co_release
      , xci.item, co.cust_num, xci.qty_ordered, xci.pricecode
      , ca.curr_code, co.order_date, co.whse
   FROM dbo.RUSXDE_coitem xci
   join dbo.co co on co.co_num = xci.co_num
   join dbo.custaddr ca on ca.cust_num = co.cust_num and ca.cust_seq = 0
   WHERE (@QueSeq is null or xci.QueSeq = @QueSeq) and
      not xci.co_num is null and
      not xci.co_line is null and
      not xci.co_release is null

   OPEN crs_coitem_im
   WHILE 0 = 0
   BEGIN
      FETCH crs_coitem_im INTO @RowPointer, @co_num, @co_line, @co_release
         , @Item, @CustNum, @QtyOrderedConv, @ItemPriceCode
         , @CurrCode, @OrderDate, @Whse
      IF @@FETCH_STATUS <> 0 BREAK

      set @tmp = 'co_num = '    + dbo.RUSToStr(@co_num)
         + ' and co_line = '    + dbo.RUSToStr(@co_line)
         + ' and co_release = ' + dbo.RUSToStr(@co_release)
      EXEC dbo.RUSBufRepos @x_coitem, 'dbo.', 'coitem', @tmp

      set @tmp = 'RowPointer = ' + dbo.RUSToStr(@RowPointer)
      EXEC dbo.RUSBufRepos @x_import, 'dbo.', 'RUSXDE_coitem', @tmp, 1

      EXEC dbo.RUSBufCopy @x_import, '', @x_coitem, ''
      EXEC dbo.RUSBufSet @x_coitem, 'qty_ordered_conv', @QtyOrderedConv
      EXEC dbo.RUSBufSet @x_coitem, 'stat', 'P'
      EXEC dbo.RUSBufSet @x_coitem, 'co_cust_num', @CustNum
      EXEC dbo.RUSBufSet @x_coitem, 'whse', @Whse
      -- EXEC dbo.RUSBufSave @x_coitem, 0

      -- Apply COITEM standard rules
      EXEC @Severity = dbo.CoitemValidateItemSp
           1   /* @NewRecord */
         , @Co_Num
         , @Item
         , NULL   /* @OldItem */
         , @CustNum
         , @QtyOrderedConv
         , @ItemPriceCode
         , @CurrCode
         , @ShipSite       OUTPUT
         , @ItemItem       OUTPUT
         , @ItemUM         OUTPUT
         , @ItemDesc       OUTPUT
         , @CustItem       OUTPUT
         , @Price          OUTPUT
         , @FeatStr        OUTPUT
         , @ItemPlanFlag   OUTPUT
         , @ItemFeatTempl  OUTPUT
         , @ItemCommCode   OUTPUT
         , @ItemUnitWeight OUTPUT
         , @ItemOrigin     OUTPUT
         , @DueDate        OUTPUT
         , @RefType        OUTPUT
         , @RefNum         OUTPUT
         , @RefLineSuf     OUTPUT
         , @RefRelease     OUTPUT
         , @TaxCode1       OUTPUT
         , @TaxCode1Desc   OUTPUT
         , @TaxCode2       OUTPUT
         , @TaxCode2Desc   OUTPUT
         , @DiscPct        OUTPUT
         , @Infobar        OUTPUT
         , @Co_Line
         , @RUSGROUPID     OUTPUT
      if @Severity <> 0 BREAK

      -- EXEC dbo.RUSBufSet @x_coitem, 'due_date', @DueDate

      EXEC dbo.RUSBufSet @x_coitem, 'ship_site', @ShipSite
      EXEC dbo.RUSBufSet @x_coitem, 'u_m', @ItemUM
      EXEC dbo.RUSBufSet @x_coitem, 'description', @ItemDesc
      EXEC dbo.RUSBufSet @x_coitem, 'cust_item', @CustItem
      EXEC dbo.RUSBufSet @x_coitem, 'feat_str', @FeatStr
      EXEC dbo.RUSBufSet @x_coitem, 'comm_code', @ItemCommCode
      EXEC dbo.RUSBufSet @x_coitem, 'unit_weight', @ItemUnitWeight
      EXEC dbo.RUSBufSet @x_coitem, 'origin', @ItemOrigin
      EXEC dbo.RUSBufSet @x_coitem, 'ref_type', @RefType
      EXEC dbo.RUSBufSet @x_coitem, 'ref_num', @RefNum
      EXEC dbo.RUSBufSet @x_coitem, 'ref_line_suf', @RefLineSuf
      EXEC dbo.RUSBufSet @x_coitem, 'ref_release', @RefRelease
      EXEC dbo.RUSBufSet @x_coitem, 'tax_code1', @TaxCode1
      EXEC dbo.RUSBufSet @x_coitem, 'tax_code2', @TaxCode2
      EXEC dbo.RUSBufSet @x_coitem, 'disc', @DiscPct
      EXEC dbo.RUSBufSet @x_coitem, 'RUSGROUPID', @RUSGROUPID

      if @Price is null set @Price = 0
      EXEC dbo.RUSBufSet @x_coitem, 'Price', @Price
      -- EXEC dbo.RUSBufSave @x_coitem, 0

      EXEC @Severity = dbo.CalculateCoitemPriceSp
           @Co_Num
         , @CustNum
         , @Item
         , @ItemUM
         , @CustItem
         , @ShipSite
         , @OrderDate
         , @QtyOrderedConv
         , @CurrCode
         , @ItemPriceCode
         , @PriceConv OUTPUT
         , @Infobar OUTPUT
         , @Co_Line
      if @Severity <> 0 BREAK

      EXEC dbo.RUSBufSet @x_coitem, 'price_conv', @PriceConv
      -- EXEC dbo.RUSBufSave @x_coitem, 0

      EXEC @Severity = dbo.CoitemValidateQtyOrderedSp
           1
         , @Co_Num
         , @Co_Line
         , @Item
         , @ItemUM
         , @CustNum
         , @CurrCode
         , @ItemPriceCode
         , @QtyOrderedConv
         , @CustItem
         , @ShipSite
         , @OrderDate
         , @Whse
         , @RefType
         , @Price
         , @QtyReady OUTPUT
         , @Infobar OUTPUT
      if @Severity <> 0 BREAK

      EXEC dbo.RUSBufSet @x_coitem, 'qty_ready', @QtyReady
      EXEC dbo.RUSBufSave @x_coitem

      -- Clear input buffer
      delete from dbo.RUSXDE_coitem where current of crs_coitem_im
   END
   CLOSE      crs_coitem_im
   DEALLOCATE crs_coitem_im

   RETURN @Severity
END

GO