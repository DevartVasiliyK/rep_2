SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create Procedure [dbo].[RUSXDE_ImportTransfersSp_SSD] 
(
  @RetErr        nvarchar(2800) OUTPUT
 ,@ProcExecState bit            OUTPUT
 ,@LogFlag       bit = 0
 ,@LogFile       varchar(255) = 'C:\RUSXDE_ImportTransfersSp_SSD.txt'
)
As 
Begin 
-- transfer variables 
Declare @trn_num               TrnNumType
Declare @from_whse             WhseType
Declare @to_whse               WhseType
Declare @stat                  TransferStatusType
Declare @ship_code             ShipCodeType
Declare @weight                WeightType
Declare @qty_packages          PackagesType
Declare @from_site             SiteType
Declare @to_site               SiteType
Declare @entered_site          SiteType
Declare @fob_site              SiteType
Declare @exch_rate             ExchRateType
Declare @freight_vendor        VendNumType
Declare @duty_vendor           VendNumType
Declare @brokerage_vendor      VendNumType
Declare @frt_alloc_percent     LcAllocPercentType
Declare @duty_alloc_percent    LcAllocPercentType
Declare @brk_alloc_percent     LcAllocPercentType
Declare @est_freight_amt       AmountType
Declare @act_freight_amt       AmountType
Declare @est_brokerage_amt     AmountType
Declare @act_brokerage_amt     AmountType
Declare @est_duty_amt          AmountType
Declare @act_duty_amt          AmountType
Declare @freight_amt_t         AmountType
Declare @brokerage_amt_t       AmountType
Declare @duty_amt_t            AmountType
Declare @duty_alloc_meth       LcAllocMethodType
Declare @frt_alloc_meth        LcAllocMethodType
Declare @brk_alloc_meth        LcAllocMethodType
Declare @duty_alloc_type       LcAllocTypeType
Declare @frt_alloc_type        LcAllocTypeType
Declare @brk_alloc_type        LcAllocTypeType
Declare @trans_nat             TransNatType
Declare @process_ind           ProcessIndType
Declare @delterm               DeltermType
Declare @ins_vendor            VendNumType
Declare @ins_alloc_percent     LcAllocPercentType
Declare @ins_alloc_type        LcAllocTypeType
Declare @est_insurance_amt     AmountType
Declare @ins_alloc_meth        LcAllocMethodType
Declare @act_insurance_amt     AmountType
Declare @insurance_amt_t       AmountType
Declare @loc_frt_vendor        VendNumType
Declare @loc_frt_alloc_percent LcAllocPercentType
Declare @loc_frt_alloc_type    LcAllocTypeType
Declare @est_local_freight_amt AmountType
Declare @loc_frt_alloc_meth    LcAllocMethodType
Declare @act_local_freight_amt AmountType
Declare @local_freight_amt_t   AmountType
Declare @trans_nat_2           TransNat2Type
Declare @export_type           ListDirectIndirectNonExportType
Declare @order_date            DateType
-- trnitem variables  
Declare @tri_trn_num                  TrnNumType
Declare @tri_trn_line                 TrnLineType
Declare @tri_stat                     TransferStatusType
Declare @tri_item                     ItemType
Declare @tri_trn_loc                  LocType
Declare @tri_ship_date                DateType
Declare @tri_rcvd_date                DateType
Declare @tri_qty_req                  QtyUnitType
Declare @tri_qty_shipped              QtyUnitType
Declare @tri_qty_received             QtyUnitType
Declare @tri_qty_loss                 QtyUnitType
Declare @tri_unit_cost                CostPrcType
Declare @tri_frm_ref_type             RefTypeIJPRType
Declare @tri_frm_ref_num              JobPoReqNumType
Declare @tri_frm_ref_line_suf         SuffixPoReqLineType
Declare @tri_frm_ref_release          PoReleaseType
Declare @tri_qty_packed               QtyUnitType
Declare @tri_pick_date                DateType
Declare @tri_qty_req_conv             QtyUnitType
Declare @tri_u_m                      UMType
Declare @tri_matl_cost                CostPrcType
Declare @tri_lbr_cost                 CostPrcType
Declare @tri_fovhd_cost               CostPrcType
Declare @tri_vovhd_cost               CostPrcType
Declare @tri_out_cost                 CostPrcType
Declare @tri_sch_rcv_date             DateType
Declare @tri_sch_ship_date            DateType
Declare @tri_unit_price               CostPrcType
Declare @tri_pricecode                PriceCodeType
Declare @tri_to_ref_type              RefTypeIJOType
Declare @tri_to_ref_num               CoNumJobType
Declare @tri_to_ref_line_suf          CoLineSuffixType
Declare @tri_to_ref_release           CoReleaseOperNumType
Declare @tri_from_site                SiteType
Declare @tri_from_whse                WhseType
Declare @tri_to_site                  SiteType
Declare @tri_to_whse                  WhseType
Declare @tri_cross_site               ListYesNoType
Declare @tri_unit_freight_cost        CostPrcType
Declare @tri_unit_freight_cost_conv   CostPrcType
Declare @tri_unit_brokerage_cost      CostPrcType
Declare @tri_unit_brokerage_cost_conv CostPrcType
Declare @tri_unit_duty_cost           CostPrcType
Declare @tri_unit_duty_cost_conv      CostPrcType
Declare @tri_unit_mat_cost            CostPrcType
Declare @tri_unit_mat_cost_conv       CostPrcType
Declare @tri_unit_weight              UnitWeightType
Declare @tri_lc_override              ListYesNoType
Declare @tri_projected_date           DateType
Declare @tri_comm_code                CommodityCodeType
Declare @tri_trans_nat                TransNatType
Declare @tri_process_ind              ProcessIndType
Declare @tri_delterm                  DeltermType
Declare @tri_origin                   EcCodeType
Declare @tri_cons_num                 ConsignmentsType
Declare @tri_export_value             AmountType
Declare @tri_ec_code                  EcCodeType
Declare @tri_transport                TransportType
Declare @tri_unit_insurance_cost      CostPrcType
Declare @tri_unit_insurance_cost_conv CostPrcType
Declare @tri_unit_loc_frt_cost        CostPrcType
Declare @tri_unit_loc_frt_cost_conv   CostPrcType
Declare @tri_trans_nat_2              TransNat2Type
Declare @tri_suppl_qty_conv_factor    UMConvFactorType
Declare @tri_RUS_co_num               CoNumType 
Declare @tri_RUS_jobssd               nvarchar(10) 
Declare @tri_Tip_writing              nvarchar(7) 
Declare @tri_Tip_costs                nvarchar(3) 
Declare @tri_object                   nvarchar(6) 
Declare @tri_Balance_sheet            nvarchar(8) 
--
Declare @site                      SiteType 
Declare @CurrRateIsFixed           ListYesNoType 
Declare @IsNewTrn                  ListYesNoType 
Declare @IsNewTrnItem              ListYesNoType 
Declare @currency_amt_format       InputMaskType 
Declare @TaxCodeType               TaxCodeTypeType 
Declare @NewRecordFlag             Flag 
-- 
Declare @Result                    int 
Declare @ErrorCode                 int 
Declare @Infobar                   InfobarType 
Declare @RowPointer                RowPointerType 
Declare @ParamToSave               varchar(255) 
Declare @Cnt                       int 
--

exec dbo.DefineVariableSp 'MessageLanguage' 
                         ,'1049' 
                         ,@Infobar OUTPUT 

Select @site = IsNull(site, '') 
From dbo.parms, dbo.coparms, dbo.currparms, dbo.invparms, dbo.poparms, dbo.sfcparms 

