SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_IOFSp.sp 3     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_IOFSp.sp $
 *
 * SL7.04 3 85960 Cummbry Tue Feb 22 09:29:55 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_IOFSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',0,N'SSSROEIOFLockedOrders','3081a006092a864886f70d010705a0819230818f020100300c06082a864886f70d02050500306a06092a864886f70d010701a05d045b5300530053005f0049004f0046007c005300530053005f0049004f0046007c0030007c0053005300530052004f00450049004f0046004c004f0043004b00450044004f00520044004500520053007c004a005800330034003600000410c7845d94e468819d26b96b4aec1a1c3b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',0,N'SSSROEIOFPackingSlips','3081a006092a864886f70d010705a0819230818f020100300c06082a864886f70d02050500306a06092a864886f70d010701a05d045b5300530053005f0049004f0046007c005300530053005f0049004f0046007c0030007c0053005300530052004f00450049004f0046005000410043004b0049004e00470053004c004900500053007c004a0058003300340036000004103f6a1e770c82ffa32669d32fd21343de')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',0,N'SSSROEIOFPackSlipReport','3081a406092a864886f70d010705a08196308193020100300c06082a864886f70d02050500306e06092a864886f70d010701a061045f5300530053005f0049004f0046007c005300530053005f0049004f0046007c0030007c0053005300530052004f00450049004f0046005000410043004b0053004c00490050005200450050004f00520054007c004a005800330034003600000410c00de2d66ceb56c3d0d1cd1d4f5dec36')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',0,N'SSSROEIOFPickPackRoutine','3081a606092a864886f70d010705a08198308195020100300c06082a864886f70d02050500307006092a864886f70d010701a06304615300530053005f0049004f0046007c005300530053005f0049004f0046007c0030007c0053005300530052004f00450049004f0046005000490043004b005000410043004b0052004f005500540049004e0045007c004a005800330034003600000410385e4ec6ab1d148cb007292ed7f6599c')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',0,N'SSSROEParms','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f0049004f0046007c005300530053005f0049004f0046007c0030007c0053005300530052004f0045005000410052004d0053007c004a0058003300340036000004109b785c70c29e1bd442acf3317358a1ce')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',0,N'SSSROERapidOrderEntry','3081a006092a864886f70d010705a0819230818f020100300c06082a864886f70d02050500306a06092a864886f70d010701a05d045b5300530053005f0049004f0046007c005300530053005f0049004f0046007c0030007c0053005300530052004f004500520041005000490044004f00520044004500520045004e005400520059007c004a005800330034003600000410bc2c2cc2e517a3dbfe0b2e605ab0fa52')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',0,N'SSSROEWhseParms','30819406092a864886f70d010705a08186308183020100300c06082a864886f70d02050500305e06092a864886f70d010701a051044f5300530053005f0049004f0046007c005300530053005f0049004f0046007c0030007c0053005300530052004f00450057004800530045005000410052004d0053007c004a005800330034003600000410bbd59efd96bac5a6755f4f0a44dae4aa')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',2,N'ROELockedCos','30818c06092a864886f70d010705a07f307d020100300c06082a864886f70d02050500305806092a864886f70d010701a04b04495300530053005f0049004f0046007c005300530053005f0049004f0046007c0032007c0052004f0045004c004f0043004b004500440043004f0053007c004a0058003300340036000004105e684cbe2f4c07b290f00309611361f4')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',2,N'ROEMethods','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f0049004f0046007c005300530053005f0049004f0046007c0032007c0052004f0045004d004500540048004f00440053007c004a00580033003400360000041077e1c6cd424f109075864ca0c97f7182')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',2,N'ROEParms','30818406092a864886f70d010705a0773075020100300c06082a864886f70d02050500305006092a864886f70d010701a04304415300530053005f0049004f0046007c005300530053005f0049004f0046007c0032007c0052004f0045005000410052004d0053007c004a00580033003400360000041037cb574fde5f0e2edd4cf0eff6e9f0c6')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',2,N'ROEParmsWhses','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b5300530053005f0049004f0046007c005300530053005f0049004f0046007c0032007c0052004f0045005000410052004d005300570048005300450053007c004a0058003300340036000004103f8714450b872352fc88a14c5a2d41df')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',2,N'ROEPckDetails','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b5300530053005f0049004f0046007c005300530053005f0049004f0046007c0032007c0052004f004500500043004b00440045005400410049004c0053007c004a005800330034003600000410b39ba8ee6c9f13d9c3e0175a2e50b945')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',2,N'ROEPckHdrs','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f0049004f0046007c005300530053005f0049004f0046007c0032007c0052004f004500500043004b0048004400520053007c004a005800330034003600000410f592f1958413cb7c177b0991b3831871')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_IOF',N'SSS_IOF',2,N'ROEPckItems','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f0049004f0046007c005300530053005f0049004f0046007c0032007c0052004f004500500043004b004900540045004d0053007c004a005800330034003600000410dc5b61eca0baff9da08b39e42ef17e6b')
GO