SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_SHPSp.sp 4     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_SHPSp.sp $
 *
 * SL7.04 4 85960 Cummbry Tue Feb 22 09:29:58 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_SHPSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPCleanup','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b5300530053005f005300480050007c005300530053005f005300480050007c0030007c0053005300530053004800500043004c00450041004e00550050007c004a005800330034003600000410808ecba92b70d01d33a191c5ac5a752b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPCreateFromOrder','3081a006092a864886f70d010705a0819230818f020100300c06082a864886f70d02050500306a06092a864886f70d010701a05d045b5300530053005f005300480050007c005300530053005f005300480050007c0030007c00530053005300530048005000430052004500410054004500460052004f004d004f0052004400450052007c004a005800330034003600000410b3925d026d5081389f623f8af72ab393')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPLinesAdd','30819206092a864886f70d010705a08184308181020100300c06082a864886f70d02050500305c06092a864886f70d010701a04f044d5300530053005f005300480050007c005300530053005f005300480050007c0030007c005300530053005300480050004c0049004e00450053004100440044007c004a0058003300340036000004101888b5c60eaadc3f5e92583450dcdf6c')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPPackageCleanupUtility','3081ac06092a864886f70d010705a0819e30819b020100300c06082a864886f70d02050500307606092a864886f70d010701a06904675300530053005f005300480050007c005300530053005f005300480050007c0030007c005300530053005300480050005000410043004b0041004700450043004c00450041004e00550050005500540049004c004900540059007c004a005800330034003600000410ec1c9e9d4fcabda367de8592c992314a')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPPackageExportUtility','3081aa06092a864886f70d010705a0819c308199020100300c06082a864886f70d02050500307406092a864886f70d010701a06704655300530053005f005300480050007c005300530053005f005300480050007c0030007c005300530053005300480050005000410043004b004100470045004500580050004f00520054005500540049004c004900540059007c004a005800330034003600000410b5d9887930f5e8ba7deff8614c50b5af')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPPackages','30819206092a864886f70d010705a08184308181020100300c06082a864886f70d02050500305c06092a864886f70d010701a04f044d5300530053005f005300480050007c005300530053005f005300480050007c0030007c005300530053005300480050005000410043004b0041004700450053007c004a00580033003400360000041051dbf85dade6b409a3621622ff1f0f18')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPPackagesQuery','30819c06092a864886f70d010705a0818e30818b020100300c06082a864886f70d02050500306606092a864886f70d010701a05904575300530053005f005300480050007c005300530053005f005300480050007c0030007c005300530053005300480050005000410043004b004100470045005300510055004500520059007c004a0058003300340036000004108dc8c0da4bfe8c9caa2825f427d12f8f')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPParms','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f005300480050007c005300530053005f005300480050007c0030007c005300530053005300480050005000410052004d0053007c004a005800330034003600000410e367a6f99fb630e4141709e0cc46fa52')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPShipCodes','30819406092a864886f70d010705a08186308183020100300c06082a864886f70d02050500305e06092a864886f70d010701a051044f5300530053005f005300480050007c005300530053005f005300480050007c0030007c00530053005300530048005000530048004900500043004f004400450053007c004a005800330034003600000410207c253ad41b48569e84a0ea0f3566d2')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',0,N'SSSSHPTmpAdd','30818c06092a864886f70d010705a07f307d020100300c06082a864886f70d02050500305806092a864886f70d010701a04b04495300530053005f005300480050007c005300530053005f005300480050007c0030007c0053005300530053004800500054004d0050004100440044007c004a00580033003400360000041057f6743d872955383b6133a89ef303ed')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',2,N'SHPCodes','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f005300480050007c005300530053005f005300480050007c0032007c0053004800500043004f004400450053007c004a0058003300340036000004100c8c663143daf5fd91bf2d19c62f1b09')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',2,N'SHPLines','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f005300480050007c005300530053005f005300480050007c0032007c005300480050004c0049004e00450053007c004a00580033003400360000041048139c1107809e5c5c1b89f2b2d0593b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',2,N'SHPPackages','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f005300480050007c005300530053005f005300480050007c0032007c005300480050005000410043004b0041004700450053007c004a0058003300340036000004107bb821c46ce48101b9bc14c8033d9c93')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_SHP',N'SSS_SHP',2,N'SHPParms','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f005300480050007c005300530053005f005300480050007c0032007c005300480050005000410052004d0053007c004a005800330034003600000410d7564a3df6b74d3ecd52bad08e868f39')
GO