-- prepare tables, set values to original & defaults 
Update trn Set  trn.stat = IsNull(trn.stat, 'O') 
               ,trn.weight = IsNull(trn.weight, 0) 
               ,trn.qty_packages = IsNull(trn.qty_packages, 0) 
               ,trn.entered_site = (CASE When trn.entered_site Is Not Null And LEN(trn.entered_site) > 0 
                                         Then es.site 
                                         Else @site 
                                    End 
                                   ) 
               ,trn.exch_rate = IsNull(trn.exch_rate, 1) 
               ,trn.frt_alloc_percent = IsNull(trn.frt_alloc_percent, 0) 
               ,trn.duty_alloc_percent = IsNull(trn.duty_alloc_percent, 0) 
               ,trn.brk_alloc_percent = IsNull(trn.brk_alloc_percent, 0) 
               ,trn.est_freight_amt = IsNull(trn.est_freight_amt, 0) 
               ,trn.act_freight_amt = IsNull(trn.act_freight_amt, 0) 
               ,trn.est_brokerage_amt = IsNull(trn.est_brokerage_amt, 0) 
               ,trn.act_brokerage_amt = IsNull(trn.act_brokerage_amt, 0) 
               ,trn.est_duty_amt = IsNull(trn.est_duty_amt, 0) 
               ,trn.act_duty_amt = IsNull(trn.act_duty_amt, 0) 
               ,trn.freight_amt_t = IsNull(trn.freight_amt_t, 0) 
               ,trn.brokerage_amt_t = IsNull(trn.brokerage_amt_t, 0) 
               ,trn.duty_amt_t = IsNull(trn.duty_amt_t, 0) 
               ,trn.duty_alloc_meth = IsNull(trn.duty_alloc_meth, 'C') 
               ,trn.frt_alloc_meth = IsNull(trn.frt_alloc_meth, 'C') 
               ,trn.brk_alloc_meth = IsNull(trn.brk_alloc_meth, 'C') 
               ,trn.duty_alloc_type = IsNull(trn.duty_alloc_type, '%') 
               ,trn.frt_alloc_type = IsNull(trn.frt_alloc_type, '%') 
               ,trn.brk_alloc_type = IsNull(trn.brk_alloc_type, '%') 
               ,trn.ins_alloc_percent = IsNull(trn.ins_alloc_percent, 0) 
               ,trn.ins_alloc_type = IsNull(trn.ins_alloc_type, '%') 
               ,trn.est_insurance_amt = IsNull(trn.est_insurance_amt, 0) 
               ,trn.ins_alloc_meth = IsNull(trn.ins_alloc_meth, 'C') 
               ,trn.act_insurance_amt = IsNull(trn.act_insurance_amt, 0) 
               ,trn.insurance_amt_t = IsNull(trn.insurance_amt_t, 0) 
               ,trn.loc_frt_alloc_percent = IsNull(trn.loc_frt_alloc_percent, 0) 
               ,trn.loc_frt_alloc_type = IsNull(trn.loc_frt_alloc_type, '%') 
               ,trn.est_local_freight_amt = IsNull(trn.est_local_freight_amt, 0) 
               ,trn.loc_frt_alloc_meth = IsNull(trn.loc_frt_alloc_meth, 'C') 
               ,trn.act_local_freight_amt = IsNull(trn.act_local_freight_amt, 0) 
               ,trn.local_freight_amt_t = IsNull(trn.local_freight_amt_t, 0) 
               ,trn.export_type = IsNull(trn.export_type, 'N') 
               ,trn.order_date = IsNull(trn.order_date, GetDate()) 
               ,trn.trn_num = IsNull( real_trn.trn_num 
                                     ,(CASE When IsNull(trn.trn_num, '') = '' 
                                            Then 'TBD' 
                                            Else (CASE When LTRIM(RTRIM(trn.trn_num)) <> 'TBD' 
                                                       Then dbo.ExpandKyByType('TrnNumType', trn.trn_num) 
                                                       Else 'TBD' 
                                                  End 
                                                 ) 
                                       End 
                                      ) 
                                    ) 
               ,trn.from_site = fs.site 
               ,trn.to_site   = ts.site 
               ,trn.from_whse = fw.whse 
               ,trn.to_whse   = tw.whse 
               ,trn.trans_nat = IsNull(trn.trans_nat, tw.trans_nat) 
               ,trn.trans_nat_2 = IsNull(trn.trans_nat_2, tw.trans_nat_2) 
               ,trn.delterm = IsNull(trn.delterm, tw.delterm) 
               ,trn.process_ind = IsNull(trn.process_ind, tw.process_ind) 
From #RUSXDE_transfer          as trn 
left join dbo.transfer         as real_trn On LTRIM(RTRIM(real_trn.trn_num))= LTRIM(RTRIM(trn.trn_num)) 
left join dbo.site             as fs       On     LTRIM(RTRIM(fs.site)) = LTRIM(RTRIM(trn.from_site)) 
                                              And fs.type               = 'S' 
left join dbo.site             as ts       On     LTRIM(RTRIM(ts.site)) = LTRIM(RTRIM(trn.to_site)) 
                                              And ts.type               = 'S' 
left join dbo.whse_all         as fw       On     LTRIM(RTRIM(fw.whse)) = LTRIM(RTRIM(trn.from_whse)) 
                                              And fw.site_ref           = fs.site 
left join dbo.whse_all         as tw       On     LTRIM(RTRIM(tw.whse)) = LTRIM(RTRIM(trn.to_whse)) 
                                              And tw.site_ref           = ts.site 
left join dbo.site             as es       On     LTRIM(RTRIM(es.site)) = LTRIM(RTRIM(trn.entered_site)) 
                                              And es.type               = 'S' 
-- -- -- left join dbo.trans_nature_all as tna      On     LTRIM(RTRIM(tna.trans_nat)) = LTRIM(RTRIM(trn.trans_nat)) 
-- -- --                                               And tna.site_ref = fs.site 
-- -- -- left join dbo.trans_nature_2   as tn2      On     LTRIM(RTRIM(tn2.trans_nat_2)) = LTRIM(RTRIM(trn.trans_nat2)) 
-- -- -- left join dbo.del_term_all     as dta      On     LTRIM(RTRIM(dta.delterm)) = LTRIM(RTRIM(trn.delterm)) 
-- -- --                                               And dta.site_ref = fs.site 

Update tri Set  tri.trn_line = IsNull(tri.trn_line, 0) 
--               ,tri.stat = IsNull(tri.stat, 'O') 
               ,tri.qty_req = IsNull(tri.qty_req, 0) 
               ,tri.qty_shipped = IsNull(tri.qty_shipped, 0) 
               ,tri.qty_received = IsNull(tri.qty_received, 0) 
               ,tri.qty_loss = IsNull(tri.qty_loss, 0) 
               ,tri.unit_cost = IsNull(tri.unit_cost, 0) 
               ,tri.frm_ref_type = IsNull(tri.frm_ref_type, 'I') 
               ,tri.frm_ref_line_suf = IsNull(tri.frm_ref_line_suf, 0) 
               ,tri.frm_ref_release = IsNull(tri.frm_ref_release, 0) 
               ,tri.qty_packed = IsNull(tri.qty_packed, 0) 
               ,tri.qty_req_conv = IsNull(tri.qty_req_conv, 0) 
               ,tri.matl_cost = IsNull(tri.matl_cost, 0) 
               ,tri.lbr_cost = IsNull(tri.lbr_cost, 0) 
               ,tri.fovhd_cost = IsNull(tri.fovhd_cost, 0) 
               ,tri.vovhd_cost = IsNull(tri.vovhd_cost, 0) 
               ,tri.out_cost = IsNull(tri.out_cost, 0) 
               ,tri.sch_rcv_date = IsNull(tri.sch_rcv_date, GetDate()) 
               ,tri.sch_ship_date = IsNull(tri.sch_ship_date, GetDate()) 
               ,tri.unit_price = IsNull(tri.unit_price, 0) 
               ,tri.to_ref_type = IsNull(tri.to_ref_type, 'I') 
               ,tri.to_ref_line_suf = IsNull(tri.to_ref_line_suf, 0) 
               ,tri.to_ref_release = IsNull(tri.to_ref_release, 0) 
               ,tri.cross_site = IsNull(tri.cross_site, 0) 
               ,tri.unit_freight_cost = IsNull(tri.unit_freight_cost, 0) 
               ,tri.unit_freight_cost_conv = IsNull(tri.unit_freight_cost_conv, 0) 
               ,tri.unit_brokerage_cost = IsNull(tri.unit_brokerage_cost, 0) 
               ,tri.unit_brokerage_cost_conv = IsNull(tri.unit_brokerage_cost_conv, 0) 
               ,tri.unit_duty_cost = IsNull(tri.unit_duty_cost, 0) 
               ,tri.unit_duty_cost_conv = IsNull(tri.unit_duty_cost_conv, 0) 
               ,tri.unit_mat_cost = IsNull(tri.unit_mat_cost, 0) 
               ,tri.unit_mat_cost_conv = IsNull(tri.unit_mat_cost_conv, 0) 
               ,tri.unit_weight = IsNull(tri.unit_weight, 0) 
               ,tri.lc_override = IsNull(tri.lc_override, 0) 
               ,tri.cons_num = IsNull(tri.cons_num, 0) 
               ,tri.unit_insurance_cost = IsNull(tri.unit_insurance_cost, 0) 
               ,tri.unit_insurance_cost_conv = IsNull(tri.unit_insurance_cost_conv, 0) 
               ,tri.unit_loc_frt_cost = IsNull(tri.unit_loc_frt_cost, 0) 
               ,tri.unit_loc_frt_cost_conv = IsNull(tri.unit_loc_frt_cost_conv, 0) 
               ,tri.suppl_qty_conv_factor = IsNull(tri.suppl_qty_conv_factor, 1) 
               ,tri.trn_num = IsNull(real_trn.trn_num 
                                     ,(CASE When IsNull(tri.trn_num, '') = '' 
                                            Then 'TBD' 
                                            Else (CASE When LTRIM(RTRIM(tri.trn_num)) <> 'TBD' 
                                                       Then dbo.ExpandKyByType('TrnNumType', tri.trn_num) 
                                                       Else 'TBD' 
                                                  End 
                                                 ) 
                                       End 
                                      ) 
                                    ) 
               ,tri.item = itm.item 
               ,tri.u_m = (CASE When tri.u_m Is Not Null 
                                Then um.u_m 
                                Else itm.u_m 
                           End 
                          ) 
               ,tri.trn_loc = (CASE When tri.trn_loc Is Not Null And LEN(tri.trn_loc) > 0 And loc.loc Is Not Null 
                                    Then loc.loc 
                                    Else tri.trn_loc 
                               End 
                              ) 
               ,tri.RUS_co_num = (CASE When tri.RUS_co_num Is Not Null And LEN(tri.RUS_co_num) > 0 And co.co_num Is Not Null 
                                    Then co.co_num 
                                    Else tri.RUS_co_num 
                               End 
                              ) 
