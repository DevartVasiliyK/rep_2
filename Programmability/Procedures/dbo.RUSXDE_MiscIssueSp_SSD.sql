SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create Procedure [dbo].[RUSXDE_MiscIssueSp_SSD] 
( 
  @RetErr        nvarchar(2800) OUTPUT 
 ,@ProcExecState bit            OUTPUT 
 ,@LogFlag       bit = 0 
 ,@LogFile       varchar(255) = 'C:\RUSXDE_MiscIssueSp_SSD.txt' 
) 
As 
Begin 

-- table vars 
Declare @trans_date     DateType 
Declare @qty            QtyUnitType 
Declare @whse           WhseType 
Declare @item           ItemType 
Declare @u_m            UMType 
Declare @loc            LocType 
Declare @perm_flag      ListYesNoType 
Declare @lot            LotType 
Declare @document_num   RUSDocNumType 
Declare @reason_code    ReasonCodeType 
-- other vars 
Declare @matl_cost      CostPrcType 
Declare @lbr_cost       CostPrcType 
Declare @fovhd_cost     CostPrcType 
Declare @vovhd_cost     CostPrcType 
Declare @out_cost       CostPrcType 
Declare @total_cost     CostPrcType 
Declare @profit_markup  CostPrcType 
Declare @import_doc_id  ImportDocIdType 
Declare @site           SiteType 
Declare @product_code   ProductCodeType 
Declare @serial_tracked ListYesNoType 
Declare @lot_tracked    ListYesNoType 
Declare @Acct           AcctType 
Declare @AcctUnit1      UnitCode1Type 
Declare @AcctUnit2      UnitCode2Type 
Declare @AcctUnit3      UnitCode3Type 
Declare @AcctUnit4      UnitCode4Type 
Declare @AccessUnit1    UnitCodeAccessType 
Declare @AccessUnit2    UnitCodeAccessType 
Declare @AccessUnit3    UnitCodeAccessType 
Declare @AccessUnit4    UnitCodeAccessType 
Declare @Description    DescriptionType 

Declare @Severity       int 
Declare @Infobar        InfobarType 
Declare @ParamToSave    varchar(255) 
Declare @ErrorCode      int 
Declare @RUSDocType     RUSDocNumType 
Declare @original_u_m   UMType 
Declare @UMConvFactor   UMConvFactorType 

Set @Site = (Select site 
             From dbo.parms 
            ) 

Set @RUSDocType = 'InvMiscIss' 

exec dbo.DefineVariableSp 'MessageLanguage' 
                         ,'1049' 
                         ,@Infobar OUTPUT 

If @LogFlag = 1 
     exec dbo.RUS_DiagnosticInTXTSp '', @LogFile, 2 -- delete old log 

