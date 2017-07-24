SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[U-44-PIVOT/Empty]
AS
 SELECT 'AvCost' AS Cost_Sorted_By_Production_Days, 
[0], [1], [2], [3], [4]
 FROM
(SELECT dname, deptno
 FROM [U-44-DEPT]) AS SourceTable
PIVOT
(
AVG(deptno)
FOR dname IN ([0], [1], [2], [3], [4])
) AS PivotTable;
GO