From #RUSXDE_trnitem       as tri 
left join dbo.transfer     as real_trn On LTRIM(RTRIM(real_trn.trn_num)) = LTRIM(RTRIM(tri.trn_num)) 
left join dbo.item         as itm      On LTRIM(RTRIM(itm.item))         = LTRIM(RTRIM(tri.item)) 
left join dbo.u_m          as um       On LTRIM(RTRIM(um.u_m))           = LTRIM(RTRIM(tri.u_m)) 
left join dbo.location_all as loc      On LTRIM(RTRIM(loc.loc))          = LTRIM(RTRIM(tri.trn_loc)) And loc.loc_type = 'T' 
left join dbo.co           as co       On LTRIM(RTRIM(co.co_num))        = LTRIM(RTRIM(tri.RUS_co_num)) 

Update tri Set  tri.stat        = (CASE When tri.stat Is Null Or LEN(tri.stat) = 0 
                                        Then trn.stat 
                                        Else tri.stat 
                                   End 
                                  ) 
               ,tri.trans_nat   = trn.trans_nat 
               ,tri.delterm     = trn.delterm 
               ,tri.process_ind = trn.process_ind 
               ,tri.from_site   = trn.from_site 
               ,tri.to_site     = trn.to_site 
               ,tri.from_whse   = trn.from_whse 
               ,tri.to_whse     = trn.to_whse 
From #RUSXDE_trnitem  as tri 
join #RUSXDE_transfer as trn On trn.trn_num = tri.trn_num 

Update tri 
           Set tri.trn_loc = IsNull(il.loc, il_default.loc) 
From #RUSXDE_trnitem  as tri 
left join dbo.itemloc_all as il On     il.loc      = tri.trn_loc 
                                   And il.whse     = tri.to_whse 
                                   And il.site_ref = tri.to_site 
                                   And il.item     = tri.item 
                                   And il.loc_type = 'T' 
left join dbo.itemloc_all as il_default On      il_default.loc      = tri.trn_loc 
                                            And il_default.site_ref = tri.to_site 
                                            And il_default.item     = tri.item 
                                            And il_default.loc_type = 'T' 
                                            And il_default.rank     = (Select MIN(rank) 
                                                                       From dbo.itemloc_all 
                                                                       Where     loc      = tri.trn_loc 
                                                                             And site_ref = tri.to_site 
                                                                             And item     = tri.item 
                                                                             And loc_type = 'T' 
                                                                      ) 
-- end of preparing 

If OBJECT_ID('tempdb..#ErrorCodes') Is Not Null Drop Table #ErrorCodes

-- Select -20, 'В файле содержится две или более шапки смет, где co_num не указано, либо пусто' Union 
-- Select -25, 'В файле содержится две или более строки сметы, совпадающие по co_num и co_line' Union 
-- Select -27, 'В файле содержится строка сметы, где item не указан, либо не входит в справочник "Изделия"' Union 
-- Select -28, 'В файле содержится строка сметы, где указанный u_m не входит в справочник "Единицы измерения"' Union 

Create Table #ErrorCodes (ErrorCode int, ErrMsg varchar(255))

Insert Into #ErrorCodes 
Select  -1, 'В шапках ЗнП (тэги trn) содержится строка с неверным from_site (from_site не указан или не входит в справочник Предприятия/Объекты)' Union 
Select  -2, 'В шапках ЗнП (тэги trn) содержится строка с неверным to_site (to_site не указан или не входит в справочник Предприятия/Объекты)' Union 
Select  -3, 'В шапках ЗнП (тэги trn) содержится строка с неверным from_whse (from_whse не указан или не входит в справочник Склады)' Union 
Select  -4, 'В шапках ЗнП (тэги trn) содержится строка с неверным to_whse (to_whse не указан или не входит в справочник Склады)' Union 
Select  -5, 'В шапках ЗнП (тэги trn) содержится строка, где указанный stat не входит в перечень допустимых значений - O, T, C' Union 
Select  -6, 'В шапках ЗнП (тэги trn) содержится строка с неверным entered_site (entered_site не входит в справочник Предприятия/Объекты)' Union 
Select  -7, 'В шапках ЗнП (тэги trn) содержится строка, где указанный brk_alloc_meth не входит в перечень допустимых значений - U, W, C' Union 
Select  -8, 'В шапках ЗнП (тэги trn) содержится строка, где указанный brk_alloc_type не входит в перечень допустимых значений - $, %' Union 
Select  -9, 'В шапках ЗнП (тэги trn) содержится строка, где указанный duty_alloc_meth не входит в перечень допустимых значений - U, W, C' Union 
Select -10, 'В шапках ЗнП (тэги trn) содержится строка, где указанный duty_alloc_type не входит в перечень допустимых значений - $, %' Union 
Select -11, 'В шапках ЗнП (тэги trn) содержится строка, где указанный exch_rate <= 0 (должен быть > 0)' Union 
Select -12, 'В шапках ЗнП (тэги trn) содержится строка, где указанный export_type не входит в перечень допустимых значений - D, I, N' Union 
Select -13, 'В шапках ЗнП (тэги trn) содержится строка, где указанный frt_alloc_meth не входит в перечень допустимых значений - U, W, C' Union 
Select -14, 'В шапках ЗнП (тэги trn) содержится строка, где указанный frt_alloc_type не входит в перечень допустимых значений - $, %' Union 
Select -15, 'В шапках ЗнП (тэги trn) содержится строка, где указанный ins_alloc_meth не входит в перечень допустимых значений - U, W, C' Union 
Select -16, 'В шапках ЗнП (тэги trn) содержится строка, где указанный ins_alloc_type не входит в перечень допустимых значений - $, %' Union 
Select -17, 'В шапках ЗнП (тэги trn) содержится строка, где указанный loc_frt_alloc_meth не входит в перечень допустимых значений - U, W, C' Union 
Select -18, 'В шапках ЗнП (тэги trn) содержится строка, где указанный loc_frt_alloc_type не входит в перечень допустимых значений - $, %' Union 
Select -19, 'В шапках ЗнП (тэги trn) содержится две или более строк, совпадающих по trn_num' Union 
Select -20, 'В строках ЗнП (тэги tri) содержится две или более строк, совпадающих по trn_num и trn_line' Union 
Select -21, 'В строках ЗнП (тэги tri) содержится строка ЗнП, где item не указан, либо не входит в справочник "Изделия"' Union 
Select -22, 'В строках ЗнП (тэги tri) содержится строка, где указанный stat не входит в перечень допустимых значений - O, T, C' Union 
Select -23, 'В строках ЗнП (тэги tri) содержится строка ЗнП, где указанный u_m не входит в справочник "Изделия"' Union 
Select -24, 'В строках ЗнП (тэги tri) содержится строка ЗнП, где указанный trn_line <= 0 (должен быть > 0)' Union 
Select -25, 'В строках ЗнП (тэги tri) содержится строка ЗнП, где не указан trn_line' Union 
Select -26, 'В строках ЗнП (тэги tri) содержится строка, где указанный cross_site не входит в перечень допустимых значений - 0, 1' Union 
Select -27, 'В строках ЗнП (тэги tri) содержится строка, где указанный lc_override не входит в перечень допустимых значений - 0, 1' Union 
Select -28, 'В строках ЗнП (тэги tri) содержится строка, где указанный qty_req_conv < 0 (должен быть >= 0 )' Union 
Select -29, 'В строках ЗнП (тэги tri) содержится строка, где указанный suppl_qty_conv_factor = 0 (должен быть <> 0 )' Union 
Select -30, 'В строках ЗнП (тэги tri) содержится строка, где указанный frm_ref_type не входит в перечень допустимых значений - R, J, P, I' Union 
Select -31, 'В строках ЗнП (тэги tri) содержится строка, где указанный to_ref_type не входит в перечень допустимых значений - O, J, I' Union 
Select -32, 'В строках ЗнП (тэги tri) содержится строка, где указанный trn_loc не входит в справочник "Места складирования" (тип - транзитное)' Union 
Select -33, 'В строках ЗнП (тэги tri) содержится строка, где указанный RUS_co_num не существует в заказах клиентов' Union 
Select -34, 'В строках ЗнП (тэги tri) содержится строка, где trn_loc не соответствует критериям транзитного склада' Union 
Select -35, 'В строках ЗнП (тэги tri) содержится строка, где sch_ship_date не указано' Union 
Select -36, 'В строках ЗнП (тэги tri) содержится строка, где sch_rcv_date не указано' 

