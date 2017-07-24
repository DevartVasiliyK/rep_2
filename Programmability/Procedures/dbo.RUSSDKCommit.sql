SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[RUSSDKCommit]
   @CentralSrv nvarchar(500),
   @block nvarchar(500)
AS BEGIN
   if exists (select 1 from #ttStat) and
      not exists (select 1 from #ttStat where stat <> 'Local')
   begin
      declare @sid uniqueidentifier, @sun nvarchar(4000)
      set @sid = newid()
      set @sun = suser_sname()

      insert dbo.RUSSDK_Trans (TransID, DBType, ObjectType, ObjectName, UserID, DateStamp)
      values (@sid, '', 'RUSSDKSync', 'COMMIT', @sun, getdate())

      update s set s.TransID = newid()
         from #ttStat s
         join #RUSSDK_Central c on c.TransID = s.TransID

      update l set l.TransID = s.TransID
      from #ttStat s
      join dbo.RUSSDK_Trans l on l.Seq = s.Seq

      EXEC('insert ' + @CentralSrv + 'dbo.RUSSDK_Trans ([DateStamp], [UserID], [DBType], [ObjectType], [ObjectName], [FileName], [TaskID], [InWorkflow], [NoteExistsFlag], [RecordDate], [RowPointer], [CreatedBy], [UpdatedBy], [CreateDate], [Action], [PatchNum], [Spec], [TransID])'
         + '    select [DateStamp], ''' + @sun + ''', [DBType], [ObjectType], [ObjectName], [FileName], [TaskID], [InWorkflow], [NoteExistsFlag], [RecordDate], newid(), [CreatedBy], [UpdatedBy], [CreateDate], [Action], [PatchNum], [Spec], [TransID]'
         + '    from #ttStat order by Stat, Seq'
         + ' insert ' + @CentralSrv + 'dbo.RUSSDK_Trans (TransID, DBType, ObjectType, ObjectName, UserID, DateStamp)'
         + '    values (''' + @sid + ''', '''', ''RUSSDKSync'', ''COMMIT'', ''' + @sun + ''', getdate())')
   end
END

GO