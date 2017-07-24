SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Declare @RetErr nvarchar(2800)
-- Declare @ProcExecState bit
-- exec RUSXDE_MiscReceipt_Proc @RetErr  OUTPUT, @ProcExecState OUTPUT
-- Declare @cmd varchar(128) Set @cmd = 'exec master.dbo.xp_cmdshell ' + '''' + 'Echo ' + CAST(@ErrorCode as varchar(2)) + ' >> C:\Temp\Inbound2\1.txt' + '''' + ', NO_OUTPUT' exec (@cmd)
--exec dbo.RUS_DiagnosticInTXTSp '•', 'C:\log.txt', 1

CREATE Procedure [dbo].[RUSXDE_MiscReceipt_Proc]
(
  @RetErr        nvarchar(2800) OUTPUT
 ,@ProcExecState bit            OUTPUT
 ,@LogFlag       bit = 0
 ,@LogFile       varchar(255) = 'C:\RUSXDE_MiscReceipt_Proc_Log.txt'
)
As
Begin

--set dateformat dmy

Declare @whse         WhseType
Declare @item         ItemType
Declare @qty          QtyUnitType
Declare @u_m          UMType
Declare @matl_cost    CostPrcType
Declare @lbr_cost     CostPrcType
Declare @fovhd_cost   CostPrcType
Declare @vovhd_cost   CostPrcType
Declare @out_cost     CostPrcType
Declare @loc          LocType
Declare @perm_flag    ListYesNoType
Declare @lot          LotType
Declare @tran_date    DateTimeType
Declare @reason_code  ReasonCodeType
Declare @document_num RUSDocNumType
Declare @acct         AcctType
Declare @access_unit1 UnitCode1Type
Declare @access_unit2 UnitCode2Type
Declare @access_unit3 UnitCode3Type
Declare @access_unit4 UnitCode4Type
Declare @ser_num      SerNumType

Declare @original_u_m   UMType
Declare @lot_tracked    ListYesNoType
Declare @serial_tracked ListYesNoType
Declare @UMConvFactor   UMConvFactorType
Declare @UnitCost       CostPrcType
Declare @tran_date_str  varchar(128)

Declare @Result         int
Declare @ErrorCode      int
Declare @Infobar        InfobarType
Declare @RowPointer     RowPointerType

Declare @TransID        MatlTransNumType
Declare @RUSDocType     RUSDocNumType
Declare @Note_Content   nvarchar(2048)
Declare @Note_Desc      LongDescType
Declare @NewLotUID      RowPointerType
Declare @NewNoteUID     RowPointerType
Declare @NewSerialUID   RowPointerType
Declare @SpecificNoteToken TokenType
Declare @NoteHeaderToken   TokenType
Declare @NonModifiedLot    LotType
Declare @Cnt               bigint
Declare @ParamToSave       varchar(255)


DECLARE @ImportDocId ImportDocIdType

Set @RUSDocType = 'InvMiscRcpt'

exec dbo.DefineVariableSp 'MessageLanguage'
                         ,'1049'
                         ,@Infobar OUTPUT

If OBJECT_ID('tempdb..#ErrorCodes') Is Not Null Drop Table #ErrorCodes

Create Table #ErrorCodes (ErrorCode int, ErrMsg varchar(255))

Insert Into #ErrorCodes
Select -8, 'Не удалось добавить один или несколько серийных номеров' Union
Select -7, 'Не удалось добавить привязку Изделие\Склад' Union
Select -6, 'Во входном файле имеются 2 или более кода одного и того же изделия, отслеживаемого по серийному номеру' Union
Select -5, 'Не удалось создать партию' Union
Select -4, 'Не удалось выполнить привязку Изделие\Склад\МС' Union
Select -3, 'Не удалось внести запись в справочник "Места складирования партий изделий"' Union
Select -2, 'Не удалось создать номер документа-основания' Union
Select -1, 'Не удалось зарегистрировать приход' Union
Select  0, 'Загрузка прошла успешно' Union
Select  1, 'Код изделия не указан, либо указан неверно' Union
Select  2, 'Код склада не указан, либо указан неверно' Union
Select  3, 'Код единицы измерения указан неверно' Union
Select  4, 'Код причины не указан, либо указан неверно' Union
Select  5, 'Код МС не указан, либо указан неверно' Union
Select  6, 'Единица измерения по изделию отличается от базовой и отсутствует коэффициент перевода' Union
Select  7, 'Для партионных изделий не указан код партии' Union
Select  8, 'Количество по изделию не соответствует количеству серийных номеров' Union
Select  9, 'Указанный счет не существует' Union
Select 10, 'Счет недействителен, т.к. является статистическим счетом или недопустимым счетом' Union
Select 11, 'Указанный код аналитики1 не существует' Union
Select 12, 'Указанный код аналитики2 не существует' Union
Select 13, 'Указанный код аналитики3 не существует' Union
Select 14, 'Указанный код аналитики4 не существует' Union
Select 15, 'Не указано, либо указано нулевое или отрицательное количество по изделию' Union
Select 16, 'Указанные серийные номера для изделия должны быть уникальными' Union
Select 17, 'Указанные серийные номера уже имеются в справочнике серийных номеров' Union
Select 18, 'Серийные номера не должны содержать пустые значения' Union
Select 19, 'Имеется предмет примечания без текста примечания' Union
Select 20, 'Имеется текст примечания без предмета примечания'

