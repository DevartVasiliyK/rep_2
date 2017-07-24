SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* ODT - Object Dependency Scanner
**
** This routine populates default dependencies between:
**   - Table Column Default Links and Table Columns
**   - Tables and Table Columns which have defaults
**   - Table Links and Tables
**   - Table Column Insert/Update Links and Table Columns
**   - View Select Links and Views
**   - View Column Select Links and View Columns
**   - Trigger Links and Triggers
**   - Table Links and Trigger Links
**
*/
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
CREATE PROCEDURE [dbo].[ODTPopulateSystemLinksSp] (
  @TABLESELECTLINK          CHAR(3)
, @TABLEDELETELINK          CHAR(3)
, @TABLEINSERTLINK          CHAR(3)
, @TABLEUPDATELINK          CHAR(3)
, @TABLE                    CHAR(3)
, @VIEWSELECTLINK           CHAR(3)
, @VIEW                     CHAR(3)
, @TABLECOLUMNSELECTLINK    CHAR(3)
, @TABLECOLUMNDEFAULTLINK   CHAR(3)
, @TABLECOLUMNINSERTLINK    CHAR(3)
, @TABLECOLUMNUPDATELINK    CHAR(3)
, @TABLECOLUMN              CHAR(3)
, @VIEWCOLUMNSELECTLINK     CHAR(3)
, @VIEWCOLUMN               CHAR(3)
, @TRIGGERDELETELINK        CHAR(3)
, @TRIGGERINSERTLINK        CHAR(3)
, @TRIGGERUPDATELINK        CHAR(3)
, @TRIGGER                  CHAR(3)
)
AS
DELETE FROM ODTObjectDepends
WHERE ChildType IN ( @TRIGGER, @TABLE, @TABLECOLUMN, @VIEW, @VIEWCOLUMN )
OR    ChildType IN ( @TRIGGERDELETELINK, @TRIGGERINSERTLINK, @TRIGGERUPDATELINK )

DELETE FROM ODTTableColumns

INSERT INTO ODTObjects ( ObjectName )
SELECT sob.name
FROM sysobjects sob
WHERE sob.type IN ( 'U', 'V', 'TR' )
AND   NOT EXISTS ( SELECT 1 FROM ODTObjects oob WHERE oob.ObjectName = sob.name )

INSERT INTO ODTObjects ( ObjectName )
SELECT sob.name + '.' + sco.name
FROM sysobjects sob
     INNER JOIN syscolumns sco ON
         sob.id = sco.id
WHERE sob.type IN ( 'U', 'V' )
AND   NOT EXISTS ( SELECT 1 FROM ODTObjects oob WHERE oob.ObjectName = sob.name + '.' + sco.name )

CREATE TABLE #TABLELINKSTMP (
  TABLELINK    CHAR(3)
)
INSERT INTO #TABLELINKSTMP ( TABLELINK ) VALUES ( @TABLESELECTLINK )
INSERT INTO #TABLELINKSTMP ( TABLELINK ) VALUES ( @TABLEDELETELINK )
INSERT INTO #TABLELINKSTMP ( TABLELINK ) VALUES ( @TABLEINSERTLINK )
INSERT INTO #TABLELINKSTMP ( TABLELINK ) VALUES ( @TABLEUPDATELINK )

CREATE TABLE #TABLECOLUMNLINKSTMP (
  TABLECOLUMNLINK    CHAR(3)
)
INSERT INTO #TABLECOLUMNLINKSTMP ( TABLECOLUMNLINK ) VALUES ( @TABLECOLUMNSELECTLINK )
INSERT INTO #TABLECOLUMNLINKSTMP ( TABLECOLUMNLINK ) VALUES ( @TABLECOLUMNINSERTLINK )
INSERT INTO #TABLECOLUMNLINKSTMP ( TABLECOLUMNLINK ) VALUES ( @TABLECOLUMNUPDATELINK )

-- Populate dependencies between Table Column Default Links and Table Columns
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT
  oob.ObjectID
, @TABLECOLUMNDEFAULTLINK
, oob.ObjectID
, @TABLECOLUMN
FROM sysobjects sob
     INNER JOIN syscolumns sco ON
         sob.id = sco.id
     INNER JOIN ODTObjects oob ON
         sob.name + '.' + sco.name = oob.ObjectName
WHERE sob.type = 'U'
AND   sco.cdefault > 0

-- Populate dependencies between Tables and Table Columns which have defaults
INSERT INTO ODTTableColumns (
  TableID
, ColumnID
)
SELECT
  oob2.ObjectID
