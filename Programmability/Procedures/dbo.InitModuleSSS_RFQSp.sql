SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_RFQSp.sp 6     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_RFQSp.sp $
 *
 * SL7.04 6 85960 Cummbry Tue Feb 22 09:29:57 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_RFQSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQGenFromCO','30819406092a864886f70d010705a08186308183020100300c06082a864886f70d02050500305e06092a864886f70d010701a051044f5300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100470045004e00460052004f004d0043004f007c004a005800330034003600000410032008b06940ac75041e3213025bf13c')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQGenFromItem','30819806092a864886f70d010705a0818a308187020100300c06082a864886f70d02050500306206092a864886f70d010701a05504535300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100470045004e00460052004f004d004900540045004d007c004a0058003300340036000004105c86a18a7861d2e4ca85c97dfbc961c7')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQGenFromJob','30819606092a864886f70d010705a08188308185020100300c06082a864886f70d02050500306006092a864886f70d010701a05304515300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100470045004e00460052004f004d004a004f0042007c004a005800330034003600000410a9459e613a36161c4b23dcac97a1c9c7')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQGenFromReq','30819606092a864886f70d010705a08188308185020100300c06082a864886f70d02050500306006092a864886f70d010701a05304515300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100470045004e00460052004f004d005200450051007c004a00580033003400360000041022a6b2fcf95830900be4e779a4456236')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQLineMethod','30819606092a864886f70d010705a08188308185020100300c06082a864886f70d02050500306006092a864886f70d010701a05304515300530053005f005200460051007c005300530053005f005200460051007c0030007c005300530053005200460051004c0049004e0045004d004500540048004f0044007c004a0058003300340036000004100aa17043597f10adb18d140ca92bac53')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQLines','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f005200460051007c005300530053005f005200460051007c0030007c005300530053005200460051004c0049004e00450053007c004a00580033003400360000041042c263211eb12179962b7b9ef54decb5')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQParms','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f005200460051007c005300530053005f005200460051007c0030007c005300530053005200460051005000410052004d0053007c004a0058003300340036000004104f2be0e31b12ab5004f0c3b0550debcc')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQQuotesByVendor','30819e06092a864886f70d010705a0819030818d020100300c06082a864886f70d02050500306806092a864886f70d010701a05b04595300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100510055004f0054004500530042005900560045004e0044004f0052007c004a005800330034003600000410493826d833be8d73be6939d0ec2fc0e0')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQQuotesByVendorPreview','3081ac06092a864886f70d010705a0819e30819b020100300c06082a864886f70d02050500307606092a864886f70d010701a06904675300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100510055004f0054004500530042005900560045004e0044004f00520050005200450056004900450057007c004a005800330034003600000410581ba372c29842a2250e77ff5750f5c5')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQs','30818206092a864886f70d010705a0753073020100300c06082a864886f70d02050500304e06092a864886f70d010701a041043f5300530053005f005200460051007c005300530053005f005200460051007c0030007c0053005300530052004600510053007c004a005800330034003600000410834ec54c7d898f442a519e92f79594a0')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQSendQuote','30819406092a864886f70d010705a08186308183020100300c06082a864886f70d02050500305e06092a864886f70d010701a051044f5300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100530045004e004400510055004f00540045007c004a005800330034003600000410ed5b81e2540778f61fb24f5e6978fadf')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQTemplates','30819406092a864886f70d010705a08186308183020100300c06082a864886f70d02050500305e06092a864886f70d010701a051044f5300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100540045004d0050004c0041005400450053007c004a00580033003400360000041075d76242ccd76aa4643e8b93577ba461')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQVendors','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b5300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100560045004e0044004f00520053007c004a005800330034003600000410adf4d1e321d2a4dadccdc4f46daa8359')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',0,N'SSSRFQVendorSelection','3081a006092a864886f70d010705a0819230818f020100300c06082a864886f70d02050500306a06092a864886f70d010701a05d045b5300530053005f005200460051007c005300530053005f005200460051007c0030007c00530053005300520046005100560045004e0044004f005200530045004c0045004300540049004f004e007c004a005800330034003600000410149d6d328b8a2cfdcd6566f437991902')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',2,N'RFQAtts','30818206092a864886f70d010705a0753073020100300c06082a864886f70d02050500304e06092a864886f70d010701a041043f5300530053005f005200460051007c005300530053005f005200460051007c0032007c0052004600510041005400540053007c004a005800330034003600000410af81af67edd2ed83a23ac71fbddfb216')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',2,N'RFQLines','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f005200460051007c005300530053005f005200460051007c0032007c005200460051004c0049004e00450053007c004a00580033003400360000041074f1ae567895bd14ed15d43f8c6c8980')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',2,N'RFQParms','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f005200460051007c005300530053005f005200460051007c0032007c005200460051005000410052004d0053007c004a0058003300340036000004100208be6dfe87ae5a555480bb0115babc')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',2,N'RFQs','307c06092a864886f70d010705a06f306d020100300c06082a864886f70d02050500304806092a864886f70d010701a03b04395300530053005f005200460051007c005300530053005f005200460051007c0032007c0052004600510053007c004a00580033003400360000041030e978e7add287a52146b24180c1262a')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_RFQ',N'SSS_RFQ',2,N'RFQTemplateVends','30819606092a864886f70d010705a08188308185020100300c06082a864886f70d02050500306006092a864886f70d010701a05304515300530053005f005200460051007c005300530053005f005200460051007c0032007c00520046005100540045004d0050004c00410054004500560045004e00440053007c004a0058003300340036000004107ff56db9cb40886a85a6cd3bd57aba7e')
GO