UPDATE #RUSXDE_MiscReceipt SET
  lot =  dbo.ExpandKyLotType(item, lot)

UPDATE #RUSXDE_MiscReceipt_serials SET
  lot =  dbo.ExpandKyLotType(item, lot)


-- Check section open

If @LogFlag = 1
     exec dbo.RUS_DiagnosticInTXTSp '', @LogFile, 2 -- delete old log

Set @ErrorCode = 0

Set @item = (Select Top 1 itm.item
             From #RUSXDE_MiscReceipt as mr
             join dbo.item as itm On RTRIM(LTRIM(itm.item)) = RTRIM(LTRIM(mr.item))
             Where itm.serial_tracked = 1
             Group By itm.item Having Count(*) > 1
            )

If @item Is Not Null
     Select @ErrorCode = -6, @RetErr = 'Изделие: ' + IsNull(@item, '')

If @ErrorCode = 0
Begin

     Declare item_cur Cursor For Select  (CASE When RTRIM(LTRIM(mr.whse)) = '' Then Null Else mr.whse End)
                                        ,mr.item
                                        ,mr.qty
                                        ,(CASE When RTRIM(LTRIM(mr.u_m)) = '' Then Null Else mr.u_m End)
                                        ,mr.matl_cost
                                        ,mr.lbr_cost
                                        ,mr.fovhd_cost
                                        ,mr.vovhd_cost
                                        ,mr.out_cost
                                        ,(CASE When RTRIM(LTRIM(mr.loc)) = '' Then Null Else mr.loc End)
                                        ,mr.perm_flag
                                        ,(CASE When RTRIM(LTRIM(mr.lot)) = '' Then Null Else mr.lot End)
                                        ,mr.tran_date
                                        ,(CASE When RTRIM(LTRIM(mr.reason_code)) = '' Then Null Else mr.reason_code End)
                                        ,(CASE When RTRIM(LTRIM(mr.document_num)) = '' Then Null Else mr.document_num End)
                                        ,(CASE When RTRIM(LTRIM(mr.acct)) = '' Then Null Else mr.acct End)
                                        ,(CASE When RTRIM(LTRIM(mr.access_unit1)) = '' Then Null Else mr.access_unit1 End)
                                        ,(CASE When RTRIM(LTRIM(mr.access_unit2)) = '' Then Null Else mr.access_unit2 End)
                                        ,(CASE When RTRIM(LTRIM(mr.access_unit3)) = '' Then Null Else mr.access_unit3 End)
                                        ,(CASE When RTRIM(LTRIM(mr.access_unit4)) = '' Then Null Else mr.access_unit4 End)
                                        ,itm.u_m
                                        ,itm.lot_tracked
                                        ,itm.serial_tracked
                                        ,(CASE When RTRIM(LTRIM(mr.note_content)) = '' Then Null Else mr.note_content End)
                                        ,(CASE When RTRIM(LTRIM(mr.note_desc)) = '' Then Null Else mr.note_desc End)
                                  From #RUSXDE_MiscReceipt as mr
                                  left join dbo.item as itm On RTRIM(LTRIM(itm.item)) = RTRIM(LTRIM(mr.item))

     Open item_cur

     Fetch Next From item_cur Into  @whse
                                   ,@item
                                   ,@qty
                                   ,@u_m
                                   ,@matl_cost
                                   ,@lbr_cost
                                   ,@fovhd_cost
                                   ,@vovhd_cost
                                   ,@out_cost
                                   ,@loc
                                   ,@perm_flag
                                   ,@lot
                                   ,@tran_date
                                   ,@reason_code
                                   ,@document_num
                                   ,@acct
                                   ,@access_unit1
                                   ,@access_unit2
                                   ,@access_unit3
                                   ,@access_unit4
                                   ,@original_u_m
                                   ,@lot_tracked
                                   ,@serial_tracked
                                   ,@Note_Content
                                   ,@Note_Desc
                              While @@FETCH_STATUS = 0 And @ErrorCode = 0

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
                         + 'Счет: ' + IsNull(@acct, '')
                         + CHAR(13) + CHAR(10)
                         + 'Код аналитики 1: ' + IsNull(@access_unit1, '')
                         + CHAR(13) + CHAR(10)
                         + 'Код аналитики 2: ' + IsNull(@access_unit2, '')
                         + CHAR(13) + CHAR(10)
                         + 'Код аналитики 3: ' + IsNull(@access_unit3, '')
                         + CHAR(13) + CHAR(10)
                         + 'Код аналитики 4: ' + IsNull(@access_unit4, '')
                         + CHAR(13) + CHAR(10)
                         + 'Номер документа-основания: ' + IsNull(@document_num, '')

          Set @item = (Select item
                       From dbo.item
                       Where RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                      )

          If @item Is Null
          Set @ErrorCode = 1

          If @ErrorCode = 0
               If    @qty Is Null
                  Or @qty <= 0
               Set @ErrorCode = 15

          If @ErrorCode = 0
               If Not Exists (Select * From dbo.whse Where RTRIM(LTRIM(whse)) = RTRIM(LTRIM(@whse)))
               Set @ErrorCode = 2

          If @ErrorCode = 0
               If @u_m Is Not Null
                    If Not Exists (Select * From dbo.u_m Where RTRIM(LTRIM(u_m)) = RTRIM(LTRIM(@u_m)))
                    Set @ErrorCode = 3
                    Else
                    Set @u_m = (Select u_m From dbo.u_m Where RTRIM(LTRIM(u_m)) = RTRIM(LTRIM(@u_m)))

          If @ErrorCode = 0
               If @original_u_m <> @u_m
                    If Not Exists (Select * From dbo.u_m_conv Where (from_u_m = @u_m And to_u_m = @original_u_m
                                                                     Or
                                                                     from_u_m = @original_u_m And to_u_m = @u_m
                                                                    )
                                  )
                    Set @ErrorCode = 6
                    Else
                    Begin
                         Set @UMConvFactor = dbo.Getumcf(@u_m, @item, Null, Null)
                         Set @qty          = dbo.UomConvQty(@qty, @UMConvFactor, 'To Base')
                    End

          If @ErrorCode = 0
               If Not Exists (Select * From dbo.reason Where RTRIM(LTRIM(reason_code)) = RTRIM(LTRIM(@reason_code)))
               Set @ErrorCode = 4

          If @ErrorCode = 0
               If Not Exists (Select * From dbo.location Where RTRIM(LTRIM(loc)) = RTRIM(LTRIM(@loc)))
               Set @ErrorCode = 5

          If @ErrorCode = 0
               If @lot_tracked = 1 And @lot Is Null
               Set @ErrorCode = 7

          If @ErrorCode = 0
               If @serial_tracked = 1 And (Select Count(*) From #RUSXDE_MiscReceipt_serials
                                           Where     RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                 And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))
                                          ) <> @qty
               Set @ErrorCode = 8

          If @ErrorCode = 0
               If @serial_tracked = 1 And Exists (Select ser_num From #RUSXDE_MiscReceipt_serials
                                                  Where     RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                        And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))
                                                  Group By ser_num
                                                  Having Count(*) > 1
                                                 )
               Set @ErrorCode = 16

          If @ErrorCode = 0
               If @serial_tracked = 1 And Exists (Select * From #RUSXDE_MiscReceipt_serials as ser
                                                  Where      RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                        And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))
                                                        And Exists (Select * From dbo.serial
                                                                    Where RTRIM(LTRIM(ser_num)) = RTRIM(LTRIM(ser.ser_num))
                                                                   )
                                                 )
               Set @ErrorCode = 17

          If @ErrorCode = 0
               If @serial_tracked = 1 And Exists (Select * From #RUSXDE_MiscReceipt_serials as ser
                                                  Where      RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                        And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))
                                                        And (ser_num = '' Or ser_num Is Null)
                                                 )
               Set @ErrorCode = 18

          If @ErrorCode = 0
                If @acct Is Not Null
                Begin
                     Set @acct = (Select acct From dbo.chart Where RTRIM(LTRIM(acct)) = RTRIM(LTRIM(@acct)))

                     If @acct Is Null
                     Set @ErrorCode = 9
