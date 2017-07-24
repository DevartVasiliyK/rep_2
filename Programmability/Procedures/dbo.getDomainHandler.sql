SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getDomainHandler](@Hostname nvarchar(255))
AS SELECT     dbo.DomainHandler.*
FROM         dbo.DomainHandler
WHERE     (Hostname = @Hostname)

GO