SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE Procedure [dbo].[RUSXDE_PoImport_Sp]
(
  @RetErr        nvarchar(2800) OUTPUT
 ,@ProcExecState bit            OUTPUT
 ,@LogFlag       bit = 0
 ,@LogFile       varchar(255) = 'C:\RUSXDE_PoImport_Sp_Log.txt'
)
As
Begin

Declare @Result         int
Declare @ErrorCode      int
Declare @Infobar        InfobarType
Declare @RowPointer     RowPointerType
Declare @ParamToSave    varchar(255)

Declare @po_num                       PoNumType 
Declare @stat                         PoStatType 
Declare @order_date                   DateType 
Declare @vend_num                     VendNumType 
Declare @type                         PoTypeType 
Declare @vend_order                   VendOrderType 
Declare @buyer                        NameType 
Declare @ship_code                    ShipCodeType 
Declare @fob                          FOBType 
Declare @whse                         WhseType 
Declare @terms_code                   TermsCodeType 
Declare @vend_lcr_num                 VendLcrNumType 
Declare @contains_only_tax_free_matls ListYesNoType 
Declare @po_line                      PoLineType 
Declare @poi_stat                     PoitemStatType 
Declare @due_date                     DateType 
Declare @promise_date                 DateType 
Declare @item                         ItemType 
Declare @qty_ordered                  QtyUnitNoNegType 
Declare @u_m                          UMType 
Declare @poi_whse                     WhseType 
Declare @unit_mat_cost                CostPrcType 
Declare @unit_freight_cost            CostPrcType 
Declare @unit_duty_cost               CostPrcType 
Declare @unit_brokerage_cost          CostPrcType 
Declare @unit_insurance_cost          CostPrcType 
Declare @unit_loc_frt_cost            CostPrcType 
Declare @tax_code1                    TaxCodeType 

exec dbo.DefineVariableSp 'MessageLanguage'
                         ,'1049'
                         ,@Infobar OUTPUT

Update #po Set  po_num   = dbo.ExpandKyByType('PoNumType', po_num)
               ,vend_num = dbo.ExpandKyByType('VendNumType', vend_num) 

Update #poitem Set po_num = dbo.ExpandKyByType('PoNumType', po_num) 

If OBJECT_ID('tempdb..#ErrorCodes') Is Not Null Drop Table #ErrorCodes

Create Table #ErrorCodes (ErrorCode int, ErrMsg varchar(255))

Insert Into #ErrorCodes 
Select -8, 'В файле содержатся строки ЗП, с po_line = Null, либо <= 0 ' Union 
Select -7, 'В файле содержатся строки ЗП, не имеющие соответствующих ЗП по po_num' Union 
Select -6, 'В файле содержатся ЗП, не имеющие соответствующих строк ЗП по po_num' Union 
Select -5, 'В файле содержатся строки ЗП, совпадающие по po_num и po_line' Union 
Select -4, 'В файле содержится строка ЗП, совпадающая по po_num и po_line с существующей строкой ЗП' Union 
Select -3, 'В файле содержится два или более ЗП с одинаковым номером' Union 
Select -2, 'В файле содержится ЗП с po_num = Null, пустым, либо состоящем из пробелов' Union 
Select -1, 'В файле содержится ЗП, по которому уже был совершен приход или возврат' Union 
Select  0, 'Загрузка прошла успешно' Union
Select  1, 'Статус ЗП не указан, либо указан неверно. Допустимые значения - P, O, C' Union 
Select  2, 'Не указана дата ЗП' Union 
Select  3, 'Код поставщика не указан, либо не входит в справочник поставщиков' Union 
Select  4, 'Тип ЗП не указан, либо указан неверно. Допустимые значения - R, B' Union 
Select  5, 'Указанный покупатель не существует в справочнике' Union 
Select  6, 'Указанный способ поставки не существует в справочнике' Union 
Select  7, 'Код склада не указан, либо указан неверно' Union 
Select  8, 'Указанное условие оплаты не существует в справочнике' Union 
Select  9, 'Указанный договор поставщика не существует в справочнике' Union 
Select 10, 'Признак содержания беспошл.материалов указан неверно. Допустимые значения - 0, 1' Union 
Select 11, 'Статус строки ЗП не указан, либо указан неверно. Допустимые значения - P, O, F, C' Union 
Select 12, 'Не указана план.дата строки ЗП' Union 
Select 13, 'Код изделия строки ЗП не указан, либо не входит в справочник изделий' Union 
Select 14, 'Количество по изделию строки ЗП не указан, либо <= 0' Union 
Select 15, 'Единица измерения строки ЗП не указана, либо не входит в справочник единиц измерений' Union 
Select 16, 'Код склада строки ЗП не указан, либо указан неверно' Union 
Select 17, 'Код налога строки ЗП не указан, либо указан неверно' 

