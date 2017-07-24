SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create Procedure [dbo].[RUSXDE_Rpt17Sp_SSD] 
-- ( 
--  @Delimiter char(1) 
-- ,@Path      varchar(255) 
-- )  
As 
Begin   
  
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
Declare @stat2_ext          varchar(8)  
Declare @Uf_jobssdqtyord    QtyUnitNoNegType  

Declare @LastSuccessRunDate datetime 
Declare @Now datetime 
Declare @CommonString as varchar(1024) 
  
Set @LastSuccessRunDate = IsNull((Select MAX(RecordDate) 
                                  From dbo.RUSXDEQue 
                                  Where     Cmd                  = 'Export' 
                                         And PointID              = 'RUSXDE_CO_Export_SSD' 
                                         And IsNull(Response, '') = '' 
                                         And Status               = 'Done' 
                                  )  
                                  , '19000101' 
                                 ) 

Create Table #Out 
( 
 co_num          nvarchar(10)
,co_line         smallint
,cust_num        nvarchar(7)
,order_date      varchar(10)
,item            nvarchar(30)
,due_date        varchar(10)
,stat_ext        varchar(64) 
,qty_ordered     decimal(19,8) 
,Uf_upak         decimal(19,8) 
,Uf_txt          varchar(60) 
,Uf_jobssdqtyord decimal(19,8) 
,Uf_stat2        varchar(8) 
) 
  
Declare CoNum_cur Cursor For Select DISTINCT co_num   
                                    From dbo.coitem   
                                    Where RecordDate > @LastSuccessRunDate   

Open CoNum_cur  
Fetch Next From CoNum_cur Into @co_num   
While @@FETCH_STATUS = 0  
Begin  

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
                                          ,coi.Uf_jobssdqtyord 
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
                                     ,@Uf_jobssdqtyord 
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

          Set @stat2_ext = (CASE @Uf_stat2    
                                 When 'O' Then 'Заказано'   
                                 When 'Z' Then 'Цех'   
                                 When 'S' Then 'Склад' 
                            End  
                           )   

          Set @Uf_txt = IsNull(@uf_txt, '')  
          Set @Uf_upak = IsNull(@Uf_upak, 0)   
  
          Insert Into #Out 
          Select 
           @co_num 
          ,@co_line 
          ,@cust_num 
          ,CONVERT(varchar(10), @order_date, 104) 
          ,@item 
          ,CONVERT(varchar(10), @due_date, 104) 
          ,@stat_ext 
          ,@qty_ordered 
          ,@Uf_upak 
          ,@Uf_txt 
          ,@Uf_jobssdqtyord 
          ,@Uf_stat2 
  
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
                                         ,@Uf_jobssdqtyord 
     End  
     Close CoItem_cur  
     Deallocate CoItem_cur  

     Fetch Next From CoNum_cur Into @co_num  
End  
Close CoNum_cur  
Deallocate CoNum_cur  

If Not Exists (Select * From #Out) 
Begin 
     Drop Table #Out 
     RaisError('Со времени последней успешной выгрузки не появилось измененных строк ЗК', 16, 1) 
     Return 16 
End 

Select * 
From #Out as line 
For XML Auto 

Drop Table #Out 
  
End   
GO