SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create Procedure [dbo].[RUS_CreateItemWhseLocAssociationsSp_SSD] 
( 
  @RetErr        nvarchar(2800) OUTPUT 
 ,@ProcExecState bit            OUTPUT 
 ,@LogFlag       bit = 0 
 ,@LogFile       varchar(255) = 'C:\RUSXDE_MiscIssueSp_SSD.txt' 
) 
As 
Begin 

     Declare @whse           WhseType 
     Declare @item           ItemType 
     Declare @loc            LocType 
     Declare @perm_flag      ListYesNoType 

     Declare @Severity       int 
     Declare @Infobar        InfobarType 
     Declare @RowPointer     RowPointerType 

     exec dbo.DefineVariableSp 'MessageLanguage' 
                              ,'1049' 
                              ,@Infobar OUTPUT 

     Declare mi_cur Cursor For Select  ws.whse 
                                      ,itm.item 
                                      ,loc.loc 
                                      ,(CASE When mi.perm_flag <> 1 Then 0 Else 1 End) 
                                      From #RUSXDE_MiscIssue as mi 
                                      join dbo.whse            as ws  On LTRIM(RTRIM(ws.whse))  = LTRIM(RTRIM(mi.whse)) 
                                      join dbo.item            as itm On LTRIM(RTRIM(itm.item)) = LTRIM(RTRIM(mi.item)) 
                                      join dbo.location        as loc On LTRIM(RTRIM(loc.loc))  = LTRIM(RTRIM(mi.loc)) 
   
     Open mi_cur 
  
     Fetch Next From mi_cur Into  @whse 
                                 ,@item 
                                 ,@loc 
                                 ,@perm_flag 

     While     @@FETCH_STATUS = 0 
     Begin  

          Set @RetErr =   'Изделие: ' + IsNull(@item, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Склад: ' + IsNull(@whse, '') 
                         + CHAR(13) + CHAR(10) 
                         + 'Место складирования: ' + IsNull(@loc, '') 

          If Not Exists (Select * 
                         From dbo.itemwhse 
                         Where     item = @item 
                               And whse = @whse 
                         ) 
               Insert Into dbo.itemwhse 
               ( 
                item 
               ,whse 
               ) 
               Select  @item 
                      ,@whse 

          If Not Exists (Select * 
                         From dbo.itemloc 
                         Where     whse = @whse 
                               And item = @item 
                               And loc  = @loc 
                        ) 
               Begin 

                    exec @Severity = dbo.ItemLocAddSp  @Whse        = @whse
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

               End

          Fetch Next From mi_cur Into  @whse 
                                      ,@item 
                                      ,@loc 
                                      ,@perm_flag 
  
     End 
     Close mi_cur 
     Deallocate mi_cur 

     If @Severity <> 0 
          Set @RetErr = @RetErr + CHAR(13) + CHAR(10) + @Infobar 

     exec dbo.UndefineVariableSp 'MessageLanguage' 
                                ,@Infobar OUTPUT 

     Set @ProcExecState = 1 -- procedure completed 

End 
GO