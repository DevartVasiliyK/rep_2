SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[RUSSDK_RptTaskSp]
  @PatchNum varchar(20) = null
, @Spec varchar(20)     = null
AS

DECLARE 
  @SpecDescription DescriptionType
  
SELECT
  @SpecDescription = Description
FROM UserDefinedTypeValues
WHERE TypeName = 'RUSSDKSpec' AND
      Value = isnull(@Spec,'')
  
SELECT
  1 type
, t.RowPointer
, t.Description
, t.CRM
, t.SLModule
, tr.DBType
, tr.ObjectType
, tr.ObjectName
INTO #tt_rpt
FROM RUSSDK_Tasks t join RUSSDK_Trans tr on t.RowPointer = tr.TaskID
                                        and tr.PatchNum = isnull(@PatchNum, tr.PatchNum)
                                        and isnull(tr.Spec,'') in ('',isnull(@Spec,''))  
WHERE isnull(t.IncludeDesc,0) = 1

-- List of Modified Forms
DECLARE 
  @tSql nvarchar(3000)
, @FormsServer nvarchar(300)
, @FormsDb nvarchar(300)

SELECT
  @FormsServer = Forms_Server
, @FormsDb = Forms_DB
FROM RUSSDK_Configs
WHERE Name = isnull(@Spec,'MAIN')
  
SET @tSql ='
INSERT INTO #tt_rpt (type, RowPointer, ObjectName, Description)
SELECT distinct
  2
, ''00000000-0000-0000-0000-0000000000000000''
, tr.ObjectName
, r.string
FROM RUSSDK_Tasks t join RUSSDK_Trans tr on t.RowPointer = tr.TaskID
                                        and isnull(tr.PatchNum,'''') = ''{&PATCH_NUM}''
                                        and isnull(tr.Spec,'''') in ('''',''{&SPEC}'')
                    left outer join [{&DB_SRV}].[{&DB_NAME}].dbo.forms f on tr.ObjectName = f.name 
                    left outer join [{&DB_SRV}].[{&DB_NAME}].dbo.russianstrings r on r.name = f.caption
WHERE isnull(t.IncludeDesc,0) = 1 AND
      tr.DBType = ''F'' AND
      tr.ObjectType = ''Frm''

-- List of Modified Reports
INSERT INTO #tt_rpt (type, RowPointer, ObjectName, Description)
SELECT distinct
  3
, ''00000000-0000-0000-0000-0000000000000000''
, tr.ObjectName
, r.string
FROM RUSSDK_Tasks t join RUSSDK_Trans tr on t.RowPointer = tr.TaskID
                                        and isnull(tr.PatchNum,'''') = ''{&PATCH_NUM}''
                                        and isnull(tr.Spec,'''') in ('''',''{&SPEC}'')
         left outer join BGTaskDefinitions b on b.TaskExecutable + ''.rpt'' = tr.ObjectName
         left outer join [{&DB_SRV}].[{&DB_NAME}].dbo.russianstrings r on r.name like ''%'' + b.TaskName
WHERE isnull(t.IncludeDesc,0) = 1 AND
      tr.DBType = ''R'' AND
      tr.ObjectType = ''Rpt''
'
      
SET @tSql = REPLACE (@tSql,'{&PATCH_NUM}', isnull(@PatchNum,''))
SET @tSql = REPLACE (@tSql,'{&SPEC}', isnull(@Spec,''))
IF SERVERPROPERTY('ServerName') = @FormsServer
  SET @tSql = REPLACE (@tSql,'[{&DB_SRV}].', '')
ELSE
  SET @tSql = REPLACE (@tSql,'{&DB_SRV}', @FormsServer)

SET @tSql = REPLACE (@tSql,'{&DB_NAME}', @FormsDb)
      
--print @tSql     
exec (@tSql)

      
                                     
select @SpecDescription as SpecDescription, * from #tt_rpt
order by type 

drop table #tt_rpt

GO