-- ============================================================
-- BASELINE: dbo.vw_validacao_teste_pgto_rota
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validacao_teste_pgto_rota]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_validacao_teste_pgto_rota]
as
select
	isnull(depois.ppr_cd_periodo,antes.ppr_cd_periodo) ppr_cd_periodo
	,isnull(depois.mot_ctn_cd_tipo_contrato,antes.mot_ctn_cd_tipo_contrato) mot_ctn_cd_tipo_contrato
	,isnull(depois.ppr_cd_rota,antes.ppr_cd_rota) ppr_cd_rota
	,antes.ppr_base_principal ppr_base_principal_antes
	,depois.ppr_base_principal ppr_base_principal_depois
	,antes.ppr_nm_cidade ppr_nm_cidade_antes
	,depois.ppr_nm_cidade ppr_nm_cidade_depois
	,antes.ppr_ds_tipo_veiculo ppr_ds_tipo_veiculo_antes
	,depois.ppr_ds_tipo_veiculo ppr_ds_tipo_veiculo_depois
	,antes.ppr_cd_faixa_km ppr_cd_faixa_km_antes
	,depois.ppr_cd_faixa_km ppr_cd_faixa_km_depois
	,antes.ppr_ds_ciclo ppr_ds_cicloa_ntes
	,depois.ppr_ds_ciclo ppr_ds_ciclo_depois
	,antes.ppr_data_referencia ppr_data_referencia_antes
	,depois.ppr_data_referencia ppr_data_referencia_depois
	,antes.ppr_vl_base ppr_vl_base_antes
	,depois.ppr_vl_base ppr_vl_base_depois
	,antes.ppr_vl_dom_fer ppr_vl_dom_fer_antes
	,depois.ppr_vl_dom_fer ppr_vl_dom_fer_depois
	,antes.ppr_vl_paradas ppr_vl_paradas_antes
	,depois.ppr_vl_paradas ppr_vl_paradas_depois
	,antes.ppr_vl_lancamentos ppr_vl_lancamentos_antes
	,depois.ppr_vl_lancamentos ppr_vl_lancamentos_depois
	,antes.ppr_vl_total ppr_vl_total_antes
	,depois.ppr_vl_total ppr_vl_total_depois
from
	(
	select 
		ppr_cd_periodo,
		m.mot_ctn_cd_tipo_contrato,
		ppr_cd_rota, 
		ppr_vl_base,
		ppr_vl_dom_fer,
		ppr_vl_paradas,
		ppr_vl_lancamentos,
		ppr_vl_total,
		ppr_base_principal,
		ppr_ds_tipo_veiculo,
		ppr_cd_faixa_km,
		ppr_ds_ciclo,
		ppr_nm_cidade,
		ppr_data_referencia
	from 
		tb_pgto_periodo_rota_teste_calculo p
		left join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
		left join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
		left join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
	where 
		ppr_fase_teste = 'Depois'
		and ppr_cd_rota is not null
		and ppr_cd_tipo_pgto = 1362
	) depois
	full join 
	(
	select 
		ppr_cd_periodo,
		m.mot_ctn_cd_tipo_contrato,
		ppr_cd_rota, 
		ppr_vl_base,
		ppr_vl_dom_fer,
		ppr_vl_paradas,
		ppr_vl_lancamentos,
		ppr_vl_total,
		ppr_base_principal,
		ppr_ds_tipo_veiculo,
		ppr_cd_faixa_km,
		ppr_ds_ciclo,
		ppr_nm_cidade,
		ppr_data_referencia
	from 
		tb_pgto_periodo_rota_teste_calculo p
		left join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
		left join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
		left join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
	where 
		ppr_fase_teste = 'Antes'
		and ppr_cd_rota is not null
		and ppr_cd_tipo_pgto = 1362
	) antes on depois.ppr_cd_periodo = antes.ppr_cd_periodo and depois.ppr_cd_rota = antes.ppr_cd_rota
where
	isnull(antes.ppr_vl_base,0) <> isnull(depois.ppr_vl_base,0)
	or isnull(antes.ppr_vl_dom_fer,0) <> isnull(depois.ppr_vl_dom_fer,0)
	or isnull(antes.ppr_vl_paradas,0) <> isnull(depois.ppr_vl_paradas,0)
	or isnull(antes.ppr_vl_lancamentos,0) <> isnull(depois.ppr_vl_lancamentos,0)
	or isnull(antes.ppr_vl_total,0) <> isnull(depois.ppr_vl_total,0)
GO