-- check section open 
Begin 

     If OBJECT_ID('tempdb..#ErrorCodes') Is Not Null 
          Drop Table #ErrorCodes

     Create Table #ErrorCodes (ErrorCode int, ErrMsg varchar(255))

     Insert Into #ErrorCodes 
     Select -1, 'Не удалось зарегистрировать расход' Union 
     Select  1, 'Код изделия не указан, либо указан неверно' Union 
     Select  2, 'Код склада не указан, либо указан неверно' Union 
     Select  3, 'Код единицы измерения указан неверно' Union 
     Select  4, 'Код причины не указан, либо указан неверно' Union 
     Select  5, 'Код места складирования не указан, либо указан неверно' Union 
     Select  6, 'Единица измерения по изделию отличается от базовой и отсутствует коэффициент перевода' Union 
     Select  7, 'Для партионного изделия не указан код партии' Union 
     Select 15, 'Количество не указано, либо указано нулевое или отрицательное количество по изделию' Union 
     Select 21, 'Указанная партия для данного изделия не существует' Union 
     Select 22, 'Указанный номер документа не существует' Union 
     Select 23, 'Изделие отслеживается по с/н, прочий расход в данной реализации выполнить невозможно' Union 
     Select 24, 'Причина указана, но не входит в допустимый список для прочего расхода' 

     Set @ErrorCode = 0 

     Declare mi_cur Cursor For Select  qty 
                                      ,(CASE When LEN(whse) = 0 Then Null Else whse End) 
                                      ,(CASE When LEN(item) = 0 Then Null Else item End) 
                                      ,(CASE When LEN(u_m) = 0 Then Null Else u_m End) 
                                      ,(CASE When LEN(loc) = 0 Then Null Else loc End) 
                                      ,(CASE When LEN(lot) = 0 Then Null Else lot End) 
                                      ,(CASE When LEN(document_num) = 0 Then Null Else document_num End) 
                                      ,(CASE When LEN(reason_code) = 0 Then Null Else reason_code End) 
                                      From #RUSXDE_MiscIssue 
   
     Open mi_cur 
  
     Fetch Next From mi_cur Into  @qty 
                                 ,@whse 
                                 ,@item 
                                 ,@u_m 
                                 ,@loc 
                                 ,@lot 
                                 ,@document_num 
                                 ,@reason_code 

     While     @@FETCH_STATUS = 0 
           And @ErrorCode     = 0 
     Begin  

          Set @RetErr =   'Изделие: ' + IsNull(@item, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Количество: ' + IsNull(CAST(@qty as varchar(50)), '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Склад: ' + IsNull(@whse, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Место складирования: ' + IsNull(@loc, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Единица измерения: ' + IsNull(@u_m, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Партия: ' + IsNull(@lot, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Код причины: ' + IsNull(@reason_code, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Номер документа-основания: ' + IsNull(@document_num, '') 

          If @ErrorCode = 0 
               If Not Exists (Select * 
                              From dbo.item 
                              Where RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item)) 
                             ) 
                    Set @ErrorCode = 1 
               Else 
                    Select  @original_u_m   = u_m 
                           ,@lot_tracked    = lot_tracked 
                           ,@serial_tracked = serial_tracked 
                           ,@item           = item 
                    From dbo.item 
                    Where RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item)) 

          If @ErrorCode = 0 
               If    @qty Is Null 
                  Or @qty <= 0 
               Set @ErrorCode = 15 
  
          If @ErrorCode = 0 
               If Not Exists (Select * 
                              From dbo.whse 
                              Where RTRIM(LTRIM(whse)) = RTRIM(LTRIM(@whse)) 
                             ) 
                    Set @ErrorCode = 2 
    
          If @ErrorCode = 0 
               If @u_m Is Not Null And LEN(@u_m) > 0 
                    If Not Exists (Select * 
                                   From dbo.u_m 
                                   Where RTRIM(LTRIM(u_m)) = RTRIM(LTRIM(@u_m)) 
                                  ) 
                         Set @ErrorCode = 3 
                    Else 
                         Set @u_m = (Select u_m 
                                     From dbo.u_m 
                                     Where RTRIM(LTRIM(u_m)) = RTRIM(LTRIM(@u_m)) 
                                    ) 

          If @ErrorCode = 0 
               If     @u_m <> @original_u_m 
                  And Not Exists (Select * 
                                  From dbo.u_m_conv 
                                  Where     from_u_m = @u_m 
                                        And to_u_m   = @original_u_m  
                                        Or 
                                            from_u_m = @original_u_m 
                                        And to_u_m = @u_m 
                                 ) 
                    Set @ErrorCode = 6 
    
          If @ErrorCode = 0 
               If Not Exists (Select * 
                              From dbo.location 
                              Where RTRIM(LTRIM(loc)) = RTRIM(LTRIM(@loc)) 
                             ) 
                    Set @ErrorCode = 5 
  
          If @ErrorCode = 0 
               If     @lot_tracked = 1 
                  And    @lot Is Null 
                      Or LEN(@lot) = 0 
                    Set @ErrorCode = 7 

          If @ErrorCode = 0 
               If     @lot_tracked = 1 
                  And Not Exists (Select * 
                                  From dbo.lot 
                                  Where     RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) 
                                        And item = @item 
                                 ) 
                    Set @ErrorCode = 21 

          If @ErrorCode = 0 
               If     @document_num Is Not Null 
                  And LEN(@document_num) > 0 
                  And Not Exists (Select * 
                                  From dbo.RUSmtl_doc 
                                  Where     RTRIM(LTRIM(document_num)) = RTRIM(LTRIM(@document_num)) 
                                        And Type                       = @RUSDocType 
                                 ) 
                    Set @ErrorCode = 22 

          If @ErrorCode = 0 
               If @serial_tracked = 1 
                    Set @ErrorCode = 23 

          If @ErrorCode = 0 
               If     @reason_code Is Not Null And LEN(@reason_code) > 0 
                  And Not Exists (Select * 
                                  From dbo.reason 
                                  Where     RTRIM(LTRIM(reason_code)) = RTRIM(LTRIM(@reason_code)) 
                                        And reason_class              = 'MISC ISSUE' 
                                 ) 
                    Set @ErrorCode = 24 

          If @ErrorCode = 0 
               If    @reason_code Is Null 
                  Or LEN(@reason_code) = 0 
                    Set @ErrorCode = 4 

          Fetch Next From mi_cur Into  @qty 
                                      ,@whse 
                                      ,@item 
                                      ,@u_m 
                                      ,@loc 
                                      ,@lot 
                                      ,@document_num 
                                      ,@reason_code 
  
     End 
     Close mi_cur 
     Deallocate mi_cur 

