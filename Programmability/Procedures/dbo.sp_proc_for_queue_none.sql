SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_proc_for_queue_none]
AS
SELECT * FROM f_for_proc_none(0);
SELECT * FROM snm_for_proc_none;
EXEC dbo.sp_proc_for_proc_none;
GO