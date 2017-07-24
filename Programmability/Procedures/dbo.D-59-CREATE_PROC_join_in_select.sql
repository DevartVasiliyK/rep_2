SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[D-59-CREATE_PROC_join_in_select]
FOR REPLICATION
AS 
BEGIN
select * from [D-59-CREATE_PROC7]as t7
inner join [D-59-CREATE_PROC8]as t8 on t7.col1=t8.col2
where t7.col3>34 and t8.col3<5
END;
GO