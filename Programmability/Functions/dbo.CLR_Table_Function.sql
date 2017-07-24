SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[CLR_Table_Function] (@servername [nvarchar](128),
@username [nvarchar](128),
@pwd [nvarchar](128),
@sql_stmt [nvarchar](4000))
RETURNS TABLE (
  [empno] [decimal] NULL,
  [ename] [nvarchar](10) NULL,
  [job] [nvarchar](9) NULL,
  [mgr] [decimal] NULL,
  [hiredate] [datetime] NULL,
  [sal] [decimal] NULL,
  [comm] [decimal] NULL,
  [deptno] [decimal] NULL
)
AS
EXTERNAL NAME [OracleTVF].[Microsoft.Samples.SqlServer.OracleSample].[GetDataFromOracle]
GO