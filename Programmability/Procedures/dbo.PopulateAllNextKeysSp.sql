SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/PopulateAllNextKeysSp.sp 3     5/03/05 8:54a Coatper $  */
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
--  Merely the guts of the PopulateAllNextKeys script to get initial values
-- for an already populated database into the NextKeys table.

/* $Archive: /ApplicationDB/Stored Procedures/PopulateAllNextKeysSp.sp $
 *
 * SL7.04 3 87035 Coatper Tue May 03 08:54:50 2005
 * EDI Transaction Load Routine
 * Issue 87035 - Changed to have EDI use a tablename of edi_co in the NextKeys functionality.
 *
 * SL7.03 3 87035 Coatper Mon May 02 15:30:05 2005
 * Issue 87035 - Changed to have EDI use a tablename of edi_co in the NextKeys functionality.
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[PopulateAllNextKeysSp]
AS
--  Journals are a special case of next key which has no abbreviation, just
-- an integer seq part with a subkey of id.

EXEC PopulateJournalKeysSp
--  This script populates the NextKeys table with the current high values for
-- each prefix for the tables and columns which get their next auto generated
-- values via the SetNextKeySp routine.

EXEC PopulateNextKeysSp 
  @TableName  = 'cfg_main'
, @ColumnName = 'config_id'

EXEC PopulateNextKeysSp 
  @TableName  = 'bol'
, @ColumnName = 'bol_num'
, @SubKeyName = 'ref_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'do_hdr'
, @ColumnName = 'do_num'

EXEC PopulateNextKeysSp 
  @TableName   = 'co'
, @ColumnName  = 'co_num'
, @Table2Name  = 'coh'
, @Column2Name = 'co_num'

EXEC PopulateNextKeysSp 
  @TableName   = 'edi_co'
, @ColumnName  = 'co_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'ack'
, @ColumnName = 'ack_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'position'
, @ColumnName = 'job_id'

EXEC PopulateNextKeysSp 
  @TableName  = 'applicant'
, @ColumnName = 'app_num'

EXEC PopulateNextKeysSp
  @TableName  = 'customer'
, @ColumnName = 'cust_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'do_hdr'
, @ColumnName = 'do_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'job'
, @ColumnName = 'job'

EXEC PopulateNextKeysSp 
  @TableName  = 'employee'
, @ColumnName = 'emp_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'office'
, @ColumnName = 'lcn_no'

EXEC PopulateNextKeysSp 
  @TableName   = 'po'
, @ColumnName  = 'po_num'
, @Table2Name  = 'poh'
, @Column2Name = 'po_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'preq'
, @ColumnName = 'req_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'proj'
, @ColumnName = 'proj_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'prod_mix'
, @ColumnName = 'prod_mix'

EXEC PopulateNextKeysSp 
  @TableName  = 'ps'
, @ColumnName = 'ps_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'rma'
, @ColumnName = 'rma_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'shipto'
, @ColumnName = 'drop_ship_no'

EXEC PopulateNextKeysSp 
  @TableName  = 'transfer'
, @ColumnName = 'trn_num'

EXEC PopulateNextKeysSp
  @TableName  = 'vendor'
, @ColumnName = 'vend_num'

EXEC PopulateNextKeysSp 
  @TableName  = 'proj_bol'
, @ColumnName = 'bol_num'
, @SubKeyName = 'proj_num'
GO