SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_FSPDCSp.sp 2     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_FSPDCSp.sp $
 *
 * SL7.04 2 85960 Cummbry Tue Feb 22 09:29:53 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_FSPDCSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_FSPDC',N'SSS_FSPDC',0,N'SSSFSPartnerConsole','3081a406092a864886f70d010705a08196308193020100300c06082a864886f70d02050500306e06092a864886f70d010701a061045f5300530053005f00460053005000440043007c005300530053005f00460053005000440043007c0030007c005300530053004600530050004100520054004e004500520043004f004e0053004f004c0045007c004a005800330034003600000410f51201a85155baac553701d30498a3dc')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_FSPDC',N'SSS_FSPDC',0,N'SSSFSSRODCLabor','30819c06092a864886f70d010705a0818e30818b020100300c06082a864886f70d02050500306606092a864886f70d010701a05904575300530053005f00460053005000440043007c005300530053005f00460053005000440043007c0030007c0053005300530046005300530052004f00440043004c00410042004f0052007c004a0058003300340036000004107506fb6887eaaa50d56a1ca8a27d42b2')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_FSPDC',N'SSS_FSPDC',0,N'SSSFSSRODCMatl','30819a06092a864886f70d010705a0818c308189020100300c06082a864886f70d02050500306406092a864886f70d010701a05704555300530053005f00460053005000440043007c005300530053005f00460053005000440043007c0030007c0053005300530046005300530052004f00440043004d00410054004c007c004a005800330034003600000410a836e9fa99fa0df1f26414ed5ba8b0f2')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_FSPDC',N'SSS_FSPDC',0,N'SSSFSSRODCMisc','30819a06092a864886f70d010705a0818c308189020100300c06082a864886f70d02050500306406092a864886f70d010701a05704555300530053005f00460053005000440043007c005300530053005f00460053005000440043007c0030007c0053005300530046005300530052004f00440043004d004900530043007c004a005800330034003600000410ec02e31e5d6e9e2d8fc813d84cc8e934')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_FSPDC',N'SSS_FSPDC',0,N'SSSFSSROLaborDCClockOff','3081ac06092a864886f70d010705a0819e30819b020100300c06082a864886f70d02050500307606092a864886f70d010701a06904675300530053005f00460053005000440043007c005300530053005f00460053005000440043007c0030007c0053005300530046005300530052004f004c00410042004f0052004400430043004c004f0043004b004f00460046007c004a005800330034003600000410658fc1ef1e54f7a487322c240de5d619')
GO