-- Check section open

If @LogFlag = 1 
     exec dbo.RUS_DiagnosticInTXTSp '', @LogFile, 2 -- delete old log

Set @ErrorCode = 0

If Exists (Select * 
           From #po 
           Where Exists (Select * 
                         From dbo.matltran 
                         Where     ref_type = 'P' 
                               And RTRIM(LTRIM(ref_num)) = RTRIM(LTRIM(po_num)) 
                        ) 
          )
Set @ErrorCode = -1 

If @ErrorCode = 0 
     If Exists (Select * 
                From #po 
                Where    po_num Is Null 
                      Or LEN(po_num) = 0 
               ) 
     Set @ErrorCode = -2 

If @ErrorCode = 0 
     If Exists (Select po_num 
                From #po 
                Where     po_num Is Not Null 
                      And LEN(po_num) > 0 
                Group By po_num 
                Having Count(*) > 1 
               ) 
     Set @ErrorCode = -3 

If @ErrorCode = 0 
     If Exists (Select po_num 
                From #po 
                Where     po_num Is Not Null 
                      And LEN(po_num) > 0 
                Group By po_num 
                Having Count(*) > 1 
               ) 
     Set @ErrorCode = -3 

-- If @ErrorCode = 0 
--      If Exists (Select * 
--                 From #po 
--                 join #poitem On #po.po_num = #poitem.po_num 
--                 join dbo.poitem as poi On poi.po_num = #poitem.po_num And poi.po_line = #poitem.po_line 
--                )
--      Set @ErrorCode = -4 

If @ErrorCode = 0 
     If Exists (Select po_num, po_line 
                From #poitem 
                Where     po_num Is Not Null 
                      And LEN(po_num) > 0 
                      And po_line Is Not Null 
                      And po_line > 0 
                Group By po_num, po_line 
                Having Count(*) > 1 
               )
     Set @ErrorCode = -5 

If @ErrorCode = 0 
     If Exists (Select * 
                From #po 
                Where Not Exists (Select * 
                                  From #poitem 
                                  Where #poitem.po_num = #po.po_num 
                                 ) 
               )
     Set @ErrorCode = -6 

If @ErrorCode = 0 
     If Exists (Select * 
                From #poitem 
                Where Not Exists (Select * 
                                  From #po 
                                  Where #po.po_num = #poitem.po_num 
                                 ) 
               )
     Set @ErrorCode = -7 

If @ErrorCode = 0 
     If Exists (Select * 
                From #poitem 
                Where Exists (Select * 
                              From #po 
                              Where #po.po_num = #poitem.po_num 
                             ) 
                      And (po_line Is Null Or po_line <= 0) 
               )
     Set @ErrorCode = -8 

