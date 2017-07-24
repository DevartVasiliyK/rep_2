SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Load_setuprgid]
AS



UPDATE jrt_sch
SET jrt_sch.setuprgid = jrtresourcegroup.rgid
FROM jrt_sch 
INNER JOIN jrtresourcegroup ON 
jrt_sch.job = jrtresourcegroup.job AND 
jrt_sch.suffix = jrtresourcegroup.suffix AND 
jrt_sch.oper_num = jrtresourcegroup.oper_num 
INNER JOIN RGRP000 ON 
jrtresourcegroup.rgid = RGRP000.RGID AND 
jrt_sch.sched_drv = RGRP000.SLTYPE
GO