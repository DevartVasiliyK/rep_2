SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_RMXSp.sp 6     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_RMXSp.sp $
 *
 * SL7.04 6 85960 Cummbry Tue Feb 22 09:29:58 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_RMXSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXDispositionCodes','3081a206092a864886f70d010705a08194308191020100300c06082a864886f70d02050500306c06092a864886f70d010701a05f045d5300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d00580044004900530050004f0053004900540049004f004e0043004f004400450053007c004a005800330034003600000410682d80817619be7965375b3a08e6201f')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXDispositions','30819a06092a864886f70d010705a0818c308189020100300c06082a864886f70d02050500306406092a864886f70d010701a05704555300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d00580044004900530050004f0053004900540049004f004e0053007c004a00580033003400360000041025ae2afa73f3875e07addc7f7c76fa1d')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXItemAtVendorReport','3081a606092a864886f70d010705a08198308195020100300c06082a864886f70d02050500307006092a864886f70d010701a06304615300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d0058004900540045004d0041005400560045004e0044004f0052005200450050004f00520054007c004a00580033003400360000041092521c090ed835e89fe4eb62ba56e853')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXParms','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d0058005000410052004d0053007c004a005800330034003600000410e0cf11fb185d40eaff75be1e017ed6b9')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXReprintVendorPackingSlipReport','3081bf06092a864886f70d010705a081b13081ae020100300c06082a864886f70d0205050030818806092a864886f70d010701a07b04795300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d005800520045005000520049004e005400560045004e0044004f0052005000410043004b0049004e00470053004c00490050005200450050004f00520054007c004a005800330034003600000410ab2ecc300638e7ce0cb7df44968aef82')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXSerials','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b5300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d005800530045005200490041004c0053007c004a0058003300340036000004104d4314b8ee90ce9bf122b7494db78b20')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXVendorPackingSlip','3081a406092a864886f70d010705a08196308193020100300c06082a864886f70d02050500306e06092a864886f70d010701a061045f5300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d005800560045004e0044004f0052005000410043004b0049004e00470053004c00490050007c004a005800330034003600000410489514ef248465030466f7f12d55b3f9')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXVendorPackingSlipSelection','3081b706092a864886f70d010705a081a93081a6020100300c06082a864886f70d0205050030818006092a864886f70d010701a07304715300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d005800560045004e0044004f0052005000410043004b0049004e00470053004c0049005000530045004c0045004300540049004f004e007c004a005800330034003600000410fde418b722d15bc8854a77a4b6725840')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXVendorReturns','30819c06092a864886f70d010705a0818e30818b020100300c06082a864886f70d02050500306606092a864886f70d010701a05904575300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d005800560045004e0044004f005200520045005400550052004e0053007c004a0058003300340036000004105e9f05273ab4d7efdbe7298e37839d9e')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXVendorShipping','30819e06092a864886f70d010705a0819030818d020100300c06082a864886f70d02050500306806092a864886f70d010701a05b04595300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d005800560045004e0044004f0052005300480049005000500049004e0047007c004a0058003300340036000004108f2c7c6a925ad9165c58641b46aa0357')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',0,N'SSSRMXVendorToBeShippedReport','3081b006092a864886f70d010705a081a230819f020100300c06082a864886f70d02050500307a06092a864886f70d010701a06d046b5300530053005f0052004d0058007c005300530053005f0052004d0058007c0030007c0053005300530052004d005800560045004e0044004f00520054004f004200450053004800490050005000450044005200450050004f00520054007c004a00580033003400360000041034dbe32524cf9ad61b1ab6895d02fd32')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',2,N'RMXDispCodes','30818c06092a864886f70d010705a07f307d020100300c06082a864886f70d02050500305806092a864886f70d010701a04b04495300530053005f0052004d0058007c005300530053005f0052004d0058007c0032007c0052004d005800440049005300500043004f004400450053007c004a005800330034003600000410047d21aaaba7be9de15e3d6de73cfaf0')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',2,N'RMXDisps','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f0052004d0058007c005300530053005f0052004d0058007c0032007c0052004d005800440049005300500053007c004a0058003300340036000004104461ae405c03f925c7c38ce531e7f590')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',2,N'RMXParms','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f0052004d0058007c005300530053005f0052004d0058007c0032007c0052004d0058005000410052004d0053007c004a0058003300340036000004106641b42d27758006edc40160105c8ccd')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',2,N'RMXPckHdrs','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f0052004d0058007c005300530053005f0052004d0058007c0032007c0052004d005800500043004b0048004400520053007c004a005800330034003600000410d08175dfb77dbff50564210e2de45edf')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',2,N'RMXSerials','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f0052004d0058007c005300530053005f0052004d0058007c0032007c0052004d005800530045005200490041004c0053007c004a005800330034003600000410b5b4718ccb5f90733b0d7cc7fdf83024')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',2,N'RMXToShips','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f0052004d0058007c005300530053005f0052004d0058007c0032007c0052004d00580054004f00530048004900500053007c004a0058003300340036000004100921cf253c47dd65cb86eb8cbe9dffb0')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',2,N'RMXVendorPackingSlipChilds','3081aa06092a864886f70d010705a0819c308199020100300c06082a864886f70d02050500307406092a864886f70d010701a06704655300530053005f0052004d0058007c005300530053005f0052004d0058007c0032007c0052004d005800560045004e0044004f0052005000410043004b0049004e00470053004c00490050004300480049004c00440053007c004a005800330034003600000410faad8c9b1889a1ad1b1a5e10da0fa958')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',2,N'RMXVendorPackingSlips','3081a006092a864886f70d010705a0819230818f020100300c06082a864886f70d02050500306a06092a864886f70d010701a05d045b5300530053005f0052004d0058007c005300530053005f0052004d0058007c0032007c0052004d005800560045004e0044004f0052005000410043004b0049004e00470053004c004900500053007c004a005800330034003600000410a34cd4d2f14f6848d80cd86e694a142f')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RMX',N'SSS_RMX',2,N'RMXVndRtns','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f0052004d0058007c005300530053005f0052004d0058007c0032007c0052004d00580056004e004400520054004e0053007c004a0058003300340036000004109a7312e3cc1ebea807e5569f5bfa9939')
GO