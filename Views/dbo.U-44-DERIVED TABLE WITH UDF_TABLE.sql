﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[U-44-DERIVED TABLE WITH UDF/TABLE]
AS
 SELECT * FROM (SELECT * FROM (SELECT * FROM[U-44-UDF]() as t1) as t2) as t3;
GO