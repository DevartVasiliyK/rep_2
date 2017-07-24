SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CLR_Procedure]
AS EXTERNAL NAME [CLR_For_StoredProcedure].[Clr_for_trigg_DDL.DDLTrig.namespace.Sql].[GetEnvironmentVars]
GO