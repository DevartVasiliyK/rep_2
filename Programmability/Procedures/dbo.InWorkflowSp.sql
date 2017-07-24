SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InWorkflowSp.sp 3     2/21/04 2:04p Cummbry $  */
/*
Copyright © MAPICS, Inc. 2003 - All Rights Reserved

Use, duplication, or disclosure by the Government is subject to restrictions
as set forth in subparagraph (c)(1)(ii) of the Rights in Technical Data and
Computer Software clause at DFARS 252.227-7013, and Rights in Data-General at
FAR 52.227.14, as applicable.

Name of Contractor: MAPICS, Inc., 1000 Windward Concourse Parkway Suite 100,
Alpharetta, GA 30005 USA

Unless customer maintains a license to source code, customer shall not:
(i) copy, modify or otherwise update the code contained within this file or
(ii) merge such code with other computer programs.

Provided customer maintains a license to source code, then customer may modify
or otherwise update the code contained within this file or merge such code with
other computer programs subject to the following: (i) customer shall maintain
the source code as the trade secret and confidential information of MAPICS,
Inc. ("MAPICS"), (ii) the source code may only be used for so long as customer
maintains a license to source code pursuant to a separately executed license
agreement, and only for the purpose of developing and supporting customer
specific modifications to the source code, and not for the purpose of
substituting or replacing software support provided by MAPICS; (iii) MAPICS
will have no responsibility to provide software support for any customer
specific modifications developed by or for the customer, including those
developed by MAPICS, unless otherwise agreed to by MAPICS on a time and
materials basis pursuant to a separately executed services agreement;
(iv) MAPICS exclusively retains ownership to all intellectual property rights
associated with the source code, and any derivative works thereof;
(v) upon any expiration or termination of the license agreement, or upon
customer's termination of software support, customer's license to the source
code will immediately terminate and customer shall return the source code to
MAPICS or prepare and send to MAPICS a written affidavit certifying destruction
of the source code within ten (10) days following the expiration or termination
of customer's license right to the source code;
(vi) customer may not copy the source code and may only disclose the source code
to its employees or the employees of a MAPICS affiliate or business partner with
which customer contracts for modifications services, but only for so long as
such employees remain employed by customer or a MAPICS affiliate or business
partner and/or only for so long as there is an agreement in effect between
MAPICS and such affiliate or business partner authorizing them to provide
modification services for the source code ("Authorized Partner" a current list
of Authorized Partners can be found at the following link
http://www.mapics.com/company/SalesOffices/);
(vii) customer shall and shall obligate all employees of customer or an
Authorized Partner that have access to the source code to maintain the source
code as the trade secret and confidential information of MAPICS and to protect
the source code from disclosure to any third parties, including employees of
customer or an Authorized Partner that are not under an obligation to maintain
the confidentiality of the source code; (viii) MAPICS may immediately terminate
a source code license in the event that MAPICS becomes aware of a breach of
these provisions or if, in the commercially reasonable discretion of MAPICS, a
breach is probable; (ix) any breach by customer of its confidentiality
obligations hereunder may cause irreparable damage for which MAPICS may have no
adequate remedy at law, and that MAPICS may exercise all available equitable
remedies, including seeking injunctive relief, without having to post a bond;
and, (x) if Customer becomes aware of a breach or if a breach is probable,
customer will promptly notify MAPICS, and will provide assistance and
cooperation as is necessary to remedy a breach that has already occurred or to
prevent a threatened breach.

MAPICS is a trademark of MAPICS, Inc.

All other product or brand names used in this code may be trademarks,
registered trademarks, or trade names of their respective owners.
*/

CREATE PROCEDURE [dbo].[InWorkflowSp] ( 
  @Name    sysname  = NULL 
, @Name1   sysname  = NULL 
, @Value1  sysname  = NULL
, @Name2   sysname  = NULL
, @Value2  sysname  = NULL
, @Name3   sysname  = NULL
, @Value3  sysname  = NULL
, @Name4   sysname  = NULL
, @Value4  sysname  = NULL
, @Name5   sysname  = NULL
, @Value5  sysname  = NULL
, @Name6   sysname  = NULL
, @Value6  sysname  = NULL
, @Name7   sysname  = NULL
, @Value7  sysname  = NULL
, @Name8   sysname  = NULL
, @Value8  sysname  = NULL
, @Name9   sysname  = NULL
, @Value9  sysname  = NULL
, @Name10  sysname  = NULL
, @Value10 sysname  = NULL
) AS 

DECLARE 
  @SQLNames   LongListType
, @SQLValues  LongListType
, @SQL        LongListType

