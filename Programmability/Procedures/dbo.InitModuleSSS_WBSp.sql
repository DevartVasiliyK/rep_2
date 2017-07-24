SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_WBSp.sp 4     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_WBSp.sp $
 *
 * SL7.04 4 85960 Cummbry Tue Feb 22 09:29:59 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_WBSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_WB',N'SSS_WB',0,N'SSSWBCustomerOrder','30819606092a864886f70d010705a08188308185020100300c06082a864886f70d02050500306006092a864886f70d010701a05304515300530053005f00570042007c005300530053005f00570042007c0030007c005300530053005700420043005500530054004f004d00450052004f0052004400450052007c004a005800330034003600000410b6f71e511723d0890942f73ebfc4e170')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_WB',N'SSS_WB',0,N'SSSWBCustomerService','30819a06092a864886f70d010705a0818c308189020100300c06082a864886f70d02050500306406092a864886f70d010701a05704555300530053005f00570042007c005300530053005f00570042007c0030007c005300530053005700420043005500530054004f004d004500520053004500520056004900430045007c004a0058003300340036000004100bedeb2d2c0f1dedf4b58245d576e148')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_WB',N'SSS_WB',0,N'SSSWBItem','30818206092a864886f70d010705a0753073020100300c06082a864886f70d02050500304e06092a864886f70d010701a041043f5300530053005f00570042007c005300530053005f00570042007c0030007c00530053005300570042004900540045004d007c004a005800330034003600000410775884ef319ca3db5438e6b0378f4da6')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_WB',N'SSS_WB',0,N'SSSWBJob','30818006092a864886f70d010705a0733071020100300c06082a864886f70d02050500304c06092a864886f70d010701a03f043d5300530053005f00570042007c005300530053005f00570042007c0030007c00530053005300570042004a004f0042007c004a0058003300340036000004106ce30f1719a166862b3364a8b0cf4cd7')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_WB',N'SSS_WB',0,N'SSSWBPartner','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f00570042007c005300530053005f00570042007c0030007c005300530053005700420050004100520054004e00450052007c004a00580033003400360000041066cd539c192ab511523442e2094ac2b3')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_WB',N'SSS_WB',0,N'SSSWBProject','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f00570042007c005300530053005f00570042007c0030007c0053005300530057004200500052004f004a004500430054007c004a005800330034003600000410b153fe58e9167a66607b134b3f1fe893')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_WB',N'SSS_WB',0,N'SSSWBPurchasing','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b5300530053005f00570042007c005300530053005f00570042007c0030007c0053005300530057004200500055005200430048004100530049004e0047007c004a00580033003400360000041007e575e74ee29923089d1058237ed9c5')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_WB',N'SSS_WB',0,N'SSSWBUnit','30818206092a864886f70d010705a0753073020100300c06082a864886f70d02050500304e06092a864886f70d010701a041043f5300530053005f00570042007c005300530053005f00570042007c0030007c005300530053005700420055004e00490054007c004a00580033003400360000041018c5c8e487c22bfd82d1ed1d19b561f6')
GO