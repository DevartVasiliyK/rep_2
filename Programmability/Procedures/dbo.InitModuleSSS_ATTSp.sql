SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_ATTSp.sp 4     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_ATTSp.sp $
 *
 * SL7.04 4 85960 Cummbry Tue Feb 22 09:29:52 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_ATTSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',0,N'SSSATTAttachmentAdd','30819c06092a864886f70d010705a0818e30818b020100300c06082a864886f70d02050500306606092a864886f70d010701a05904575300530053005f004100540054007c005300530053005f004100540054007c0030007c005300530053004100540054004100540054004100430048004d0045004e0054004100440044007c004a005800330034003600000410de2c9e18c980f0a660c87253fa4e863f')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',0,N'SSSATTAttachments','30819806092a864886f70d010705a0818a308187020100300c06082a864886f70d02050500306206092a864886f70d010701a05504535300530053005f004100540054007c005300530053005f004100540054007c0030007c005300530053004100540054004100540054004100430048004d0045004e00540053007c004a005800330034003600000410db5ae0d52c229e7f7ea06610710cfdca')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',0,N'SSSATTDocumentTypes','30819c06092a864886f70d010705a0818e30818b020100300c06082a864886f70d02050500306606092a864886f70d010701a05904575300530053005f004100540054007c005300530053005f004100540054007c0030007c0053005300530041005400540044004f00430055004d0045004e005400540059005000450053007c004a005800330034003600000410bf9beb1a9b58f632f0de9f94e49bb0cf')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',0,N'SSSATTExtensions','30819606092a864886f70d010705a08188308185020100300c06082a864886f70d02050500306006092a864886f70d010701a05304515300530053005f004100540054007c005300530053005f004100540054007c0030007c0053005300530041005400540045005800540045004e00530049004f004e0053007c004a005800330034003600000410924dcab5701e50ae0923cf564fc5aaa3')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',0,N'SSSATTFasMailParms','30819a06092a864886f70d010705a0818c308189020100300c06082a864886f70d02050500306406092a864886f70d010701a05704555300530053005f004100540054007c005300530053005f004100540054007c0030007c005300530053004100540054004600410053004d00410049004c005000410052004d0053007c004a005800330034003600000410169da2f100ac4d81c08a044a68dffdb3')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',0,N'SSSATTFasviewParms','30819a06092a864886f70d010705a0818c308189020100300c06082a864886f70d02050500306406092a864886f70d010701a05704555300530053005f004100540054007c005300530053005f004100540054007c0030007c0053005300530041005400540046004100530056004900450057005000410052004d0053007c004a00580033003400360000041076e9688c8ae5b5d2bca053b6fef57d0a')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',0,N'SSSATTMessages','30819206092a864886f70d010705a08184308181020100300c06082a864886f70d02050500305c06092a864886f70d010701a04f044d5300530053005f004100540054007c005300530053005f004100540054007c0030007c005300530053004100540054004d0045005300530041004700450053007c004a0058003300340036000004109068db36c0eb5f5c6dc91934d3932db8')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',2,N'ATTExts','30818206092a864886f70d010705a0753073020100300c06082a864886f70d02050500304e06092a864886f70d010701a041043f5300530053005f004100540054007c005300530053005f004100540054007c0032007c0041005400540045005800540053007c004a0058003300340036000004105669d63dd56ad5ecfe9204e5e0e97fb2')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',2,N'ATTFields','30818606092a864886f70d010705a0793077020100300c06082a864886f70d02050500305206092a864886f70d010701a04504435300530053005f004100540054007c005300530053005f004100540054007c0032007c004100540054004600490045004c00440053007c004a005800330034003600000410c8de2066f5503e2d3ebcad100842cd01')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',2,N'ATTMsgs','30818206092a864886f70d010705a0753073020100300c06082a864886f70d02050500304e06092a864886f70d010701a041043f5300530053005f004100540054007c005300530053005f004100540054007c0032007c004100540054004d005300470053007c004a0058003300340036000004102d7b368ce4362996dd0bd6cfbc6b43ba')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',2,N'ATTParmLists','30818c06092a864886f70d010705a07f307d020100300c06082a864886f70d02050500305806092a864886f70d010701a04b04495300530053005f004100540054007c005300530053005f004100540054007c0032007c004100540054005000410052004d004c0049005300540053007c004a005800330034003600000410213d002c496bc2687d7de5cda9cf48a6')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',2,N'ATTParms','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f004100540054007c005300530053005f004100540054007c0032007c004100540054005000410052004d0053007c004a005800330034003600000410a7f494d41cdf3b54cebe664ba33acd2c')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',2,N'ATTProfiles','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f004100540054007c005300530053005f004100540054007c0032007c00410054005400500052004f00460049004c00450053007c004a0058003300340036000004107a25ae3e22b1335b84820b8f23765302')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',2,N'ATTProps','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f004100540054007c005300530053005f004100540054007c0032007c00410054005400500052004f00500053007c004a0058003300340036000004102c760e905f591332aa523eac384295e1')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',2,N'ATTTypeFields','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b5300530053005f004100540054007c005300530053005f004100540054007c0032007c0041005400540054005900500045004600490045004c00440053007c004a00580033003400360000041061fc5ddf3e1a41005cba735d60afa203')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_ATT',N'SSS_ATT',2,N'ATTTypes','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f004100540054007c005300530053005f004100540054007c0032007c00410054005400540059005000450053007c004a005800330034003600000410b0dff0499cd886bb473b81c8992f7b58')
GO