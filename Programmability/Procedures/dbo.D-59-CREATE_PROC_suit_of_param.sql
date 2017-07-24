SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[D-59-CREATE_PROC_suit_of_param]
with exec as CALLER,encryption
FOR REPLICATION
AS 
BEGIN
select * from [D-59-CREATE_PROC9]as t9
inner join [D-59-CREATE_PROC10]as t10 on t9.col1=t10.col2
where t9.col2 like '_1%2_';
END;
GO