SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[RUSSDKCheckBlock]
   @CentralSrv nvarchar(500),
   @chkdate datetime,
   @block nvarchar(500) output
AS BEGIN

   delete from #RUSSDK_Central

   insert #RUSSDK_Central
   EXEC ('declare @cseq int set @cseq = 0'
       + ' select top 1 @cseq = c.seq'
       + '    from ' + @CentralSrv + 'dbo.RUSSDK_Trans c'
       + '    join dbo.RUSSDK_Trans l on l.TransID = c.TransID'
       + '    where c.ObjectType = ''RUSSDKSync'''
       + '    order by c.seq desc'
       + ' select *'
       + '    from ' + @CentralSrv + 'dbo.RUSSDK_Trans'
       + '    where seq >= @cseq'
       + '    order by seq')

   declare @lseq int
   select @lseq = 0, @block = null

   select top 1
      @lseq = l.Seq
      from dbo.RUSSDK_Trans l
      join #RUSSDK_Central c on c.TransID = l.TransID
      order by c.Seq desc

   -- Check BLOCKed state
   select
      @block = (case UserID when suser_sname()
         then ''
         else 'Blocked by ' + UserID
            + ' till ' + rtrim(convert(nvarchar(300), DateStamp, 20)) end)
      from #RUSSDK_Central
      where DBType = '' and
         ObjectType = 'RUSSDKSync' and
         ObjectName = 'BLOCK' and
         DateStamp > @chkdate
END

GO