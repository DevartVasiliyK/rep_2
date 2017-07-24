SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/InitModuleRSVP_USSSp.sp 6     2/22/05 9:29a Cummbry $ */
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

/* $Archive: /ApplicationDB/Stored Procedures/InitModuleRSVP_USSSp.sp $
 *
 * SL7.04 6 85960 Cummbry Tue Feb 22 09:29:52 2005
 * 85960
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[InitModuleRSVP_USSSp]
AS

   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSCARRIER','30819406092a864886f70d010705a08186308183020100300c06082a864886f70d02050500305e06092a864886f70d010701a051044f52005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f0055005300530043004100520052004900450052007c004a0058003300340036000004106a505f22349725fbbd4f5363757762ff')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSCARSH','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b52005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f00550053005300430041005200530048007c004a0058003300340036000004106b8999fad866a2e066a5db2f56e57b0b')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSCOUNTRIES','30819806092a864886f70d010705a0818a308187020100300c06082a864886f70d02050500306206092a864886f70d010701a055045352005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f0055005300530043004f0055004e00540052004900450053007c004a005800330034003600000410529c303b3aba51f9a6ac5dd5384d3b94')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSCUSTM','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b52005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f0055005300530043005500530054004d007c004a005800330034003600000410a98715b3c029683d6132ec52071e0a22')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSENDOFDAY','30819606092a864886f70d010705a08188308185020100300c06082a864886f70d02050500306006092a864886f70d010701a053045152005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f0055005300530045004e0044004f0046004400410059007c004a00580033003400360000041031a77a2bfbfee635749b8fa0cb6b08d1')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSMISC','30818c06092a864886f70d010705a07f307d020100300c06082a864886f70d02050500305806092a864886f70d010701a04b044952005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f005500530053004d004900530043007c004a005800330034003600000410a4300b99e0075fee38037aed98ad2945')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSMISCQUERY','30819806092a864886f70d010705a0818a308187020100300c06082a864886f70d02050500306206092a864886f70d010701a055045352005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f005500530053004d00490053004300510055004500520059007c004a005800330034003600000410d572f3019008f056fc9967635427abb8')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSPACKAGES','30819606092a864886f70d010705a08188308185020100300c06082a864886f70d02050500306006092a864886f70d010701a053045152005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f005500530053005000410043004b0041004700450053007c004a0058003300340036000004105592cdd01d6413c3739f23e1f681cdd5')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSPACKQUERY','30819806092a864886f70d010705a0818a308187020100300c06082a864886f70d02050500306206092a864886f70d010701a055045352005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f005500530053005000410043004b00510055004500520059007c004a0058003300340036000004105f46a20572ed920e1c4a1d9dc50835aa')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSRATE','30818c06092a864886f70d010705a07f307d020100300c06082a864886f70d02050500305806092a864886f70d010701a04b044952005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f0055005300530052004100540045007c004a005800330034003600000410ecb0a8898f374b66b1144457688006f6')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSSHIP','30818c06092a864886f70d010705a07f307d020100300c06082a864886f70d02050500305806092a864886f70d010701a04b044952005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f0055005300530053004800490050007c004a0058003300340036000004101157a230b344fb0885755452b3e036ba')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSSHIPMENTREPORT','3081a206092a864886f70d010705a08194308191020100300c06082a864886f70d02050500306c06092a864886f70d010701a05f045d52005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f0055005300530053004800490050004d0045004e0054005200450050004f00520054007c004a005800330034003600000410ef80a9f47b6b162e11aaec0c982f7a61')
   INSERT INTO ModuleMembers (ModuleName, OriginalModuleName, ObjectType, ObjectName, ModuleMemberSpec) VALUES(N'RSVP_USS',N'RSVP_USS',0,N'RS_USSSYSTM','30818f06092a864886f70d010705a08181307f020100300c06082a864886f70d02050500305a06092a864886f70d010701a04d044b52005300560050005f005500530053007c0052005300560050005f005500530053007c0030007c00520053005f0055005300530053005900530054004d007c004a0058003300340036000004108d950f12ae9625edb8c04fbcdc0967ec')
GO