-- check section open
If @LogFlag = 1 
     exec dbo.RUS_DiagnosticInTXTSp '', @LogFile, 2 -- delete old log

Set @ErrorCode = 0 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where from_site Is Null 
          ) 
Set @ErrorCode = -1 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where to_site Is Null 
          ) 
Set @ErrorCode = -2 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where from_whse Is Null 
          ) 
Set @ErrorCode = -3 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where to_whse Is Null 
          ) 
Set @ErrorCode = -4 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where stat Not In ('O', 'T', 'C') 
          ) 
Set @ErrorCode = -5 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where entered_site Is Null 
          ) 
Set @ErrorCode = -6 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where brk_alloc_meth Not In ('U', 'W', 'C') 
          ) 
Set @ErrorCode = -7 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where brk_alloc_type Not In ('$', '%') 
          ) 
Set @ErrorCode = -8 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where duty_alloc_meth Not In ('U', 'W', 'C') 
          ) 
Set @ErrorCode = -9 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where duty_alloc_type Not In ('$', '%') 
          ) 
Set @ErrorCode = -10 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where exch_rate <= 0 
          ) 
Set @ErrorCode = -11 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where export_type Not In ('D', 'I', 'N') 
          ) 
Set @ErrorCode = -12 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where frt_alloc_meth Not In ('U', 'W', 'C') 
          ) 
Set @ErrorCode = -13 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where frt_alloc_type Not In ('$', '%') 
          ) 
Set @ErrorCode = -14 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where ins_alloc_meth Not In ('U', 'W', 'C') 
          ) 
Set @ErrorCode = -15 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where ins_alloc_type Not In ('$', '%') 
          ) 
Set @ErrorCode = -16 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where loc_frt_alloc_meth Not In ('U', 'W', 'C') 
          ) 
Set @ErrorCode = -17 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_transfer 
           Where loc_frt_alloc_type Not In ('$', '%') 
          ) 
Set @ErrorCode = -18 

If @ErrorCode = 0 
If Exists (Select LTRIM(RTRIM(IsNull(trn_num, ''))) 
           From #RUSXDE_transfer 
           Group By LTRIM(RTRIM(IsNull(trn_num, ''))) 
           Having Count(*) > 1 
          ) 
Set @ErrorCode = -19 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where trn_line Is Null 
          ) 
Set @ErrorCode = -25 

If @ErrorCode = 0 
If Exists (Select LTRIM(RTRIM(IsNull(trn_num, ''))), trn_line 
           From #RUSXDE_trnitem 
           Group By LTRIM(RTRIM(IsNull(trn_num, ''))), trn_line 
           Having Count(*) > 1 
          ) 
Set @ErrorCode = -20 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where item Is Null 
          ) 
Set @ErrorCode = -21 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where     stat Is Not Null 
                 And stat Not In ('O', 'T', 'C') 
          ) 
Set @ErrorCode = -22  

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where u_m Is Null 
          ) 
Set @ErrorCode = -23 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where trn_line <= 0 
          ) 
Set @ErrorCode = -24 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where cross_site Not In (0, 1) 
          ) 
Set @ErrorCode = -26 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where lc_override Not In (0, 1) 
          ) 
Set @ErrorCode = -27 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where qty_req_conv < 0 
          ) 
Set @ErrorCode = -28 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where suppl_qty_conv_factor = 0 
          ) 
Set @ErrorCode = -29 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where frm_ref_type Not In ('R', 'J', 'P', 'I') 
          ) 
Set @ErrorCode = -30 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where to_ref_type Not In ('O', 'J', 'I') 
          ) 
Set @ErrorCode = -31 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where     trn_loc Is Not Null 
                 And LEN(trn_loc) > 0 
                 And Not Exists (Select * 
                                 From dbo.location 
                                 Where     loc_type = 'T' 
                                       And loc = #RUSXDE_trnitem.trn_loc 
                                ) 
          ) 
Set @ErrorCode = -32 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where     RUS_co_num Is Not Null 
                 And LEN(RUS_co_num) > 0 
                 And Not Exists (Select * 
                                 From dbo.co 
                                 Where co_num = #RUSXDE_trnitem.RUS_co_num 
                                ) 
          ) 
Set @ErrorCode = -33 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where trn_loc Is Null 
          ) 
Set @ErrorCode = -34 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where sch_ship_date Is Null 
          ) 
Set @ErrorCode = -35 

If @ErrorCode = 0 
If Exists (Select * 
           From #RUSXDE_trnitem 
           Where sch_rcv_date Is Null 
          ) 
Set @ErrorCode = -36 


-- If @ErrorCode = 0 
-- If Exists (Select * 
--            From #RUSXDE_trnitem 
--            Where     packed Is Not Null 
--                  And packed Not In (0, 1) 
--           ) 
-- Set @ErrorCode = -15 


-- Check section closed 

