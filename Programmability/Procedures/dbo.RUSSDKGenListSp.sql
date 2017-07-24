SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[RUSSDKGenListSp](
  @TaskID uniqueidentifier
, @ListType varchar(20)
, @DBType char(10)
, @ObjectType varchar(50) = null
, @ObjectName nvarchar(300) = null
)
AS

DECLARE 
  @Description DescriptionType
, @ConnStr nvarchar(3000)
, @tsql nvarchar(3000)
, @Forms_Server   OSLocationType
, @Forms_DB       OSLocationType
, @Forms_Login    UsernameType
, @Forms_Password EncryptedPasswordType
, @cmd_line nvarchar(3000)
, @RptDir nvarchar(500)

SELECT 
  @Forms_Server = Forms_Server
, @Forms_DB     = Forms_DB
, @Forms_Login  = Forms_Login
, @Forms_Password = Forms_Password
FROM RUSSDK_Tasks t join RUSSDK_Configs c on t.ConfigName = c.Name
WHERE t.RowPointer = @TaskID

 
--set @Forms_Server = 'mike-p4'
--set @Forms_DB     = 'SL70308_Forms'
--set @Forms_Login  = 'sa'
--set @Forms_Password = ''

--SET @ConnStr = 'Data Source=' + isnull(@Forms_Server,'') + ';User ID=' + isnull(@Forms_Login,'sa') 
--+ ';Password=' + isnull(@Forms_Password,'')

if @Forms_Server is not null and 
   @Forms_Server <> SERVERPROPERTY('ServerName') and
   not exists (select * from master.dbo.sysservers where srvname = @Forms_Server)
   EXEC sp_addlinkedserver 
     @Forms_Server,
     N'SQL Server'
     
SELECT
  @ObjectName ObjectName
, @Description Description
INTO #RUSSDK_tt
WHERE 1=2
--DECLARE #RUSSDK_tt table (ObjectName nvarchar(300), Description nvarchar(80)) 

IF @ListType = 'ObjectType' BEGIN
  IF @DBType = 'A' BEGIN
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('P','Stored Proc')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('TR','Trigger')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('FN','Function')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('U','Table')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('C','Table Column')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('I','Table Index')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('V','View')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('UDDT','User Defined Type')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('TXT','Data update Script')     
  END
  IF @DBType = 'F' BEGIN
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('Frm','Form')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('Scr','Global Script')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('Vld','Validator')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('Cls','Component Class/Property Ext')
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('TXT','Data update Script')
  END
  IF @DBType = 'R' BEGIN
     INSERT INTO #RUSSDK_tt (ObjectName, Description) VALUES ('Rpt','Crystal Report')
  END  
END

IF @ListType = 'ObjectName' BEGIN
  IF @DBType = 'A' BEGIN
     IF @ObjectType IN ('P','TR','FN','U','V')
       INSERT INTO #RUSSDK_tt (ObjectName)
       SELECT name from sysobjects WHERE xtype = isnull(@ObjectType,'')
       
     IF @ObjectType = 'UDDT' 
       INSERT INTO #RUSSDK_tt (ObjectName)
       SELECT name from systypes         
     
     IF @ObjectType = 'I'
       INSERT INTO #RUSSDK_tt (ObjectName)
       SELECT i.name 
       FROM sysobjects o JOIN sysindexes i on o.id = i.id
       WHERE o.name = @ObjectName AND NOT i.name LIKE '_WA_Sys%'
        
     IF @ObjectType = 'C'
       INSERT INTO #RUSSDK_tt (ObjectName)
       SELECT col.name
       FROM syscolumns AS col JOIN sysobjects AS tab
       ON tab.id = col.id
       WHERE tab.type = 'U' AND tab.name = @ObjectName

     IF @ObjectType = 'TXT' BEGIN -- Messages or Data for tables
       INSERT INTO #RUSSDK_tt (ObjectName)
       VALUES('_NewMsg')
       
       INSERT INTO #RUSSDK_tt (ObjectName)
       SELECT name from sysobjects WHERE xtype = 'U' 

     END          
  END
  IF @DBType = 'F' BEGIN
     IF @ObjectType = 'Frm' BEGIN
        SET @tsql = 'INSERT INTO #RUSSDK_tt (ObjectName)
                 SELECT DISTINCT name FROM [' + isnull(@Forms_Server,'') + '].[' + 
                 isnull(@Forms_DB,'') + '].dbo.Forms'      
     END   

     IF @ObjectType = 'Scr' BEGIN
        SET @tsql = 'INSERT INTO #RUSSDK_tt (ObjectName)
                 SELECT DISTINCT name FROM [' + isnull(@Forms_Server,'') + '].[' + 
                 isnull(@Forms_DB,'') + '].dbo.Scripts'                 
     END   
      
     IF @ObjectType = 'Vld' BEGIN
        SET @tsql = 'INSERT INTO #RUSSDK_tt (ObjectName)
                 SELECT DISTINCT name FROM [' + isnull(@Forms_Server,'') + '].[' + 
                 isnull(@Forms_DB,'') + '].dbo.Validators'                 
     END   
     
     IF @ObjectType = 'Cls' BEGIN
        SET @tsql = 'INSERT INTO #RUSSDK_tt (ObjectName, Description)
                 SELECT DISTINCT PropertyName, IsPropertyClassExtension FROM [' + isnull(@Forms_Server,'') + '].[' + 
                 isnull(@Forms_DB,'') + '].dbo.PropertyDefaults'                 
     END        
     
     IF @ObjectType = 'TXT' BEGIN -- Messages or Data for tables
       INSERT INTO #RUSSDK_tt (ObjectName)
       VALUES('_Explorer')
       INSERT INTO #RUSSDK_tt (ObjectName)
       VALUES('_NewStrings')
       INSERT INTO #RUSSDK_tt (ObjectName)
       VALUES('_RussianStrings')
              
     END   

     IF @Forms_Server = SERVERPROPERTY('ServerName')
       SET @tsql = REPLACE (@tsql,'[' + isnull(@Forms_Server,'') + '].','')
    -- print @tsql
     IF NOT @tsql IS NULL
       EXEC (@tsql)
  END
  IF @DBType = 'R' and @ObjectType = 'Rpt' BEGIN
     select 
       @RptDir = tm_path + '\Report\Reports' 
     from intranet
     set @cmd_line = 'dir "' + @RptDir + '" /B /N'
     INSERT INTO #RUSSDK_tt (ObjectName)
     exec master..xp_cmdshell @cmd_line
  END
END


SELECT * FROM #RUSSDK_tt ORDER BY ObjectName

RETURN 0

GO