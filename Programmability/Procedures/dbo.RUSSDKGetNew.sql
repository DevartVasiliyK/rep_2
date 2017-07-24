SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[RUSSDKGetNew]
   @CentralSrv nvarchar(500),
   @block nvarchar(500)
AS BEGIN
   if exists (select 1 from #ttStat) begin
      declare @sid uniqueidentifier, @sun nvarchar(4000)
      set @sid = newid()
      set @sun = suser_sname()

      if @block is null
      EXEC('insert ' + @CentralSrv + 'dbo.RUSSDK_Trans (TransID, DBType, ObjectType, ObjectName, UserID, DateStamp)'
         + ' values (''' + @sid + ''', '''', ''RUSSDKSync'', ''BLOCK'', ''' + @sun + ''', dateadd(mi, 30, getdate()))')

      EXEC(' delete c from ' + @CentralSrv + 'dbo.RUSSDK_Trans c'
         + '   join #RUSSDK_Central tt on tt.TransID = c.TransID'
         + ' insert ' + @CentralSrv + 'dbo.RUSSDK_Trans ([DateStamp], [UserID], [DBType], [ObjectType], [ObjectName], [FileName], [TaskID], [InWorkflow], [NoteExistsFlag], [RecordDate], [RowPointer], [CreatedBy], [UpdatedBy], [CreateDate], [Action], [PatchNum], [Spec], [TransID])'
         + '   select [DateStamp], [UserID], [DBType], [ObjectType], [ObjectName], [FileName], [TaskID], [InWorkflow], [NoteExistsFlag], [RecordDate], newid(), [CreatedBy], [UpdatedBy], [CreateDate], [Action], [PatchNum], [Spec], [TransID]'
         + '   from #RUSSDK_Central')

      if @block is null
      insert dbo.RUSSDK_Trans (TransID, DBType, ObjectType, ObjectName, UserID, DateStamp)
         values (@sid, '', 'RUSSDKSync', 'BLOCK', @sun, dateadd(mi, 30, getdate()))

      insert dbo.RUSSDK_Trans ([DateStamp], [UserID], [DBType], [ObjectType], [ObjectName], [FileName], [TaskID], [InWorkflow], [NoteExistsFlag], [RecordDate], [RowPointer], [CreatedBy], [UpdatedBy], [CreateDate], [Action], [PatchNum], [Spec], [TransID])
         select [DateStamp], @sun, [DBType], [ObjectType], [ObjectName], [FileName], [TaskID], [InWorkflow], [NoteExistsFlag], [RecordDate], newid(), [CreatedBy], [UpdatedBy], [CreateDate], [Action], [PatchNum], [Spec], [TransID]
         from #ttStat
         order by Stat, Seq

      delete l
         from dbo.RUSSDK_Trans l
         join #ttStat s on s.Seq = l.Seq
         where s.Stat = 'Local'
   end

END

GO