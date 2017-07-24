SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE         Procedure [dbo].[RUSXDE_MiscIss_Proc]
(
  @RetErr        nvarchar(2800) OUTPUT
 ,@ProcExecState bit            OUTPUT
 ,@LogFlag       bit = 0
 ,@LogFile       varchar(255) = 'C:\RUSXDE_MiscIss_Proc_Log.txt'
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
Declare @cre_date    DateTimeType
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

DECLARE
  @KOCode nvarchar(20)
, @KODesc nvarchar(255)
, @LogoCode nvarchar(20)
, @LogoDesc nvarchar(255)
, @ItPrice1 CostPrcType
, @CurrCode CurrCodeType
, @TAcct                  AcctType
, @TAcctUnit1             UnitCode1Type
, @TAcctUnit2             UnitCode2Type
, @TAcctUnit3             UnitCode3Type
, @TAcctUnit4             UnitCode4Type
, @TUnit                  UnitCode2Type
, @SessionID                  uniqueidentifier


DECLARE @ImportDocId ImportDocIdType

Set @RUSDocType = 'InvMiscIss'
SET @SessionID            = dbo.SessionIdSp()

exec dbo.DefineVariableSp 'MessageLanguage'
                         ,'1049'
                         ,@Infobar OUTPUT

If OBJECT_ID('tempdb..#ErrorCodes') Is Not Null Drop Table #ErrorCodes

Create Table #ErrorCodes (ErrorCode int, ErrMsg varchar(255))

Insert Into #ErrorCodes
Select -8, 'Не удалось добавить один или несколько серийных номеров' Union
Select -7, 'Не удалось добавить привязку Изделие\Склад' Union
Select -6, 'Во входном файле имеются 2 или более кода одного и того же изделия, отслеживаемого по серийному номеру' Union
Select -5, 'Нет партии' Union
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
Select 20, 'Имеется текст примечания без предмета примечания'Union
Select 21, 'Текст конструктивных особенностей не соответствует коду'Union
Select 22, 'Текст логотипа не соответствует коду'Union
Select 23, 'Цена 1 данного изделия не определена либо уже не действует'Union
Select 24, 'Для изделия не отслеживающегося по партиям указан код партии'Union
Select 25, 'Для изделия не отслеживающегося по С/Н указаны коды С/Н'

UPDATE #RUSXDE_MiscIss SET
  lot =  dbo.ExpandKyLotType(item, lot)

UPDATE #RUSXDE_MiscIss_serials SET
  lot =  dbo.ExpandKyLotType(item, lot)


-- Check section open

If @LogFlag = 1
     exec dbo.RUS_DiagnosticInTXTSp '', @LogFile, 2 -- delete old log

SELECT @CurrCode = currparms.curr_code
FROM currparms

Set @ErrorCode = 0
/*
Set @item = (Select Top 1 itm.item
             From #RUSXDE_MiscReceipt as mr
             join dbo.item as itm On RTRIM(LTRIM(itm.item)) = RTRIM(LTRIM(mr.item))
             Where itm.serial_tracked = 1
             Group By itm.item Having Count(*) > 1
            )

If @item Is Not Null
     Select @ErrorCode = -6, @RetErr = 'Изделие: ' + IsNull(@item, '')
*/
If @ErrorCode = 0
Begin

     Declare item_cur Cursor For Select  (CASE When RTRIM(LTRIM(mr.whse)) = '' Then Null Else mr.whse End)
                                        ,mr.item
                                        ,mr.qty
                                        ,(CASE When RTRIM(LTRIM(mr.u_m)) = '' Then Null Else mr.u_m End)
                                        ,(CASE When RTRIM(LTRIM(mr.loc)) = '' Then Null Else mr.loc End)
                                        ,(CASE When RTRIM(LTRIM(mr.lot)) = '' Then Null Else mr.lot End)
                                        ,mr.tran_date
                                        ,(CASE When RTRIM(LTRIM(mr.reason_code)) = '' Then Null Else mr.reason_code End)
                                        ,(CASE When RTRIM(LTRIM(mr.document_num)) = '' Then Null Else mr.document_num End)
                                        ,itm.u_m
                                        ,itm.lot_tracked
                                        ,itm.serial_tracked
                                  From #RUSXDE_MiscIss as mr
                                  left join dbo.item as itm On RTRIM(LTRIM(itm.item)) = RTRIM(LTRIM(mr.item))

     Open item_cur

     Fetch Next From item_cur Into  @whse
                                   ,@item
                                   ,@qty
                                   ,@u_m
                                   ,@loc
                                   ,@lot
                                   ,@tran_date
                                   ,@reason_code
                                   ,@document_num
                                   ,@original_u_m
                                   ,@lot_tracked
                                   ,@serial_tracked
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
               If @serial_tracked = 1 And (Select Count(*) From #RUSXDE_MiscIss_serials
                                           Where     RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                 and loc = @Loc
                                                 And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))
                                          ) <> @qty
               Set @ErrorCode = 8

          If @ErrorCode = 0
               If @serial_tracked = 1 And Exists (Select ser_num From #RUSXDE_MiscIss_serials
                                                  Where     RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                        and loc = @Loc
                                                        And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))
                                                  Group By ser_num
                                                  Having Count(*) > 1
                                                 )
               Set @ErrorCode = 16

          If @ErrorCode = 0
               If @serial_tracked = 1 And Exists (Select * From #RUSXDE_MiscIss_serials as ser
                                                  Where      RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                        and loc = @Loc
                                                        And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))
                                                        And (ser_num = '' Or ser_num Is Null)
                                                 )
               Set @ErrorCode = 18


 
 
          If @ErrorCode = 0
            IF @Lot is not null and @lot_tracked = 0
              SET @ErrorCode = 24

          If @ErrorCode = 0
            IF @serial_tracked = 0 and EXISTS(Select 1 From #RUSXDE_MiscIss_serials
                                                              Where      RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item)))
              SET @ErrorCode = 25

          Fetch Next From item_cur Into  @whse
                                        ,@item
                                        ,@qty
                                        ,@u_m
                                        ,@loc
                                        ,@lot
                                        ,@tran_date
                                        ,@reason_code
                                        ,@document_num
                                        ,@original_u_m
                                        ,@lot_tracked
                                        ,@serial_tracked
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
                                        ,(CASE When RTRIM(LTRIM(mr.loc)) = '' Then Null Else mr.loc End)
                                        ,(CASE When RTRIM(LTRIM(mr.lot)) = '' Then Null Else mr.lot End)
                                        ,mr.tran_date
                                        ,(CASE When RTRIM(LTRIM(mr.reason_code)) = '' Then Null Else mr.reason_code End)
                                        ,(CASE When RTRIM(LTRIM(mr.document_num)) = '' Then Null Else mr.document_num End)
                                        ,(CASE When RTRIM(LTRIM(mr.import_doc_id)) = '' Then Null Else mr.import_doc_id End)
                                        ,itm.u_m
                                        ,itm.lot_tracked
                                        ,itm.serial_tracked
                                  From #RUSXDE_MiscIss as mr
                                  left join dbo.item as itm On RTRIM(LTRIM(itm.item)) = RTRIM(LTRIM(mr.item))

     Open item_cur

     Fetch Next From item_cur Into  @whse
                                   ,@item
                                   ,@qty
                                   ,@u_m
                                   ,@loc
                                   ,@lot
                                   ,@tran_date
                                   ,@reason_code
                                   ,@document_num
                                   ,@ImportDocId
                                   ,@original_u_m
                                   ,@lot_tracked
                                   ,@serial_tracked
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
                         + 'Номер документа-основания: ' + IsNull(@document_num, '')

          Set @Cnt         = @Cnt + 1
          Set @item        = (Select item From dbo.item Where RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item)))
          Set @whse        = (Select whse From dbo.whse Where RTRIM(LTRIM(whse)) = RTRIM(LTRIM(@whse)))
          Set @reason_code = (Select Top 1 reason_code From dbo.reason Where RTRIM(LTRIM(reason_code)) = RTRIM(LTRIM(@reason_code)))
          Set @loc         = (Select loc From dbo.location Where RTRIM(LTRIM(loc)) = RTRIM(LTRIM(@loc)))
          Set @tran_date   = IsNull(@tran_date, GetDate())

          SELECT
            @TAcct         = prodcode.inv_adj_acct
          , @TAcctUnit1    = prodcode.inv_adj_acct_unit1
          , @TAcctUnit2    = prodcode.inv_adj_acct_unit2
          , @TAcctUnit3    = prodcode.inv_adj_acct_unit3
          , @TAcctUnit4    = prodcode.inv_adj_acct_unit4
          , @TUnit         = prodcode.unit
          FROM item, prodcode
          WHERE item.item = @item
            AND item.product_code = prodcode.product_code


          If @u_m Is Not Null
          Set @u_m = (Select u_m From dbo.u_m Where RTRIM(LTRIM(u_m)) = RTRIM(LTRIM(@u_m)))
          Else
          Set @u_m = (Select u_m From dbo.item Where item = @item)

          If @original_u_m <> @u_m
          Begin
               Set @UMConvFactor = dbo.Getumcf(@u_m, @item, Null, Null)
               Set @qty          = dbo.UomConvQty(@qty, @UMConvFactor, 'To Base')
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
               Set @ParamToSave = '@tran_date = '  + CAST(@tran_date as varchar(200))
               exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
          End

          EXEC @Result = dbo.ReasonGetInvAdjAcctSp
            @ReasonCode       = @Reason_Code
          , @ReasonClass      = 'MISC ISSUE'
          , @Item             = @Item
          , @Acct             = @TAcct OUTPUT
          , @AcctUnit1        = @TAcctUnit1 OUTPUT
          , @AcctUnit2        = @TAcctUnit2 OUTPUT
          , @AcctUnit3        = @TAcctUnit3 OUTPUT
          , @AcctUnit4        = @TAcctUnit4 OUTPUT
          , @AccessUnit1      = null
          , @AccessUnit2      = null
          , @AccessUnit3      = null
          , @AccessUnit4      = null
          , @Description      = null
          , @Infobar          = @Infobar OUTPUT


          If @lot_tracked = 1 and @ErrorCode = 0
          BEGIN
               If Not Exists (Select * From dbo.lot Where item = @item And RTRIM(LTRIM(lot)) = RTRIM(LTRIM(dbo.ExpandKyLotType(@item, @lot))))
                   Set @ErrorCode = -5
                         
          END      
            
          
          If @ErrorCode = 0
               If @serial_tracked = 1
               Begin
                    Declare ser_cur Cursor For Select ser_num From #RUSXDE_MiscIss_serials
                                                              Where      RTRIM(LTRIM(item)) = RTRIM(LTRIM(@item))
                                                                    and loc = @loc
                                                                    And (RTRIM(LTRIM(lot)) = RTRIM(LTRIM(@lot)) Or IsNull(lot, '') = IsNull(@lot, ''))
                    Open ser_cur
                    Fetch Next From ser_cur Into @ser_num While @@FETCH_STATUS = 0 And @ErrorCode = 0
                    Begin

                         If @LogFlag = 1
                              exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.SerialSaveSp ...', @LogFile, 1

                          If EXISTS (SELECT * FROM tmp_ser
                                      WHERE tmp_ser.ser_num = @Ser_Num
                                                   AND SessionId = @SessionID)
                          BEGIN
                              EXEC @Result = MsgAppSp @Infobar OUTPUT, 'E=MustCompare0'
                                   , '@dcitem_serial.ser_num', '@user_index.index_unique', @Ser_Num
                          END
                          INSERT tmp_ser ( SessionId, ser_num )
                          VALUES(@SessionID, @Ser_Num )

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
                    exec dbo.RUS_DiagnosticInTXTSp 'Trying to execute dbo.IaPostSp ...', @LogFile, 1

               exec @Result = dbo.IaPostSp
                              @TrxType      = 'I'
                            , @TransDate    = @Tran_Date
                            , @Acct         = @TAcct
                            , @AcctUnit1    = @TAcctUnit1
                            , @AcctUnit2    = @TAcctUnit2
                            , @AcctUnit3    = @TAcctUnit3
                            , @AcctUnit4    = @TAcctUnit4
                            , @TransQty     = @Qty
                            , @Whse         = @Whse
                            , @Item         = @Item
                            , @Loc          = @Loc
                            , @Lot          = @Lot
                            , @FromSite     = @Whse
                            , @ToSite       = @Whse
                            , @ReasonCode   = @Reason_Code
                            , @TrnNum       = NULL
                            , @TrnLine      = 0
                            , @TransNum     = 0
                            , @RsvdNum      = 0
                            , @SerialStat   = 'O'
                            , @Workkey      = NULL  -- 'DCITEM' + FORMAT(@DcitemTransNum, '999999999')
                            , @MatlCost     = @Matl_Cost OUTPUT
                            , @Infobar      = @Infobar OUTPUT
                            , @DocumentNum  = @Document_Num
                            , @MoveZeroCostItem = 1

               If @LogFlag = 1
                    exec dbo.RUS_DiagnosticInTXTSp 'Succesful.', @LogFile, 1

               If @Result <> 0
               Set @ErrorCode = -1
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
                                        ,@loc
                                        ,@lot
                                        ,@tran_date
                                        ,@reason_code
                                        ,@document_num
                                        ,@ImportDocId
                                        ,@original_u_m
                                        ,@lot_tracked
                                        ,@serial_tracked

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