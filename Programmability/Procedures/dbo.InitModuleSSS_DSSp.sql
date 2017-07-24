SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_DSSp.sp 3     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_DSSp.sp $
 *
 * SL7.04 3 85960 Cummbry Tue Feb 22 09:29:52 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_DSSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_DS',N'SSS_DS',0,N'SSSDSForecastImport','30819806092a864886f70d010705a0818a308187020100300c06082a864886f70d02050500306206092a864886f70d010701a05504535300530053005f00440053007c005300530053005f00440053007c0030007c005300530053004400530046004f0052004500430041005300540049004d0050004f00520054007c004a005800330034003600000410b299d05f8ebe35d1201c876d73b81360')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_DS',N'SSS_DS',0,N'SSSDSParms','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f00440053007c005300530053005f00440053007c0030007c00530053005300440053005000410052004d0053007c004a00580033003400360000041087eab73cc1ac96017a2afb3cfa674990')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_DS',N'SSS_DS',0,N'SSSDSSalesHistoryExport','3081a006092a864886f70d010705a0819230818f020100300c06082a864886f70d02050500306a06092a864886f70d010701a05d045b5300530053005f00440053007c005300530053005f00440053007c0030007c0053005300530044005300530041004c004500530048004900530054004f00520059004500580050004f00520054007c004a00580033003400360000041048c58be8264f02e5116745cac7ca2ae1')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_DS',N'SSS_DS',2,N'DSParms','307e06092a864886f70d010705a071306f020100300c06082a864886f70d02050500304a06092a864886f70d010701a03d043b5300530053005f00440053007c005300530053005f00440053007c0032007c00440053005000410052004d0053007c004a005800330034003600000410c53880a7b308d56e1c4dd735e8aa9142')
GO