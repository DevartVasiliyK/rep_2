SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE procedure [dbo].[RUSXrefJobPLNSP]
as
delete from bom000 where RUSFORPLNFG=1
delete from procpln000 where RUSFORPLNFG=1
delete from jobstep000 where RUSFORPLNFG=1
delete from matl000 where RUSFORPLNFG=1
delete from js19vr000 where RUSFORPLNFG=1

select distinct
  PROCPLANID = dbo.ApsRouteId(job.job, job.suffix)
 ,JSID = dbo.ApsOperationId(job.job, job.suffix, jobmatl.oper_num)
 ,MATERIALID = 'PLN' + ApsPlan.ref_num + '.PJOS' --jobmatl.item--dbo.ApsJobOrderId(jobmatl.ref_num, jobmatl.ref_line_suf)
 ,quancd = 'L'
 ,QUANTITY = cjobplan.quantity
 ,item = jobmatl.item
 ,Cpocplanid= APSPlan.Procplanid
 ,cjsid = (select top 1 jobstep000.JSID from jobstep000 where jobstep000.procplanid = APSPlan.Procplanid order by jobstep000.JSID desc)
 ,orderid=order000.orderid
into #res
from jobmatl 
join jobroute on jobroute.job = jobmatl.job and jobroute.suffix = jobmatl.suffix and jobroute.complete = 0
join job on job.job = jobmatl.job and job.suffix = jobmatl.suffix and job.type = 'j'
join item as xitem (NOLOCK) on xitem.item = jobmatl.item and xitem.p_m_t_code = 'M'
join order000 on order000.OrderRowPointer = job.RowPointer
join jobstep000 on jobstep000.RefRowPointer = jobroute.rowpointer 
join jobplan000 on jobstep000.jsid = jobplan000.jsid
join matlplan000 on matlplan000.matltag = jobplan000.matltag
join matlplan000 as cmatlplan on cmatlplan.pmatltag = matlplan000.matltag
join jobplan000 as cjobplan on cjobplan.matltag = cmatlplan.matltag and jobmatl.item = cmatlplan.materialid
join apsplan on apsplan.ref_type = 'N' and apsplan.is_demand = 0 and apsplan.ref_num = cmatlplan.matltag
where
      jobmatl.matl_type <> 'F' and
      jobmatl.matl_type <> 'O' and -- Skip "other" materials
      jobmatl.matl_qty > 0 

--insert into bom000
--(ROCPLANID,JSID,MATERIALID,QUANCD,QUANTITY,EFFDATE,OBSDATE)

select  Cpocplanid as procplanid,
	CJSID as jsid,
	MATERIALID,
	QUANCD,
	-QUANTITY as QUANTITY,
	dbo.Lowdate() as lowd ,
	dbo.HighDate() as Highd 
into #res2 
from #res
order by PROCPLANID

insert into bom000
	(pROCPLANID,
	JSID,
	MATERIALID,
	QUANCD,
	QUANTITY,
	EFFDATE,
	OBSDATE,
	RUSFORPLNFG,
	RUSNativeprocplanID,
	RUSNativeJSid)
select 
	procplanid,
	jsid,
	MATERIALID,
	QUANCD,
	QUANTITY,
	dbo.Lowdate() as lowd ,
	dbo.HighDate() as Highd ,
	1,
	procplanid,
	jsid
from #res 
where jsid is not null

insert into bom000
	(pROCPLANID,
	JSID,
	MATERIALID,
	QUANCD,
	QUANTITY,
	EFFDATE,
	OBSDATE,
	RUSFORPLNFG,
	RUSNativeprocplanID,
	RUSNativeJSid)
select 
	dbo.RUS_procplanPLN(procplanid,MATERIALID),	
	dbo.RUS_jsidPLN(jsid,MATERIALID),
	MATERIALID,
	QUANCD,
	QUANTITY,
	lowd,
	highd,
	1,
	procplanid,
	jsid 
from #res2 where procplanid is not null and jsid is not null

exec dbo.RUSXrefPLNPLNSP

update order000 
set 
    procplanid=dbo.RUS_procplanPLN(o.procplanid,o.orderid),	
     RUSNativeprocplanID=o.procplanid ,PRIORITY = 0
from order000 as o 
inner join bom000 as bom on bom.materialid = o.orderid and bom.RUSFORPLNFG = 1

SELECT distinct 
    js.PROCPLANID,
    js.JSID,
    js.DESCR,
    js.TYPE,
    js.ALTJSID,
    js.NEXTJSID,
    js.ALOCRL,
    js.SELECTRL,
    js.STEPEXP,
    js.STEPEXPRL,
    js.FREECHCKFG,
    js.HOLDTEMPFG,
    js.RESACTN1,
    js.RESACTN2,
    js.RESACTN3,
    js.RESACTN4,
    js.RESACTN5,
    js.RESACTN6,
    js.RESID1,
    js.RESID2,
    js.RESID3,
    js.RESID4,js.RESID5,js.RESID6,js.RESNMBR1,
js.RESNMBR2,js.RESNMBR3,js.RESNMBR4,js.RESNMBR5,js.RESNMBR6,js.RESSCHDFG,js.STEPTIME,js.STEPTMRL,js.EFFDATE,
js.OBSDATE,js.RefRowPointer,js.RUSFORPLNFG,b.materialid 
into #tempjs FROM JOBSTEP000 AS JS
JOIN BOM000 AS B ON (B.RUSNativeprocplanID=JS.procplanid)

