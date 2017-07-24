SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleSyteLineConfigSp.sp 5     2/22/05 9:30a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleSyteLineConfigSp.sp $
 *
 * SL7.04 5 85960 Cummbry Tue Feb 22 09:30:01 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleSyteLineConfigSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'ConfigControl','3081ac06092a864886f70d010705a0819e30819b020100300c06082a864886f70d02050500307606092a864886f70d010701a069046753005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e0046004900470043004f004e00540052004f004c007c004a005800330034003600000410239b18e33c09dad38f5a5646f5a50508')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'ConfigForms','3081a806092a864886f70d010705a0819a308197020100300c06082a864886f70d02050500307206092a864886f70d010701a065046353005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e0046004900470046004f0052004d0053007c004a005800330034003600000410f9b33de5defd52ec8a9f3d4d36165202')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'ConfigUI','3081a206092a864886f70d010705a08194308191020100300c06082a864886f70d02050500306c06092a864886f70d010701a05f045d53005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e00460049004700550049007c004a0058003300340036000004104b0b970da4729c52b53243eca5a701d8')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'ConfigUITemplate','3081b206092a864886f70d010705a081a43081a1020100300c06082a864886f70d02050500307c06092a864886f70d010701a06f046d53005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e0046004900470055004900540045004d0050004c004100540045007c004a005800330034003600000410e98eb28573761256e5ab45ea978fe0be')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'Configuration Processing Utility - Customer Orders','3081f906092a864886f70d010705a081eb3081e8020100300c06082a864886f70d020505003081c206092a864886f70d010701a081b40481b153005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e00460049004700550052004100540049004f004e002000500052004f00430045005300530049004e00470020005500540049004c0049005400590020002d00200043005500530054004f004d004500520020004f00520044004500520053007c004a005800330034003600000410776a50cf7bd510f147ce3bd54d965733')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'ConfigurationProcessingUtilityEstimateJobs','3081e906092a864886f70d010705a081db3081d8020100300c06082a864886f70d020505003081b206092a864886f70d010701a081a40481a153005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e00460049004700550052004100540049004f004e00500052004f00430045005300530049004e0047005500540049004c0049005400590045005300540049004d004100540045004a004f00420053007c004a0058003300340036000004102bdf1d6cd9afb71c3c3795a0a1f491c8')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'ConfigurationProcessingUtilityEstimates','3081e306092a864886f70d010705a081d53081d2020100300c06082a864886f70d020505003081ac06092a864886f70d010701a0819e04819b53005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e00460049004700550052004100540049004f004e00500052004f00430045005300530049004e0047005500540049004c0049005400590045005300540049004d0041005400450053007c004a005800330034003600000410eeb7aa47e4d37437f5b996d99e984d05')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'ConfigurationProcessingUtilityJobs','3081d906092a864886f70d010705a081cb3081c8020100300c06082a864886f70d020505003081a206092a864886f70d010701a0819404819153005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e00460049004700550052004100540049004f004e00500052004f00430045005300530049004e0047005500540049004c004900540059004a004f00420053007c004a00580033003400360000041056f9ae176b15f4818b4cb24a6cc33cbf')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'ConfigurationPurgeUtility','3081c606092a864886f70d010705a081b83081b5020100300c06082a864886f70d0205050030818f06092a864886f70d010701a08181047f53005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e00460049004700550052004100540049004f004e00500055005200470045005500540049004c004900540059007c004a005800330034003600000410b683d2ff6f315994cc8a3d866d0bbbe4')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'SyteLineConfig',N'SyteLineConfig',0,N'ConfigurationValues','3081b906092a864886f70d010705a081ab3081a8020100300c06082a864886f70d0205050030818206092a864886f70d010701a075047353005900540045004c0049004e00450043004f004e004600490047007c0053005900540045004c0049004e00450043004f004e004600490047007c0030007c0043004f004e00460049004700550052004100540049004f004e00560041004c005500450053007c004a0058003300340036000004109ad3a029670cd94b2dbc365a66db9a85')
GO