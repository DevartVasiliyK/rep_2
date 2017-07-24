SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[RUS_UtilityExportChangedCOs_SSD]   
(  
 @Delimiter char(1)   
,@Path varchar(255)   
)  
As   
Begin   
  
Declare @LastSuccessRunDate datetime   
Declare @co_num             CoNumType   
Declare @cust_num           CustNumType   
Declare @co_line            CoLineType
Declare @order_date         DateType  
Declare @item               ItemType   
Declare @due_date           DateType   
Declare @stat               CoitemStatusType  
Declare @Uf_stat2           CoitemStatusType   
Declare @qty_ordered        QtyUnitNoNegType  
Declare @Uf_upak            QtyUnitNoNegType  
Declare @Uf_txt             varchar(60)  
Declare @stat_ext           varchar(64)  
Declare @stat2_ext          varchar(64)  
Declare @Uf_izgot           QtyUnitNoNegType  
  
Declare @FileName varchar(267)   
Declare @Now datetime  
Declare @FSObject int   
Declare @FSOResult int  
Declare @FileDescriptor int  
Declare @CommonString as varchar(1024)   
  
exec sp_oacreate 'scripting.filesystemobject', @FSObject OUT  

If @FSObject Is Null 
Begin 
     RaisError('Ошибка создания объекта файловой системы - scripting.filesystemobject', 16, 1) 
     Return 16 
End 
  
exec sp_oamethod @FSObject, 'folderexists', @FSOResult OUT, @Path   

If @FSOResult <> 1 Or @FSOResult Is Null 
Begin 
     RaisError('Указанный путь экспорта не существует', 16, 1) 
     Return 16 
End 
  