--                      Else
--                      If (Select Type From dbo.chart Where acct = @acct) <> 'S'
--                      Set @ErrorCode = 10
                End

          If @ErrorCode = 0 And @acct Is Not Null
          Begin

               If (Select access_unit1 From dbo.chart Where acct = @acct) = 'A'
                    If     @access_unit1 Is Not Null
                       And Not Exists (Select * From dbo.unitcd1 Where RTRIM(LTRIM(unit1)) = RTRIM(LTRIM(@access_unit1)))
                    Set @ErrorCode = 11

               If @ErrorCode = 0
                      If (Select access_unit2 From dbo.chart Where acct = @acct) = 'A'
                             If     @access_unit2 Is Not Null
                                And Not Exists (Select * From dbo.unitcd2 Where RTRIM(LTRIM(unit2)) = RTRIM(LTRIM(@access_unit2)))
                             Set @ErrorCode = 12

               If @ErrorCode = 0
                      If (Select access_unit3 From dbo.chart Where acct = @acct) = 'A'
                             If     @access_unit3 Is Not Null
                                And Not Exists (Select * From dbo.unitcd3 Where RTRIM(LTRIM(unit3)) = RTRIM(LTRIM(@access_unit3)))
                             Set @ErrorCode = 13

               If @ErrorCode = 0
                      If (Select access_unit4 From dbo.chart Where acct = @acct) = 'A'
                             If     @access_unit4 Is Not Null
                                And Not Exists (Select * From dbo.unitcd4 Where RTRIM(LTRIM(unit4)) = RTRIM(LTRIM(@access_unit4)))
                             Set @ErrorCode = 14

          End

          If @ErrorCode = 0
               If (@lot_tracked = 1 Or @serial_tracked = 1 ) And @Note_Content Is Not Null And @Note_Desc Is Null
               Set @ErrorCode = 19

          If @ErrorCode = 0
               If (@lot_tracked = 1 Or @serial_tracked = 1 ) And @Note_Content Is Null And @Note_Desc Is Not Null
               Set @ErrorCode = 20

          Fetch Next From item_cur Into  @whse
                                        ,@item
                                        ,@qty
                                        ,@u_m
                                        ,@matl_cost
                                        ,@lbr_cost
                                        ,@fovhd_cost
                                        ,@vovhd_cost
                                        ,@out_cost
                                        ,@loc
                                        ,@perm_flag
                                        ,@lot
                                        ,@tran_date
                                        ,@reason_code
                                        ,@document_num
                                        ,@acct
                                        ,@access_unit1
                                        ,@access_unit2
                                        ,@access_unit3
                                        ,@access_unit4
                                        ,@original_u_m
                                        ,@lot_tracked
                                        ,@serial_tracked
                                        ,@Note_Content
                                        ,@Note_Desc

     End
     Close item_cur
     Deallocate item_cur