-- Receipt section open
If @ErrorCode = 0
Begin 

     If @LogFlag = 1 exec dbo.RUS_DiagnosticInTXTSp @ParamToSave = 'Receipt section open', @LogFile = @LogFile, @AppendFlag = 0

     Declare trn_cur Cursor For Select  trn.trn_num 
                                       ,trn.from_whse 
                                       ,trn.to_whse 
                                       ,trn.stat 
                                       ,trn.ship_code 
                                       ,trn.weight 
                                       ,trn.qty_packages 
                                       ,trn.from_site 
                                       ,trn.to_site 
                                       ,trn.entered_site 
                                       ,trn.fob_site 
                                       ,trn.exch_rate 
                                       ,trn.freight_vendor 
                                       ,trn.duty_vendor 
                                       ,trn.brokerage_vendor 
                                       ,trn.frt_alloc_percent 
                                       ,trn.duty_alloc_percent 
                                       ,trn.brk_alloc_percent 
                                       ,trn.est_freight_amt 
                                       ,trn.act_freight_amt 
                                       ,trn.est_brokerage_amt 
                                       ,trn.act_brokerage_amt 
                                       ,trn.est_duty_amt 
                                       ,trn.act_duty_amt 
                                       ,trn.freight_amt_t 
                                       ,trn.brokerage_amt_t 
                                       ,trn.duty_amt_t 
                                       ,trn.duty_alloc_meth 
                                       ,trn.frt_alloc_meth 
                                       ,trn.brk_alloc_meth 
                                       ,trn.duty_alloc_type 
                                       ,trn.frt_alloc_type 
                                       ,trn.brk_alloc_type 
                                       ,trn.trans_nat 
                                       ,trn.process_ind 
                                       ,trn.delterm 
                                       ,trn.ins_vendor 
                                       ,trn.ins_alloc_percent 
                                       ,trn.ins_alloc_type 
                                       ,trn.est_insurance_amt 
                                       ,trn.ins_alloc_meth 
                                       ,trn.act_insurance_amt 
                                       ,trn.insurance_amt_t 
                                       ,trn.loc_frt_vendor 
                                       ,trn.loc_frt_alloc_percent 
                                       ,trn.loc_frt_alloc_type 
                                       ,trn.est_local_freight_amt 
                                       ,trn.loc_frt_alloc_meth 
                                       ,trn.act_local_freight_amt 
                                       ,trn.local_freight_amt_t 
                                       ,trn.trans_nat_2 
                                       ,trn.export_type 
                                       ,trn.order_date 
                                From #RUSXDE_transfer as trn 

     Open trn_cur

     Fetch Next From trn_cur Into  @trn_num 
                                  ,@from_whse 
                                  ,@to_whse 
                                  ,@stat 
                                  ,@ship_code 
                                  ,@weight 
                                  ,@qty_packages 
                                  ,@from_site 
                                  ,@to_site 
                                  ,@entered_site 
                                  ,@fob_site 
                                  ,@exch_rate 
                                  ,@freight_vendor 
                                  ,@duty_vendor 
                                  ,@brokerage_vendor 
                                  ,@frt_alloc_percent 
                                  ,@duty_alloc_percent 
                                  ,@brk_alloc_percent 
                                  ,@est_freight_amt 
                                  ,@act_freight_amt 
                                  ,@est_brokerage_amt 
                                  ,@act_brokerage_amt 
                                  ,@est_duty_amt 
                                  ,@act_duty_amt 
                                  ,@freight_amt_t 
                                  ,@brokerage_amt_t 
                                  ,@duty_amt_t 
                                  ,@duty_alloc_meth 
                                  ,@frt_alloc_meth 
                                  ,@brk_alloc_meth 
                                  ,@duty_alloc_type 
                                  ,@frt_alloc_type 
                                  ,@brk_alloc_type 
                                  ,@trans_nat 
                                  ,@process_ind 
                                  ,@delterm 
                                  ,@ins_vendor 
                                  ,@ins_alloc_percent 
                                  ,@ins_alloc_type 
                                  ,@est_insurance_amt 
                                  ,@ins_alloc_meth 
                                  ,@act_insurance_amt 
                                  ,@insurance_amt_t 
                                  ,@loc_frt_vendor 
                                  ,@loc_frt_alloc_percent 
                                  ,@loc_frt_alloc_type 
                                  ,@est_local_freight_amt 
                                  ,@loc_frt_alloc_meth 
                                  ,@act_local_freight_amt 
                                  ,@local_freight_amt_t 
                                  ,@trans_nat_2 
                                  ,@export_type 
                                  ,@order_date 

     While @@FETCH_STATUS = 0 And @ErrorCode = 0
     Begin

          If    @trn_num = 'TBD' 
             Or     @trn_num <> 'TBD' 
                And Not Exists (Select * 
                                From dbo.transfer 
                                Where trn_num = @trn_num 
                               ) 
               Set @IsNewTrn = 1 
          Else 
               Set @IsNewTrn = 0 

          If @IsNewTrn = 1 
          Begin 

               exec dbo.GetTransferFobSiteSp  @FromSite = @from_site 
                                             ,@ToSite   = @to_site 
                                             ,@FobSite  = @fob_site  OUTPUT 
                                             ,@ExchRate = @exch_rate OUTPUT 

               Insert Into dbo.transfer 
               ( 
                 trn_num 
                ,from_whse 
                ,to_whse 
                ,stat 
                ,ship_code 
                ,weight 
                ,qty_packages 
                ,from_site 
                ,to_site 
                ,entered_site 
                ,fob_site 
                ,exch_rate 
                ,freight_vendor 
                ,duty_vendor 
                ,brokerage_vendor 
                ,frt_alloc_percent 
                ,duty_alloc_percent 
                ,brk_alloc_percent 
                ,est_freight_amt 
                ,act_freight_amt 
                ,est_brokerage_amt 
                ,act_brokerage_amt 
                ,est_duty_amt 
                ,act_duty_amt 
                ,freight_amt_t 
                ,brokerage_amt_t 
                ,duty_amt_t 
                ,duty_alloc_meth 
                ,frt_alloc_meth 
                ,brk_alloc_meth 
                ,duty_alloc_type 
                ,frt_alloc_type 
                ,brk_alloc_type 
                ,trans_nat 
                ,process_ind 
                ,delterm 
                ,ins_vendor 
                ,ins_alloc_percent 
                ,ins_alloc_type 
                ,est_insurance_amt 
                ,ins_alloc_meth 
                ,act_insurance_amt 
                ,insurance_amt_t 
                ,loc_frt_vendor 
                ,loc_frt_alloc_percent 
                ,loc_frt_alloc_type 
                ,est_local_freight_amt 
                ,loc_frt_alloc_meth 
                ,act_local_freight_amt 
                ,local_freight_amt_t 
                ,trans_nat_2 
                ,export_type 
                ,order_date 
               ) 
               Select  @trn_num 
                      ,@from_whse 
                      ,@to_whse 
                      ,@stat 
                      ,@ship_code 
                      ,@weight 
                      ,@qty_packages 
                      ,@from_site 
                      ,@to_site 
                      ,@entered_site 
                      ,@fob_site 
                      ,@exch_rate 
                      ,@freight_vendor 
                      ,@duty_vendor 
                      ,@brokerage_vendor 
                      ,@frt_alloc_percent 
                      ,@duty_alloc_percent 
                      ,@brk_alloc_percent 
                      ,@est_freight_amt 
                      ,@act_freight_amt 
                      ,@est_brokerage_amt 
                      ,@act_brokerage_amt 
                      ,@est_duty_amt 
                      ,@act_duty_amt 
                      ,@freight_amt_t 
                      ,@brokerage_amt_t 
                      ,@duty_amt_t 
                      ,@duty_alloc_meth 
                      ,@frt_alloc_meth 
                      ,@brk_alloc_meth 
                      ,@duty_alloc_type 
                      ,@frt_alloc_type 
                      ,@brk_alloc_type 
                      ,@trans_nat 
                      ,@process_ind 
                      ,@delterm 
                      ,@ins_vendor 
                      ,@ins_alloc_percent 
                      ,@ins_alloc_type 
                      ,@est_insurance_amt 
                      ,@ins_alloc_meth 
                      ,@act_insurance_amt 
                      ,@insurance_amt_t 
                      ,@loc_frt_vendor 
                      ,@loc_frt_alloc_percent 
                      ,@loc_frt_alloc_type 
                      ,@est_local_freight_amt 
                      ,@loc_frt_alloc_meth 
                      ,@act_local_freight_amt 
                      ,@local_freight_amt_t 
                      ,@trans_nat_2 
                      ,@export_type 
                      ,@order_date 

               If @trn_num = 'TBD' 
               Begin 
                    Set @trn_num = (Select Top 1 trn_num 
                                    From dbo.transfer 
                                    Where     from_whse    = @from_whse 
                                          And to_whse      = @to_whse 
                                          And stat         = @stat 
                                          And weight       = @weight 
                                          And qty_packages = @qty_packages 
                                          And from_site    = @from_site 
                                          And to_site      = @to_site 
                                          And entered_site = @entered_site 
                                          And fob_site     = @fob_site 
                                          And exch_rate    = @exch_rate 
                                          And order_date   = @order_date 
                                    Order By CreateDate DESC 
                                   ) 

                    Update #RUSXDE_trnitem 
                                          Set trn_num = @trn_num 
                    Where trn_num = 'TBD' 
               End

          End 
          Else 
               Update dbo.transfer Set  from_whse = IsNull(@from_whse, from_whse) 
                                       ,to_whse = IsNull(@to_whse, to_whse) 
                                       ,stat = IsNull(@stat, stat) 
                                       ,ship_code = IsNull(@ship_code, ship_code) 
                                       ,weight = IsNull(@weight, weight) 
                                       ,qty_packages = IsNull(@qty_packages, qty_packages) 
                                       ,from_site = IsNull(@from_site, from_site) 
                                       ,to_site = IsNull(@to_site, to_site) 
                                       ,entered_site = IsNull(@entered_site, entered_site) 
                                       ,fob_site = IsNull(@fob_site, fob_site) 
                                       ,exch_rate = IsNull(@exch_rate, exch_rate) 
                                       ,freight_vendor = IsNull(@freight_vendor, freight_vendor) 
                                       ,duty_vendor = IsNull(@duty_vendor, duty_vendor) 
                                       ,brokerage_vendor = IsNull(@brokerage_vendor, brokerage_vendor) 
                                       ,frt_alloc_percent = IsNull(@frt_alloc_percent, frt_alloc_percent) 
                                       ,duty_alloc_percent = IsNull(@duty_alloc_percent, duty_alloc_percent) 
                                       ,brk_alloc_percent = IsNull(@brk_alloc_percent, brk_alloc_percent) 
                                       ,est_freight_amt = IsNull(@est_freight_amt, est_freight_amt) 
                                       ,act_freight_amt = IsNull(@act_freight_amt, act_freight_amt) 
                                       ,est_brokerage_amt = IsNull(@est_brokerage_amt, est_brokerage_amt) 
                                       ,act_brokerage_amt = IsNull(@act_brokerage_amt, act_brokerage_amt) 
                                       ,est_duty_amt = IsNull(@est_duty_amt, est_duty_amt) 
                                       ,act_duty_amt = IsNull(@act_duty_amt, act_duty_amt) 
                                       ,freight_amt_t = IsNull(@freight_amt_t, freight_amt_t) 
                                       ,brokerage_amt_t = IsNull(@brokerage_amt_t, brokerage_amt_t) 
                                       ,duty_amt_t = IsNull(@duty_amt_t, duty_amt_t) 
                                       ,duty_alloc_meth = IsNull(@duty_alloc_meth, duty_alloc_meth) 
                                       ,frt_alloc_meth = IsNull(@frt_alloc_meth, frt_alloc_meth) 
                                       ,brk_alloc_meth = IsNull(@brk_alloc_meth, brk_alloc_meth) 
                                       ,duty_alloc_type = IsNull(@duty_alloc_type, duty_alloc_type) 
                                       ,frt_alloc_type = IsNull(@frt_alloc_type, frt_alloc_type) 
                                       ,brk_alloc_type = IsNull(@brk_alloc_type, brk_alloc_type) 
                                       ,trans_nat = IsNull(@trans_nat, trans_nat) 
                                       ,process_ind = IsNull(@process_ind, process_ind) 
                                       ,delterm = IsNull(@delterm, delterm) 
                                       ,ins_vendor = IsNull(@ins_vendor, ins_vendor) 
                                       ,ins_alloc_percent = IsNull(@ins_alloc_percent, ins_alloc_percent) 
                                       ,ins_alloc_type = IsNull(@ins_alloc_type, ins_alloc_type) 
                                       ,est_insurance_amt = IsNull(@est_insurance_amt, est_insurance_amt) 
                                       ,ins_alloc_meth = IsNull(@ins_alloc_meth, ins_alloc_meth) 
                                       ,act_insurance_amt = IsNull(@act_insurance_amt, act_insurance_amt) 
                                       ,insurance_amt_t = IsNull(@insurance_amt_t, insurance_amt_t) 
                                       ,loc_frt_vendor = IsNull(@loc_frt_vendor, loc_frt_vendor) 
                                       ,loc_frt_alloc_percent = IsNull(@loc_frt_alloc_percent, loc_frt_alloc_percent) 
                                       ,loc_frt_alloc_type = IsNull(@loc_frt_alloc_type, loc_frt_alloc_type) 
                                       ,est_local_freight_amt = IsNull(@est_local_freight_amt, est_local_freight_amt) 
                                       ,loc_frt_alloc_meth = IsNull(@loc_frt_alloc_meth, loc_frt_alloc_meth) 
                                       ,act_local_freight_amt = IsNull(@act_local_freight_amt, act_local_freight_amt) 
                                       ,local_freight_amt_t = IsNull(@local_freight_amt_t, local_freight_amt_t) 
                                       ,trans_nat_2 = IsNull(@trans_nat_2, trans_nat_2) 
                                       ,export_type = IsNull(@export_type, export_type) 
                                       ,order_date = IsNull(@order_date, order_date) 
               Where trn_num = @trn_num 
                               
               Declare tri_cur Cursor For Select  trn_num 
                                                 ,trn_line 
                                                 ,stat 
                                                 ,item 
                                                 ,trn_loc 
                                                 ,ship_date 
                                                 ,rcvd_date 
                                                 ,qty_req 
                                                 ,qty_shipped 
                                                 ,qty_received 
                                                 ,qty_loss 
                                                 ,unit_cost 
                                                 ,frm_ref_type 
                                                 ,frm_ref_num 
                                                 ,frm_ref_line_suf 
                                                 ,frm_ref_release 
                                                 ,qty_packed 
                                                 ,pick_date 
                                                 ,qty_req_conv 
                                                 ,u_m 
                                                 ,matl_cost 
                                                 ,lbr_cost 
                                                 ,fovhd_cost 
                                                 ,vovhd_cost 
                                                 ,out_cost 
                                                 ,sch_rcv_date 
                                                 ,sch_ship_date 
                                                 ,unit_price 
                                                 ,pricecode 
                                                 ,to_ref_type 
                                                 ,to_ref_num 
                                                 ,to_ref_line_suf 
                                                 ,to_ref_release 
                                                 ,from_site 
                                                 ,from_whse 
                                                 ,to_site 
                                                 ,to_whse 
                                                 ,cross_site 
                                                 ,unit_freight_cost 
                                                 ,unit_freight_cost_conv 
                                                 ,unit_brokerage_cost 
                                                 ,unit_brokerage_cost_conv 
                                                 ,unit_duty_cost 
                                                 ,unit_duty_cost_conv 
                                                 ,unit_mat_cost 
                                                 ,unit_mat_cost_conv 
                                                 ,unit_weight 
                                                 ,lc_override 
                                                 ,projected_date 
                                                 ,comm_code 
                                                 ,trans_nat 
                                                 ,process_ind 
                                                 ,delterm 
                                                 ,origin 
                                                 ,cons_num 
                                                 ,export_value 
                                                 ,ec_code 
                                                 ,transport 
                                                 ,unit_insurance_cost 
                                                 ,unit_insurance_cost_conv 
                                                 ,unit_loc_frt_cost 
                                                 ,unit_loc_frt_cost_conv 
                                                 ,trans_nat_2 
                                                 ,suppl_qty_conv_factor 
                                                 ,RUS_co_num 
                                                 ,RUS_jobssd 
                                                 ,Tip_writing 
                                                 ,Tip_costs 
                                                 ,object 
                                                 ,Balance_sheet 
               From #RUSXDE_trnitem 
               Where trn_num = @trn_num 

               Open tri_cur
               Fetch Next From tri_cur Into  @tri_trn_num 
                                            ,@tri_trn_line 
                                            ,@tri_stat 
                                            ,@tri_item 
                                            ,@tri_trn_loc 
                                            ,@tri_ship_date 
                                            ,@tri_rcvd_date 
                                            ,@tri_qty_req 
                                            ,@tri_qty_shipped 
                                            ,@tri_qty_received 
                                            ,@tri_qty_loss 
                                            ,@tri_unit_cost 
                                            ,@tri_frm_ref_type 
                                            ,@tri_frm_ref_num 
                                            ,@tri_frm_ref_line_suf 
                                            ,@tri_frm_ref_release 
                                            ,@tri_qty_packed 
                                            ,@tri_pick_date 
                                            ,@tri_qty_req_conv 
                                            ,@tri_u_m 
                                            ,@tri_matl_cost 
                                            ,@tri_lbr_cost 
                                            ,@tri_fovhd_cost 
                                            ,@tri_vovhd_cost 
                                            ,@tri_out_cost 
                                            ,@tri_sch_rcv_date 
                                            ,@tri_sch_ship_date 
                                            ,@tri_unit_price 
                                            ,@tri_pricecode 
                                            ,@tri_to_ref_type 
                                            ,@tri_to_ref_num 
                                            ,@tri_to_ref_line_suf 
                                            ,@tri_to_ref_release 
                                            ,@tri_from_site 
                                            ,@tri_from_whse 
                                            ,@tri_to_site 
                                            ,@tri_to_whse 
                                            ,@tri_cross_site 
                                            ,@tri_unit_freight_cost 
                                            ,@tri_unit_freight_cost_conv 
                                            ,@tri_unit_brokerage_cost 
                                            ,@tri_unit_brokerage_cost_conv 
                                            ,@tri_unit_duty_cost 
                                            ,@tri_unit_duty_cost_conv 
                                            ,@tri_unit_mat_cost 
                                            ,@tri_unit_mat_cost_conv 
                                            ,@tri_unit_weight 
                                            ,@tri_lc_override 
                                            ,@tri_projected_date 
                                            ,@tri_comm_code 
                                            ,@tri_trans_nat 
                                            ,@tri_process_ind 
                                            ,@tri_delterm 
                                            ,@tri_origin 
                                            ,@tri_cons_num 
                                            ,@tri_export_value 
                                            ,@tri_ec_code 
                                            ,@tri_transport 
                                            ,@tri_unit_insurance_cost 
                                            ,@tri_unit_insurance_cost_conv 
                                            ,@tri_unit_loc_frt_cost 
                                            ,@tri_unit_loc_frt_cost_conv 
                                            ,@tri_trans_nat_2 
                                            ,@tri_suppl_qty_conv_factor 
                                            ,@tri_RUS_co_num 
                                            ,@tri_RUS_jobssd 
                                            ,@tri_Tip_writing 
                                            ,@tri_Tip_costs 
                                            ,@tri_object 
                                            ,@tri_Balance_sheet 

               While @@FETCH_STATUS = 0 And @ErrorCode = 0
               Begin

                    If Not Exists (Select * 
                                   From dbo.trnitem 
                                   Where     trn_num  = @tri_trn_num 
                                         And trn_line = @tri_trn_line 
                                  ) 
                         Set @IsNewTrnItem = 1 
                    Else 
                         Set @IsNewTrnItem = 0 