, ood.ParentObjectID
FROM ODTObjectDepends ood
     INNER JOIN ODTObjects oob1 ON
         ood.ParentObjectID = oob1.ObjectID
     INNER JOIN ODTObjects oob2 ON
         SUBSTRING( oob1.ObjectName , 1, CHARINDEX( '.', oob1.ObjectName ) - 1 ) = oob2.ObjectName
WHERE ood.ParentType = @TABLECOLUMNDEFAULTLINK

-- Populate dependencies between Table Links and Tables
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT
  oob.ObjectID
, tmp.TABLELINK
, oob.ObjectID
, @TABLE
FROM sysobjects sob
     INNER JOIN ODTObjects oob ON
         sob.name = oob.ObjectName
     CROSS JOIN #TABLELINKSTMP tmp
WHERE sob.type = 'U'

-- Populate dependencies between Table Column Insert/Update and Table Columns
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT
  oob.ObjectID
, tmp.TABLECOLUMNLINK
, oob.ObjectID
, @TABLECOLUMN
FROM sysobjects sob
     INNER JOIN syscolumns sco ON
         sob.id = sco.id
     INNER JOIN ODTObjects oob ON
         sob.name + '.' + sco.name = oob.ObjectName
     CROSS JOIN #TABLECOLUMNLINKSTMP tmp
WHERE sob.type = 'U'

-- Populate dependencies between View Select Links and Views
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT
  oob.ObjectID
, @VIEWSELECTLINK
, oob.ObjectID
, @VIEW
FROM sysobjects sob
     INNER JOIN ODTObjects oob ON
         sob.name = oob.ObjectName
WHERE sob.type = 'V'

-- Populate dependencies between View Column Select Links and View Columns
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT
  oob.ObjectID
, @VIEWCOLUMNSELECTLINK
, oob.ObjectID
, @VIEWCOLUMN
FROM sysobjects sob
     INNER JOIN syscolumns sco ON
         sob.id = sco.id
     INNER JOIN ODTObjects oob ON
         sob.name + '.' + sco.name = oob.ObjectName
WHERE sob.type = 'V'

-- Populates dependencies between Trigger Delete Links and Triggers
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT
  oob1.ObjectID
, @TRIGGERDELETELINK
, oob2.ObjectID
, @TRIGGER
FROM sysobjects sob1
     INNER JOIN sysobjects sob2 ON
         sob1.deltrig = sob2.id
     INNER JOIN ODTObjects oob1 ON
         sob1.name = oob1.ObjectName
     INNER JOIN ODTObjects oob2 ON
         sob2.name = oob2.ObjectName
WHERE sob1.type = 'U'

-- Populates dependencies between Trigger Insert Links and Triggers
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT
  oob1.ObjectID
, @TRIGGERINSERTLINK
, oob2.ObjectID
, @TRIGGER
FROM sysobjects sob1
     INNER JOIN sysobjects sob2 ON
         sob1.instrig = sob2.id
     INNER JOIN ODTObjects oob1 ON
         sob1.name = oob1.ObjectName
     INNER JOIN ODTObjects oob2 ON
         sob2.name = oob2.ObjectName
WHERE sob1.type = 'U'

-- Populates dependencies between Trigger Update Links and Triggers
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT
  oob1.ObjectID
, @TRIGGERUPDATELINK
, oob2.ObjectID
, @TRIGGER
FROM sysobjects sob1
     INNER JOIN sysobjects sob2 ON
         sob1.updtrig = sob2.id
     INNER JOIN ODTObjects oob1 ON
         sob1.name = oob1.ObjectName
     INNER JOIN ODTObjects oob2 ON
         sob2.name = oob2.ObjectName
WHERE sob1.type = 'U'

-- Populates dependencies between Table Links and Trigger Links
INSERT INTO ODTObjectDepends (
  ParentObjectID
, ParentType
, ChildObjectID
, ChildType
)
SELECT DISTINCT
  ParentObjectID
, CASE ParentType
    WHEN @TRIGGERDELETELINK THEN @TABLEDELETELINK
    WHEN @TRIGGERINSERTLINK THEN @TABLEINSERTLINK
    WHEN @TRIGGERUPDATELINK THEN @TABLEUPDATELINK
  END
, ParentObjectID
, ParentType
FROM ODTObjectDepends
WHERE ParentType IN ( @TRIGGERDELETELINK, @TRIGGERINSERTLINK, @TRIGGERUPDATELINK )

DROP TABLE #TABLELINKSTMP
DROP TABLE #TABLECOLUMNLINKSTMP

RETURN 0
GO