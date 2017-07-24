SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create Procedure [dbo].[RUSXDE_Rpt17PrepSp_SSD] 
( 
-- @Delimiter char(1) 
--,@Path      varchar(255) 
@OutMsg    varchar(255) OUTPUT 
)  
As 
Begin 
     Declare @ParamStr  nvarchar(3000) 

     Set @OutMsg = Null 

--      Declare @FSObject  int 
--      Declare @FSOResult int 
--  
--      exec sp_oacreate 'scripting.filesystemobject', @FSObject OUT  
-- 
--      If @FSObject Is Null 
--           Set @OutMsg = 'Ошибка создания объекта файловой системы - scripting.filesystemobject, задача не поставлена в очередь XDE' 

--      If @OutMsg Is Null 
--      Begin 
--           exec sp_oamethod @FSObject, 'folderexists', @FSOResult OUT, @Path 
-- 
--           If @FSOResult <> 1 Or @FSOResult Is Null 
--                Set @OutMsg = 'Указанный путь экспорта не существует, задача не поставлена в очередь XDE' 
--      End 

--      If @OutMsg Is Null 
--      Begin 
--           Set @Path = (CASE When SUBSTRING(@Path, LEN(@Path), 1) = '\' Then @Path Else @Path + '\' End)  

--      Set @ParamStr = '''' + @Delimiter + '''' + ', ' + '''' + @Path + ''''
     Set @ParamStr = ''

     exec dbo.RUSXDEPutToQueue1Sp 'RUSXDE_Rpt17Sp_SSD', @ParamStr, 'C', '[UNSPECIFIED]' -- XDE Queue

     Set @OutMsg = 'Success' 

--      End 
-- 
--      exec sp_oadestroy 'scripting.filesystemobject', @FSObject OUT  

End 
GO