SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSSS_POSSp.sp 4     2/22/05 10:35a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSSS_POSSp.sp $
 *
 * SL7.04 4 86157 Cummbry Tue Feb 22 10:35:09 2005
 * Updated SSS_POS Forms and IDO license information
 * 86157
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSSS_POSSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSChooseSerialNumber','3081a606092a864886f70d010705a08198308195020100300c06082a864886f70d02050500307006092a864886f70d010701a06304615300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f005300430048004f004f0053004500530045005200490041004c004e0055004d004200450052007c004a00580033003400360000041082c8958e75e6b78a2006a08332a15129')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSContractClose','30819c06092a864886f70d010705a0818e30818b020100300c06082a864886f70d02050500306606092a864886f70d010701a05904575300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530043004f004e005400520041004300540043004c004f00530045007c004a0058003300340036000004100b01622eef4cc24dd30e8e19e4088562')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSCustomerOrders','30819e06092a864886f70d010705a0819030818d020100300c06082a864886f70d02050500306806092a864886f70d010701a05b04595300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530043005500530054004f004d00450052004f00520044004500520053007c004a005800330034003600000410cce4628cf0b424ac4d05ce90e40af9e5')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSEndOfDayProcessing','3081a606092a864886f70d010705a08198308195020100300c06082a864886f70d02050500307006092a864886f70d010701a06304615300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530045004e0044004f004600440041005900500052004f00430045005300530049004e0047007c004a005800330034003600000410900730886dcad0f969cedc8dff0e5609')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSLogon','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f0053004c004f0047004f004e007c004a00580033003400360000041035957553a784a4a6617dd6785025d798')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSPointOfSaleEntry','3081a206092a864886f70d010705a08194308191020100300c06082a864886f70d02050500306c06092a864886f70d010701a05f045d5300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530050004f0049004e0054004f004600530041004c00450045004e005400520059007c004a005800330034003600000410659a158c7a52b0b33c00d1cc22894347')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSPointOfSaleInquiry','3081a606092a864886f70d010705a08198308195020100300c06082a864886f70d02050500307006092a864886f70d010701a06304615300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530050004f0049004e0054004f004600530041004c00450049004e00510055004900520059007c004a005800330034003600000410100536044998ceed24dd79c39ab14800')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSPOSLabor','30819206092a864886f70d010705a08184308181020100300c06082a864886f70d02050500305c06092a864886f70d010701a04f044d5300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530050004f0053004c00410042004f0052007c004a005800330034003600000410a662874c1b1bc097117933e945c91018')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSPOSMaterial','30819806092a864886f70d010705a0818a308187020100300c06082a864886f70d02050500306206092a864886f70d010701a05504535300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530050004f0053004d004100540045005200490041004c007c004a0058003300340036000004102f4f25914dbafa704a0669646d4a220b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSPOSMiscellaneousCharge','3081ae06092a864886f70d010705a081a030819d020100300c06082a864886f70d02050500307806092a864886f70d010701a06b04695300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530050004f0053004d0049005300430045004c004c0041004e0045004f00550053004300480041005200470045007c004a00580033003400360000041056daecb6147a7947e1236497bcf2e94e')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSPOSPayment','30819606092a864886f70d010705a08188308185020100300c06082a864886f70d02050500306006092a864886f70d010701a05304515300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530050004f0053005000410059004d0045004e0054007c004a005800330034003600000410efc0e32ebc8ebf14ce9d733aa5cf1800')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSReverseLookUpOption','3081a806092a864886f70d010705a0819a308197020100300c06082a864886f70d02050500307206092a864886f70d010701a06504635300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f00530052004500560045005200530045004c004f004f004b00550050004f005000540049004f004e007c004a00580033003400360000041035c81c018ade8b18f6d8be779283b0bd')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',0,N'SSSPOSSetup','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f0050004f0053007c005300530053005f0050004f0053007c0030007c0053005300530050004f005300530045005400550050007c004a005800330034003600000410a43f27e31d8f1bd997240cfd368a9c38')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',2,N'POSMDrawers','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f0050004f0053007c005300530053005f0050004f0053007c0032007c0050004f0053004d0044005200410057004500520053007c004a00580033003400360000041044b88d055275bf28fa91a745b119f3e9')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',2,N'POSMLabors','30818806092a864886f70d010705a07b3079020100300c06082a864886f70d02050500305406092a864886f70d010701a04704455300530053005f0050004f0053007c005300530053005f0050004f0053007c0032007c0050004f0053004d004c00410042004f00520053007c004a005800330034003600000410699b2048c6413886c8f3397d6bace18f')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',2,N'POSMMatls','30818606092a864886f70d010705a0793077020100300c06082a864886f70d02050500305206092a864886f70d010701a04504435300530053005f0050004f0053007c005300530053005f0050004f0053007c0032007c0050004f0053004d004d00410054004c0053007c004a0058003300340036000004107fe73ce14eb98b129bd6c21dd2d4573b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',2,N'POSMMiscs','30818606092a864886f70d010705a0793077020100300c06082a864886f70d02050500305206092a864886f70d010701a04504435300530053005f0050004f0053007c005300530053005f0050004f0053007c0032007c0050004f0053004d004d0049005300430053007c004a00580033003400360000041061454b82273c934e20145360bec0fcf3')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',2,N'POSMParms','30818606092a864886f70d010705a0793077020100300c06082a864886f70d02050500305206092a864886f70d010701a04504435300530053005f0050004f0053007c005300530053005f0050004f0053007c0032007c0050004f0053004d005000410052004d0053007c004a00580033003400360000041067332087de313268cf07f973096f93df')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',2,N'POSMPayments','30818c06092a864886f70d010705a07f307d020100300c06082a864886f70d02050500305806092a864886f70d010701a04b04495300530053005f0050004f0053007c005300530053005f0050004f0053007c0032007c0050004f0053004d005000410059004d0045004e00540053007c004a0058003300340036000004106281a0d298c259522d94197e6bc090c5')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',2,N'POSMPayTypes','30818c06092a864886f70d010705a07f307d020100300c06082a864886f70d02050500305806092a864886f70d010701a04b04495300530053005f0050004f0053007c005300530053005f0050004f0053007c0032007c0050004f0053004d00500041005900540059005000450053007c004a005800330034003600000410eb2b9a2f8e24cc0992055e4f778cf6aa')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',2,N'POSMPos','30818206092a864886f70d010705a0753073020100300c06082a864886f70d02050500304e06092a864886f70d010701a041043f5300530053005f0050004f0053007c005300530053005f0050004f0053007c0032007c0050004f0053004d0050004f0053007c004a005800330034003600000410fd4d6d558f00cf61faf56678c10c1306')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SSS_POS',N'SSS_POS',2,N'POSMSerials','30818a06092a864886f70d010705a07d307b020100300c06082a864886f70d02050500305606092a864886f70d010701a04904475300530053005f0050004f0053007c005300530053005f0050004f0053007c0032007c0050004f0053004d00530045005200490041004c0053007c004a0058003300340036000004105c5b86d334d1e82ce0431e791908586a')
GO