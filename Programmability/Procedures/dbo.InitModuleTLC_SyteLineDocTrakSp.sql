SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleTLC_SyteLineDocTrakSp.sp 13    8/02/05 3:52p Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleTLC_SyteLineDocTrakSp.sp $
 *
 * SL7.04 13 88477 Cummbry Tue Aug 02 15:52:44 2005
 * SL7 Products.xls
 * Added a new form LCDTDocumentProfile.
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleTLC_SyteLineDocTrakSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTAttachedDocReport','3081d306092a864886f70d010705a081c53081c2020100300c06082a864886f70d0205050030819c06092a864886f70d010701a0818e04818b54004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c004300440054004100540054004100430048004500440044004f0043005200450050004f00520054007c004a0058003300340036000004104d47f39cd9d888efee048d08f4063342')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTDocTrak','3081bd06092a864886f70d010705a081af3081ac020100300c06082a864886f70d0205050030818606092a864886f70d010701a079047754004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c0043004400540044004f0043005400520041004b007c004a0058003300340036000004108b2aa4421b5789e39d8a969749c23d07')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTDocTrakQuery','3081c906092a864886f70d010705a081bb3081b8020100300c06082a864886f70d0205050030819206092a864886f70d010701a0818404818154004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c0043004400540044004f0043005400520041004b00510055004500520059007c004a005800330034003600000410961b67710f27b40b6e915ca4b528bb6b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTDocumentProfile','3081cf06092a864886f70d010705a081c13081be020100300c06082a864886f70d0205050030819806092a864886f70d010701a0818a04818754004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c0043004400540044004f00430055004d0045004e005400500052004f00460049004c0045007c004a0058003300340036000004107b85a2dbabcbec778964f07e6c60fc0d')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTIndentedJobBOMReport','3081d906092a864886f70d010705a081cb3081c8020100300c06082a864886f70d020505003081a206092a864886f70d010701a0819404819154004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c0043004400540049004e00440045004e005400450044004a004f00420042004f004d005200450050004f00520054007c004a005800330034003600000410ede92454b9a22a86ec4a002c0693509f')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTLogFile','3081bd06092a864886f70d010705a081af3081ac020100300c06082a864886f70d0205050030818606092a864886f70d010701a079047754004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c004300440054004c004f004700460049004c0045007c004a005800330034003600000410934a19cb7d3b714f9cebe90f044f5614')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTMoveUtility','3081c606092a864886f70d010705a081b83081b5020100300c06082a864886f70d0205050030818f06092a864886f70d010701a08181047f54004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c004300440054004d004f00560045005500540049004c004900540059007c004a005800330034003600000410f1916e660f14f5f2faeaa1cd8ace4d1d')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTParameters','3081c306092a864886f70d010705a081b53081b2020100300c06082a864886f70d0205050030818c06092a864886f70d010701a07f047d54004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c0043004400540050004100520041004d00450054004500520053007c004a005800330034003600000410356c8ab409ff64ee5cb45a31a8a09c81')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTPDFHeader','3081c106092a864886f70d010705a081b33081b0020100300c06082a864886f70d0205050030818a06092a864886f70d010701a07d047b54004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c004300440054005000440046004800450041004400450052007c004a005800330034003600000410f57d05c7c6694f27962a5d6797f486b0')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTPrintJobPaperwork','3081d306092a864886f70d010705a081c53081c2020100300c06082a864886f70d0205050030819c06092a864886f70d010701a0818e04818b54004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c004300440054005000520049004e0054004a004f0042005000410050004500520057004f0052004b007c004a005800330034003600000410f344f5b7106eddfea15055aa16b1ebb0')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTPrintPOPaperwork','3081d106092a864886f70d010705a081c33081c0020100300c06082a864886f70d0205050030819a06092a864886f70d010701a0818c04818954004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c004300440054005000520049004e00540050004f005000410050004500520057004f0052004b007c004a005800330034003600000410bb202d7a6ca94f06fa2cc3a8a7d360e0')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTPrintScreen','3081c606092a864886f70d010705a081b83081b5020100300c06082a864886f70d0205050030818f06092a864886f70d010701a08181047f54004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c004300440054005000520049004e005400530043005200450045004e007c004a0058003300340036000004100cd4f3d476355633234474f3fcd2a321')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTPurge','3081b906092a864886f70d010705a081ab3081a8020100300c06082a864886f70d0205050030818206092a864886f70d010701a075047354004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c00430044005400500055005200470045007c004a00580033003400360000041059ef52c3dd6c6b6e6636df317ffd574b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'TLC_SyteLineDocTrak',N'TLC_SyteLineDocTrak',0,N'LCDTVirtual','3081bd06092a864886f70d010705a081af3081ac020100300c06082a864886f70d0205050030818606092a864886f70d010701a079047754004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0054004c0043005f0053005900540045004c0049004e00450044004f0043005400520041004b007c0030007c004c004300440054005600490052005400550041004c007c004a00580033003400360000041091fdcfef0ca178ba88712e0ad5aba8c6')
GO