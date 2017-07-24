SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- D-59-COMMENT_BEFORE_CREATE_PRC__NONE_COMMENT prints error information about the error that caused 
-- execution to jump to the CATCH block of a TRY...CATCH construct. 
-- Should be executed from within the scope of a CATCH block otherwise 
-- it will return without printing any error information.
CREATE PROCEDURE [dbo].[D-59-COMMENT_BEFORE_CREATE_PRC__NONE_COMMENT] 
AS
BEGIN
 SET NOCOUNT ON;

 -- Print error information. 
 PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
 ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
 ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
 ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
 ', Line ' + CONVERT(varchar(5), ERROR_LINE());
 PRINT ERROR_MESSAGE();
END;
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Prints error information about the error that caused execution to jump to the CATCH block of a TRY...CATCH construct. Should be executed from within the scope of a CATCH block otherwise it will return without printing any error information.', 'SCHEMA', N'dbo', 'PROCEDURE', N'D-59-COMMENT_BEFORE_CREATE_PRC__NONE_COMMENT'
GO