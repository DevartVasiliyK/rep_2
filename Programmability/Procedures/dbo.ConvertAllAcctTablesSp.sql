SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ConvertAllAcctTablesSp.sp 4     7/22/04 8:29a Grosphi $  */
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
CREATE PROCEDURE [dbo].[ConvertAllAcctTablesSp] 
AS
DECLARE
 @Severity   INT
, @ParmsSite SiteType
, @WhereClause LongListType

SET
 @Severity = 0

select @ParmsSite = parms.site from parms
set @WhereClause = 'site_ref = ''' + @ParmsSite + ''''

EXEC @Severity = dbo.AcctDynamicUpdateSp 'ana_ledger'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'ana_ledger_all'
                                     ,'acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause

EXEC @Severity = dbo.AcctDynamicUpdateSp 'apdraftt'
                                     ,'draft_payable_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'apdraftt_all'
                                     ,'draft_payable_acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'apparms'
                                     ,'ap_acct'
                                     ,'NewAcctCall'
                                     ,'brokerage_acct'
                                     ,'NewAcctCall'
                                     ,'comm_acct'
                                     ,'NewAcctCall'
                                     ,'deposit_acct'
                                     ,'NewAcctCall'
                                     ,'disc_acct'
                                     ,'NewAcctCall'
                                     ,'draft_payable_acct'
                                     ,'NewAcctCall'
                                     ,'duty_acct'
                                     ,'NewAcctCall'
                                     ,'freight_acct'
                                     ,'NewAcctCall'
                                     ,'insurance_acct'
                                     ,'NewAcctCall'
                                     ,'local_frt_acct'
                                     ,'NewAcctCall'
                                     ,'misc_acct'
                                     ,'NewAcctCall'
                                     ,'pur_acct'
                                     ,'NewAcctCall'
                                     ,'tax_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'apparms'
                                     ,'brokerage_acct' 
                                     ,'NewAcctCall' 
                                     ,'duty_acct'
                                     ,'NewAcctCall'
                                     ,'insurance_acct'
                                     ,'NewAcctCall'
                                     ,'local_frt_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'apparms_all'
                                     ,'ap_acct'
                                     ,'NewAcctCall'
                                     ,'brokerage_acct'
                                     ,'NewAcctCall'
                                     ,'comm_acct'
                                     ,'NewAcctCall'
                                     ,'deposit_acct'
                                     ,'NewAcctCall'
                                     ,'disc_acct'
                                     ,'NewAcctCall'
                                     ,'draft_payable_acct'
                                     ,'NewAcctCall'
                                     ,'duty_acct'
                                     ,'NewAcctCall'
                                     ,'freight_acct'
                                     ,'NewAcctCall'
                                     ,'insurance_acct'
                                     ,'NewAcctCall'
                                     ,'local_frt_acct'
                                     ,'NewAcctCall'
                                     ,'misc_acct'
                                     ,'NewAcctCall'
                                     ,'pur_acct'
                                     ,'NewAcctCall'
                                     ,'tax_acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause

EXEC @Severity = dbo.AcctDynamicUpdateSp 'apparms_all'
                                     ,'brokerage_acct' 
                                     ,'NewAcctCall' 
                                     ,'duty_acct'
                                     ,'NewAcctCall'
                                     ,'insurance_acct'
                                     ,'NewAcctCall'
                                     ,'local_frt_acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause
   

EXEC @Severity = dbo.AcctDynamicUpdateSp 'appmtd'
                                     ,'disc_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'aptrx'
                                     ,'ap_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'aptrxd'
                                     ,'acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'aptrxp'
                                     ,'ap_acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'aptrxp_all'
                                     ,'ap_acct'
                                     ,'NewAcctCall' 
, @WhereClause = @WhereClause
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'aptrxr'
                                     ,'ap_acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'aptxrd'
                                     ,'acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'ardraftt'
                                     ,'credit_acct'
                                     ,'NewAcctCall'
                                     ,'debit_acct'
                                     ,'NewAcctCall'  

EXEC @Severity = dbo.AcctDynamicUpdateSp 'arfin'
                                     ,'ar_acct'
                                     ,'NewAcctCall'
                                     ,'fin_acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'arinv'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'arinvd'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'arparms'
                                     ,'allow_acct'
                                     ,'NewAcctCall'
                                     ,'ar_acct'
                                     ,'NewAcctCall'
                                     ,'deposit_acct'
                                     ,'NewAcctCall'
                                     ,'disc_acct'
                                     ,'NewAcctCall'
                                     ,'draft_receivable_acct'
                                     ,'NewAcctCall'
                                     ,'fin_acct'
                                     ,'NewAcctCall'
                                     ,'freight_acct'
                                     ,'NewAcctCall'
                                     ,'misc_acct'
                                     ,'NewAcctCall'
                                     ,'prog_acct'
                                     ,'NewAcctCall'
                                     ,'proj_acct'
                                     ,'NewAcctCall'
                                     ,'sales_acct'
                                     ,'NewAcctCall'
                                     ,'sales_disc_acct'
                                     ,'NewAcctCall'  

EXEC @Severity = dbo.AcctDynamicUpdateSp 'arparms'
                                     ,'freight_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'arparms_all'
                                     ,'allow_acct'
                                     ,'NewAcctCall'
                                     ,'ar_acct'
                                     ,'NewAcctCall'
                                     ,'deposit_acct'
                                     ,'NewAcctCall'
                                     ,'disc_acct'
                                     ,'NewAcctCall'
                                     ,'draft_receivable_acct'
                                     ,'NewAcctCall'
                                     ,'fin_acct'
                                     ,'NewAcctCall'
                                     ,'freight_acct'
                                     ,'NewAcctCall'
                                     ,'misc_acct'
                                     ,'NewAcctCall'
                                     ,'prog_acct'
                                     ,'NewAcctCall'
                                     ,'proj_acct'
                                     ,'NewAcctCall'
                                     ,'sales_acct'
                                     ,'NewAcctCall'
                                     ,'sales_disc_acct'
                                     ,'NewAcctCall'  
, @WhereClause = @WhereClause
 
EXEC @Severity = dbo.AcctDynamicUpdateSp 'arparms_all'
                                     ,'freight_acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause

EXEC @Severity = dbo.AcctDynamicUpdateSp 'arpmtd'
                                     ,'allow_acct'
                                     ,'NewAcctCall'
                                     ,'deposit_acct'
                                     ,'NewAcctCall'
                                     ,'disc_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'artran'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'artran_all'
                                     ,'acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause
 
EXEC @Severity = dbo.AcctDynamicUpdateSp 'bank_addr'
                                     ,'draft_discounted_acct'
                                     ,'NewAcctCall'
                                     ,'draft_remitted_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'bank_hdr'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'chart_bp'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'chart_bp_all'
                                     ,'acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause

EXEC @Severity = dbo.AcctDynamicUpdateSp 'commdue'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'commtran'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'curracct'
                                     ,'apoff_acct'
                                     ,'NewAcctCall'
                                     ,'aroff_acct'
                                     ,'NewAcctCall'
                                     ,'gain_acct'
                                     ,'NewAcctCall'
                                     ,'loss_acct'
                                     ,'NewAcctCall'
                                     ,'non_ap_acct'
                                     ,'NewAcctCall'
                                     ,'non_ar_acct'
                                     ,'NewAcctCall'
                                     ,'ungain_acct'
                                     ,'NewAcctCall'
                                     ,'unloss_acct'
                                     ,'NewAcctCall'
                                     ,'vchoff_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'curracct_all'
                                     ,'gain_acct'
                                     ,'NewAcctCall'
                                     ,'loss_acct'
                                     ,'NewAcctCall'
                                     ,'non_ap_acct'
                                     ,'NewAcctCall'
                                     ,'non_ar_acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause

EXEC @Severity = dbo.AcctDynamicUpdateSp 'currparms'
                                     ,'apoff_acct'
                                     ,'NewAcctCall' 
                                     ,'aroff_acct'
                                     ,'NewAcctCall' 
                                     ,'gain_acct'
                                     ,'NewAcctCall'
                                     ,'loss_acct'
                                     ,'NewAcctCall'
                                     ,'non_ap_acct'
                                     ,'NewAcctCall'  
                                     ,'non_ar_acct' 
                                     ,'NewAcctCall' 
                                     ,'ungain_acct'
                                     ,'NewAcctCall' 
                                     ,'unloss_acct'
                                     ,'NewAcctCall' 
                                     ,'vchoff_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'currparms_all'
                                     ,'apoff_acct'
                                     ,'NewAcctCall' 
                                     ,'aroff_acct'
                                     ,'NewAcctCall' 
                                     ,'gain_acct'
                                     ,'NewAcctCall'
                                     ,'loss_acct'
                                     ,'NewAcctCall'
                                     ,'non_ap_acct'
                                     ,'NewAcctCall'  
                                     ,'non_ar_acct' 
                                     ,'NewAcctCall' 
                                     ,'ungain_acct'
                                     ,'NewAcctCall' 
                                     ,'unloss_acct'
                                     ,'NewAcctCall' 
                                     ,'vchoff_acct'
                                     ,'NewAcctCall' 
, @WhereClause = @WhereClause

EXEC @Severity = dbo.AcctDynamicUpdateSp 'dcjm'
                                     ,'acct'
                                     ,'NewAcctCall'
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'dept'
                                     ,'dl_acct'
                                     ,'NewAcctCall'
                                     ,'fo_acct'
                                     ,'NewAcctCall'
                                     ,'vo_acct'
                                     ,'NewAcctCall'
     
EXEC @Severity = dbo.AcctDynamicUpdateSp 'discount'
                                     ,'disc_acct'
                                     ,'NewAcctCall'
 
EXEC @Severity = dbo.AcctDynamicUpdateSp 'distacct'
                                     ,'cgs_acct'
                                     ,'NewAcctCall'
                                     ,'cgs_fovhd_acct'
                                     ,'NewAcctCall'
                                     ,'cgs_lbr_acct'
                                     ,'NewAcctCall'
                                     ,'cgs_out_acct'
                                     ,'NewAcctCall'
                                     ,'cgs_vovhd_acct'
                                     ,'NewAcctCall'
                                     ,'fovhd_acct'
                                     ,'NewAcctCall'
                                     ,'inv_acct'
                                     ,'NewAcctCall'
                                     ,'lbr_acct'
                                     ,'NewAcctCall'
                                     ,'out_acct'
                                     ,'NewAcctCall'
                                     ,'sale_ds_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'distacct'
                                     ,'sales_acct'
                                     ,'NewAcctCall'
                                     ,'tr_fovhd_acct'
                                     ,'NewAcctCall'
                                     ,'tr_inv_acct'
                                     ,'NewAcctCall'
                                     ,'tr_lbr_acct'
                                     ,'NewAcctCall'
                                     ,'tr_out_acct'
                                     ,'NewAcctCall'
                                     ,'tr_vovhd_acct'
                                     ,'NewAcctCall'
                                     ,'vovhd_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'edi_inv_hdr'
                                     ,'freight_acct'
                                     ,'NewAcctCall'
                                     ,'misc_acct'
                                     ,'NewAcctCall'
  
EXEC @Severity = dbo.AcctDynamicUpdateSp 'edi_inv_item'
                                     ,'sales_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'edi_inv_stax'
                                     ,'stax_acct'
                                     ,'NewAcctCall'
    
EXEC @Severity = dbo.AcctDynamicUpdateSp 'employee'
                                     ,'union_acct'
                                     ,'NewAcctCall'
                                     ,'wage_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'endtype'
                                     ,'ar_acct'
                                     ,'NewAcctCall'
                                     ,'cgs_fovhd_acct'
                                     ,'NewAcctCall' 
                                     ,'cgs_lbr_acct'
                                     ,'NewAcctCall' 
                                     ,'cgs_matl_acct'
                                     ,'NewAcctCall' 
                                     ,'cgs_out_acct'
                                     ,'NewAcctCall' 
                                     ,'cgs_vovhd_acct'
                                     ,'NewAcctCall' 
                                     ,'draft_receivable_acct'
                                     ,'NewAcctCall' 
                                     ,'sales_acct'
                                     ,'NewAcctCall' 
                                     ,'sales_ds_acct'
                                     ,'NewAcctCall'
 
EXEC @Severity = dbo.AcctDynamicUpdateSp 'faclass'
                                     ,'gl_asst_acct'
                                     ,'NewAcctCall'
                                     ,'gl_exp_acct'
                                     ,'NewAcctCall' 
                                     ,'gl_res_acct'
                                     ,'NewAcctCall' 
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'fadist'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'faparms'
                                     ,'cash_acct'
                                     ,'NewAcctCall'
                                     ,'gain_acct'
                                     ,'NewAcctCall' 
                                     ,'loss_acct'
                                     ,'NewAcctCall' 
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'glrptl'
                                     ,'e_acct'
                                     ,'NewAcctCall'
                                     ,'s_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'glrptl_all'
                                     ,'s_acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause
 
EXEC @Severity = dbo.AcctDynamicUpdateSp 'indcode'
                                     ,'wage_acct'
                                     ,'NewAcctCall'
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'inv_hdr'
                                     ,'freight_acct'
                                     ,'NewAcctCall'
                                     ,'misc_acct'
                                     ,'NewAcctCall'  

EXEC @Severity = dbo.AcctDynamicUpdateSp 'inv_item'
                                     ,'sales_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'inv_stax'
                                     ,'stax_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'inv_item'
                                     ,'sales_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'itemlifo'
                                     ,'fovhd_acct'
                                     ,'NewAcctCall'
                                     ,'inv_acct'
                                     ,'NewAcctCall' 
                                     ,'lbr_acct'
                                     ,'NewAcctCall' 
                                     ,'out_acct'
                                     ,'NewAcctCall' 
                                     ,'vovhd_acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'job'
                                     ,'jcb_acct'
                                     ,'NewAcctCall'
                                     ,'wip_acct'
                                     ,'NewAcctCall' 
                                     ,'wip_fovhd_acct'
                                     ,'NewAcctCall' 
                                     ,'wip_lbr_acct'
                                     ,'NewAcctCall' 
                                     ,'wip_out_acct'
                                     ,'NewAcctCall' 
                                     ,'wip_vovhd_acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'journal'
                                     ,'acct'
                                     ,'NewAcctCall'
 
EXEC @Severity = dbo.AcctDynamicUpdateSp 'journal_all'
                                     ,'acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause

EXEC @Severity = dbo.AcctDynamicUpdateSp 'ledger'
                                     ,'acct'
                                     ,'NewAcctCall'
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'ledger_all'
                                     ,'acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'matltran_amt'
                                     ,'acct'
                                     ,'NewAcctCall'
                                     ,'fovhd_acct'
                                     ,'NewAcctCall' 
                                     ,'lbr_acct'
                                     ,'NewAcctCall' 
                                      ,'matl_acct'
                                     ,'NewAcctCall'
                                     ,'out_acct'
                                     ,'NewAcctCall' 
                                     ,'vovhd_acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'matltran_amt_all'
                                     ,'acct'
                                     ,'NewAcctCall'
                                     ,'fovhd_acct'
                                     ,'NewAcctCall' 
                                     ,'lbr_acct'
                                     ,'NewAcctCall' 
                                      ,'matl_acct'
                                     ,'NewAcctCall'
                                     ,'out_acct'
                                     ,'NewAcctCall' 
                                     ,'vovhd_acct'
                                     ,'NewAcctCall' 
, @WhereClause = @WhereClause

EXEC @Severity = dbo.AcctDynamicUpdateSp 'pitemh'
                                     ,'non_inv_acct'
                                     ,'NewAcctCall' 
 
EXEC @Severity = dbo.AcctDynamicUpdateSp 'po_bln'
                                     ,'non_inv_acct'
                                     ,'NewAcctCall' 
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'poblnchg'
                                     ,'non_inv_acct'
                                     ,'NewAcctCall' 
  
EXEC @Severity = dbo.AcctDynamicUpdateSp 'poblnh'
                                     ,'non_inv_acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'poitem'
                                     ,'non_inv_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'poitmchg'
                                     ,'non_inv_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'poparms'
                                     ,'ana_inv_acct'
                                     ,'NewAcctCall'
                                     ,'brokerage_acct'
                                     ,'NewAcctCall' 
                                     ,'duty_acct'
                                     ,'NewAcctCall'
                                     ,'insurance_acct'
                                     ,'NewAcctCall'
                                     ,'local_frt_acct'
                                     ,'NewAcctCall'
                                     ,'freight_acct'
                                     ,'NewAcctCall'
                                     ,'voucher_acct'
                                     ,'NewAcctCall'
    
EXEC @Severity = dbo.AcctDynamicUpdateSp 'prbank'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'prdecd'
                                     ,'acct'
                                     ,'NewAcctCall' 
                                     ,'exp_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'preqitem'
                                     ,'non_inv_acct'
                                     ,'NewAcctCall' 

EXEC @Severity = dbo.AcctDynamicUpdateSp 'prodcode'
                                     ,'fmor_acct'
                                     ,'NewAcctCall' 
                                     ,'inv_adj_acct'
                                     ,'NewAcctCall' 
                                     ,'inv_pur_acct'
                                     ,'NewAcctCall' 
                                     ,'jcb_acct'
                                     ,'NewAcctCall' 
                                     ,'lc_inv_adj_acct'
                                     ,'NewAcctCall'
                                     ,'pcgs_acct'
                                     ,'NewAcctCall' 
                                     ,'proj_ga_acct'
                                     ,'NewAcctCall'
                                     ,'proj_labr_acct'
                                     ,'NewAcctCall'
                                     ,'proj_matl_acct'
                                     ,'NewAcctCall'
                                     ,'proj_other_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'prodcode'
                                     ,'proj_ovh_acct'
                                     ,'NewAcctCall' 
                                     ,'ps_scrap_acct'
                                     ,'NewAcctCall' 
                                     ,'vmor_acct'
                                     ,'NewAcctCall' 
                                     ,'wip_acct'
                                     ,'NewAcctCall' 
                                     ,'wip_fovhd_acct'
                                     ,'NewAcctCall'
                                     ,'wip_lbr_acct'
                                     ,'NewAcctCall' 
                                     ,'wip_out_acct'
                                     ,'NewAcctCall'
                                     ,'wip_vovhd_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'prodvar'
                                     ,'bcv_acct'
                                     ,'NewAcctCall' 
                                     ,'dcv_acct'
                                     ,'NewAcctCall' 
                                     ,'fcv_acct'
                                     ,'NewAcctCall'
                                     ,'icv_acct'
                                     ,'NewAcctCall'
                                     ,'lfcv_acct'
                                     ,'NewAcctCall'
                                     ,'flouv_acct'
                                     ,'NewAcctCall'
                                     ,'fmcouv_acct'
                                     ,'NewAcctCall' 
                                     ,'fmouv_acct'
                                     ,'NewAcctCall'
                                     ,'lrv_acct'
                                     ,'NewAcctCall'
                                     ,'luv_acct'
                                     ,'NewAcctCall'
                                     ,'muv_acct'
                                     ,'NewAcctCall'      

EXEC @Severity = dbo.AcctDynamicUpdateSp 'prodvar'
                                     ,'pcv_acct'
                                     ,'NewAcctCall' 
                                     ,'slr_acct'
                                     ,'NewAcctCall' 
                                     ,'srv_acct'
                                     ,'NewAcctCall' 
                                     ,'vlouv_acct'
                                     ,'NewAcctCall' 
                                     ,'vmcouv_acct'
                                     ,'NewAcctCall' 
                                     ,'vmouv_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'proj_wip'
                                     ,'ga_acct##1'
                                     ,'NewAcctCall' 
                                     ,'ga_acct##2'
                                     ,'NewAcctCall' 
                                     ,'labor_acct##1'
                                     ,'NewAcctCall' 
                                     ,'labor_acct##2'
                                     ,'NewAcctCall'
                                     ,'matl_acct##1'
                                     ,'NewAcctCall' 
                                     ,'matl_acct##2'
                                     ,'NewAcctCall'
                                     ,'other_acct##1'
                                     ,'NewAcctCall'
                                     ,'other_acct##2'
                                     ,'NewAcctCall'
                                     ,'ovh_acct##1'
                                     ,'NewAcctCall'    
                                     ,'ovh_acct##2'
                                     ,'NewAcctCall'  
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'projparm'
                                     ,'app_ga_acct'
                                     ,'NewAcctCall' 
                                     ,'app_ovh_acct'
                                     ,'NewAcctCall' 
                                     ,'labor_acct'
                                     ,'NewAcctCall' 
                                     ,'material_acct'
                                     ,'NewAcctCall'
                                     ,'other_acct'
                                     ,'NewAcctCall' 
                                     ,'ret_rev_acct'
                                     ,'NewAcctCall'
                                     ,'ub_rev_acct'
                                     ,'NewAcctCall'
                                     ,'ubret_rev_acct'
                                     ,'NewAcctCall'    

EXEC @Severity = dbo.AcctDynamicUpdateSp 'prparms'
                                     ,'cpie_acct'
                                     ,'NewAcctCall' 
                                     ,'cpil_acct'
                                     ,'NewAcctCall' 
                                     ,'eic_acct'
                                     ,'NewAcctCall' 
                                     ,'garn_acct'
                                     ,'NewAcctCall'
                                     ,'hol_acct'
                                     ,'NewAcctCall' 
                                     ,'loan_acct'
                                     ,'NewAcctCall'
                                     ,'other_acct'
                                     ,'NewAcctCall'
                                     ,'rete_acct'
                                     ,'NewAcctCall' 
                                     ,'retl_acct'
                                     ,'NewAcctCall'
                                     ,'sick_acct'
                                     ,'NewAcctCall'
                                     ,'vac_acct'
                                     ,'NewAcctCall'
      
EXEC @Severity = dbo.AcctDynamicUpdateSp 'prtaxt'
                                     ,'emp_fica_l_acct'
                                     ,'NewAcctCall' 
                                     ,'emp_med_l_acct'
                                     ,'NewAcctCall' 
                                     ,'empr_fica_e_acct'
                                     ,'NewAcctCall' 
                                     ,'empr_fica_l_acct'
                                     ,'NewAcctCall'
                                     ,'empr_med_e_acct'
                                     ,'NewAcctCall' 
                                     ,'empr_med_l_acct'
                                     ,'NewAcctCall'
                                     ,'fui_e_acct'
                                     ,'NewAcctCall'
                                     ,'fui_l_acct'
                                     ,'NewAcctCall' 
                                     ,'ots_l_acct'
                                     ,'NewAcctCall'
                                     ,'sui_e_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'prtaxt'
                                     ,'sui_l_acct'
                                     ,'NewAcctCall' 
                                     ,'suppl_ben_e_acct'
                                     ,'NewAcctCall' 
                                     ,'suppl_ben_l_acct'
                                     ,'NewAcctCall' 
                                     ,'tax_l_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'prtrxd'
                                     ,'acct'
                                     ,'NewAcctCall'
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'rmaparms'
                                     ,'rest_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'sfcparms'
                                     ,'jcbo_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'taxcode'
                                     ,'ap_acct'
                                     ,'NewAcctCall'
                                     ,'ar_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'taxcode_all'
                                     ,'ap_acct'
                                     ,'NewAcctCall'
                                     ,'ar_acct'
                                     ,'NewAcctCall'
, @WhereClause = @WhereClause

EXEC @Severity = dbo.AcctDynamicUpdateSp 'vch_dist'
                                     ,'acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'vch_hdr'
                                     ,'ap_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'vch_item'
                                     ,'non_inv_acct'
                                     ,'NewAcctCall'
  
EXEC @Severity = dbo.AcctDynamicUpdateSp 'vch_stax'
                                     ,'stax_acct'
                                     ,'NewAcctCall'
   
EXEC @Severity = dbo.AcctDynamicUpdateSp 'vendcat'
                                     ,'ap_acct'
                                     ,'NewAcctCall'
                                     ,'draft_payable_acct'
                                     ,'NewAcctCall'
                                     ,'pur_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'vendor'
                                     ,'pur_acct'
                                     ,'NewAcctCall'

EXEC @Severity = dbo.AcctDynamicUpdateSp 'wc'
                                     ,'flouv_acct'
                                     ,'NewAcctCall'
                                     ,'fmco_acct'
                                     ,'NewAcctCall' 
                                     ,'fmcouv_acct'
                                     ,'NewAcctCall' 
                                     ,'fmouv_acct'
                                     ,'NewAcctCall'
                                     ,'lrv_acct'
                                     ,'NewAcctCall' 
                                     ,'luv_acct'
                                     ,'NewAcctCall'
                                     ,'muv_acct'
                                     ,'NewAcctCall'
                                     ,'vlouv_acct'
                                     ,'NewAcctCall' 
                                     ,'vmco_acct'
                                     ,'NewAcctCall'
                                     ,'vmcouv_acct'
                                     ,'NewAcctCall'
 
EXEC @Severity = dbo.AcctDynamicUpdateSp 'wc'
                                     ,'vmouv_acct'
                                     ,'NewAcctCall'
                                     ,'wip_fovhd_acct'
                                     ,'NewAcctCall'
                                     ,'wip_lbr_acct'
                                     ,'NewAcctCall'
                                     ,'wip_matl_acct'
                                     ,'NewAcctCall'
                                     ,'wip_out_acct'
                                     ,'NewAcctCall'
                                     ,'wip_vovhd_acct'
                                     ,'NewAcctCall'

return @Severity
GO