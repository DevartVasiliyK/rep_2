SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[RUS_DiagnosticInTXTSp]   
(  
 @ParamToSave nvarchar(1512)   
,@LogFile     varchar(255)   
,@AppendFlag  int    
)   
As   
Begin   
  
     Declare @cmd as varchar(512)   
     Declare @CurTimeStr as varchar(50) 

     Set @CurTimeStr = CONVERT(varchar(30), GetDate(), 104) + ' ' + LEFT(CONVERT(varchar(50), GetDate(), 114), 12)
  
     If @AppendFlag = 2   
     Begin  
          Set @cmd = 'exec master.dbo.xp_cmdshell ' + '''' + 'del ' + @LogFile + '''' + ', NO_OUTPUT'  
          exec (@cmd)   
     End   
  
     Set @cmd = 'exec master.dbo.xp_cmdshell ' + '''' + 'Echo ' + @CurTimeStr + ' ' + @ParamToSave  
  
     If @AppendFlag = 1   
          Set @cmd = @cmd + ' >> '   
  
     If @AppendFlag = 0   
          Set @cmd = @cmd + ' > '  
  
     Set @cmd = @cmd + @LogFile + '''' + ', NO_OUTPUT'   
  
     If @AppendFlag <= 1   
          exec (@cmd)   
  
End
GO