End 
-- Check section closed 

-- Receipt section open
If @ErrorCode = 0 
Begin 

     -- prepare tables, set values to original & defaults 
     Update mi Set  mi.trans_date   = IsNull(mi.trans_date, GetDate()) 
                   ,mi.whse         = ws.whse 
                   ,mi.item         = itm.item 
                   ,mi.u_m          = (CASE When IsNull(mi.u_m, '') = '' 
                                            Then itm.u_m 
                                            Else u_m.u_m 
                                       End 
                                      ) 
                   ,mi.loc          = loc.loc 
                   ,mi.lot          = (CASE When itm.lot_tracked <> 1 
                                            Then Null 
                                            Else lot.lot 
                                       End 
                                      ) 
                   ,mi.document_num = (CASE When IsNull(mi.document_num, '') = '' 
                                            Then Null 
                                            Else rd.document_num 
                                       End 
                                      ) 
                   ,mi.reason_code  = rn.reason_code 
     From #RUSXDE_MiscIssue   as mi 
     join dbo.whse            as ws  On LTRIM(RTRIM(ws.whse))             = LTRIM(RTRIM(mi.whse)) 
     join dbo.item            as itm On LTRIM(RTRIM(itm.item))            = LTRIM(RTRIM(mi.item)) 
     join dbo.location        as loc On LTRIM(RTRIM(loc.loc))             = LTRIM(RTRIM(mi.loc)) 
     left join dbo.lot        as lot On LTRIM(RTRIM(lot.lot))             = LTRIM(RTRIM(mi.lot)) 
     left join dbo.u_m        as u_m On LTRIM(RTRIM(u_m.u_m))             = LTRIM(RTRIM(mi.u_m)) 
     left join dbo.RUSmtl_doc as rd  On     RTRIM(LTRIM(rd.document_num)) = RTRIM(LTRIM(mi.document_num)) 
                                   And rd.Type                       = @RUSDocType 
     left join dbo.reason   as rn  On RTRIM(LTRIM(rn.reason_code)) = RTRIM(LTRIM(mi.reason_code)) 
     -- end of preparing 

     Declare mi_cur Cursor For Select  mi.trans_date 
                                      ,mi.qty 
                                      ,mi.whse 
                                      ,mi.item 
                                      ,mi.u_m 
                                      ,mi.loc 
                                      ,mi.lot 
                                      ,mi.document_num 
                                      ,mi.reason_code 
                                      ,itm.u_m 
                                      ,itm.product_code 
                                      From #RUSXDE_MiscIssue as mi 
                                      join dbo.item          as itm On itm.item = mi.item 
   
     Open mi_cur 
  
     Fetch Next From mi_cur Into  @trans_date 
                                 ,@qty 
                                 ,@whse 
                                 ,@item 
                                 ,@u_m 
                                 ,@loc 
                                 ,@lot 
                                 ,@document_num 
                                 ,@reason_code 
                                 ,@original_u_m 
                                 ,@product_code 

     While     @@FETCH_STATUS = 0 
           And @ErrorCode     = 0 
     Begin  

          Set @RetErr =   'Изделие: ' + IsNull(@item, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Количество: ' + IsNull(CAST(@qty as varchar(50)), '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Склад: ' + IsNull(@whse, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Место складирования: ' + IsNull(@loc, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Единица измерения: ' + IsNull(@u_m, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Партия: ' + IsNull(@lot, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Код причины: ' + IsNull(@reason_code, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Номер документа-основания: ' + IsNull(@document_num, '') 

          If @u_m <> @original_u_m 
               Set @qty = dbo.UomConvQty(@qty, dbo.Getumcf(@u_m, @item, Null, Null), 'To Base') 

--           Select  @Acct      = rn.inv_adj_acct 
--                  ,@AcctUnit1 = rn.inv_adj_acct_unit1 
--                  ,@AcctUnit2 = (CASE When rn.inv_adj_acct_unit2 Is Not Null 
--                                      Then rn.inv_adj_acct_unit2 
--                                      Else dbo.ValUnit2(rn.inv_adj_acct, pc.unit, @site) 
--                                 End 
--                                ) 
--                  ,@AcctUnit3 = rn.inv_adj_acct_unit3 
--                  ,@AcctUnit4 = rn.inv_adj_acct_unit4 
--           From dbo.reason   as rn 
--           join dbo.prodcode as pc On pc.product_code = @product_code 
--           Where     rn.reason_code  = @reason_code 
--                 And rn.reason_class = 'MISC ISSUE' 

          exec @Severity = dbo.ReasonGetInvAdjAcctSp  @ReasonCode  = @reason_code 
                                                     ,@ReasonClass = 'MISC ISSUE' 
                                                     ,@Item        = @item 
                                                     ,@Acct        = @Acct        OUTPUT 
                                                     ,@AcctUnit1   = @AcctUnit1   OUTPUT 
                                                     ,@AcctUnit2   = @AcctUnit2   OUTPUT 
                                                     ,@AcctUnit3   = @AcctUnit3   OUTPUT 
                                                     ,@AcctUnit4   = @AcctUnit4   OUTPUT 
                                                     ,@AccessUnit1 = @AccessUnit1 OUTPUT 
                                                     ,@AccessUnit2 = @AccessUnit2 OUTPUT 
                                                     ,@AccessUnit3 = @AccessUnit3 OUTPUT 
                                                     ,@AccessUnit4 = @AccessUnit4 OUTPUT 
                                                     ,@Description = @Description OUTPUT 
                                                     ,@Infobar     = @Infobar     OUTPUT 

          exec @Severity = dbo.IaPostSp  @TrxType            = 'I' 
                                        ,@TransDate          = @trans_date 
                                        ,@Acct               = @Acct 
                                        ,@AcctUnit1          = @AcctUnit1 
                                        ,@AcctUnit2          = @AcctUnit2 
                                        ,@AcctUnit3          = @AcctUnit3 
                                        ,@AcctUnit4          = @AcctUnit4 
                                        ,@TransQty           = @qty 
                                        ,@Whse               = @whse 
                                        ,@Item               = @item 
                                        ,@Loc                = @loc 
                                        ,@Lot                = @lot 
                                        ,@FromSite           = @site 
                                        ,@ToSite             = @site 
                                        ,@ReasonCode         = @reason_code 
                                        ,@TrnNum             = Null 
                                        ,@TrnLine            = 0 
                                        ,@TransNum           = 0 
                                        ,@RsvdNum            = 0 
                                        ,@SerialStat         = 'O' 
                                        ,@Workkey            = Null 
                                        ,@Override           = 1 
                                        ,@MatlCost           = @matl_cost     OUTPUT 
                                        ,@LbrCost            = @lbr_cost      OUTPUT 
                                        ,@FovhdCost          = @fovhd_cost    OUTPUT 
                                        ,@VovhdCost          = @vovhd_cost    OUTPUT 
                                        ,@OutCost            = @out_cost      OUTPUT 
                                        ,@TotalCost          = @total_cost    OUTPUT 
                                        ,@ProfitMarkup       = @profit_markup OUTPUT 
                                        ,@Infobar            = @Infobar       OUTPUT 
                                        ,@ToWhse             = Null 
                                        ,@ToLoc              = Null 
                                        ,@ToLot              = Null 
                                        ,@TransferTrxType    = Null 
                                        ,@TmpSerId           = Null 
                                        ,@UseExistingSerials = Null 
                                        ,@SerialPrefix       = Null 
                                        ,@RemoteSiteLot      = Null 
                                        ,@DocumentNum        = @document_num 
                                        ,@ImportDocId        = @import_doc_id 

          If @Severity <> 0 
               Set @ErrorCode = -1 

          Fetch Next From mi_cur Into  @trans_date 
                                      ,@qty 
                                      ,@whse 
                                      ,@item 
                                      ,@u_m 
                                      ,@loc 
                                      ,@lot 
                                      ,@document_num 
                                      ,@reason_code 
                                      ,@original_u_m 
                                      ,@product_code 
  
     End 
     Close mi_cur 
     Deallocate mi_cur 

     If @LogFlag = 1 
          exec dbo.RUS_DiagnosticInTXTSp 'Receipt section closed', @LogFile, 1 

End 
-- Receipt section closed

If @ErrorCode <> 0 
     Set @RetErr = (Select ErrMsg 
                    From #ErrorCodes 
                    Where ErrorCode = @ErrorCode 
                   ) 
                   + (CASE When @ErrorCode < 0 Then ': ' + IsNull(@InfoBar, '') Else '' End) 
                   + CHAR(13) + CHAR(10) 
                   + @RetErr 
                   + (CASE When @Severity <> 0 Then CHAR(13) + CHAR(10) + @Infobar Else '' End) 
Else 
     Set @RetErr = Null 

If @LogFlag = 1 
Begin 
     Set @ParamToSave = '@ErrorCode = ' + CAST(@ErrorCode as varchar(200)) 
     exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1 
     Set @ParamToSave = '@RetErr = ' + IsNull(@RetErr, '') 
     exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1 
End 

Drop Table #ErrorCodes 

exec dbo.UndefineVariableSp 'MessageLanguage' 
                           ,@Infobar OUTPUT 

Set @ProcExecState = 1 -- procedure completed 

End 
GO