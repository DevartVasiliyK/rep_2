SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE Procedure [dbo].[RUSXDE_CODateImportSp_SSD]
(
  @RetErr        nvarchar(2800) OUTPUT
 ,@ProcExecState bit            OUTPUT
 ,@LogFlag       bit = 0
 ,@LogFile       varchar(255) = 'C:\RUSXDE_CODateImportSp_SSD_Log.txt'
)
As
Begin

Declare @Result       int 
Declare @ErrorCode    int 
Declare @Infobar      InfobarType 
Declare @RowPointer   RowPointerType 
Declare @ParamToSave  varchar(255) 

Declare @co_num          CoNumType 
Declare @co_line         CoLineType 
Declare @qty             QtyUnitNoNegType 
Declare @item            ItemType 
Declare @Uf_jobssd       nvarchar(10) 
Declare @Uf_jobssdqtyord decimal(19,8) 
Declare @Uf_Upak         decimal(19,8) 
Declare @Uf_Stat2        nvarchar(1) 
Declare @Uf_Txt          nvarchar(60) 
Declare @Uf_due_date     DateType 
Declare @Uf_jobssdqty    decimal(19,8) 

exec dbo.DefineVariableSp 'MessageLanguage'
                         ,'1049'
                         ,@Infobar OUTPUT

Update cd Set cd.co_num = dbo.ExpandKyByType('CoNumType', co_num) 
             ,cd.item   = IsNull(itm.item, cd.item) 
From #RUSXDE_CODate_SSD as cd 
left join dbo.item as itm On RTRIM(LTRIM(itm.item)) = RTRIM(LTRIM(cd.item)) 

If OBJECT_ID('tempdb..#ErrorCodes') Is Not Null Drop Table #ErrorCodes

Create Table #ErrorCodes (ErrorCode int, ErrMsg varchar(255))

Insert Into #ErrorCodes 
Select -4, 'В файле содержится строка ЗК с существующим co_num и co_line и item, но неверным qty' Union 
Select -3, 'В файле содержится строка ЗК с существующим co_num и co_line, но неверным item' Union 
Select -2, 'В файле содержится строка ЗК с сочетанием co_num и co_line, не существующим в таблице строк ЗК' Union 
Select -1, 'В файле содержится строка ЗК с co_num, не существующем в таблице строк ЗК' 

-- Check section open
If @LogFlag = 1 
     exec dbo.RUS_DiagnosticInTXTSp '', @LogFile, 2 -- delete old log

Set @ErrorCode = 0

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_CODate_SSD 
           Where Not Exists (Select * From 
                             dbo.coitem 
                             Where co_num = #RUSXDE_CODate_SSD.co_num 
                            ) 
          ) 
Set @ErrorCode = -1 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_CODate_SSD 
           Where Not Exists (Select * From 
                             dbo.coitem 
                             Where     co_num  = #RUSXDE_CODate_SSD.co_num 
                                   And co_line = #RUSXDE_CODate_SSD.co_line 
                            ) 
          ) 
Set @ErrorCode = -2 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_CODate_SSD 
           Where Not Exists (Select * From 
                             dbo.coitem 
                             Where     co_num  = #RUSXDE_CODate_SSD.co_num 
                                   And co_line = #RUSXDE_CODate_SSD.co_line 
                                   And item    = #RUSXDE_CODate_SSD.item 
                            ) 
          ) 
Set @ErrorCode = -3 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_CODate_SSD 
           Where Not Exists (Select * 
                             From dbo.coitem 
                             Where     co_num      = #RUSXDE_CODate_SSD.co_num 
                                   And co_line     = #RUSXDE_CODate_SSD.co_line 
                                   And item        = #RUSXDE_CODate_SSD.item 
                                   And qty_ordered = #RUSXDE_CODate_SSD.qty 
                            ) 
          ) 
Set @ErrorCode = -4 
-- Check section closed

-- Receipt section open
If @ErrorCode = 0
Begin

     If @LogFlag = 1 
          exec dbo.RUS_DiagnosticInTXTSp @ParamToSave = 'Receipt section open', @LogFile = @LogFile, @AppendFlag = 0 

     Update coi Set coi.Uf_jobssd       = IsNull(cd.Uf_jobssd, coi.Uf_jobssd) 
                   ,coi.Uf_jobssdqtyord = IsNull(cd.Uf_jobssdqtyord, coi.Uf_jobssdqtyord) 
                   ,coi.Uf_Upak         = IsNull(cd.Uf_Upak, coi.Uf_Upak) 
                   ,coi.Uf_Stat2        = IsNull(cd.Uf_Stat2, coi.Uf_Stat2) 
                   ,coi.Uf_Txt          = IsNull(cd.Uf_Txt, coi.Uf_Txt) 
                   ,coi.Uf_due_date     = IsNull(cd.Uf_due_date, coi.Uf_due_date) 
                   ,coi.Uf_jobssdqty    = IsNull(cd.Uf_jobssdqty, coi.Uf_jobssdqty) 
     From dbo.coitem as coi 
     join #RUSXDE_CODate_SSD as cd On     cd.co_num  = coi.co_num 
                                      And cd.co_line = coi.co_line 
                                      And cd.item    = coi.item 
                                      And cd.qty     = coi.qty_ordered 

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