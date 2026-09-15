-- ============================================================
-- BASELINE: dbo.vw_relatorio_lancamentos_manuais
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_relatorio_lancamentos_manuais]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_relatorio_lancamentos_manuais] as 

select 
	 tlm_cd_lancamento_manual
	,tlm_cd_cliente
	,cast(tlm_dh_referencia as date)  as tlm_dh_referencia
	,tlm_cd_service_center
	,tlm_cd_motorista
	,plm_nm_tipo
	,tlm_cd_rota
	,alm_ds_status
	,-1 * isnull(tlm_vl_valor_descontos,0) as tlm_vl_valor_descontos
	,isnull(tlm_vl_valor_adicional,0)  as tlm_vl_valor_adicional
	,isnull(tlm_vl_valor_rota,0)  as tlm_vl_valor_rota
	,-1 * isnull(tlm_vl_valor_apoio,0) as tlm_vl_valor_apoio
	
	,(
		(-1 * isnull(tlm_vl_valor_descontos,0))	
		+isnull(tlm_vl_valor_adicional,0)		
		+isnull(tlm_vl_valor_rota,0)			
		+(-1 * isnull(tlm_vl_valor_apoio,0))
	) as tlm_vl_total
	
	,coalesce(list.lst_ds_label,listSem.lst_ds_label) as SituacaoPagamento
	,case 
		when coalesce(list.lst_ds_label,listSem.lst_ds_label) is null
			then null
		when coalesce(list.lst_ds_label,listSem.lst_ds_label) = 'Pagamento Efetuado' 
			then 'Pagamento Efetuado' 
		else 'Pagamento pendente' 
		end as SituacaoPagamentoDim
	
	,null as DataAtualizacaoControlePowerBI

from vw_lancamentos_manuais as a

left join tb_motorista as b
on a.tlm_cd_motorista = b.mot_nm_motorista
and mot_cd_cliente = tlm_cd_cliente
and mot_cd_status = 1

left join tb_pgto_rotas_lanc_manuais as lanc
on a.tlm_cd_rota  = lanc.plm_cd_rota

left join tb_pgto_rotas_lanc_manuais as lancSemRota
on a.tlm_cd_lancamento_manual  = lancSemRota.plm_cd_lancamento

left join tb_pag_espelhos as pagLanc
on pagLanc.mtn_cd_motorista_nfs = lanc.plm_cd_espelhos

left join tb_pag_espelhos as pagLancSemRota
on pagLancSemRota.mtn_cd_motorista_nfs = lancSemRota.plm_cd_espelhos


left join tb_lista as list
on list.lst_cd_lista = pagLanc.mtn_cd_status
and list.lst_nm_lista = 'Status motorista nfs'

left join tb_lista as listSem
on listSem.lst_cd_lista = pagLancSemRota.mtn_cd_status
and listSem.lst_nm_lista = 'Status motorista nfs'


where 
 cast(tlm_dh_referencia as date) >= '2025-08-01'
--and tlm_cd_cliente = 37

--and cast(tlm_dh_referencia as date)  between '2025-08-01' and  '2025-08-31'
--and tlm_cd_tipo = 440
GO