CREATE TABLE #RPTable 
(
  TableName sysname
, RowPointer uniqueidentifier
, Name1 sysname NULL 
, Value1 sysname  NULL
, Name2 sysname  NULL
, Value2 sysname  NULL
, Name3 sysname  NULL
, Value3 sysname  NULL
, Name4 sysname  NULL
, Value4 sysname  NULL
, Name5 sysname  NULL
, Value5 sysname  NULL
, Name6 sysname  NULL
, Value6 sysname  NULL
, Name7 sysname  NULL
, Value7 sysname  NULL
, Name8 sysname  NULL
, Value8 sysname  NULL
, Name9 sysname  NULL
, Value9 sysname  NULL
, Name10 sysname  NULL
, Value10 sysname  NULL
) 

DECLARE tabcursor CURSOR LOCAL STATIC READ_ONLY
FOR 
SELECT 
  sysobjs.name 
FROM sysobjects sysobjs
WHERE sysobjs.type = 'U'
AND sysobjs.id IN 
(SELECT syscols.id FROM syscolumns syscols 
 WHERE syscols.name = 'InWorkflow' 
 AND syscols.id IN (SELECT syscols2.id 
                    FROM syscolumns syscols2 
                    WHERE syscols2.name = 'RowPointer'))
AND sysobjs.name LIKE ISNULL(@Name, sysobjs.name)

OPEN tabcursor
WHILE 1=1
BEGIN
   FETCH tabcursor INTO 
     @Name

   IF @@FETCH_STATUS = -1
      BREAK

   SET @SQLValues = ''
   SET @SQLNames = ''

   SELECT
     @SQLValues = @SQLValues + ', ''' + column_name + ''', ' + column_name
   , @SQLNames = @SQLNames + ', Name' + dbo.cstr(ordinal_position) + ', Value' 
     + dbo.cstr(ordinal_position)
   FROM dbo.PrimaryKeyColumns(@Name)

   SET @SQL = 'INSERT INTO #RPTable (TableName, RowPointer' + @SQLNames 
     + ') SELECT ''' + @Name + ''', RowPointer' + @SQLValues + ' FROM ' + @Name 
     + ' WHERE InWorkflow = 1'

--   SET @SQL =  'UPDATE ' + @Name + ' SET InWorkflow = 1 WHERE RowPointer = (SELECT TOP 1 RowPointer FROM' + @Name + ')'
   EXEC sp_executesql @SQL

   --    insert into #RPTable exec ('select ''' + @Name + ''',RowPointer 
   --    from '+ @Name + ' where InWorkflow = 1')

END
CLOSE tabcursor
DEALLOCATE tabcursor

SELECT   
  TableName 
, RowPointer 
, Name1 
, Value1 
, Name2 
, Value2 
, Name3 
, Value3 
, Name4 
, Value4
, Name5 
, Value5 
, Name6 
, Value6 
, Name7 
, Value7 
, Name8 
, Value8 
, Name9 
, Value9 
, Name10 
, Value10 
, 0 AS SelectFlag
FROM #RPTable
WHERE ISNULL(Name1,'') LIKE COALESCE(@Name1,Name1,'')
AND ISNULL(Value1,'')  LIKE COALESCE(@Value1,Value1,'')  
AND ISNULL(Name2,'')   LIKE COALESCE(@Name2,Name2,'') 
AND ISNULL(Value2,'')  LIKE COALESCE(@Value2,Value2,'')
AND ISNULL(Name3,'')   LIKE COALESCE(@Name3,Name3,'')  
AND ISNULL(Value3,'')  LIKE COALESCE(@Value3,Value3,'') 
AND ISNULL(Name4,'')   LIKE COALESCE(@Name4,Name4,'')   
AND ISNULL(Value4,'')  LIKE COALESCE(@Value4,Value4,'')  
AND ISNULL(Name5,'')   LIKE coalesce(@Name5,Name5,'')   
AND ISNULL(Value5,'')  LIKE COALESCE(@Value5,Value5,'')  
AND ISNULL(Name6,'')   LIKE COALESCE(@Name6,Name6,'')   
AND ISNULL(Value6,'')  LIKE COALESCE(@Value6,Value6,'')  
AND ISNULL(Name7,'')   LIKE COALESCE(@Name7,Name7,'')   
AND ISNULL(Value7,'')  LIKE COALESCE(@Value7,Value7,'')  
AND ISNULL(Name8,'')   LIKE COALESCE(@Name8,Name8,'') 
AND ISNULL(Value8,'')  LIKE COALESCE(@Value8,Value8,'') 
AND ISNULL(Name9,'')   LIKE COALESCE(@Name9,Name9,'')
AND ISNULL(Value9,'')  LIKE COALESCE(@Value9,Value9,'') 
AND ISNULL(Name10,'')  LIKE COALESCE(@Name10,Name10,'')
AND ISNULL(Value10,'') LIKE COALESCE(@Value10,Value10,'')

DROP TABLE #RPTable  
RETURN
GO