--                    Set @NewRecordFlag = @IsNewTrnItem 

                    If @IsNewTrnItem = 1 
                    Begin 

                         Insert Into dbo.trnitem 
                         (
                           trn_num 
                          ,trn_line 
                          ,stat 
                          ,item 
                          ,trn_loc 
                          ,ship_date 
                          ,rcvd_date 
                          ,qty_req 
                          ,qty_shipped 
                          ,qty_received 
                          ,qty_loss 
                          ,unit_cost 
                          ,frm_ref_type 
                          ,frm_ref_num 
                          ,frm_ref_line_suf 
                          ,frm_ref_release 
                          ,qty_packed 
                          ,pick_date 
                          ,qty_req_conv 
                          ,u_m 
                          ,matl_cost 
                          ,lbr_cost 
                          ,fovhd_cost 
                          ,vovhd_cost 
                          ,out_cost 
                          ,sch_rcv_date 
                          ,sch_ship_date 
                          ,unit_price 
                          ,pricecode 
                          ,to_ref_type 
                          ,to_ref_num 
                          ,to_ref_line_suf 
                          ,to_ref_release 
                          ,from_site 
                          ,from_whse 
                          ,to_site 
                          ,to_whse 
                          ,cross_site 
                          ,unit_freight_cost 
                          ,unit_freight_cost_conv 
                          ,unit_brokerage_cost 
                          ,unit_brokerage_cost_conv 
                          ,unit_duty_cost 
                          ,unit_duty_cost_conv 
                          ,unit_mat_cost 
                          ,unit_mat_cost_conv 
                          ,unit_weight 
                          ,lc_override 
                          ,projected_date 
                          ,comm_code 
                          ,trans_nat 
                          ,process_ind 
                          ,delterm 
                          ,origin 
                          ,cons_num 
                          ,export_value 
                          ,ec_code 
                          ,transport 
                          ,unit_insurance_cost 
                          ,unit_insurance_cost_conv 
                          ,unit_loc_frt_cost 
                          ,unit_loc_frt_cost_conv 
                          ,trans_nat_2 
                          ,suppl_qty_conv_factor 
                          ,RUS_co_num 
                          ,RUS_jobssd 
                          ,Uf_Tip_writing 
                          ,Uf_Tip_costs 
                          ,Uf_object 
                          ,Uf_Balance_sheet 
                         ) 
                         Select  @tri_trn_num 
                                ,@tri_trn_line 
                                ,@tri_stat 
                                ,@tri_item 
                                ,@tri_trn_loc 
                                ,@tri_ship_date 
                                ,@tri_rcvd_date 
                                ,@tri_qty_req 
                                ,@tri_qty_shipped 
                                ,@tri_qty_received 
                                ,@tri_qty_loss 
                                ,@tri_unit_cost 
                                ,@tri_frm_ref_type 
                                ,@tri_frm_ref_num 
                                ,@tri_frm_ref_line_suf 
                                ,@tri_frm_ref_release 
                                ,@tri_qty_packed 
                                ,@tri_pick_date 
                                ,@tri_qty_req_conv 
                                ,@tri_u_m 
                                ,@tri_matl_cost 
                                ,@tri_lbr_cost 
                                ,@tri_fovhd_cost 
                                ,@tri_vovhd_cost 
                                ,@tri_out_cost 
                                ,@tri_sch_rcv_date 
                                ,@tri_sch_ship_date 
                                ,@tri_unit_price 
                                ,@tri_pricecode 
                                ,@tri_to_ref_type 
                                ,@tri_to_ref_num 
                                ,@tri_to_ref_line_suf 
                                ,@tri_to_ref_release 
                                ,@tri_from_site 
                                ,@tri_from_whse 
                                ,@tri_to_site 
                                ,@tri_to_whse 
                                ,@tri_cross_site 
                                ,@tri_unit_freight_cost 
                                ,@tri_unit_freight_cost_conv 
                                ,@tri_unit_brokerage_cost 
                                ,@tri_unit_brokerage_cost_conv 
                                ,@tri_unit_duty_cost 
                                ,@tri_unit_duty_cost_conv 
                                ,@tri_unit_mat_cost 
                                ,@tri_unit_mat_cost_conv 
                                ,@tri_unit_weight 
                                ,@tri_lc_override 
                                ,@tri_projected_date 
                                ,@tri_comm_code 
                                ,@tri_trans_nat 
                                ,@tri_process_ind 
                                ,@tri_delterm 
                                ,@tri_origin 
                                ,@tri_cons_num 
                                ,@tri_export_value 
                                ,@tri_ec_code 
                                ,@tri_transport 
                                ,@tri_unit_insurance_cost 
                                ,@tri_unit_insurance_cost_conv 
                                ,@tri_unit_loc_frt_cost 
                                ,@tri_unit_loc_frt_cost_conv 
                                ,@tri_trans_nat_2 
                                ,@tri_suppl_qty_conv_factor 
                                ,@tri_RUS_co_num 
                                ,@tri_RUS_jobssd 
                                ,@tri_Tip_writing 
                                ,@tri_Tip_costs 
                                ,@tri_object 
                                ,@tri_Balance_sheet 
                    End 
                    Else 
                         Update dbo.trnitem Set  stat = IsNull(@tri_stat, stat) 
                                                ,item = IsNull(@tri_item, item) 
                                                ,trn_loc = IsNull(@tri_trn_loc, trn_loc) 
                                                ,ship_date = IsNull(@tri_ship_date, ship_date) 
                                                ,rcvd_date = IsNull(@tri_rcvd_date, rcvd_date) 
                                                ,qty_req = IsNull(@tri_qty_req, qty_req) 
                                                ,qty_shipped = IsNull(@tri_qty_shipped, qty_shipped) 
                                                ,qty_received = IsNull(@tri_qty_received, qty_received) 
                                                ,qty_loss = IsNull(@tri_qty_loss, qty_loss) 
                                                ,unit_cost = IsNull(@tri_unit_cost, unit_cost) 
                                                ,frm_ref_type = IsNull(@tri_frm_ref_type, frm_ref_type) 
                                                ,frm_ref_num = IsNull(@tri_frm_ref_num, frm_ref_num) 
                                                ,frm_ref_line_suf = IsNull(@tri_frm_ref_line_suf, frm_ref_line_suf) 
                                                ,frm_ref_release = IsNull(@tri_frm_ref_release, frm_ref_release) 
                                                ,qty_packed = IsNull(@tri_qty_packed, qty_packed) 
                                                ,pick_date = IsNull(@tri_pick_date, pick_date) 
                                                ,qty_req_conv = IsNull(@tri_qty_req_conv, qty_req_conv) 
                                                ,u_m = IsNull(@tri_u_m, u_m) 
                                                ,matl_cost = IsNull(@tri_matl_cost, matl_cost) 
                                                ,lbr_cost = IsNull(@tri_lbr_cost, lbr_cost) 
                                                ,fovhd_cost = IsNull(@tri_fovhd_cost, fovhd_cost) 
                                                ,vovhd_cost = IsNull(@tri_vovhd_cost, vovhd_cost) 
                                                ,out_cost = IsNull(@tri_out_cost, out_cost) 
                                                ,sch_rcv_date = IsNull(@tri_sch_rcv_date, sch_rcv_date) 
                                                ,sch_ship_date = IsNull(@tri_sch_ship_date, sch_ship_date) 
                                                ,unit_price = IsNull(@tri_unit_price, unit_price) 
                                                ,pricecode = IsNull(@tri_pricecode, pricecode) 
                                                ,to_ref_type = IsNull(@tri_to_ref_type, to_ref_type) 
                                                ,to_ref_num = IsNull(@tri_to_ref_num, to_ref_num) 
                                                ,to_ref_line_suf = IsNull(@tri_to_ref_line_suf, to_ref_line_suf) 
                                                ,to_ref_release = IsNull(@tri_to_ref_release, to_ref_release) 
                                                ,from_site = IsNull(@tri_from_site, from_site) 
                                                ,from_whse = IsNull(@tri_from_whse, from_whse) 
                                                ,to_site = IsNull(@tri_to_site, to_site) 
                                                ,to_whse = IsNull(@tri_to_whse, to_whse) 
                                                ,cross_site = IsNull(@tri_cross_site, cross_site) 
                                                ,unit_freight_cost = IsNull(@tri_unit_freight_cost, unit_freight_cost) 
                                                ,unit_freight_cost_conv = IsNull(@tri_unit_freight_cost_conv, unit_freight_cost_conv) 
                                                ,unit_brokerage_cost = IsNull(@tri_unit_brokerage_cost, unit_brokerage_cost) 
                                                ,unit_brokerage_cost_conv = IsNull(@tri_unit_brokerage_cost_conv, unit_brokerage_cost_conv) 
                                                ,unit_duty_cost = IsNull(@tri_unit_duty_cost, unit_duty_cost) 
                                                ,unit_duty_cost_conv = IsNull(@tri_unit_duty_cost_conv, unit_duty_cost_conv) 
                                                ,unit_mat_cost = IsNull(@tri_unit_mat_cost, unit_mat_cost) 
                                                ,unit_mat_cost_conv = IsNull(@tri_unit_mat_cost_conv, unit_mat_cost_conv) 
                                                ,unit_weight = IsNull(@tri_unit_weight, unit_weight) 
                                                ,lc_override = IsNull(@tri_lc_override, lc_override) 
                                                ,projected_date = IsNull(@tri_projected_date, projected_date) 
                                                ,comm_code = IsNull(@tri_comm_code, comm_code) 
                                                ,trans_nat = IsNull(@tri_trans_nat, trans_nat) 
                                                ,process_ind = IsNull(@tri_process_ind, process_ind) 
                                                ,delterm = IsNull(@tri_delterm, delterm) 
                                                ,origin = IsNull(@tri_origin, origin) 
                                                ,cons_num = IsNull(@tri_cons_num, cons_num) 
                                                ,export_value = IsNull(@tri_export_value, export_value) 
                                                ,ec_code = IsNull(@tri_ec_code, ec_code) 
                                                ,transport = IsNull(@tri_transport, transport) 
                                                ,unit_insurance_cost = IsNull(@tri_unit_insurance_cost, unit_insurance_cost) 
                                                ,unit_insurance_cost_conv = IsNull(@tri_unit_insurance_cost_conv, unit_insurance_cost_conv) 
                                                ,unit_loc_frt_cost = IsNull(@tri_unit_loc_frt_cost, unit_loc_frt_cost) 
                                                ,unit_loc_frt_cost_conv = IsNull(@tri_unit_loc_frt_cost_conv, unit_loc_frt_cost_conv) 
                                                ,trans_nat_2 = IsNull(@tri_trans_nat_2, trans_nat_2) 
                                                ,suppl_qty_conv_factor = IsNull(@tri_suppl_qty_conv_factor, suppl_qty_conv_factor) 
                                                ,RUS_co_num = IsNull(@tri_RUS_co_num, RUS_co_num) 
                                                ,RUS_jobssd = IsNull(@tri_RUS_jobssd, RUS_jobssd) 
                                                ,Uf_Tip_writing = IsNull(@tri_Tip_writing, Uf_Tip_writing) 
                                                ,Uf_Tip_costs = IsNull(@tri_Tip_costs, Uf_Tip_costs) 
                                                ,Uf_object = IsNull(@tri_object, Uf_object) 
                                                ,Uf_Balance_sheet = IsNull(@tri_Balance_sheet, Uf_Balance_sheet) 
                         Where     trn_num  = @tri_trn_num 
                               And trn_line = @tri_trn_line 

 --             Set @tri_due_date = DateAdd(dd, @exp_period, @order_date) 

                    Fetch Next From tri_cur Into  @tri_trn_num 
                                                 ,@tri_trn_line 
                                                 ,@tri_stat 
                                                 ,@tri_item 
                                                 ,@tri_trn_loc 
                                                 ,@tri_ship_date 
                                                 ,@tri_rcvd_date 
                                                 ,@tri_qty_req 
                                                 ,@tri_qty_shipped 
                                                 ,@tri_qty_received 
                                                 ,@tri_qty_loss 
                                                 ,@tri_unit_cost 
                                                 ,@tri_frm_ref_type 
                                                 ,@tri_frm_ref_num 
                                                 ,@tri_frm_ref_line_suf 
                                                 ,@tri_frm_ref_release 
                                                 ,@tri_qty_packed 
                                                 ,@tri_pick_date 
                                                 ,@tri_qty_req_conv 
                                                 ,@tri_u_m 
                                                 ,@tri_matl_cost 
                                                 ,@tri_lbr_cost 
                                                 ,@tri_fovhd_cost 
                                                 ,@tri_vovhd_cost 
                                                 ,@tri_out_cost 
                                                 ,@tri_sch_rcv_date 
                                                 ,@tri_sch_ship_date 
                                                 ,@tri_unit_price 
                                                 ,@tri_pricecode 
                                                 ,@tri_to_ref_type 
                                                 ,@tri_to_ref_num 
                                                 ,@tri_to_ref_line_suf 
                                                 ,@tri_to_ref_release 
                                                 ,@tri_from_site 
                                                 ,@tri_from_whse 
                                                 ,@tri_to_site 
                                                 ,@tri_to_whse 
                                                 ,@tri_cross_site 
                                                 ,@tri_unit_freight_cost 
                                                 ,@tri_unit_freight_cost_conv 
                                                 ,@tri_unit_brokerage_cost 
                                                 ,@tri_unit_brokerage_cost_conv 
                                                 ,@tri_unit_duty_cost 
                                                 ,@tri_unit_duty_cost_conv 
                                                 ,@tri_unit_mat_cost 
                                                 ,@tri_unit_mat_cost_conv 
                                                 ,@tri_unit_weight 
                                                 ,@tri_lc_override 
                                                 ,@tri_projected_date 
                                                 ,@tri_comm_code 
                                                 ,@tri_trans_nat 
                                                 ,@tri_process_ind 
                                                 ,@tri_delterm 
                                                 ,@tri_origin 
                                                 ,@tri_cons_num 
                                                 ,@tri_export_value 
                                                 ,@tri_ec_code 
                                                 ,@tri_transport 
                                                 ,@tri_unit_insurance_cost 
                                                 ,@tri_unit_insurance_cost_conv 
                                                 ,@tri_unit_loc_frt_cost 
                                                 ,@tri_unit_loc_frt_cost_conv 
                                                 ,@tri_trans_nat_2 
                                                 ,@tri_suppl_qty_conv_factor 
                                                 ,@tri_RUS_co_num 
                                                 ,@tri_RUS_jobssd 
                                                 ,@tri_Tip_writing 
                                                 ,@tri_Tip_costs 
                                                 ,@tri_object 
                                                 ,@tri_Balance_sheet 

               End
               Close tri_cur
               Deallocate tri_cur

               Fetch Next From trn_cur Into  @trn_num 
                                            ,@from_whse 
                                            ,@to_whse 
                                            ,@stat 
                                            ,@ship_code 
                                            ,@weight 
                                            ,@qty_packages 
                                            ,@from_site 
                                            ,@to_site 
                                            ,@entered_site 
                                            ,@fob_site 
                                            ,@exch_rate 
                                            ,@freight_vendor 
                                            ,@duty_vendor 
                                            ,@brokerage_vendor 
                                            ,@frt_alloc_percent 
                                            ,@duty_alloc_percent 
                                            ,@brk_alloc_percent 
                                            ,@est_freight_amt 
                                            ,@act_freight_amt 
                                            ,@est_brokerage_amt 
                                            ,@act_brokerage_amt 
                                            ,@est_duty_amt 
                                            ,@act_duty_amt 
                                            ,@freight_amt_t 
                                            ,@brokerage_amt_t 
                                            ,@duty_amt_t 
                                            ,@duty_alloc_meth 
                                            ,@frt_alloc_meth 
                                            ,@brk_alloc_meth 
                                            ,@duty_alloc_type 
                                            ,@frt_alloc_type 
                                            ,@brk_alloc_type 
                                            ,@trans_nat 
                                            ,@process_ind 
                                            ,@delterm 
                                            ,@ins_vendor 
                                            ,@ins_alloc_percent 
                                            ,@ins_alloc_type 
                                            ,@est_insurance_amt 
                                            ,@ins_alloc_meth 
                                            ,@act_insurance_amt 
                                            ,@insurance_amt_t 
                                            ,@loc_frt_vendor 
                                            ,@loc_frt_alloc_percent 
                                            ,@loc_frt_alloc_type 
                                            ,@est_local_freight_amt 
                                            ,@loc_frt_alloc_meth 
                                            ,@act_local_freight_amt 
                                            ,@local_freight_amt_t 
                                            ,@trans_nat_2 
                                            ,@export_type 
                                            ,@order_date 
                                             
     End
     Close trn_cur
     Deallocate trn_cur

     If @LogFlag = 1
          exec dbo.RUS_DiagnosticInTXTSp 'Receipt section closed', @LogFile, 1

End 
-- Receipt section closed

If @ErrorCode <> 0
     Set @RetErr = (Select ErrMsg
                    From #ErrorCodes
                    Where ErrorCode = @ErrorCode
                   )
                   + (CASE When @ErrorCode < 0 Then ': ' + IsNull(@InfoBar, '') Else '' End)
                   + CHAR(13) + CHAR(10)
                   + @RetErr
Else
     Set @RetErr = Null

If @LogFlag = 1
Begin
     Set @ParamToSave = '@ErrorCode = ' + CAST(@ErrorCode as varchar(200))
     exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
     Set @ParamToSave = '@RetErr = ' + IsNull(@RetErr, '')
     exec dbo.RUS_DiagnosticInTXTSp @ParamToSave, @LogFile, 1
End

Drop Table #ErrorCodes

exec dbo.UndefineVariableSp 'MessageLanguage'
                           ,@Infobar OUTPUT

Set @ProcExecState = 1 -- procedure completed

End 
GO