If @ErrorCode = 0 
Begin 

     Declare po_cur Cursor For Select  po_num 
                                      ,stat 
                                      ,order_date 
                                      ,vend_num 
                                      ,type 
                                      ,(CASE When LEN(buyer) = 0 Then Null Else buyer End) 
                                      ,(CASE When LEN(ship_code) = 0 Then Null Else ship_code End) 
                                      ,whse 
                                      ,terms_code 
                                      ,(CASE When LEN(vend_lcr_num) = 0 Then Null Else vend_lcr_num End) 
                                      ,contains_only_tax_free_matls 
                               From #po 

     Open po_cur

     Fetch Next From po_cur Into  @po_num 
                                 ,@stat 
                                 ,@order_date 
                                 ,@vend_num 
                                 ,@type 
                                 ,@buyer 
                                 ,@ship_code 
                                 ,@whse 
                                 ,@terms_code 
                                 ,@vend_lcr_num 
                                 ,@contains_only_tax_free_matls 

     While @@FETCH_STATUS = 0 And @ErrorCode = 0
     Begin
          If @ErrorCode = 0 
               If Not (@stat In ('P', 'O', 'C')) 
               Set @ErrorCode = 1 

          If @ErrorCode = 0 
               If @order_date Is Null 
               Set @ErrorCode = 2 

          If @ErrorCode = 0 
               If Not Exists (Select * From 
                              dbo.vendor 
                              Where vend_num = @vend_num 
                             ) 
               Set @ErrorCode = 3 

          If @ErrorCode = 0 
               If Not (@type In ('R', 'B')) 
               Set @ErrorCode = 4 

          If @ErrorCode = 0 
               If     @buyer Is Not Null 
                  And Not Exists (Select * 
                                  From dbo.user_local as ul 
                                  join dbo.UserNames  as un On un.UserId = ul.UserId 
                                  Where LTRIM(RTRIM(un.Username)) = LTRIM(RTRIM(@buyer)) 
                                 ) 
               Set @ErrorCode = 5 

          If @ErrorCode = 0 
               If     @ship_code Is Not Null 
                  And Not Exists (Select * 
                                  From dbo.shipcode 
                                  Where LTRIM(RTRIM(ship_code)) = LTRIM(RTRIM(@ship_code)) 
                                 ) 
               Set @ErrorCode = 6 

          If @ErrorCode = 0 
               If Not Exists (Select * From 
                              dbo.whse 
                              Where RTRIM(LTRIM(whse)) = RTRIM(LTRIM(@whse)) 
                             ) 
               Set @ErrorCode = 7 

          If @ErrorCode = 0 
               If Not Exists (Select * From 
                              dbo.terms 
                              Where RTRIM(LTRIM(terms_code)) = RTRIM(LTRIM(@terms_code)) 
                             ) 
               Set @ErrorCode = 8 

          If @ErrorCode = 0 
               If     @vend_lcr_num Is Not Null 
                  And Not Exists (Select * 
                                  From dbo.vend_lcr 
                                  Where     LTRIM(RTRIM(vend_lcr_num)) = LTRIM(RTRIM(@vend_lcr_num)) 
                                        And vend_num = @vend_num 
                                 ) 
               Set @ErrorCode = 9 

          If @ErrorCode = 0 
               If     @contains_only_tax_free_matls Is Not Null 
                  And Not (@contains_only_tax_free_matls In (0, 1)) 
               Set @ErrorCode = 10 

          Declare poitem_cur Cursor For Select  stat 
                                               ,due_date 
                                               ,item 
                                               ,qty_ordered 
                                               ,u_m 
                                               ,whse 
                                               ,tax_code1 
                                        From #poitem 
                                        Where po_num = @po_num 

          Open poitem_cur

          Fetch Next From poitem_cur Into  @poi_stat 
                                          ,@due_date 
                                          ,@item 
                                          ,@qty_ordered 
                                          ,@u_m 
                                          ,@poi_whse 
                                          ,@tax_code1
          While @@FETCH_STATUS = 0 And @ErrorCode = 0

          Begin

               If @ErrorCode = 0 
                    If Not (@poi_stat In ('P', 'O', 'F', 'C')) 
                    Set @ErrorCode = 11 

               If @ErrorCode = 0 
                    If @due_date Is Null 
                    Set @ErrorCode = 12 

               If @ErrorCode = 0 
                    If Not Exists (Select * From 
                                   dbo.item  
                                   Where RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item)) 
                                  ) 
                    Set @ErrorCode = 13 

               If @ErrorCode = 0 
                    If    @qty_ordered Is Null 
                       Or @qty_ordered <= 0 
                    Set @ErrorCode = 14 

               If @ErrorCode = 0 
                    If Not Exists (Select * From 
                                   dbo.u_m 
                                   Where RTRIM(LTRIM(u_m)) = RTRIM(LTRIM(@u_m)) 
                                  ) 
                    Set @ErrorCode = 15 

               If @ErrorCode = 0 
                    If Not Exists (Select * From 
                                   dbo.whse 
                                   Where RTRIM(LTRIM(whse)) = RTRIM(LTRIM(@poi_whse)) 
                                  ) 
                    Set @ErrorCode = 16 

               If @ErrorCode = 0 
                    If Not Exists (Select * From 
                                   dbo.taxcode 
                                   Where RTRIM(LTRIM(tax_code)) = RTRIM(LTRIM(@tax_code1)) 
                                  ) 
                    Set @ErrorCode = 17 
               
               Fetch Next From poitem_cur Into  @poi_stat 
                                               ,@due_date 
                                               ,@item 
                                               ,@qty_ordered 
                                               ,@u_m 
                                               ,@poi_whse 
                                               ,@tax_code1
          End
          Close poitem_cur
          Deallocate poitem_cur

          Fetch Next From po_cur Into  @po_num 
                                      ,@stat 
                                      ,@order_date 
                                      ,@vend_num 
                                      ,@type 
                                      ,@buyer 
                                      ,@ship_code 
                                      ,@whse 
                                      ,@terms_code 
                                      ,@vend_lcr_num 
                                      ,@contains_only_tax_free_matls 
     End
     Close po_cur
     Deallocate po_cur