End

-- Check section closed

-- Receipt section open
If @ErrorCode = 0
Begin

     If @LogFlag = 1 exec dbo.RUS_DiagnosticInTXTSp @ParamToSave = 'Receipt section open', @LogFile = @LogFile, @AppendFlag = 0

     Set @Cnt = 0

     Declare item_cur Cursor For Select  (CASE When RTRIM(LTRIM(mr.whse)) = '' Then Null Else mr.whse End)
                                        ,itm.item
                                        ,mr.qty
                                        ,(CASE When RTRIM(LTRIM(mr.u_m)) = '' Then Null Else mr.u_m End)
                                        ,mr.matl_cost
                                        ,mr.lbr_cost
                                        ,mr.fovhd_cost
                                        ,mr.vovhd_cost
                                        ,mr.out_cost
                                        ,(CASE When RTRIM(LTRIM(mr.loc)) = '' Then Null Else mr.loc End)
                                        ,mr.perm_flag
                                        ,(CASE When RTRIM(LTRIM(mr.lot)) = '' Then Null Else mr.lot End)
                                        ,mr.tran_date
                                        ,(CASE When RTRIM(LTRIM(mr.reason_code)) = '' Then Null Else mr.reason_code End)
                                        ,(CASE When RTRIM(LTRIM(mr.document_num)) = '' Then Null Else mr.document_num End)
                                        ,(CASE When RTRIM(LTRIM(mr.import_doc_id)) = '' Then Null Else mr.import_doc_id End)
                                        ,(CASE When RTRIM(LTRIM(mr.acct)) = '' Then Null Else mr.acct End)
                                        ,(CASE When RTRIM(LTRIM(mr.access_unit1)) = '' Then Null Else mr.access_unit1 End)
                                        ,(CASE When RTRIM(LTRIM(mr.access_unit2)) = '' Then Null Else mr.access_unit2 End)
                                        ,(CASE When RTRIM(LTRIM(mr.access_unit3)) = '' Then Null Else mr.access_unit3 End)
                                        ,(CASE When RTRIM(LTRIM(mr.access_unit4)) = '' Then Null Else mr.access_unit4 End)
                                        ,itm.u_m
                                        ,itm.lot_tracked
                                        ,itm.serial_tracked
                                        ,(CASE When RTRIM(LTRIM(mr.note_content)) = '' Then Null Else mr.note_content End)
                                        ,(CASE When RTRIM(LTRIM(mr.note_desc)) = '' Then Null Else mr.note_desc End)
                                  From #RUSXDE_MiscReceipt as mr
                                  left join dbo.item as itm On RTRIM(LTRIM(itm.item)) = RTRIM(LTRIM(mr.item))

     Open item_cur

     Fetch Next From item_cur Into  @whse
                                   ,@item
                                   ,@qty
                                   ,@u_m
                                   ,@matl_cost
                                   ,@lbr_cost
                                   ,@fovhd_cost
                                   ,@vovhd_cost
                                   ,@out_cost
                                   ,@loc
                                   ,@perm_flag
                                   ,@lot
                                   ,@tran_date
                                   ,@reason_code
                                   ,@document_num
                                   ,@ImportDocId
                                   ,@acct
                                   ,@access_unit1
                                   ,@access_unit2
                                   ,@access_unit3
                                   ,@access_unit4
                                   ,@original_u_m
                                   ,@lot_tracked
                                   ,@serial_tracked
                                   ,@Note_Content
                                   ,@Note_Desc
                              While @@FETCH_STATUS = 0 And @ErrorCode = 0

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
                         + 'Счет: ' + IsNull(@acct, '')
                         + CHAR(13) + CHAR(10)
                         + 'Код аналитики 1: ' + IsNull(@access_unit1, '')
                         + CHAR(13) + CHAR(10)
                         + 'Код аналитики 2: ' + IsNull(@access_unit2, '')
                         + CHAR(13) + CHAR(10)
                         + 'Код аналитики 3: ' + IsNull(@access_unit3, '')
                         + CHAR(13) + CHAR(10)
                         + 'Код аналитики 4: ' + IsNull(@access_unit4, '')
                         + CHAR(13) + CHAR(10)
                         + 'Номер документа-основания: ' + IsNull(@document_num, '')

          Set @Cnt         = @Cnt + 1
          Set @item        = (Select item From dbo.item Where RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item)))
          Set @whse        = (Select whse From dbo.whse Where RTRIM(LTRIM(whse)) = RTRIM(LTRIM(@whse)))
          Set @reason_code = (Select Top 1 reason_code From dbo.reason Where RTRIM(LTRIM(reason_code)) = RTRIM(LTRIM(@reason_code)))
          Set @loc         = (Select loc From dbo.location Where RTRIM(LTRIM(loc)) = RTRIM(LTRIM(@loc)))
          Set @matl_cost   = IsNull(@matl_cost, 0)
          Set @lbr_cost    = IsNull(@lbr_cost, 0)
          Set @fovhd_cost  = IsNull(@fovhd_cost, 0)
          Set @vovhd_cost  = IsNull(@vovhd_cost, 0)
          Set @out_cost    = IsNull(@out_cost, 0)
          Set @UnitCost    = @matl_cost + @lbr_cost + @fovhd_cost + @vovhd_cost + @out_cost
          Set @tran_date   = IsNull(@tran_date, GetDate())
          Set @acct = (Select acct From dbo.chart Where RTRIM(LTRIM(acct)) = RTRIM(LTRIM(@acct)))

          If @acct Is Not Null
          Begin

               If (Select access_unit1 From dbo.chart Where acct = @acct) = 'N'
               Set @access_unit1 = Null
               Else
               Set @access_unit1 = (Select unit1 From dbo.unitcd1 Where RTRIM(LTRIM(unit1)) = RTRIM(LTRIM(@access_unit1)))

               If (Select access_unit2 From dbo.chart Where acct = @acct) = 'N'
               Set @access_unit2 = Null
               Else
               Set @access_unit2 = (Select unit2 From dbo.unitcd2 Where RTRIM(LTRIM(unit2)) = RTRIM(LTRIM(@access_unit2)))

               If (Select access_unit3 From dbo.chart Where acct = @acct) = 'N'
               Set @access_unit3 = Null
               Else
               Set @access_unit3 = (Select unit3 From dbo.unitcd3 Where RTRIM(LTRIM(unit3)) = RTRIM(LTRIM(@access_unit3)))

               If (Select access_unit4 From dbo.chart Where acct = @acct) = 'N'
               Set @access_unit4 = Null
               Else
               Set @access_unit4 = (Select unit4 From dbo.unitcd4 Where RTRIM(LTRIM(unit4)) = RTRIM(LTRIM(@access_unit4)))

          End

          If @u_m Is Not Null
          Set @u_m = (Select u_m From dbo.u_m Where RTRIM(LTRIM(u_m)) = RTRIM(LTRIM(@u_m)))
          Else
          Set @u_m = (Select u_m From dbo.item Where item = @item)

          If @original_u_m <> @u_m
          Begin
               Set @UMConvFactor = dbo.Getumcf(@u_m, @item, Null, Null)
               Set @qty          = dbo.UomConvQty(@qty, @UMConvFactor, 'To Base')
               Set @matl_cost    = CAST(@matl_cost  / @UMConvFactor as decimal(18,8))
               Set @lbr_cost     = CAST(@lbr_cost   / @UMConvFactor as decimal(18,8))
               Set @fovhd_cost   = CAST(@fovhd_cost / @UMConvFactor as decimal(18,8))
               Set @vovhd_cost   = CAST(@vovhd_cost / @UMConvFactor as decimal(18,8))
               Set @out_cost     = CAST(@out_cost   / @UMConvFactor as decimal(18,8))
          End

          If @LogFlag = 1
          Begin
               Set @ParamToSave = '@Cnt = '  + CAST(@Cnt as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@item = '  + @item
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@u_m = '  + @u_m
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@qty = '  + CAST(@qty as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@UMConvFactor = '  + CAST(@UMConvFactor as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@lot_tracked = '  + CAST(@lot_tracked as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@serial_tracked = '  + CAST(@serial_tracked as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@whse = '  + @whse
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@reason_code = '  + @reason_code
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@loc = '  + @loc
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@lot = '  + @lot
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@document_num = '  + @document_num
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@matl_cost = '  + CAST(@matl_cost as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@lbr_cost = '  + CAST(@lbr_cost as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@fovhd_cost = '  + CAST(@fovhd_cost as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@vovhd_cost = '  + CAST(@vovhd_cost as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@out_cost = '  + CAST(@out_cost as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@UnitCost = '  + CAST(@UnitCost as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@tran_date = '  + CAST(@tran_date as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@acct = '  + @acct
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@access_unit1 = '  + @access_unit1
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@access_unit2 = '  + @access_unit2
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@access_unit3 = '  + @access_unit3
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
               Set @ParamToSave = '@access_unit4 = '  + @access_unit4
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
          End

          If @lot_tracked = 1
               If Not Exists (Select * From dbo.lot Where item = @item And RTRIM(LTRIM(lot)) = RTRIM(LTRIM(dbo.ExpandKyLotType(@item, @lot))))
               Begin

                    If @LogFlag = 1
                         exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.LotAddSp ...', @LogFile, 1

                    exec @Result = dbo.LotAddSp  @Item = @item
                                                ,@Lot = @lot
                                                ,@RcvdQty = 0
                                                ,@CreateNonUnique = 0
                                                ,@Infobar = @Infobar OUTPUT

                    If @LogFlag = 1
                         exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                    If @Result <> 0
                    Set @ErrorCode = -5
                    Else
                    Begin

                         Set @NonModifiedLot = @lot

                         Set @lot = (Select Top 1 lot
                                     From dbo.lot
                                     Where item = @item
                                     Order By RecordDate DESC
                                    )

                         If @LogFlag = 1
                              exec dbo.RUS_DiagnosticInTXTSp 'Trying to update #RUSXDE_MiscReceipt_serials ...', @LogFile, 1

                         Update #RUSXDE_MiscReceipt_serials Set lot = @lot
                         Where      RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@NonModifiedLot)) Or IsNull(lot, '') = IsNull(@NonModifiedLot, ''))

                         If @LogFlag = 1
                              exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                         -- Insert comments for lot
                         If @Note_Content Is Not Null And @Note_Desc Is Not Null
                         Begin

                              Set @NewLotUID = (Select Top 1 RowPointer
                                                From dbo.lot
                                                Where     lot  = @lot
                                                      And item = @item
                                                Order By RecordDate DESC
                                               )

                              Set @NewNoteUID = NewID()

                              If @LogFlag = 1
                                   exec dbo.RUS_DiagnosticInTXTSp 'Trying to insert into dbo.SpecificNotes ...', @LogFile, 1

                              Insert Into dbo.SpecificNotes
                              (
                                NoteContent
                               ,NoteDesc
                               ,RowPointer
                              )
                              Select @Note_Content
                                    ,@Note_Desc
                                    ,@NewNoteUID

                              If @LogFlag = 1
                                    exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                              Set @SpecificNoteToken = (Select SpecificNoteToken
                                                        From dbo.SpecificNotes
                                                        Where RowPointer = @NewNoteUID
                                                       )

                              Set @NoteHeaderToken = (Select NoteHeaderToken
                                                      From dbo.NoteHeaders
                                                      Where     ObjectName = 'lot'
                                                            And NoteFlag   = 0
                                                     )

                              If @LogFlag = 1
                                   exec dbo.RUS_DiagnosticInTXTSp 'Trying to insert into dbo.ObjectNotes ...', @LogFile, 1

                              Insert Into dbo.ObjectNotes
                              (
                                NoteHeaderToken
                               ,SpecificNoteToken
                               ,RefRowPointer
                               ,NoteType
                              )
                              Select @NoteHeaderToken
                                    ,@SpecificNoteToken
                                    ,@NewLotUID
                                    ,0

                              If @LogFlag = 1
                                    exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                         End
                    End
               End
               Else Set @lot = (Select lot From dbo.lot Where item = @item And RTRIM(LTRIM(lot)) = RTRIM(LTRIM(dbo.ExpandKyLotType(@item, @lot))))

          If @ErrorCode = 0
               If Not Exists (Select * From dbo.itemwhse Where item = @item And whse = @whse)
               Begin

                    If @LogFlag = 1
                         exec dbo.RUS_DiagnosticInTXTSp 'Trying to insert into dbo.itemwhse ...', @LogFile, 1

                    Insert Into dbo.itemwhse (item, whse) Select @item, @whse

                    If @LogFlag = 1
                         exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1
               End

          If @ErrorCode = 0
               If Not Exists (Select * From dbo.itemloc Where whse = @whse And item = @item And loc = @loc)
               Begin

                    If @LogFlag = 1
                         exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.ItemLocAddSp ...', @LogFile, 1

                    exec @Result = dbo.ItemLocAddSp  @Whse        = @whse
                                                    ,@Item        = @item
                                                    ,@Loc         = @loc
                                                    ,@SetPermFlag = @perm_flag
                                                    ,@UcFlag      = 0
                                                    ,@UnitCost    = 0
                                                    ,@MatlCost    = 0
                                                    ,@LbrCost     = 0
                                                    ,@FovhdCost   = 0
                                                    ,@VovhdCost   = 0
                                                    ,@OutCost     = 0
                                                    ,@RowPointer  = @RowPointer OUTPUT
                                                    ,@Infobar     = @Infobar    OUTPUT

                    If @LogFlag = 1
                         exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                    If @Result <> 0
                    Set @ErrorCode = -4

               End

          If @ErrorCode = 0
               If @lot_tracked = 1
                    If Not Exists (Select * From dbo.lot_loc Where     whse = @whse
                                                                   And item = @item
                                                                   And loc  = @loc
                                                                   And lot  = @lot
                                  )
                    Begin

                         If @LogFlag = 1
                              exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.LotLocAddSp ...', @LogFile, 1

                         exec @Result = dbo.LotLocAddSp  @PWhse           = @whse
                                                        ,@PItem           = @item
                                                        ,@PLoc            = @loc
                                                        ,@PLot            = @lot
                                                        ,@PUnitCost       = @UnitCost
                                                        ,@PMatlCost       = @matl_cost
                                                        ,@PLbrCost        = @lbr_cost
                                                        ,@PFovhdCost      = @fovhd_cost
                                                        ,@PVovhdCost      = @vovhd_cost
                                                        ,@POutCost        = @out_cost
                                                        ,@LotLocQtyOnHand = 0
                                                        ,@Infobar         = @Infobar OUTPUT

                         If @LogFlag = 1
                              exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                         If @Result <> 0
                         Set @ErrorCode = -3

                    End

          If @ErrorCode = 0
               If @serial_tracked = 1
               Begin
                    Declare ser_cur Cursor For Select ser_num From #RUSXDE_MiscReceipt_serials
                                                              Where      RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                                    And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))
                    Open ser_cur
                    Fetch Next From ser_cur Into @ser_num While @@FETCH_STATUS = 0 And @ErrorCode = 0
                    Begin

                         If @LogFlag = 1
                              exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.SerialSaveSp ...', @LogFile, 1

                         exec dbo.SerialSaveSp  @SerNum = @ser_num
                                              ,@Infobar = @Infobar OUTPUT

                         If @LogFlag = 1
                              exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                         If @Infobar Is Not Null
                         Set @ErrorCode = -8

                         Fetch Next From ser_cur Into @ser_num

                    End
                    Close ser_cur
                    Deallocate ser_cur
               End

          If @ErrorCode = 0
                If @document_num Is Not Null
                      If Not Exists (Select * From dbo.RUSmtl_doc
                                     Where     RTRIM(LTRIM(RUSmtl_doc.document_num)) = RTRIM(LTRIM(@document_num))
                                           And RTRIM(LTRIM(Type)) = @RUSDocType
                                    )
                      Begin

                           If @LogFlag = 1
                                exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.RUSMtlDocCreateSp ...', @LogFile, 1

                           exec dbo.RUSMtlDocCreateSp  @PDocNum = @document_num
                                                      ,@PType   = @RUSDocType
                                                      ,@PXref   = Null
                                                      ,@Infobar = @Infobar OUTPUT

                           If @LogFlag = 1
                                exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                           If @Infobar Is Not Null
                           Set @ErrorCode = -2

                      End
                      Else
                      Set @document_num = (Select document_num From dbo.RUSmtl_doc
                                           Where     RTRIM(LTRIM(RUSmtl_doc.document_num)) = RTRIM(LTRIM(@document_num))
                                           And RTRIM(LTRIM(Type)) = @RUSDocType
                                          )

          If @ErrorCode = 0
          Begin

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.RUSTransIdSp ...', @LogFile, 1

               exec dbo.RUSTransIdSp @TransID OUTPUT

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.DefineVariableSp ...', @LogFile, 1

               exec dbo.DefineVariableSp 'RUSMtlLastType'
                                        ,@RUSDocType
                                        ,@Infobar OUTPUT

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.DefineVariableSp ...', @LogFile, 1

               exec dbo.DefineVariableSp 'RUSMtlTransID'
                                         ,@TransID
                                         ,@Infobar OUTPUT

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.ItemMiscReceiptSp ...', @LogFile, 1

               exec @Result = dbo.ItemMiscReceiptSp  @P_Item        = @item
                                                    ,@P_Whse        = @whse
                                                    ,@P_Qty         = @qty
                                                    ,@P_UM          = @u_m
                                                    ,@P_MatlCost    = @matl_cost
                                                    ,@P_LbrCost     = @lbr_cost
                                                    ,@P_FovhdCost   = @fovhd_cost
                                                    ,@P_VovhdCost   = @vovhd_cost
                                                    ,@P_OutCost     = @out_cost
                                                    ,@P_UnitCost    = @UnitCost
                                                    ,@P_Loc         = @loc
                                                    ,@P_Lot         = @lot
                                                    ,@P_Reason      = @reason_code
                                                    ,@P_Acct        = @acct
                                                    ,@P_AcctUnit1   = @access_unit1
                                                    ,@P_AcctUnit2   = @access_unit2
                                                    ,@P_AcctUnit3   = @access_unit3
                                                    ,@P_AcctUnit4   = @access_unit4
                                                    ,@P_TransDate   = @tran_date
                                                    ,@Infobar       = @Infobar OUTPUT
                                                    ,@DocumentNum   = @document_num
                                                    ,@P_ImportDocId = @ImportDocId

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

               If @Result <> 0
               Set @ErrorCode = -1
               Else
               If @serial_tracked = 1 And @Note_Desc Is Not Null And @Note_Content Is Not Null
               Begin

                    -- Insert comments for serials
                    Declare Serial_cur Cursor For Select ser_num
                                                  From #RUSXDE_MiscReceipt_serials
                                                  Where     RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                        And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))

                    Open Serial_cur
                    Fetch Next From Serial_cur Into @ser_num While @@FETCH_STATUS = 0
                    Begin

                         Set @NewSerialUID = (Select RowPointer
                                              From dbo.serial
                                              Where ser_num = @ser_num
                                             )

                         If @NewSerialUID Is Not Null
                         Begin

                              Set @NewNoteUID = NewID()

                              If @LogFlag = 1
                                   exec dbo.RUS_DiagnosticInTXTSp 'Trying to insert into dbo.SpecificNotes ...', @LogFile, 1

                              Insert Into dbo.SpecificNotes
                              (
                                NoteContent
                               ,NoteDesc
                               ,RowPointer
                              )
                              Select @Note_Content
                                    ,@Note_Desc
                                    ,@NewNoteUID

                              If @LogFlag = 1
                                   exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                              Set @SpecificNoteToken = (Select SpecificNoteToken
                                                        From dbo.SpecificNotes
                                                        Where RowPointer = @NewNoteUID
                                                       )

                              Set @NoteHeaderToken = (Select NoteHeaderToken
                                                      From dbo.NoteHeaders
                                                      Where     ObjectName = 'serial'
                                                            And NoteFlag   = 0
                                                     )

                              If @LogFlag = 1
                                   exec dbo.RUS_DiagnosticInTXTSp 'Trying to insert into dbo.ObjectNotes ...', @LogFile, 1

                              Insert Into dbo.ObjectNotes
                              (
                                NoteHeaderToken
                               ,SpecificNoteToken
                               ,RefRowPointer
                               ,NoteType
                              )
                              Select @NoteHeaderToken
                                    ,@SpecificNoteToken
                                    ,@NewSerialUID
                                    ,0

                              If @LogFlag = 1
                                   exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

                         End

                         Fetch Next From Serial_cur Into @ser_num
                    End
                    Close Serial_cur
                    Deallocate Serial_cur

               End

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.UndefineVariableSp ...', @LogFile, 1

               exec dbo.UndefineVariableSp 'RUSMtlLastType'
                                          ,@Infobar OUTPUT

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.UndefineVariableSp ...', @LogFile, 1

               exec dbo.UndefineVariableSp 'RUSMtlTransID'
                                          ,@Infobar OUTPUT

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

          End

          Fetch Next From item_cur Into @whse
                                        ,@item
                                        ,@qty
                                        ,@u_m
                                        ,@matl_cost
                                        ,@lbr_cost
                                        ,@fovhd_cost
                                        ,@vovhd_cost
                                        ,@out_cost
                                        ,@loc
                                        ,@perm_flag
                                        ,@lot
                                        ,@tran_date
                                        ,@reason_code
                                        ,@document_num
                                        ,@ImportDocId
                                        ,@acct
                                        ,@access_unit1
                                        ,@access_unit2
                                        ,@access_unit3
                                        ,@access_unit4
                                        ,@original_u_m
                                        ,@lot_tracked
                                        ,@serial_tracked
                                        ,@Note_Content
                                        ,@Note_Desc

     End
     Close item_cur
     Deallocate item_cur

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