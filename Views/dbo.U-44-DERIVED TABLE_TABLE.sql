﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[U-44-DERIVED TABLE/TABLE]
AS
 SELECT * FROM (SELECT * FROM [U-44-DEPT]) as t;
GO