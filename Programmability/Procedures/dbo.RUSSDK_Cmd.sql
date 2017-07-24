SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[RUSSDK_Cmd]
   @CentralSrv nvarchar(500),
   @Cmd varchar(100) = 'GET',
   @Save bit = 0
AS BEGIN
   set xact_abort on    -- to use linked servers

   set @CentralSrv = isnull(@CentralSrv, '')
   if @CentralSrv <> '' set @CentralSrv = @CentralSrv + '.'

   -- Declare temp-tables
   create table #RUSSDK_Central (
	   [DateStamp] [datetime],
   	[UserID] [nvarchar] (100),
   	[DBType] [char] (10),
   	[ObjectType] [varchar] (50),
   	[ObjectName] [nvarchar] (300),
   	[FileName] [nvarchar] (1000),
   	[TaskID] [uniqueidentifier],
   	[InWorkflow] [bit] DEFAULT (0),
   	[NoteExistsFlag] [bit] DEFAULT (0),
   	[RecordDate] [datetime] DEFAULT (getdate()),
   	[RowPointer] [uniqueidentifier] DEFAULT (newid()),
   	[CreatedBy] [nvarchar] (256) DEFAULT (suser_sname()),
   	[UpdatedBy] [nvarchar] (256) DEFAULT (suser_sname()),
   	[CreateDate] [datetime] DEFAULT (getdate()),
   	[Action] [varchar] (50),
   	[PatchNum] [varchar] (10),
   	[Spec] [nvarchar] (50),
   	[Seq] [int],
   	[TransID] [uniqueidentifier])

   create table #ttStat (
      [Stat] varchar(300),
	   [DateStamp] [datetime],
   	[UserID] [nvarchar] (100),
   	[DBType] [char] (10),
   	[ObjectType] [varchar] (50),
   	[ObjectName] [nvarchar] (300),
   	[FileName] [nvarchar] (1000),
   	[TaskID] [uniqueidentifier],
   	[InWorkflow] [bit] DEFAULT (0),
   	[NoteExistsFlag] [bit] DEFAULT (0),
   	[RecordDate] [datetime] DEFAULT (getdate()),
   	[RowPointer] [uniqueidentifier] DEFAULT (newid()),
   	[CreatedBy] [nvarchar] (256) DEFAULT (suser_sname()),
   	[UpdatedBy] [nvarchar] (256) DEFAULT (suser_sname()),
   	[CreateDate] [datetime] DEFAULT (getdate()),
   	[Action] [varchar] (50),
   	[PatchNum] [varchar] (10),
   	[Spec] [nvarchar] (50),
   	[Seq] [int],
   	[TransID] [uniqueidentifier])

   create table #ttObjs (
      [crp] uniqueidentifier,
      [lrp] uniqueidentifier,
	   [DateStamp] [datetime],
   	[UserID] [nvarchar] (100),
   	[DBType] [char] (10),
   	[ObjectType] [varchar] (50),
   	[ObjectName] [nvarchar] (300),
   	[FileName] [nvarchar] (1000),
   	[TaskID] [uniqueidentifier],
   	[InWorkflow] [bit] DEFAULT (0),
   	[NoteExistsFlag] [bit] DEFAULT (0),
   	[RecordDate] [datetime] DEFAULT (getdate()),
   	[RowPointer] [uniqueidentifier] DEFAULT (newid()),
   	[CreatedBy] [nvarchar] (256) DEFAULT (suser_sname()),
   	[UpdatedBy] [nvarchar] (256) DEFAULT (suser_sname()),
   	[CreateDate] [datetime] DEFAULT (getdate()),
   	[Action] [varchar] (50),
   	[PatchNum] [varchar] (10),
   	[Spec] [nvarchar] (50),
   	[Seq] [int],
   	[TransID] [uniqueidentifier])

   declare @block nvarchar(500), @chkdate datetime
   select @chkdate = getdate()
   EXEC dbo.RUSSDKCheckBlock @CentralSrv, @chkdate, @block output

   -- @block is null       --> no block
   -- @block is blank      --> my block already set
   -- @block is non-blank  --> blocked by other user

   if isnull(@block, '') = '' begin

      EXEC dbo.RUSSDKViewChanges

      begin tran RUSSDKCMD

      if @Cmd = 'GET'
         EXEC dbo.RUSSDKGetNew @CentralSrv, @block
      else
      if @Cmd = 'PUT'
         EXEC dbo.RUSSDKCommit @CentralSrv, @block

      if @Save = 1
         commit tran RUSSDKCMD
      else
         rollback tran RUSSDKCMD

   end
   else if @block <> ''
      insert #ttStat (Stat, FileName) values ('ERROR', @block)

   select * from #ttStat
END

GO