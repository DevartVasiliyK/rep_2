SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[U-44-spaces, comments, case/normal]
AS
 Select dname,loc,ename froM ([U-44-DEPT] fuLL JOin [u-44-EMP] On /*comment*/(dname = ename)); -- comment
GO