insert into jobstep000 (PROCPLANID,JSID,DESCR,TYPE,ALTJSID,NEXTJSID,ALOCRL,
SELECTRL,STEPEXP,STEPEXPRL,FREECHCKFG,HOLDTEMPFG,RESACTN1,RESACTN2,RESACTN3,
RESACTN4,RESACTN5,RESACTN6,RESID1,RESID2,RESID3,RESID4,RESID5,RESID6,RESNMBR1,
RESNMBR2,RESNMBR3,RESNMBR4,RESNMBR5,RESNMBR6,RESSCHDFG,STEPTIME,STEPTMRL,EFFDATE,OBSDATE,RefRowPointer,RUSFORPLNFG)
select dbo.RUS_procplanPLN(a.procplanid,a.MATERIALID),dbo.RUS_jsidPLN(a.jsid,a.MATERIALID),a.DESCR,a.TYPE,a.ALTJSID,a.NEXTJSID,a.ALOCRL,
a.SELECTRL,a.STEPEXP,a.STEPEXPRL,a.FREECHCKFG,a.HOLDTEMPFG,a.RESACTN1,a.RESACTN2,a.RESACTN3,
a.RESACTN4,a.RESACTN5,a.RESACTN6,a.RESID1,a.RESID2,a.RESID3,a.RESID4,a.RESID5,a.RESID6,a.RESNMBR1,
a.RESNMBR2,a.RESNMBR3,a.RESNMBR4,a.RESNMBR5,a.RESNMBR6,a.RESSCHDFG,a.STEPTIME,a.STEPTMRL,a.EFFDATE,a.OBSDATE,a.RefRowPointer,1 from #tempjs as a


SELECT distinct js19.PROCPLANID,js19.JSID,js19.RGID,RSETUPID,TABID,WHENRL,BASEDCD,START,LENGTH,SETUPTIME,STIMEXP,STIMEXPRL,MOVETIME,QTIME,ISNULL(res.bufferout,0)AS BUFFEROUT,CRSBRKRL,INVENTORY,HORIZON,OLTYPE,OLVALUE,SPLITSIZE, js19.RUSFORPLNFG ,b.materialid 
into #tempjs19VR FROM JS19VR000 as JS19
JOIN BOM000 AS b ON (b.RUSNativeprocplanID=JS19.procplanid)
join jobstep000 as js on js19.JSID=js.jsid
join jobroute as jr on  jr.RowPointer=js.RefRowPointer
join jrtresourcegroup as jrr on jr.job=jrr.job and jr.suffix=jrr.suffix and jr.oper_num=jrr.oper_num
join rgrp000  as res on res.rgid=jrr.rgid 

insert into JS19VR000 (PROCPLANID,JSID,RGID,RSETUPID,TABID,WHENRL,BASEDCD,START,LENGTH,SETUPTIME,STIMEXP,STIMEXPRL,MOVETIME,QTIME,COOLTIME,CRSBRKRL,INVENTORY,HORIZON,OLTYPE,OLVALUE,SPLITSIZE, RUSFORPLNFG )
select dbo.RUS_procplanPLN(procplanid,MATERIALID),dbo.RUS_jsidPLN(jsid,MATERIALID) ,RGID,RSETUPID,TABID,WHENRL,BASEDCD,START,LENGTH,SETUPTIME,STIMEXP,STIMEXPRL,MOVETIME,QTIME,BUFFEROUT,CRSBRKRL,INVENTORY,HORIZON,OLTYPE,OLVALUE,SPLITSIZE , 1 from #tempjs19VR 

select dbo.RUS_procplanPLN(procplanid,MATERIALID),dbo.RUS_jsidPLN(jsid,MATERIALID) ,RGID,RSETUPID,TABID,WHENRL,BASEDCD,START,LENGTH,SETUPTIME,STIMEXP,STIMEXPRL,MOVETIME,QTIME,BUFFEROUT,CRSBRKRL,INVENTORY,HORIZON,OLTYPE,OLVALUE,SPLITSIZE , 1 from #tempjs19VR 



select p.PROCPLANID,p.DESCR,p.FIRSTJS,p.EFFECTID,p.SCHEDONLYFG,RefRowPointer, b.materialid into #tempprocplan from procpln000 as p
JOIN BOM000 AS B ON (B.RUSNativeprocplanID=p.procplanid)
insert into procpln000 (PROCPLANID,DESCR,FIRSTJS,EFFECTID,SCHEDONLYFG, RefRowPointer,RUSFORPLNFG ) 
select dbo.RUS_procplanPLN(t.procplanid,t.MATERIALID),t.DESCR,t.FIRSTJS,t.EFFECTID,t.SCHEDONLYFG, t.RefRowPointer,1 from #tempprocplan as t


select distinct materialid into #tempmatl from bom000 where RUSFORPLNFG=1 
insert into MATL000 (
   MATERIALID, CAPACITY, SCHEDONLYFG,RUSFORPLNFG)
select
  #tempmatl.materialid
, 999999999
, 'Y'
, 1
from #tempmatl


/*
select ,JSID,MATERIALID,QUANCD,QUANTITY as QUANTITY,dbo.Lowdate() as lowd ,dbo.HighDate() as Highd ,1 from #res
select *,1 from #res2 order by PROCPLANID
*/
drop table #tempjs
drop table #res
drop table #res2
drop table #tempprocplan
drop table #tempmatl
drop table #tempjs19VR







GO