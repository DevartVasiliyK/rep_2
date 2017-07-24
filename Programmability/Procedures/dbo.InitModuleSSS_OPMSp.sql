SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_OPMSp.sp 3     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_OPMSp.sp $
 *
 * SL7.04 3 85960 Cummbry Tue Feb 22 09:29:56 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_OPMSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',0,N'SSSOPMParms','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f004f0050004d007c005300530053005f004f0050004d007c0030007c005300530053004f0050004d005000410052004d0053007c004a0058003300340036000004107afe0ac43a4cfd5e1206df5341a42abd')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',0,N'SSSRMXItemAtVendorReport','3081a606092a864886f70d010705a08198308195020100300c06082a864886f70d02050500307006092a864886f70d010701a06304615300530053005f004f0050004d007c005300530053005f004f0050004d007c0030007c0053005300530052004d0058004900540045004d0041005400560045004e0044004f0052005200450050004f00520054007c004a0058003300340036000004105d1c685bb85252ed77d201d3d51e7f4c')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',0,N'SSSRMXReprintVendorPackingSlipReport','3081bf06092a864886f70d010705a081b13081ae020100300c06082a864886f70d0205050030818806092a864886f70d010701a07b04795300530053005f004f0050004d007c005300530053005f004f0050004d007c0030007c0053005300530052004d005800520045005000520049004e005400560045004e0044004f0052005000410043004b0049004e00470053004c00490050005200450050004f00520054007c004a005800330034003600000410d1a5c2c0908692feb4d156def31ddae1')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',0,N'SSSRMXSerials','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b5300530053005f004f0050004d007c005300530053005f004f0050004d007c0030007c0053005300530052004d005800530045005200490041004c0053007c004a00580033003400360000041021a9a4b6345c7bc4066ef268c3dad51f')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',0,N'SSSRMXVendorPackingSlip','3081a406092a864886f70d010705a08196308193020100300c06082a864886f70d02050500306e06092a864886f70d010701a061045f5300530053005f004f0050004d007c005300530053005f004f0050004d007c0030007c0053005300530052004d005800560045004e0044004f0052005000410043004b0049004e00470053004c00490050007c004a005800330034003600000410cc9ff65246f0153a1fbb9fc42de63521')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',0,N'SSSRMXVendorPackingSlipSelection','3081b706092a864886f70d010705a081a93081a6020100300c06082a864886f70d0205050030818006092a864886f70d010701a07304715300530053005f004f0050004d007c005300530053005f004f0050004d007c0030007c0053005300530052004d005800560045004e0044004f0052005000410043004b0049004e00470053004c0049005000530045004c0045004300540049004f004e007c004a0058003300340036000004108996c8fca9b5f83a497b2401b3360270')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',0,N'SSSRMXVendorShipping','30819e06092a864886f70d010705a0819030818d020100300c06082a864886f70d02050500306806092a864886f70d010701a05b04595300530053005f004f0050004d007c005300530053005f004f0050004d007c0030007c0053005300530052004d005800560045004e0044004f0052005300480049005000500049004e0047007c004a005800330034003600000410d903f87260b1fd756984b0016876becd')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',0,N'SSSRMXVendorToBeShippedReport','3081b006092a864886f70d010705a081a230819f020100300c06082a864886f70d02050500307a06092a864886f70d010701a06d046b5300530053005f004f0050004d007c005300530053005f004f0050004d007c0030007c0053005300530052004d005800560045004e0044004f00520054004f004200450053004800490050005000450044005200450050004f00520054007c004a005800330034003600000410838106ecfed5f9d509b7bca5c024dd60')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',2,N'OPMMethods','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f004f0050004d007c005300530053005f004f0050004d007c0032007c004f0050004d004d004500540048004f00440053007c004a0058003300340036000004103ccbcd9d2da3f85abd251cd1e4f45afd')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',2,N'RMXParms','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f004f0050004d007c005300530053005f004f0050004d007c0032007c0052004d0058005000410052004d0053007c004a005800330034003600000410c64f7baabdf5a8cda294d23cbcee772b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',2,N'RMXPckHdrs','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f004f0050004d007c005300530053005f004f0050004d007c0032007c0052004d005800500043004b0048004400520053007c004a005800330034003600000410c9a3ea1d52a3d465a404f3a3b5df7bdd')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',2,N'RMXSerials','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f004f0050004d007c005300530053005f004f0050004d007c0032007c0052004d005800530045005200490041004c0053007c004a005800330034003600000410b35b2216ab9cf4494916d35d02708927')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',2,N'RMXToShips','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f004f0050004d007c005300530053005f004f0050004d007c0032007c0052004d00580054004f00530048004900500053007c004a0058003300340036000004100c02a9387f3581bf4d2a9610705d051b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',2,N'RMXVendorPackingSlipChilds','3081aa06092a864886f70d010705a0819c308199020100300c06082a864886f70d02050500307406092a864886f70d010701a06704655300530053005f004f0050004d007c005300530053005f004f0050004d007c0032007c0052004d005800560045004e0044004f0052005000410043004b0049004e00470053004c00490050004300480049004c00440053007c004a0058003300340036000004103a5da0a2e03267172307255d0c1c4cf6')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',2,N'RMXVendorPackingSlips','3081a006092a864886f70d010705a0819230818f020100300c06082a864886f70d02050500306a06092a864886f70d010701a05d045b5300530053005f004f0050004d007c005300530053005f004f0050004d007c0032007c0052004d005800560045004e0044004f0052005000410043004b0049004e00470053004c004900500053007c004a00580033003400360000041082f1a29d1c17868923d1159a8aa3aa0f')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_OPM',N'SSS_OPM',2,N'RMXVndRtns','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f004f0050004d007c005300530053005f004f0050004d007c0032007c0052004d00580056004e004400520054004e0053007c004a0058003300340036000004102a8a47be004b55949d1d5bec7f657ccd')
GO