Set @Path = (CASE When SUBSTRING(@Path, LEN(@Path), 1) = '\' Then @Path Else @Path + '\' End)  
  
Set @LastSuccessRunDate = (Select MAX(StartDate) 
                           From dbo.BGTaskHistory   
                           Where     TaskName = 'RUS_UtilityExportChangedCOs_SSD' 
                                 And CompletionStatus = 0  
                          )   
  
Set @LastSuccessRunDate = IsNull(@LastSuccessRunDate, '19000101')   
  
Declare CoNum_cur Cursor For Select DISTINCT co_num   
                                    From dbo.coitem   
                                    Where RecordDate > @LastSuccessRunDate   
  
Open CoNum_cur  
Fetch Next From CoNum_cur Into @co_num   
While @@FETCH_STATUS = 0  
Begin  
     Set @FSOResult = 1   
  
     While @FSOResult = 1 -- create unique filename  
     Begin   
          Set @Now = GetDate()   
          Set @FileName =   @Path     
                          + (CASE When LEN(CAST(DatePart(Hour, @Now) as varchar(2))) = 2 Then '' Else '0' End) + CAST(DatePart(Hour, @Now) as varchar(2))   
                          + (CASE When LEN(CAST(DatePart(Minute, @Now) as varchar(2))) = 2 Then '' Else '0' End) + CAST(DatePart(Minute, @Now) as varchar(2))   
                          + (CASE When LEN(CAST(DatePart(Second, @Now) as varchar(2))) = 2 Then '' Else '0' End) + CAST(DatePart(Second, @Now) as varchar(2))   
                          + SUBSTRING(CAST(DatePart(Millisecond, @Now) as varchar(3)), 1, 2)   
                          + '.txt'  
  
          exec sp_oamethod @FSObject, 'fileexists', @FSOResult OUT, @FileName   
     End  
  
     exec sp_oamethod @FSObject, 'createtextfile', @FileDescriptor OUT, @FileName   

     If @FileDescriptor Is Null 
     Begin 
          RaisError('Возникла ошибка при создании файла', 16, 1) 
          Return 16 
     End 
  
     exec sp_oamethod @FSObject, 'opentextfile', @FSOResult OUT, @FileName, 8, True, 0 -- open for append  

     Declare CoItem_cur Cursor For Select  co.order_date   
                                          ,coi.item   
                                          ,coi.due_date   
                                          ,coi.stat   
                                          ,coi.Uf_stat2   
                                          ,coi.qty_ordered   
                                          ,coi.Uf_upak   
                                          ,coi.Uf_txt   
                                          ,co.cust_num 
                                          ,coi.co_line 
                                          ,coi.Uf_izgot 
                                   From dbo.coitem as coi   
                                   join dbo.co On co.co_num = coi.co_num   
                                   Where co.co_num = @co_num   
                                   Order By coi.co_line 
  
     Open CoItem_cur  
     Fetch Next From CoItem_cur Into  @order_date  
                                     ,@item  
                                     ,@due_date  
                                     ,@stat  
                                     ,@Uf_stat2  
                                     ,@qty_ordered  
                                     ,@Uf_upak  
                                     ,@Uf_txt   
                                     ,@cust_num 
                                     ,@co_line 
                                     ,@Uf_izgot 
     While @@FETCH_STATUS = 0  
     Begin  
  
          Set @stat_ext = (CASE @stat   
                                When 'P' Then 'Запланир.'   
                                When 'O' Then 'Заказан.'   
                                When 'F' Then 'Выполнено'   
                                When 'C' Then 'Завершено'   
                                When 'Q' Then 'Квота'   
                                When 'W' Then 'В работе'   
                                When 'H' Then 'Архив'   
                           End  
                          )   

          If @Uf_stat2 Is Not Null 
               Set @stat2_ext = (CASE @Uf_stat2    
                                      When 'O' Then 'Заказано'   
                                      When 'Z' Then 'Цех'   
                                      When 'S' Then 'Склад' 
                                 End  
                                )   
          Else 
               Set @stat2_ext = '' 

          Set @Uf_txt = IsNull(@uf_txt, '')  
          Set @Uf_upak = IsNull(@Uf_upak, 0)   
  
          Set @CommonString = ''  
  
          Set @CommonString =  dbo.RUS_StringANSItoOEM(@co_num) + @Delimiter   
                             + CAST(@co_line as varchar(6)) + @Delimiter   
                             + dbo.RUS_StringANSItoOEM(@cust_num) + @Delimiter   
                             + CONVERT(varchar(10), @order_date, 104) + @Delimiter   
                             + dbo.RUS_StringANSItoOEM(@item) + @Delimiter   
                             + CONVERT(varchar(10), @due_date, 104) + @Delimiter   
                             + dbo.RUS_StringANSItoOEM(@stat_ext) + @Delimiter   
--                             + dbo.RUS_StringANSItoOEM(@stat2_ext) + @Delimiter   
                             + CAST(@qty_ordered as varchar(19)) + @Delimiter   
                             + IsNull(CAST(@Uf_upak as varchar(19)), '') + @Delimiter   
                             + dbo.RUS_StringANSItoOEM(@Uf_txt) + @Delimiter 
                             + IsNull(CAST(@Uf_izgot as varchar(19)), '') 
  
          exec @FSOResult = sp_oamethod @FileDescriptor, 'writeline', NULL, @CommonString  
       
          Fetch Next From CoItem_cur Into @order_date  
                                         ,@item  
                                         ,@due_date  
                                         ,@stat  
                                         ,@Uf_stat2  
                                         ,@qty_ordered  
                                         ,@Uf_upak  
                                         ,@Uf_txt  
                                         ,@cust_num 
                                         ,@co_line 
                                         ,@Uf_izgot 
     End  
     Close CoItem_cur  
     Deallocate CoItem_cur  
  
     exec @FSOResult = sp_oamethod @FileDescriptor, 'close'  
       
     Fetch Next From CoNum_cur Into @co_num  
End  
Close CoNum_cur  
Deallocate CoNum_cur  
  
exec sp_oadestroy 'scripting.filesystemobject', @FSObject OUT  
  
End   
  
GO