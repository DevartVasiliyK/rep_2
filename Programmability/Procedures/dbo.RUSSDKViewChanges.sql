SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[RUSSDKViewChanges]
AS BEGIN
   declare @lseq int, @cseq int

   select @lseq = 0, @cseq = 0

   select top 1
      @lseq = l.Seq, @cseq = c.Seq
      from dbo.RUSSDK_Trans l
      join #RUSSDK_Central c on c.TransID = l.TransID
      where
         c.DBType = '' and c.ObjectType = 'RUSSDKSync' and
         l.DBType = '' and l.ObjectType = 'RUSSDKSync'
      order by c.Seq desc

   -- Compare updates
   delete from #ttObjs

   insert #ttObjs
   select null, null, *
      from #RUSSDK_Central
      where Seq > @cseq and
         not (DBType = '' and ObjectType = 'RUSSDKSync')
      union
      select null, null, *
      from dbo.RUSSDK_Trans
      where Seq > @lseq and
         not (DBType = '' and ObjectType = 'RUSSDKSync')

   update o
      set o.crp = c.TransID
      from #ttObjs o
      join #RUSSDK_Central c on
         c.Seq = (select top 1 log.Seq
            from #RUSSDK_Central log
            where log.Seq > @cseq            and
               log.DBType     = o.DBType     and
               log.ObjectType = o.ObjectType and
               log.ObjectName = o.ObjectName
            order by log.Seq desc)

   update o
   set o.lrp = l.TransID
   from #ttObjs o
   join dbo.RUSSDK_Trans l on
      l.Seq = (select top 1 log.Seq
         from dbo.RUSSDK_Trans log
         where log.Seq > @lseq            and
            log.DBType     = o.DBType     and
            log.ObjectType = o.ObjectType and
            log.ObjectName = o.ObjectName
         order by log.Seq desc)

   -- Eliminate equivalent changes
   delete from #ttObjs where crp = lrp

   -- Eliminate duplicate Objects
   delete o
   from #ttObjs o
   join #ttObjs s on
      s.DBType     = o.DBType     and
      s.ObjectType = o.ObjectType and
      s.ObjectName = o.ObjectName and
      s.Seq < o.Seq


   delete from #ttStat

   insert #ttStat
   select 'FromCentral' as 'Stat', log.*
      from #ttObjs o
      join #RUSSDK_Central log on
         log.DBType     = o.DBType     and
         log.ObjectType = o.ObjectType and
         log.ObjectName = o.ObjectName and
         log.Seq > @cseq
      where o.lrp is null
   UNION ALL
   select 'Local', log.*
      from #ttObjs o
      join dbo.RUSSDK_Trans log on
         log.DBType     = o.DBType     and
         log.ObjectType = o.ObjectType and
         log.ObjectName = o.ObjectName and
         log.Seq > @lseq
      where o.crp is null
   UNION ALL
   select 'Merge', log.*
      from #ttObjs o
      join #RUSSDK_Central log on
         log.DBType     = o.DBType     and
         log.ObjectType = o.ObjectType and
         log.ObjectName = o.ObjectName and
         log.Seq > @cseq
      where o.crp is not null and o.lrp is not null
END


GO