End 

-- Check section closed

-- Receipt section open
If @ErrorCode = 0
Begin

     If @LogFlag = 1 exec dbo.RUS_DiagnosticInTXTSp @ParamToSave = 'Receipt section open', @LogFile = @LogFile, @AppendFlag = 0

     Declare po_cur Cursor For Select  po_num 
                                      ,stat 
                                      ,order_date 
                                      ,vend_num 
                                      ,type 
                                      ,(Select un.Username 
                                        From dbo.user_local as ul 
                                        join dbo.UserNames  as un On un.UserId = ul.UserId 
                                        Where LTRIM(RTRIM(un.Username)) = LTRIM(RTRIM(#po.buyer))
                                       ) 
                                      ,(Select ship_code 
                                        From dbo.shipcode 
                                        Where LTRIM(RTRIM(ship_code)) = LTRIM(RTRIM(#po.ship_code)) 
                                       )
                                      ,fob 
                                      ,(Select whse 
                                        From dbo.whse 
                                        Where RTRIM(LTRIM(whse)) = RTRIM(LTRIM(#po.whse)) 
                                       ) 
                                      ,(Select terms_code 
                                        From dbo.terms 
                                        Where RTRIM(LTRIM(terms_code)) = RTRIM(LTRIM(#po.terms_code)) 
                                       ) 
                                      ,(Select vend_lcr_num 
                                        From dbo.vend_lcr 
                                        Where     LTRIM(RTRIM(vend_lcr_num)) = LTRIM(RTRIM(#po.vend_lcr_num)) 
                                              And vend_num = @vend_num 
                                       ) 
                                      ,contains_only_tax_free_matls 
                               From #po 
                               Order By po_num 

     Open po_cur

     Fetch Next From po_cur Into  @po_num 
                                 ,@stat 
                                 ,@order_date 
                                 ,@vend_num 
                                 ,@type 
                                 ,@buyer 
                                 ,@ship_code 
                                 ,@fob 
                                 ,@whse 
                                 ,@terms_code 
                                 ,@vend_lcr_num 
                                 ,@contains_only_tax_free_matls 

     While @@FETCH_STATUS = 0 And @ErrorCode = 0 
     Begin

Set @ParamToSave = @po_num
     If @LogFlag = 1
          exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1

          If Exists (Select * 
                         From dbo.po 
                         Where po_num = @po_num
                        ) 
Begin
Set @ParamToSave = 'Exists'
     If @LogFlag = 1
          exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1

End 

          If Not Exists (Select * 
                         From dbo.po 
                         Where po_num = @po_num 
                        ) 
          Insert Into dbo.po 
          (
            po_num 
           ,stat 
           ,order_date 
           ,vend_num 
           ,type 
           ,buyer 
           ,ship_code 
           ,fob 
           ,whse 
           ,terms_code 
           ,vend_lcr_num 
           ,contains_only_tax_free_matls 
          ) 
          Select 
            @po_num 
           ,@stat 
           ,@order_date 
           ,@vend_num 
           ,@type 
           ,@buyer 
           ,@ship_code 
           ,@fob 
           ,@whse 
           ,@terms_code 
           ,@vend_lcr_num 
           ,@contains_only_tax_free_matls 
          Else
          Update dbo.po 
          Set 
              stat = @stat 
             ,order_date = @order_date
             ,vend_num = @vend_num 
             ,type = @type 
             ,buyer = @buyer 
             ,ship_code = @ship_code 
             ,fob = @fob 
             ,whse = @whse 
             ,terms_code = @terms_code 
             ,vend_lcr_num = @vend_lcr_num
             ,contains_only_tax_free_matls = @contains_only_tax_free_matls 
          Where po_num = @po_num 

          Declare poitem_cur Cursor For Select  po_line 
                                               ,stat 
                                               ,due_date 
                                               ,promise_date 
                                               ,(Select item 
                                                 From dbo.item 
                                                 Where RTRIM(LTRIM(item)) = RTRIM(LTRIM(#poitem.item)) 
                                                ) 
                                               ,qty_ordered 
                                               ,(Select u_m 
                                                 From dbo.u_m 
                                                 Where RTRIM(LTRIM(u_m)) = RTRIM(LTRIM(#poitem.u_m)) 
                                                ) 
                                               ,(Select whse 
                                                 From dbo.whse 
                                                 Where RTRIM(LTRIM(whse)) = RTRIM(LTRIM(#poitem.whse)) 
                                                ) 
                                               ,unit_mat_cost 
                                               ,unit_freight_cost 
                                               ,unit_duty_cost 
                                               ,unit_brokerage_cost 
                                               ,unit_insurance_cost 
                                               ,unit_loc_frt_cost 
                                               ,(Select tax_code 
                                                 From dbo.taxcode 
                                                 Where RTRIM(LTRIM(tax_code)) = RTRIM(LTRIM(#poitem.tax_code1)) 
                                                ) 
                                        From #poitem 
                                        Where po_num = @po_num 
                                        Order By po_line 

          Open poitem_cur

          Fetch Next From poitem_cur Into  @po_line 
                                          ,@poi_stat 
                                          ,@due_date 
                                          ,@promise_date 
                                          ,@item 
                                          ,@qty_ordered 
                                          ,@u_m 
                                          ,@poi_whse 
                                          ,@unit_mat_cost 
                                          ,@unit_freight_cost 
                                          ,@unit_duty_cost 
                                          ,@unit_brokerage_cost 
                                          ,@unit_insurance_cost 
                                          ,@unit_loc_frt_cost 
                                          ,@tax_code1 

          While @@FETCH_STATUS = 0 And @ErrorCode = 0

          Begin

               If Not Exists (Select * 
                              From dbo.poitem 
                              Where     po_num  = @po_num 
                                    And po_line = @po_line 
                             ) 
               Insert Into dbo.poitem 
               ( 
                po_num 
               ,po_line 
               ,stat 
               ,due_date 
               ,promise_date 
               ,item 
               ,qty_ordered 
               ,qty_ordered_conv 
               ,u_m 
               ,whse 
               ,unit_mat_cost 
               ,unit_freight_cost 
               ,unit_duty_cost 
               ,unit_brokerage_cost 
               ,unit_insurance_cost 
               ,unit_loc_frt_cost 
               ,tax_code1 
               ,unit_mat_cost_conv 
               ,unit_freight_cost_conv 
               ,unit_duty_cost_conv 
               ,unit_brokerage_cost_conv 
               ,unit_insurance_cost_conv 
               ,unit_loc_frt_cost_conv 
               ,item_cost 
               ,item_cost_conv 
               ) 
               Select 
                @po_num 
               ,@po_line 
               ,@poi_stat 
               ,@due_date 
               ,@promise_date 
               ,@item 
               ,@qty_ordered 
               ,@qty_ordered 
               ,@u_m 
               ,@poi_whse 
               ,@unit_mat_cost 
               ,@unit_freight_cost 
               ,@unit_duty_cost 
               ,@unit_brokerage_cost 
               ,@unit_insurance_cost 
               ,@unit_loc_frt_cost 
               ,@tax_code1 
               ,@unit_mat_cost 
               ,@unit_freight_cost 
               ,@unit_duty_cost 
               ,@unit_brokerage_cost 
               ,@unit_insurance_cost 
               ,@unit_loc_frt_cost 
               ,IsNull(@unit_mat_cost, 0) + IsNull(@unit_freight_cost, 0) + IsNull(@unit_duty_cost, 0) + IsNull(@unit_brokerage_cost, 0) + IsNull(@unit_insurance_cost, 0) + IsNull(@unit_loc_frt_cost, 0) 
               ,IsNull(@unit_mat_cost, 0) + IsNull(@unit_freight_cost, 0) + IsNull(@unit_duty_cost, 0) + IsNull(@unit_brokerage_cost, 0) + IsNull(@unit_insurance_cost, 0) + IsNull(@unit_loc_frt_cost, 0) 
               Else 
               Update dbo.poitem 
               Set 
                   stat = @poi_stat 
                  ,due_date = @due_date 
                  ,promise_date = @promise_date 
                  ,item = @item 
                  ,qty_ordered = @qty_ordered 
                  ,qty_ordered_conv = @qty_ordered 
                  ,u_m = @u_m 
                  ,whse = @poi_whse 
                  ,unit_mat_cost = @unit_mat_cost 
                  ,unit_freight_cost = unit_freight_cost 
                  ,unit_duty_cost = @unit_duty_cost 
                  ,unit_brokerage_cost = @unit_brokerage_cost 
                  ,unit_insurance_cost = @unit_insurance_cost 
                  ,unit_loc_frt_cost = @unit_loc_frt_cost 
                  ,tax_code1 = @tax_code1 
                  ,unit_mat_cost_conv = @unit_mat_cost 
                  ,unit_freight_cost_conv = unit_freight_cost 
                  ,unit_duty_cost_conv = @unit_duty_cost 
                  ,unit_brokerage_cost_conv = @unit_brokerage_cost 
                  ,unit_insurance_cost_conv = @unit_insurance_cost 
                  ,unit_loc_frt_cost_conv = @unit_loc_frt_cost 
                  ,item_cost = IsNull(@unit_mat_cost, 0) + IsNull(@unit_freight_cost, 0) + IsNull(@unit_duty_cost, 0) + IsNull(@unit_brokerage_cost, 0) + IsNull(@unit_insurance_cost, 0) + IsNull(@unit_loc_frt_cost, 0) 
                  ,item_cost_conv = IsNull(@unit_mat_cost, 0) + IsNull(@unit_freight_cost, 0) + IsNull(@unit_duty_cost, 0) + IsNull(@unit_brokerage_cost, 0) + IsNull(@unit_insurance_cost, 0) + IsNull(@unit_loc_frt_cost, 0) 
               Where     po_num  = @po_num 
                     And po_line = @po_line 
               
               Fetch Next From poitem_cur Into  @po_line 
                                               ,@poi_stat 
                                               ,@due_date 
                                               ,@promise_date 
                                               ,@item 
                                               ,@qty_ordered 
                                               ,@u_m 
                                               ,@poi_whse 
                                               ,@unit_mat_cost 
                                               ,@unit_freight_cost 
                                               ,@unit_duty_cost 
                                               ,@unit_brokerage_cost 
                                               ,@unit_insurance_cost 
                                               ,@unit_loc_frt_cost 
                                               ,@tax_code1 
          End
          Close poitem_cur
          Deallocate poitem_cur

          Fetch Next From po_cur Into  @po_num 
                                      ,@stat 
                                      ,@order_date 
                                      ,@vend_num 
                                      ,@type 
                                      ,@buyer 
                                      ,@ship_code 
                                      ,@fob 
                                      ,@whse 
                                      ,@terms_code 
                                      ,@vend_lcr_num 
                                      ,@contains_only_tax_free_matls 
     End
     Close po_cur
     Deallocate po_cur

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