﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[only_in_target]
AS
SELECT * FROM table1 t
GO