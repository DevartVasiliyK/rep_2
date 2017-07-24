SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[RUSXDECheckDirsSp]
as

declare
  @f_mask   varchar(50)
, @cmd_line nvarchar(1000)
, @PointID  RUSXDEPointIDType
, @OSDir    RUSXDEOSDirType
, @SoftID   RUSXDESoftIDType

create table #tt (f_name nvarchar(100))

set @f_mask = '.xml'

DECLARE PointsCrs CURSOR LOCAL STATIC FOR
SELECT
  PointID
, OSDir
, SoftID
FROM RUSXDEPoint
WHERE Type = 1 and --Import
      Active = 1

OPEN PointsCrs
WHILE 0 = 0
BEGIN
   FETCH PointsCrs INTO
     @PointID
   , @OSDir
   , @SoftID
   IF @@FETCH_STATUS <> 0 BREAK

   IF isnull(@OSDir,'') = '' CONTINUE

   IF substring(@OSDir,len(@OSDir),1) <> '\'
      set @OSDir = @OSDir + '\'

   set @cmd_line = 'dir "' + @OSDir + '*_' + @PointID + @f_mask + '" /B /N'
--   set @cmd_line = 'dir "' + @OSDir + '*' + @f_mask + '" /B /N'
   insert into #tt
   exec master..xp_cmdshell @cmd_line

   insert into RUSXDEQue (PointID, Cmd, FileMask)
   select @PointID, 'Import', f_name
   from #tt
   where charindex(@f_mask, isnull(f_name,'')) > 0 and
   not exists(select 1 from RUSXDEQue q2 where q2.PointID = @PointID and
                                               q2.FileMask = f_name and 
                                               q2.Status = 'Queued')

   delete from #tt
END
CLOSE      PointsCrs
DEALLOCATE PointsCrs

drop table #tt


GO